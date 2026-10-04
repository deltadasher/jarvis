# CALDERA — The faultline cleaver

A magma fantasy sword built as real mesh geometry. The unequal guard, knapped glass edge, deep recessed faultline, coarse basalt plates, scorched grip and copper fasteners form an intentionally brutal silhouette. This is a new design, not a recolored Genesis sword.

## Package

- `Caldera_Sword.blend`: editable Blender source with packed textures, named export and separate studio collections
- `build_caldera.py`: reproducible geometry, textures, exports and renders. Run `blender -b -t 4 --python build_caldera.py` with Blender 4.3+ and its bundled NumPy; outputs go beside the script
- FBX (preferred Studio import), GLB, OBJ and MTL: one mesh named `Handle`, one atlas material
- Hero, Detail and Front PNGs: actual mesh renders; Front is orthographic
- 1024×1024 BaseColor, Normal, Roughness and Metalness maps for SurfaceAppearance
- ORM: R=constant occlusion 1, G=roughness, B=metalness, for interchange workflows
- Emission: optional companion for Blender/glTF or a separately configured supported engine emission workflow

The atlas deliberately reuses eight tiled material regions. It is not a unique bake layout for painting each individual plate. Procedural fine grain, material-specific roughness and a subtle tangent-space normal map accompany the sculpted facets and modeled cracks. Components are overlapping closed shells, not a single boolean-unioned solid.

## Roblox Studio import

Import the FBX with Studio's 3D importer. Keep the source as a single MeshPart named `Handle`; inspect the importer preview, scale and warnings before uploading. Preserve the imported grip-centered pivot if the importer offers that option. The sword points along Blender +Z, with the front facing -Y; export files apply their format's up-axis conversion. Source height is approximately 9.83 units. Scale uniformly for your avatar and experience. No account uploads or publication have been performed.

If textures do not populate automatically, add one SurfaceAppearance below the Handle and assign:

- ColorMap → `Caldera_BaseColor.png`
- MetalnessMap → `Caldera_Metalness.png`
- RoughnessMap → `Caldera_Roughness.png`
- NormalMap → `Caldera_Normal.png`

Use white Handle.Color and no duplicate SurfaceAppearance. Do not put packed ORM in a grayscale Roblox slot. The orange and yellow are part of the actual color atlas, so the molten fissures retain their color without emission. Blender's optional emission, lighting and background do not transfer as gameplay glow. The supplied standard four-map setup does not create glow or light; adding engine-specific emission or VFX is separate work.

## Tool assembly

1. Create a Tool named `Caldera` and move Handle directly into it
2. Keep its SurfaceAppearance under Handle; one mesh needs no welds
3. Set Handle.Anchored=false, Handle.CanCollide=false and optionally Massless=true
4. Set Tool.RequiresHandle=true and place the Tool in StarterPack for testing
5. Play-test equip/unequip on the actual character rig and adjust Tool.Grip for the desired hold; the centered source pivot alone does not guarantee the final hand orientation

If you add parts later, weld them to Handle. This is an art kit: combat scripts, hit detection, animation, sounds and networking are not included.

## Validation scope

See `qa/` for independent final export audits. Local Blender source and round-trip checks cover geometry, triangle count, normals, UVs, materials and texture presence. GLB can split vertices at UV/normal seams. Do not globally weld unrelated decorative components. Blender previews are not proof of Studio appearance. Roblox Studio import, moderation, permissions, rig fit and in-game rendering have not been tested.

## References

- https://create.roblox.com/docs/studio/importer
- https://create.roblox.com/docs/art/modeling/surface-appearance
- https://create.roblox.com/docs/art/modeling/specifications
- https://create.roblox.com/docs/players/tools

### Final local audit

Independent final FBX, OBJ and GLB round trips each contain **12,476 triangles**, one `Handle`, one material and one UV set. Source/FBX/OBJ shells have no boundary/nonmanifold edges; GLB is likewise clean after accounting for format seam splits. All checked components have positive nonzero enclosed volume and no degenerate triangles or inconsistent winding. Bounds are **3.027570 × 0.774000 × 9.832687** in Blender coordinates. All maps are valid 1024px PNGs, and separate grayscale maps match the packed ORM channels. See the included machine-readable QA reports for details.


## Download packaging note

To keep downloads manageable, the Hero, Front and Detail preview PNGs are supplied as separate downloads beside this kit, rather than inside this ZIP. `Caldera_Sword.glb` is also supplied separately; the FBX and OBJ/MTL remain in this ZIP. The mesh and texture files are unchanged from the validated full kit. The independent export report also covers the separately supplied GLB where applicable. Download links are in the collection overview.
