// Orrery — a clockwork of the solar system, running on real orbital elements.
// Run:  python3 main.py      (or: qml Main.qml)
import QtQuick
import QtQuick.Window
import "Ephemeris.js" as Eph

Window {
    id: root
    width: 1360; height: 880
    minimumWidth: 1000; minimumHeight: 700
    visible: true
    color: theme.bg
    title: "Orrery — " + Eph.dateText(days)

    QtObject {
        id: theme
        readonly property color bg: "#070a12"
        readonly property color brass: "#c9a45c"
        readonly property color brassDim: "#6d5a34"
        readonly property color ink: "#ece2c8"
        readonly property color inkDim: "#8d8672"
        readonly property color panel: "#0d121e"
        readonly property color line: "#1f2638"
        readonly property color retro: "#e36b5a"
        readonly property string serif: "DejaVu Serif"
        readonly property string sans: "DejaVu Sans"
    }

    // ---- simulation state ---------------------------------------------------
    property real days: Eph.msToDays(Date.now())          // days since J2000.0
    property bool playing: true
    readonly property var rates: [-365.25, -30.44, -7, -1, 1 / 86400, 1, 7, 30.44, 91.31, 365.25]
    readonly property var rateNames: ["−1 year", "−1 month", "−1 week", "−1 day", "real time",
                                      "+1 day", "+1 week", "+1 month", "+1 season", "+1 year"]
    property int rateIndex: 7
    property real rate: rates[rateIndex]                   // days per second, eased
    Behavior on rate { NumberAnimation { duration: 700; easing.type: Easing.InOutCubic } }

    property int selected: 3                               // Mars: the loop-maker
    property int hovered: -1
    readonly property int focusBody: hovered >= 0 ? hovered : selected
    property bool trueScale: false
    property real scaleMix: trueScale ? 1 : 0
    Behavior on scaleMix { NumberAnimation { duration: 1400; easing.type: Easing.InOutQuart } }
    onScaleMixChanged: { staticLayer.requestPaint(); scene.requestPaint() }

    FrameAnimation {
        running: true
        onTriggered: {
            if (root.playing) root.days += root.rate * Math.min(frameTime, 0.1)
            scene.requestPaint()
        }
    }

    function step(dir) { rateIndex = Math.max(0, Math.min(rates.length - 1, rateIndex + dir)); playing = true }

    Item {
        focus: true
        Keys.onPressed: (e) => {
            if (e.key === Qt.Key_Space) root.playing = !root.playing
            else if (e.key === Qt.Key_Right || e.key === Qt.Key_Up) root.step(1)
            else if (e.key === Qt.Key_Left || e.key === Qt.Key_Down) root.step(-1)
            else if (e.key === Qt.Key_N) root.days = Eph.msToDays(Date.now())
            else if (e.key === Qt.Key_S) root.trueScale = !root.trueScale
            else if (e.key >= Qt.Key_1 && e.key <= Qt.Key_8) root.selected = e.key - Qt.Key_1
            else return
            e.accepted = true
        }
    }

    // ---- the instrument -----------------------------------------------------
    Item {
        id: stage
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom; right: panel.left }

        readonly property real cx: width / 2
        readonly property real cy: height / 2
        readonly property real dialR: Math.min(width, height) / 2 - 22       // outer edge of zodiac ring
        readonly property real ringW: Math.max(34, dialR * 0.085)
        readonly property real orbitR: dialR - ringW - 16                   // Neptune's aphelion lives here
        readonly property real sunR: 13

        // AU -> pixels. Blend of a square-root map (legible) and the honest linear one.
        function rpx(r) {
            var sq = sunR + 10 + (orbitR - sunR - 10) * Math.sqrt(r / 30.4)
            var li = orbitR * r / 30.4
            return sq + (li - sq) * root.scaleMix
        }
        function toScreen(p) {
            var r = Math.sqrt(p.x * p.x + p.y * p.y), k = r > 0 ? rpx(r) / r : 0
            return { x: cx + p.x * k, y: cy - p.y * k }
        }
        function polar(lonDeg, r) {
            var a = lonDeg * Math.PI / 180
            return { x: cx + r * Math.cos(a), y: cy - r * Math.sin(a) }
        }

        onWidthChanged: staticLayer.requestPaint()
        onHeightChanged: staticLayer.requestPaint()

        // Stars, engraved dial and orbits: repainted only on resize / rescale.
        Canvas {
            id: staticLayer
            anchors.fill: parent
            property var orbits: Eph.bodies.map(b => Eph.orbit(b, 360))
            onPaint: {
                var c = getContext("2d"), s = stage
                c.reset()
                // starfield (seeded, so it never shimmers between repaints)
                var seed = 7
                function rnd() { seed = (seed * 16807) % 2147483647; return seed / 2147483647 }
                for (var i = 0; i < 900; ++i) {
                    var x = rnd() * width, y = rnd() * height, m = Math.pow(rnd(), 3)
                    c.fillStyle = Qt.rgba(0.85 + 0.15 * rnd(), 0.88, 1, 0.12 + 0.6 * m)
                    c.fillRect(x, y, m > 0.7 ? 1.6 : 1, m > 0.7 ? 1.6 : 1)
                }
                // soft vignette of the Milky Way-ish haze behind the dial
                var haze = c.createRadialGradient(s.cx, s.cy, 0, s.cx, s.cy, s.dialR * 1.1)
                haze.addColorStop(0, "rgba(40,48,80,0.35)"); haze.addColorStop(1, "rgba(7,10,18,0)")
                c.fillStyle = haze; c.beginPath(); c.arc(s.cx, s.cy, s.dialR * 1.1, 0, 2 * Math.PI); c.fill()

                // zodiac ring
                var R = s.dialR, r0 = R - s.ringW
                c.beginPath(); c.arc(s.cx, s.cy, R, 0, 2 * Math.PI); c.arc(s.cx, s.cy, r0, 0, 2 * Math.PI, true)
                c.fillStyle = "rgba(201,164,92,0.06)"; c.fill()
                c.lineWidth = 1.2; c.strokeStyle = theme.brass
                c.beginPath(); c.arc(s.cx, s.cy, R, 0, 2 * Math.PI); c.stroke()
                c.beginPath(); c.arc(s.cx, s.cy, r0, 0, 2 * Math.PI); c.stroke()
                c.lineWidth = 0.6
                c.beginPath(); c.arc(s.cx, s.cy, R - 7, 0, 2 * Math.PI); c.stroke()
                for (var deg = 0; deg < 360; ++deg) {
                    var len = deg % 30 === 0 ? s.ringW : deg % 10 === 0 ? 7 : deg % 5 === 0 ? 5 : 3
                    var a = s.polar(deg, R), b = s.polar(deg, R - len)
                    c.strokeStyle = deg % 30 === 0 ? theme.brass : theme.brassDim
                    c.lineWidth = deg % 30 === 0 ? 1.2 : 0.7
                    c.beginPath(); c.moveTo(a.x, a.y); c.lineTo(b.x, b.y); c.stroke()
                }
                c.textAlign = "center"; c.textBaseline = "middle"
                for (var k = 0; k < 12; ++k) {
                    var mid = k * 30 + 15, g = s.polar(mid, R - 7 - (s.ringW - 7) * 0.58)
                    c.fillStyle = theme.brass
                    c.font = Math.round(s.ringW * 0.5) + "px '" + theme.sans + "'"
                    c.fillText(Eph.signGlyphs[k], g.x, g.y)
                    // sign name along the arc, small caps feel
                    var name = Eph.signs[k].toUpperCase(), fs = Math.max(7, Math.round(s.ringW * 0.17))
                    c.font = fs + "px '" + theme.serif + "'"
                    c.fillStyle = theme.brassDim
                    var rr = R - 7 - (s.ringW - 7) * 0.2
                    // read left-to-right on both halves: clockwise on top, anticlockwise below
                    var top = mid < 180, stepDeg = fs * 0.78 / rr * 180 / Math.PI
                    for (var j = 0; j < name.length; ++j) {
                        var off = ((name.length - 1) / 2 - j) * stepDeg
                        var ang = top ? mid + off : mid - off
                        var q = s.polar(ang, rr)
                        c.save(); c.translate(q.x, q.y); c.rotate(((top ? 90 : 270) - ang) * Math.PI / 180)
                        c.fillText(name[j], 0, 0); c.restore()
                    }
                }
                // vernal equinox marker
                var ve = s.polar(0, R + 9)
                c.fillStyle = theme.brass; c.font = "11px '" + theme.sans + "'"
                c.fillText(Eph.signGlyphs[0] + " 0\u00B0", ve.x - 2, ve.y - 12)

                // faint radial AU graticule
                c.setLineDash([2, 6]); c.lineWidth = 0.6; c.strokeStyle = "rgba(141,134,114,0.22)"
                ;[1, 5, 10, 20, 30].forEach(function (au) {
                    c.beginPath(); c.arc(s.cx, s.cy, s.rpx(au), 0, 2 * Math.PI); c.stroke()
                    c.fillStyle = "rgba(141,134,114,0.55)"; c.font = "9px '" + theme.sans + "'"
                    var lp = s.polar(-58, s.rpx(au)); c.fillText(au + " AU", lp.x + 12, lp.y)
                })
                c.setLineDash([])

                // orbits
                for (var o = 0; o < orbits.length; ++o) {
                    var pts = orbits[o]
                    c.beginPath()
                    for (var n = 0; n < pts.length; ++n) {
                        var p = s.toScreen(pts[n])
                        if (n === 0) c.moveTo(p.x, p.y); else c.lineTo(p.x, p.y)
                    }
                    c.strokeStyle = Qt.rgba(0.79, 0.64, 0.36, 0.28); c.lineWidth = 0.9; c.stroke()
                }
            }
        }

        // Everything that moves.
        Canvas {
            id: scene
            anchors.fill: parent
            property var screenPos: []
            onPaint: {
                var c = getContext("2d"), s = stage, d = root.days
                c.reset()
                var pos = []
                for (var i = 0; i < Eph.bodies.length; ++i) pos.push(Eph.helio(Eph.bodies[i], d))
                var sp = pos.map(p => s.toScreen(p))
                screenPos = sp
                var earth = sp[Eph.EARTH], fb = root.focusBody

                // Sun
                var glow = c.createRadialGradient(s.cx, s.cy, 0, s.cx, s.cy, s.sunR * 4.5)
                glow.addColorStop(0, "rgba(255,236,190,0.95)"); glow.addColorStop(0.18, "rgba(255,196,96,0.85)")
                glow.addColorStop(0.35, "rgba(255,150,50,0.25)"); glow.addColorStop(1, "rgba(255,120,40,0)")
                c.fillStyle = glow; c.beginPath(); c.arc(s.cx, s.cy, s.sunR * 4.5, 0, 2 * Math.PI); c.fill()
                c.fillStyle = "#fff4d6"; c.beginPath(); c.arc(s.cx, s.cy, s.sunR * 0.8, 0, 2 * Math.PI); c.fill()

                // sight line: Earth -> focused planet -> the stars behind it
                if (fb >= 0 && fb !== Eph.EARTH) {
                    var g = Eph.geo(Eph.bodies[fb], d), retro = Eph.motion(Eph.bodies[fb], d) < 0
                    var hitR = s.dialR - s.ringW, dx = Math.cos(g.lon * Math.PI / 180), dy = -Math.sin(g.lon * Math.PI / 180)
                    // ray/circle intersection from Earth's position
                    var ex = earth.x - s.cx, ey = earth.y - s.cy, bq = ex * dx + ey * dy
                    var t = -bq + Math.sqrt(bq * bq - (ex * ex + ey * ey - hitR * hitR))
                    var hx = earth.x + dx * t, hy = earth.y + dy * t
                    var col = retro ? theme.retro : theme.ink
                    var lg = c.createLinearGradient(earth.x, earth.y, hx, hy)
                    lg.addColorStop(0, Qt.rgba(col.r, col.g, col.b, 0.05)); lg.addColorStop(1, Qt.rgba(col.r, col.g, col.b, 0.75))
                    c.strokeStyle = lg; c.lineWidth = 1; c.setLineDash([4, 4])
                    c.beginPath(); c.moveTo(earth.x, earth.y); c.lineTo(hx, hy); c.stroke(); c.setLineDash([])
                    // pointer on the ring
                    c.save(); c.translate(hx, hy); c.rotate(-g.lon * Math.PI / 180)
                    c.fillStyle = col; c.beginPath(); c.moveTo(1, 0); c.lineTo(-9, -5); c.lineTo(-9, 5); c.closePath(); c.fill()
                    c.restore()
                    // the planet's path against the stars: 1 year back and forth, drawn inside the ring
                    c.beginPath()
                    var rIn = hitR - 5
                    for (var k = -60; k <= 60; ++k) {
                        var gl = Eph.geo(Eph.bodies[fb], d + k * 3).lon
                        var pp = s.polar(gl, rIn - Math.abs(k) * 0.05)
                        if (k === -60) c.moveTo(pp.x, pp.y); else c.lineTo(pp.x, pp.y)
                    }
                    c.strokeStyle = Qt.rgba(col.r, col.g, col.b, 0.35); c.lineWidth = 2; c.stroke()
                }

                // trails: the last stretch of each orbit, fading
                for (i = 0; i < Eph.bodies.length; ++i) {
                    var b = Eph.bodies[i], N = 40, span = b.P * 0.14
                    var prev = sp[i]
                    for (var n = 1; n <= N; ++n) {
                        var q = s.toScreen(Eph.helio(b, d - span * n / N))
                        var bc = Qt.color(b.color)
                        c.strokeStyle = Qt.rgba(bc.r, bc.g, bc.b, 0.55 * (1 - n / N))
                        c.lineWidth = Math.max(1, b.size * 0.45 * (1 - n / N))
                        c.beginPath(); c.moveTo(prev.x, prev.y); c.lineTo(q.x, q.y); c.stroke()
                        prev = q
                    }
                }

                // planets, lit from the Sun
                for (i = 0; i < Eph.bodies.length; ++i) {
                    b = Eph.bodies[i]; var p = sp[i], r = b.size
                    var ang = Math.atan2(s.cy - p.y, s.cx - p.x)
                    var lx = p.x + Math.cos(ang) * r * 0.45, ly = p.y + Math.sin(ang) * r * 0.45
                    if (i === fb || i === root.selected) {
                        c.strokeStyle = i === fb ? theme.ink : theme.brass
                        c.lineWidth = 1; c.beginPath(); c.arc(p.x, p.y, r + 6, 0, 2 * Math.PI); c.stroke()
                        c.lineWidth = 1.5
                        for (var tk = 0; tk < 4; ++tk) {
                            var ta = tk * Math.PI / 2 + Math.PI / 4
                            c.beginPath(); c.moveTo(p.x + Math.cos(ta) * (r + 8), p.y + Math.sin(ta) * (r + 8))
                            c.lineTo(p.x + Math.cos(ta) * (r + 12), p.y + Math.sin(ta) * (r + 12)); c.stroke()
                        }
                    }
                    if (b.rings) {
                        c.save(); c.translate(p.x, p.y); c.scale(1, 0.38)
                        c.strokeStyle = "rgba(236,217,166,0.55)"; c.lineWidth = 2.2
                        c.beginPath(); c.arc(0, 0, r * 1.9, 0, 2 * Math.PI); c.stroke(); c.restore()
                    }
                    var pg = c.createRadialGradient(lx, ly, r * 0.1, p.x, p.y, r)
                    pg.addColorStop(0, "#ffffff"); pg.addColorStop(0.25, b.color); pg.addColorStop(1, b.shade)
                    c.fillStyle = pg; c.beginPath(); c.arc(p.x, p.y, r, 0, 2 * Math.PI); c.fill()
                    if (b.rings) {
                        c.save(); c.translate(p.x, p.y); c.scale(1, 0.38)
                        c.strokeStyle = "rgba(236,217,166,0.8)"; c.lineWidth = 2.2
                        c.beginPath(); c.arc(0, 0, r * 1.9, 0, Math.PI); c.stroke(); c.restore()
                    }
                    c.font = "10px '" + theme.sans + "'"; c.textAlign = "left"; c.textBaseline = "middle"
                    c.fillStyle = i === fb ? theme.ink : "rgba(236,226,200,0.55)"
                    c.fillText(b.glyph + " " + b.name, p.x + r + 7, p.y - r - 5)
                }

                // the Moon (orbit exaggerated, direction true)
                var ml = Eph.moonLon(d) * Math.PI / 180, mr = 13
                var mx = earth.x + Math.cos(ml) * mr, my = earth.y - Math.sin(ml) * mr
                c.strokeStyle = "rgba(200,210,230,0.18)"; c.lineWidth = 0.6
                c.beginPath(); c.arc(earth.x, earth.y, mr, 0, 2 * Math.PI); c.stroke()
                c.fillStyle = "#dfe3ea"; c.beginPath(); c.arc(mx, my, 1.8, 0, 2 * Math.PI); c.fill()

                // ecliptic longitude hand for Earth's Sun: where the Sun sits among the signs today
                var sl = Eph.sunLon(d), a1 = s.polar(sl, s.dialR - s.ringW - 2), a2 = s.polar(sl, s.dialR + 4)
                c.strokeStyle = "rgba(255,200,110,0.9)"; c.lineWidth = 2
                c.beginPath(); c.moveTo(a1.x, a1.y); c.lineTo(a2.x, a2.y); c.stroke()
                c.fillStyle = "#ffc86e"; c.beginPath(); c.arc(a2.x, a2.y, 3.5, 0, 2 * Math.PI); c.fill()
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            cursorShape: root.hovered >= 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
            function pick(mx, my) {
                var best = -1, bd = 1e9, sp = scene.screenPos
                for (var i = 0; i < sp.length; ++i) {
                    var dd = Math.hypot(sp[i].x - mx, sp[i].y - my)
                    if (dd < Eph.bodies[i].size + 12 && dd < bd) { bd = dd; best = i }
                }
                return best
            }
            onPositionChanged: (m) => root.hovered = pick(m.x, m.y)
            onExited: root.hovered = -1
            onClicked: (m) => { var p = pick(m.x, m.y); if (p >= 0) root.selected = p }
            onWheel: (w) => { root.days += (w.angleDelta.y / 120) * Math.max(1, Math.abs(root.rate) * 0.25) }
        }

        Text {
            anchors { left: parent.left; bottom: parent.bottom; margins: 16 }
            color: theme.inkDim; font.family: theme.sans; font.pixelSize: 11
            text: (root.trueScale ? "True linear scale" : "Distances √-compressed") + "  ·  planet sizes not to scale  ·  scroll to scrub time"
        }
    }

    // ---- the panel ----------------------------------------------------------
    component Rule: Rectangle { width: parent.width; height: 1; color: theme.line }
    component Caption: Text { color: theme.inkDim; font.family: theme.sans; font.pixelSize: 10; font.letterSpacing: 2 }
    component Btn: Rectangle {
        id: btn
        property string label
        property bool active: false
        signal clicked
        width: Math.max(38, lbl.implicitWidth + 20); height: 32; radius: 4
        color: active ? Qt.rgba(0.79, 0.64, 0.36, 0.22) : ma.containsMouse ? "#161d2e" : "transparent"
        border.color: active ? theme.brass : theme.line
        Behavior on color { ColorAnimation { duration: 150 } }
        Text { id: lbl; anchors.centerIn: parent; text: btn.label; color: btn.active ? theme.ink : theme.inkDim
               font.family: theme.sans; font.pixelSize: 13 }
        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: btn.clicked() }
    }

    Rectangle {
        id: panel
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
        width: 360
        color: theme.panel
        Rectangle { width: 1; height: parent.height; color: theme.line }

        Column {
            anchors { fill: parent; margins: 28; topMargin: 30 }
            spacing: 18

            Column {
                spacing: 2
                Text { text: "ORRERY"; color: theme.brass; font.family: theme.serif; font.pixelSize: 26; font.letterSpacing: 9 }
                Text { text: "a clockwork of the solar system"; color: theme.inkDim; font.family: theme.serif; font.italic: true; font.pixelSize: 12 }
            }
            Rule {}

            Column {
                spacing: 4
                Caption { text: Eph.weekday(root.days).toUpperCase() }
                Text { text: Eph.dateText(root.days); color: theme.ink; font.family: theme.serif; font.pixelSize: 28 }
                Text {
                    color: theme.inkDim; font.family: theme.sans; font.pixelSize: 11
                    text: Eph.timeText(root.days) + "   ·   JD " + (root.days + 2451545).toFixed(2)
                          + "   ·   ☉ in " + Eph.zodiac(Eph.sunLon(root.days)).sign
                }
            }

            Column {
                spacing: 8
                Caption { text: "TIME  ·  " + (root.playing ? root.rateNames[root.rateIndex] + " per second" : "paused").toUpperCase() }
                Row {
                    spacing: 6
                    Btn { label: "◀◀"; onClicked: root.step(-1) }
                    Btn { label: root.playing ? "❚❚" : "▶"; active: !root.playing; width: 58; onClicked: root.playing = !root.playing }
                    Btn { label: "▶▶"; onClicked: root.step(1) }
                    Btn { label: "Now"; onClicked: { root.days = Eph.msToDays(Date.now()); root.rateIndex = 4 } }
                    Btn { label: "Scale"; active: root.trueScale; onClicked: root.trueScale = !root.trueScale }
                }
                // rate dial: a row of pips, centre is stillness
                Row {
                    spacing: 5
                    Repeater {
                        model: root.rates.length
                        Rectangle {
                            width: 25; height: 4; radius: 2
                            color: index === root.rateIndex ? (root.rates[index] < 0 ? theme.retro : theme.brass) : theme.line
                            Behavior on color { ColorAnimation { duration: 200 } }
                            MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor
                                        onClicked: { root.rateIndex = index; root.playing = true } }
                        }
                    }
                }
            }
            Rule {}

            // planet chooser
            Row {
                spacing: 4
                Repeater {
                    model: Eph.bodies.length
                    Rectangle {
                        readonly property var b: Eph.bodies[index]
                        width: 34; height: 34; radius: 17
                        color: index === root.selected ? Qt.rgba(0.79, 0.64, 0.36, 0.2) : pm.containsMouse ? "#161d2e" : "transparent"
                        border.color: index === root.selected ? theme.brass : "transparent"
                        Text { anchors.centerIn: parent; text: parent.b.glyph; color: parent.b.color; font.family: theme.sans; font.pixelSize: 17 }
                        MouseArea { id: pm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: root.selected = index
                                    onContainsMouseChanged: root.hovered = containsMouse ? index : -1 }
                    }
                }
            }

            // planet card
            Item {
                id: card
                width: parent.width; height: childrenRect.height
                readonly property var b: Eph.bodies[root.focusBody]
                readonly property var h: { root.days; return Eph.helio(b, root.days) }
                readonly property bool isEarth: root.focusBody === Eph.EARTH
                readonly property var g: { root.days; return isEarth ? null : Eph.geo(b, root.days) }
                readonly property int motion: { root.days; return isEarth ? 1 : Eph.motion(b, root.days) }
                readonly property real station: { Math.floor(root.days); return isEarth ? -1 : Eph.nextStation(b, Math.floor(root.days), 900) }
                readonly property real yearFrac: { var y = (root.days * 360 / b.P + b.L0 - b.w) % 360; return (y < 0 ? y + 360 : y) / 360 }

                Column {
                    width: parent.width; spacing: 10
                    Row {
                        spacing: 12
                        Text { text: card.b.glyph; color: card.b.color; font.family: theme.sans; font.pixelSize: 36; anchors.verticalCenter: parent.verticalCenter }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text { text: card.b.name; color: theme.ink; font.family: theme.serif; font.pixelSize: 22 }
                            Text {
                                visible: !card.isEarth
                                text: card.motion < 0 ? "℞  RETROGRADE" : "DIRECT MOTION"
                                color: card.motion < 0 ? theme.retro : theme.inkDim
                                font.family: theme.sans; font.pixelSize: 10; font.letterSpacing: 2
                            }
                        }
                    }
                    Text { width: parent.width; wrapMode: Text.WordWrap; text: card.b.fact
                           color: theme.inkDim; font.family: theme.serif; font.italic: true; font.pixelSize: 12 }

                    Grid {
                        columns: 2; columnSpacing: 18; rowSpacing: 7
                        Caption { text: "FROM THE SUN" }
                        Text { color: theme.ink; font.family: theme.sans; font.pixelSize: 12; text: card.h.r.toFixed(3) + " AU" }
                        Caption { text: card.isEarth ? "SUN APPEARS IN" : "FROM EARTH" }
                        Text { color: theme.ink; font.family: theme.sans; font.pixelSize: 12
                               text: card.isEarth ? Eph.zodiac(Eph.sunLon(root.days)).text + " " + Eph.zodiac(Eph.sunLon(root.days)).sign
                                                  : card.g.dist.toFixed(3) + " AU  ·  light " + (card.g.dist * 8.3167).toFixed(1) + " min" }
                        Caption { text: "SEEN IN"; visible: !card.isEarth }
                        Text { visible: !card.isEarth; color: card.motion < 0 ? theme.retro : theme.ink; font.family: theme.sans; font.pixelSize: 12
                               text: card.isEarth ? "" : Eph.zodiac(card.g.lon).glyph + "  " + Eph.zodiac(card.g.lon).text + " " + Eph.zodiac(card.g.lon).sign }
                        Caption { text: "NEXT STATION"; visible: !card.isEarth }
                        Text { visible: !card.isEarth; color: theme.ink; font.family: theme.sans; font.pixelSize: 12
                               text: card.station < 0 ? "—" : (card.motion < 0 ? "direct on " : "retrograde on ") + Eph.shortDate(root.days + card.station) }
                    }
                    Column {
                        width: parent.width; spacing: 5
                        Caption { text: "ORBIT FROM PERIHELION  ·  " + Math.round(card.yearFrac * 100) + "%" }
                        Rectangle {
                            width: parent.width; height: 3; radius: 1.5; color: theme.line
                            Rectangle { width: parent.width * card.yearFrac; height: parent.height; radius: 1.5; color: card.b.color; opacity: 0.8 }
                        }
                    }
                }
            }
            Rule {}

            // the Moon
            Row {
                spacing: 16
                readonly property real el: { root.days; return Eph.moonElongation(root.days) }
                Canvas {
                    id: moonCanvas
                    width: 46; height: 46
                    property real el: parent.el
                    onElChanged: requestPaint()
                    onPaint: {
                        var c = getContext("2d"), r = 20, cx = 23, cy = 23
                        c.reset()
                        c.fillStyle = "#1a2030"; c.beginPath(); c.arc(cx, cy, r, 0, 2 * Math.PI); c.fill()
                        var k = Math.cos(el * Math.PI / 180)           // terminator ellipse half-width factor
                        var waxing = el < 180
                        c.fillStyle = "#e8e4d6"; c.beginPath()
                        // lit limb: right half when waxing, left when waning
                        c.arc(cx, cy, r, -Math.PI / 2, Math.PI / 2, !waxing)
                        // terminator back to the top
                        c.save(); c.translate(cx, cy); c.scale(Math.abs(k) < 1e-3 ? -1e-3 : -k, 1)
                        c.arc(0, 0, r, Math.PI / 2, -Math.PI / 2, !waxing)
                        c.restore(); c.fill()
                    }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter; spacing: 3
                    Text { text: Eph.moonPhaseName(parent.parent.el); color: theme.ink; font.family: theme.serif; font.pixelSize: 16 }
                    Caption { text: "☽  " + Math.round((1 - Math.cos(parent.parent.el * Math.PI / 180)) * 50) + "% ILLUMINATED  ·  IN "
                                    + Eph.zodiac(Eph.moonLon(root.days)).sign.toUpperCase() }
                }
            }
        }

        Text {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 28 }
            wrapMode: Text.WordWrap; lineHeight: 1.4
            color: theme.inkDim; font.family: theme.sans; font.pixelSize: 10
            text: "SPACE pause  ·  ← → speed  ·  1–8 planet  ·  N now  ·  S scale\nKeplerian elements, J2000. Accurate to about a degree."
        }
    }
}
