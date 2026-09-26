# Shape visual tests

Open these files in OpenSCAD and use Preview (F5) to inspect colors and placement:

- `test_cylindric_orientation.scad`: seven cylindrical specimens across all six
  orientations, including cones, asymmetric notches, and tapered rings. Every
  reference box is centered on X/Y and rests on Z=0.
- `test_cylindric_anchors.scad`: horizontal specimens with six final-axis anchors.
  The axes mark each local origin: red +X, green +Y, blue +Z. Cut profiles use
  their uncut circular reference box, so a flat need not touch an anchored plane.
- `test_colors.scad`: all eleven public shape modules, plus the ring's
  `whole_color=false` mode. Each pair inherits blue on the left (`color=undef`)
  and specifies orange on the right.
- `test_rounded_sides.scad`: side lists, independent numeric/percentage radii,
  and a square-corner override. Blue profiles show `rounded_rect()` above the
  matching orange `cuboid()` specimens.

Generate previews from the repository root (requires a nightly OpenSCAD with
`roof` and `textmetrics`):

```sh
mkdir -p build/skill-previews
for name in test_cylindric_orientation test_cylindric_anchors test_colors test_rounded_sides; do
  openscad --backend=Manifold --enable=textmetrics --enable=roof \
    --hardwarnings --preview --projection=ortho --camera=0,0,0,35,0,0,700 \
    --colorscheme=Tomorrow --view=axes \
    --viewall --autocenter --imgsize=1600,1400 \
    -o "$PWD/build/skill-previews/$name.png" "$PWD/tests/test_shapes/$name.scad"
done
```

These galleries are manual visual tests; `make tests-scad` only discovers the
top-level assertion suites in `tests/`.
