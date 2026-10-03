include <../colors.scad>
include <../parameters.scad>

use <../lib/plist.scad>
use <../lib/functions.scad>
use <../lib/transforms.scad>
use <grid.scad>
use <smd_placeholder_renderer.scad>
use <pcb_placeholder_renderer.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  pcb_grid
  ─────────────────────────────────────────────────────────────────────────────

  Place PCB components in rows and nested cells measured from the top-left.

  **Parameters:**
  - `grid`: Grid plist with `type="grid"`, `size=[w,l]` and `rows`. Row `h`
    and cell `w` values greater than one are millimeters; values up to one are
    fractions of their parent dimension. Rows descend along negative Y.
  - `debug`: Show row and cell boundaries and dimension labels.
  - `mode`: `"placeholder"` renders components; `"slot"` renders supported slots.
  - `thickness`: PCB top-surface Z for placeholders, or thickness for slots.
  - `debug_spec`: Plist controlling debug colors, border and text dimensions.
  - `level`: Starting nesting level used in debug labels.

  Cells accept `placeholder` or a nested `grid`. `align_x` and `align_y`
  default to zero (center); -1 selects the minimum side and 1 the maximum side.
  `spin` rotates the component around Z before alignment. Optional `x_offset`,
  `y_offset` and `z_offset` shift a leaf component after alignment. Components
  may overhang cells; cell dimensions describe placement, not clipping bounds.

  **Examples:**
  ```scad
  translate([0, 40, 0]) {
    pcb_grid(["type", "grid", "size", [30, 40],
              "rows", [["h", 1, "cells", [["w", 1,
                         "placeholder", ["type", "cuboid",
                                         "size", [10, 12, 2]]]]]]],
             thickness=1.6);
  }
  ```
 */
module pcb_grid(grid,
                debug=false,
                mode="placeholder",
                thickness=2,
                debug_spec=["gap", 10,
                            "color", yellow_3,
                            "text_h", 1,
                            "border_h", 2,
                            "border_w", 0.5,
                            "size", 2],

                level=0) {

  assert(grid_is(grid),
         "grid_plist: grid must be a plist with type='grid'");

  size = plist_get("size", grid, undef);
  assert(!is_undef(size) && len(size)==2,
         "grid_plist: grid must have 'size'=[x,y] at top level");

  grid_plist_render(size=size,
                    grid=grid,
                    debug=debug,
                    mode=mode,
                    debug_spec=debug_spec,
                    level=level) {

    placeholder_type = plist_get("type", $placeholder);
    placeholder = plist_get("placeholder", $cell);
    spin = plist_get("spin", $cell, 0);
    align_x = plist_get("align_x", $cell, 0);
    align_y = plist_get("align_y", $cell, 0);
    y_offset = plist_get("y_offset", $cell, 0);
    x_offset = plist_get("x_offset", $cell, 0);
    z_offset = plist_get("z_offset", $cell, 0);

    maybe_translate([with_default(x_offset, 0),
                     with_default(y_offset, 0),
                     with_default(z_offset, 0)]) {
      if (mode == "placeholder" && !is_undef(placeholder_type)
          && !is_undef(placeholder)) {

        pcb_placeholder_renderer(plist=placeholder,
                                 thickness=thickness,
                                 spin=spin,
                                 align_x=align_x,
                                 align_y=align_y,
                                 cell_size=$cell_size);
      } else if (mode == "slot") {
        smd_placeholder_slot_renderer(plist=placeholder,
                                      thickness=thickness,
                                      spin=spin,
                                      align_x=align_x,
                                      align_y=align_y,
                                      cell_size=$cell_size);
      }
    }
  }
}

pcb_grid(motor_driver_grid,
         debug=true,
         mode="placeholder");
