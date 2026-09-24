.pragma library
// Low-precision heliocentric ephemeris (J2000 mean elements, Keplerian motion).
// Good to roughly a degree for several centuries around 2000: an orrery, not a navigator.

var D2R = Math.PI / 180
var J2000_MS = Date.UTC(2000, 0, 1, 12, 0, 0)

//  a: semi-major axis (AU)  e: eccentricity  L0: mean longitude at J2000 (deg)
//  w: longitude of perihelion (deg)  P: sidereal period (days)
var bodies = [
    { name: "Mercury", glyph: "☿", a: 0.38710, e: 0.20563, L0: 252.2503, w:  77.4577, P:    87.969, size: 3.2, color: "#b8b1a6", shade: "#5c5750", fact: "A year shorter than two of its own days." },
    { name: "Venus",   glyph: "♀", a: 0.72333, e: 0.00677, L0: 181.9791, w: 131.6025, P:   224.701, size: 5.0, color: "#e9d3a0", shade: "#8a6d3b", fact: "Spins backwards, beneath a sky of sulphuric acid." },
    { name: "Earth",   glyph: "♁", a: 1.00000, e: 0.01671, L0: 100.4645, w: 102.9373, P:   365.256, size: 5.4, color: "#6fb4e8", shade: "#1f4a73", fact: "The only place any of this has been looked at from." },
    { name: "Mars",    glyph: "♂", a: 1.52368, e: 0.09340, L0: 355.4533, w: 336.0602, P:   686.980, size: 4.2, color: "#e07a4f", shade: "#6e2a15", fact: "Its oppositions come every 26 months; watch it loop." },
    { name: "Jupiter", glyph: "♃", a: 5.20260, e: 0.04849, L0:  34.3515, w:  14.3312, P:  4332.589, size: 10.5, color: "#e3c39a", shade: "#7a5230", fact: "Twice the mass of every other planet combined." },
    { name: "Saturn",  glyph: "♄", a: 9.55491, e: 0.05551, L0:  50.0774, w:  93.0572, P: 10759.22,  size: 9.0, color: "#ecd9a6", shade: "#7d6634", fact: "Less dense than water; its rings, a few metres thick.", rings: true },
    { name: "Uranus",  glyph: "♅", a: 19.2184, e: 0.04630, L0: 314.0550, w: 173.0053, P: 30688.5,   size: 7.0, color: "#9fe0dc", shade: "#2f6f72", fact: "Rolls around the Sun on its side." },
    { name: "Neptune", glyph: "♆", a: 30.1104, e: 0.00899, L0: 304.3487, w:  48.1203, P: 60182.0,   size: 6.8, color: "#6f8ff0", shade: "#1f2f80", fact: "Found with a pen before a telescope: 1846." }
]
var EARTH = 2

var signs = ["Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
             "Libra", "Scorpius", "Sagittarius", "Capricornus", "Aquarius", "Pisces"]
var signGlyphs = ["♈", "♉", "♊", "♋", "♌", "♍",
                  "♎", "♏", "♐", "♑", "♒", "♓"]
var months = ["January", "February", "March", "April", "May", "June", "July",
              "August", "September", "October", "November", "December"]

function norm360(x) { x %= 360; return x < 0 ? x + 360 : x }
function wrap180(x) { x = norm360(x); return x > 180 ? x - 360 : x }

function solveKepler(M, e) {
    var E = M + e * Math.sin(M)
    for (var i = 0; i < 8; ++i)
        E -= (E - e * Math.sin(E) - M) / (1 - e * Math.cos(E))
    return E
}

// Heliocentric ecliptic position of body b, d days after J2000.
function helio(b, d) {
    var M = norm360(b.L0 - b.w + 360 * d / b.P) * D2R
    var E = solveKepler(M, b.e)
    var v = 2 * Math.atan2(Math.sqrt(1 + b.e) * Math.sin(E / 2), Math.sqrt(1 - b.e) * Math.cos(E / 2))
    var r = b.a * (1 - b.e * Math.cos(E))
    var lon = v + b.w * D2R
    return { r: r, lon: norm360(lon / D2R), x: r * Math.cos(lon), y: r * Math.sin(lon) }
}

// Points around the full orbit, sampled in eccentric anomaly (dense near perihelion).
function orbit(b, n) {
    var pts = [], w = b.w * D2R, bb = b.a * Math.sqrt(1 - b.e * b.e)
    for (var i = 0; i <= n; ++i) {
        var E = 2 * Math.PI * i / n
        var x = b.a * (Math.cos(E) - b.e), y = bb * Math.sin(E)
        pts.push({ x: x * Math.cos(w) - y * Math.sin(w), y: x * Math.sin(w) + y * Math.cos(w) })
    }
    return pts
}

function geo(b, d) {
    var p = helio(b, d), e = helio(bodies[EARTH], d)
    var dx = p.x - e.x, dy = p.y - e.y
    return { lon: norm360(Math.atan2(dy, dx) / D2R), dist: Math.sqrt(dx * dx + dy * dy) }
}

function sunLon(d) { return norm360(helio(bodies[EARTH], d).lon + 180) }

// Apparent motion against the stars, as seen from Earth: -1 retrograde, +1 direct.
function motion(b, d) {
    return wrap180(geo(b, d + 0.5).lon - geo(b, d - 0.5).lon) < 0 ? -1 : 1
}

// Days until the planet's apparent motion next reverses (station), searching up to a limit.
function nextStation(b, d, limit) {
    var m = motion(b, d), step = 2
    for (var t = step; t <= limit; t += step)
        if (motion(b, d + t) !== m) {
            var lo = t - step, hi = t
            for (var k = 0; k < 12; ++k) {
                var mid = (lo + hi) / 2
                if (motion(b, d + mid) === m) lo = mid; else hi = mid
            }
            return hi
        }
    return -1
}

function moonLon(d) { return norm360(218.3165 + 13.17639648 * d + 6.289 * Math.sin((134.963 + 13.064993 * d) * D2R)) }
function moonElongation(d) { return norm360(moonLon(d) - sunLon(d)) }
function moonPhaseName(el) {
    var names = ["New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous",
                 "Full Moon", "Waning Gibbous", "Last Quarter", "Waning Crescent"]
    return names[Math.floor(norm360(el + 22.5) / 45) % 8]
}

function zodiac(lon) {
    lon = norm360(lon)
    var s = Math.floor(lon / 30), inSign = lon - 30 * s
    var deg = Math.floor(inSign), min = Math.floor((inSign - deg) * 60)
    return { sign: signs[s], glyph: signGlyphs[s], text: deg + "°" + (min < 10 ? "0" : "") + min + "′" }
}

function msToDays(ms) { return (ms - J2000_MS) / 86400000 }
function dateOf(d) { return new Date(J2000_MS + d * 86400000) }

function pad(n) { return (n < 10 ? "0" : "") + n }
function shortDate(d) {
    var t = dateOf(d)
    return t.getUTCDate() + " " + months[t.getUTCMonth()].slice(0, 3) + " " + t.getUTCFullYear()
}
function dateText(d) {
    var t = dateOf(d), y = t.getUTCFullYear()
    return t.getUTCDate() + " " + months[t.getUTCMonth()] + " " + (y > 0 ? y : (1 - y) + " BC")
}
function timeText(d) { var t = dateOf(d); return pad(t.getUTCHours()) + ":" + pad(t.getUTCMinutes()) + " UTC" }
function weekday(d) { return ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][dateOf(d).getUTCDay()] }
