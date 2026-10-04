# NERIS — Pearl of the Undertow

An elegant water relic with an asymmetric breaking-wave blade, a true open curled heel, a tidal crescent guard cradling a nacre pearl, crosswoven ocean-hide grip, and a suspended droplet pommel. This is a real modeled sword, not an image plane. The blue accents use opaque glossy PBR for reliable game-engine appearance.

## Included

- `Neris_Sword.blend`: editable mesh, packed texture atlas and a separate non-export studio collection
- `build_neris.py`: complete procedural construction, UV/material assignment, export and render recipe. Requires Blender 4.3+; run `blender -b -t 6 --python build_neris.py` in this directory. It overwrites generated files
- `Neris_Sword.fbx`: primary import candidate; contains only the Handle mesh
- `Neris_Sword.glb`: self-contained glTF alternative with textures
- `Neris_Sword.obj` and `.mtl`: geometry/base-color fallback. Keep accompanying PNGs beside these files
- `Neris_BaseColor.png`, `Neris_Metalness.png`, `Neris_Roughness.png`, `Neris_Normal.png`: 1024×1024 Roblox maps
- `Neris_ORM.png`: packed AO/Roughness/Metallic map for glTF/other engines; not a Roblox map slot
- Hero, detail and orthographic front preview PNGs
- `model_stats.txt` and independent validation report when included

## Geometry and layout

One mesh named **Handle**, one material, one UV atlas, grip-centered origin. Blender coordinates: +Z toward the blade; -Y is the hero-facing surface. The design uses individually closed decorative shells joined into one MeshPart. Shells intentionally overlap where pieces meet; this is a game asset, not a single watertight manufacturing solid. Fine metal lips, engraved ripple lines, shell scallops and grip braid are modeled geometry. The normal map is neutral tangent-space blue; it intentionally adds no fake relief.

The atlas uses eight padded reusable material swatches. UV islands deliberately overlap within each swatch: economical trim-atlas mapping, not a unique painting/baking unwrap. Silver, nacre, leather, sapphire and foam highlights are distinguished by color/roughness/metalness. Core materials are portable; Blender studio lighting, compositor glow and reflections are not transferred.

## Import to Roblox Studio

1. Open your place, use Studio's 3D Importer and select `Neris_Sword.fbx`. Review the preview before completing the import. GLB or OBJ may be used as alternatives supported by your current importer.
2. Confirm there is one sword MeshPart named `Handle`. Do not import the Blender studio collection; it is already omitted from these exports.
3. Pick the gameplay scale in the importer. The source is about 9.76 modeling units tall; source dimensions are not a prescribed avatar size. Scale uniformly and check against your actual character.
4. Insert a `SurfaceAppearance` under Handle. Upload the supplied PNGs and assign their image asset IDs:
   - ColorMap → Neris_BaseColor.png
   - MetalnessMap → Neris_Metalness.png
   - RoughnessMap → Neris_Roughness.png
   - NormalMap → Neris_Normal.png (optional neutral normal)
5. Keep the mesh color white and transparency zero. Do not place the packed ORM image into any individual Roblox map field. Do not expect OBJ/MTL to import every PBR property automatically.
6. Inspect both sides in neutral lighting and your game's actual lighting. The silver needs an environment with reflected light; apparent gloss may differ from the Blender renders.

No glass refraction or true translucency is required for the included appearance. A more translucent/custom glowing version would require deliberate material separation and game-specific setup; it is not promised by this single-mesh package. You can add tasteful game effects separately, but none is necessary to read the design.

## Assemble a held Tool

1. Create a `Tool` and place the Handle MeshPart directly inside it. Keep the exact name `Handle`; leave Tool.RequiresHandle enabled.
2. Set Handle.Anchored = false, Handle.CanCollide = false, and Handle.Massless = true. Choose CanTouch/CanQuery according to your own hit-detection design.
3. Move the Tool to StarterPack for a local equip test. Adjust Tool.Grip translation/rotation for your rig so the palm lies at the grip center and the blade points correctly. FBX/glTF/OBJ import axis handling can differ; test, do not assume an identical Grip transform across formats.
4. Test the equipped Tool on your target R6/R15 avatar and animation set. Check hand alignment, scale, movement, back/front rendering and clipping.

This package is the visual asset and assembly guidance. It does not include combat code, damage, animations, inventory logic, collision hitboxes, marketplace publishing, or a Studio-tested place file. Never trust the elaborate visible mesh as a precise damage hitbox; use a simple gameplay collider under your own game logic.

## Rebuild and edit

Open the `.blend` to edit the joined Handle mesh directly. For separate named construction components, edit `build_neris.py` or stop before its join section. The script constructs the high-detail closed parts, assigns atlas UVs, joins them, applies a budget simplification, and exports one mesh. Re-export only Handle after changes and recheck the triangle budget, UVs, normals and scale. Rendering is CPU Cycles, 80 samples, without denoising to support the bundled Blender runtime.

## Validation boundaries

See included QA for measured topology, triangle counts and fresh export reimports. External file validation is not the same as an actual Roblox Studio import/equip test. No asset IDs were uploaded and no game was published.

Official documentation checked 2026-10-04:
- [Roblox PBR textures](https://create.roblox.com/docs/art/modeling/surface-appearance)
- [SurfaceAppearance](https://create.roblox.com/docs/reference/engine/classes/SurfaceAppearance)
- [Tool](https://create.roblox.com/docs/reference/engine/classes/Tool)


## Download packaging note

To keep downloads manageable, the Hero, Front and Detail preview PNGs are supplied as separate downloads beside this kit, rather than inside this ZIP. The mesh and texture files are unchanged from the validated full kit. The independent export report also covers the separately supplied GLB where applicable. Download links are in the collection overview.
