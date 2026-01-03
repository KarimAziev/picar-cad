include <../colors.scad>
include <../parameters.scad>

use <grid.scad>

use <smd_placeholder_renderer.scad>
use <../placeholders/smd/can_capacitor.scad>
use <../lib/plist.scad>

module pcb_grid(grid,
                debug=false,
                mode,
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
    if (mode == "placeholder" && !is_undef(placeholder_type)
        && !is_undef(placeholder)) {

      smd_placeholder_renderer(plist=placeholder,
                               thickness=thickness,
                               spin=spin,
                               align_x=align_x,
                               align_y=align_y,
                               cell_size=$cell_size);
    }
  }
}

pcb_grid(motor_driver_grid,
         debug=true,
         mode="placeholder");
