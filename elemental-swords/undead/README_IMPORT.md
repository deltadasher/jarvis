# VESPERMARROW — The Hollow Vigil

An undead ceremonial sword built around an empty crown, overlapping vertebral shields, a swept rib cage and burial linen. There is no skull emblem or central jewel: anatomy is the structure of the weapon. The palette is old ivory, blackened grave iron, oxidized bronze and muted verdigris.

## Contents

- `Vespermarrow_Sword.blend`: editable mesh with named component vertex groups, packed texture images and separate non-export studio collection
- `build_vespermarrow.py`: standalone reproducible Blender 4.3+ builder; run `blender -b --python build_vespermarrow.py`. It overwrites its own output files in the script directory
- FBX, GLB, OBJ + MTL: sword only, one mesh called `Handle`
- Hero, front and hilt-detail PNGs: renders of the actual supplied model
- BaseColor, Metalness, Roughness, Normal and ORM PNG maps, all 1024 × 1024
- `qa/`: independent final export checks when supplied

## Art and construction

The iron blade sweeps around a curved spinal keel. Twelve pairs of bone shields overlap along the blade. A tear-shaped through-opening beneath the hook point makes absence the focal detail. Six tapered ribs form the guard, with marrow channels and bronze sutures. The sternum is mechanically stitched, the grip wrapped in linen, and the sacral pommel retains an empty aperture.

The model is made of overlapping individually closed decorative shells, rather than one boolean-unioned solid. It is intended for realtime visuals and is not a watertight 3D-print solid. Do not globally weld all coincident vertices; this can create non-manifold contacts. The UV atlas uses deliberately shared palette swatches with small procedural color grain. Islands overlap by design: it is not a unique bake atlas. Broad shape and incised/fitted details are modeled; the normal map is neutral, not a high-poly detail bake. Occlusion in ORM is neutral white.

## Roblox import

1. Open your experience in Roblox Studio and use its 3D importer to select the FBX. GLB and OBJ are alternate interchange files; `.blend` is only for editing in Blender
2. Check preview scale and axes. Blender authoring is +Z blade-up and -Y front. The FBX is exported Y-up. Keep the imported grip-centered pivot and avoid automatic simplification until you compare the supplied front render
3. Import the single mesh as `Handle`, with one atlas material. Source size is approximately 2.876 × 0.525 × 10.014 units, long axis about 10 units. Scale uniformly for the intended avatar. Verify the import dimensions rather than assuming unit conversion
4. If materials do not populate correctly, add one SurfaceAppearance under Handle: ColorMap = BaseColor, MetalnessMap = Metalness, RoughnessMap = Roughness, optional NormalMap = Normal. Keep the part color white
5. The standalone grayscale maps are for Roblox. ORM is packed R=occlusion, G=roughness, B=metalness for GLB/other engines; do not put it directly into a grayscale Roblox slot
6. Import/upload under your own authorized creator or group and inspect Studio warnings. Nothing has been uploaded or published for you

## Tool assembly

- Create a Tool named `Vespermarrow` and place the MeshPart `Handle` directly beneath it, retaining its SurfaceAppearance
- Set Handle Anchored=false, CanCollide=false, and optionally Massless=true; keep Tool RequiresHandle=true
- Put the Tool in StarterPack for a test. One visual mesh requires no welds
- Play-test equip/unequip using your actual rig. Adjust Tool.Grip to fit the palm and rotate the blade correctly. A mesh's centered grip pivot does not guarantee its Tool attachment orientation
- If you split parts later, weld visual parts to Handle while preserving their assembled locations

This kit supplies art only. It does not contain damage, attacks, animations, sounds, hit detection, networking or scripts. It is a held prop, not a Marketplace avatar-accessory submission.

## What is and is not verified

Independent FBX, OBJ and GLB re-imports contain 15,280 triangles, one Handle mesh, one material, one UV set and origin (0, 0, 0) at the grip. FBX and OBJ each retain 7,908 vertices and 134 positive-volume closed components. Checks found no boundary edges, inconsistent winding, loose vertices or degenerate triangles. GLB passes the same geometric closure checks after welding expected UV/normal seam duplicates. See `qa/export_roundtrip.json` for exact hashes and per-format results. GLB normally splits vertices at UV and normal seams; this is distinct from unintended open physical geometry.

Roblox Studio import, in-game appearance, rig fit, moderation and asset ownership have not been tested. Blender lighting and the preview compositor do not transfer to Roblox. There is no gameplay glow or emissive mask. Every dark or green detail is ordinary PBR color. The neutral normal map may be omitted.

Reference documentation: [3D importer](https://create.roblox.com/docs/studio/importer), [mesh specifications](https://create.roblox.com/docs/art/modeling/specifications), [SurfaceAppearance](https://create.roblox.com/docs/art/modeling/surface-appearance), [Tools](https://create.roblox.com/docs/players/tools).


## Download packaging note

To keep downloads manageable, the Hero, Front and Detail preview PNGs are supplied as separate downloads beside this kit, rather than inside this ZIP. The mesh and texture files are unchanged from the validated full kit. The independent export report also covers the separately supplied GLB where applicable. Download links are in the collection overview.
