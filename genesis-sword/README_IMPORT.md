# GENESIS — Roblox import guide

## What this delivers

An editable Blender model plus interchange meshes for a **held in-game sword**. This is not a Marketplace avatar-accessory submission. Blender renders are presentation views: studio lighting, bloom, camera and background are not included in the sword export. Appearance in Roblox depends on your game's lighting.

## Import the sword

1. Open your experience in **Roblox Studio**. Choose **File → Import** and select the supplied `.fbx`.
2. In the importer preview, use **Import Only As Model = on**, **Merge Meshes = off**, **Scale Unit = Stud**, **World Forward = Front**, and **World Up = Top**. The sword is a single mesh named `Handle`, with one UV atlas material.
3. Keep **Set Pivot to Scene Origin** and **Use Imported Pivot** enabled; the authoring origin is at the grip. Inspect the preview before importing; do not automatically simplify the mesh.
4. For a static display, enable **Anchored**. For a held Tool, its Handle must be unanchored.
5. Choose the correct creator (your account or the experience's group). **Upload to Roblox** controls saving the model into your asset inventory. Check the importer warnings before confirming. Importing/uploads are actions you perform in Studio; this package has not been uploaded for you.
6. Compare the imported silhouette and dimensions with the supplied preview and validation report. If the size is wrong, change the scale uniformly. Retain the source copy while testing. The source sword is approximately 8.88 units long; use about 8.88 studs for the original oversized fantasy proportions, or scale down uniformly to taste.

Roblox's current importer accepts FBX, OBJ and glTF. `.blend` is the editable source and is not the Studio import file. FBX is the preferred delivery format here.

## Materials and textures

The model uses one material and a 512×512 atlas. Keep all supplied textures beside the export. If the FBX importer does not populate the textures correctly, insert a **SurfaceAppearance** under `Handle` and use these supplied images:

- **ColorMap:** `Genesis_BaseColor.png`
- **MetalnessMap:** `Genesis_Metalness.png`
- **RoughnessMap:** `Genesis_Roughness.png`
- **NormalMap:** `Genesis_Normal.png` (optional neutral/flat tangent-space map)

Keep `Handle.Color` white so it does not tint the atlas. The standalone metalness and roughness maps are provided specifically for Roblox. `Genesis_ORM.png` packs occlusion, roughness and metalness for interchange workflows; do not assign it directly to a Roblox grayscale map slot. If Studio already creates a correct SurfaceAppearance, reuse it rather than adding a duplicate.

Arbitrary Blender shader graphs and compositor effects do not become Roblox shaders. The cyan inlays are colored surfaces; rendered highlights/bloom are presentation effects, not an included gameplay glow system. Roblox supports emissive masks, but no emissive mask or active VFX are required for this delivery. See [Roblox PBR textures](https://create.roblox.com/docs/art/modeling/surface-appearance).

## Make it equippable

- Create a **Tool** named `Genesis`.
- Move the imported **MeshPart** named `Handle` directly inside the Tool. Keep its SurfaceAppearance attached. The one-mesh version needs no welds.
- If you later split or add visual parts, join them to Handle using **WeldConstraint** objects, preserving their assembled positions.
- Set every part's **Anchored = false** and **CanCollide = false**. You can use **Massless = true** for this visual prop.
- Keep **RequiresHandle = true**. Put the completed Tool in **StarterPack** to give it to spawning players.
- Play-test equip/unequip with your actual character rig. Adjust **Tool.Grip** until the hand sits naturally on the hilt. The imported mesh pivot is not a guarantee of the Tool attachment location. No grip orientation is guaranteed without an in-Studio test.
- This is an art asset. Damage, attacks, animation, sound, hit detection and networking are intentionally not implemented.

## Verified local geometry

Final FBX re-import: **19,224 triangles**, 9,804 vertices, one material and one UV set. No boundary/non-manifold edges, degenerate faces or loose vertices were detected. Blender-space bounds: **3.203 × 0.603 × 8.875 units**. The UV atlas stays within 0–1 and all five texture images are 512×512 PNGs.

## Validation boundaries

The validation folder records local checks and FBX re-imports in Blender. Geometry checks cover triangle counts, non-manifold/boundary edges, degenerate faces, finite coordinates and enclosed signed volume. These checks do not prove that Roblox moderation, asset permissions, Studio import, shading, grip or gameplay work. Studio import and in-game testing still need to be performed in your own experience.

## Official references

Checked against current Roblox Creator Hub documentation on October 4, 2026:

- [Importer and supported formats](https://create.roblox.com/docs/studio/importer)
- [General mesh specifications](https://create.roblox.com/docs/art/modeling/specifications): no more than 20,000 triangles in an individual mesh, closed surfaces and nonzero volume
- [Blender units, axes and scale](https://create.roblox.com/docs/art/blender)
- [FBX export settings](https://create.roblox.com/docs/art/modeling/export-requirements)
- [Texture specifications](https://create.roblox.com/docs/art/modeling/texture-specifications)
- [Tool creation and handle setup](https://create.roblox.com/docs/players/tools)
- [Weld constraints](https://create.roblox.com/docs/physics/constraints/weld)
