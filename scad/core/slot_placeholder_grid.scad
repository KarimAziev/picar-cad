
include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/holes.scad>
use <../lib/placement.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slider.scad>
use <../lib/transforms.scad>
use <../lib/wire.scad>
use <../placeholders/atc_ato_blade_fuse_holder.scad>;
use <../placeholders/atm_fuse_holder/atm_fuse_holder.scad>
use <../placeholders/battery_holder/battery_holder.scad>
use <../placeholders/bolt.scad>
use <../placeholders/lipo_pack.scad>
use <../placeholders/perf_board.scad>
use <../placeholders/rpi_5.scad>
use <../placeholders/step-down-voltage-d24vxf5.scad>
use <../placeholders/toggle_switch.scad>
use <../placeholders/voltmeter.scad>
use <../placeholders/xt90e-m.scad>
use <grid.scad>
use <slot_layout.scad>
use <slot_renderer.scad>

module slot_or_placeholder(slot_mode=true) {
  placeholder = $placeholder;
  plist = placeholder;

  thickness = $thickness;
  cell_size = $cell_size;
  align_x = $align_x;
  align_y = $align_y;
  spin = $spin;
  placeholder_type = plist_get("placeholder_type", placeholder);

  slot_type = placeholder_type;

  x_offset = plist_get("x_offset", plist);
  y_offset = plist_get("y_offset", plist);

  has_offset = (is_num(x_offset) && x_offset != 0) || (is_num(y_offset) && y_offset != 0);

  maybe_translate([has_offset ? with_default(x_offset, 0) : x_offset,
                   has_offset ? with_default(y_offset, 0) : y_offset, 0]) {
    if (slot_type == "voltmeter") {
      voltmeter_from_plist(plist=plist,
                           align_x=align_x,
                           align_y=align_y,
                           thickness=thickness,
                           cell_size=cell_size,
                           spin=spin,
                           slot_mode=slot_mode,
                           debug=false,
                           stand_up=false,
                           center=false);
    } else if (slot_type == "atm_fuse_holder") {
      atm_fuse_holder_from_spec(plist=plist,
                                align_x=align_x,
                                align_y=align_y,
                                thickness=thickness,
                                cell_size=cell_size,
                                spin=spin,
                                slot_mode=slot_mode,
                                center=false);
    } else if (slot_type == "step_down_voltage_regulator") {
      let (length = with_default(placeholder_size,
                                 [step_down_voltage_regulator_len,
                                  step_down_voltage_regulator_w])[0],
           w = with_default(placeholder_size,
                            [step_down_voltage_regulator_len,
                             step_down_voltage_regulator_w])[1]) {
        align_children_with_spin(parent_size=[length, w],
                                 size=full_size,
                                 align_x=align_x,
                                 align_y=align_y,
                                 spin=spin) {
          step_down_voltage_regulator(slot_mode=slot_mode,
                                      plist=plist,
                                      center=false,
                                      slot_thickness=thickness);
        }
      }
    } else if (slot_type == "xt90e_m") {
      let (slot_size = plist_get("slot_size", plist, undef),
           d = plist_get("mount_dia", plist, undef),
           bolt_spacing = plist_get("bolt_spacing", plist),
           bore_d = plist_get("bore_d", plist, undef),
           bore_h = plist_get("bore_h", plist, undef),
           full_size = four_corner_counterbores_full_size(size=bolt_spacing,
                                                          d=d,
                                                          bore_d=bore_d,
                                                          bore_h=bore_h),
           full_x = max(full_size[0], slot_size[0]),
           full_y = max(full_size[1], slot_size[1])) {
        if (slot_mode) {
          align_children_with_spin(parent_size=cell_size,
                                   size=[full_x, full_y],
                                   align_x=align_x,
                                   align_y=align_y,
                                   spin=spin) {
            xt_90_slot(plist,
                       thickness=thickness,
                       center=false);
          }
        } else {
          // xt_90_slot
        }
      }
    } else if (slot_type == "battery_holder") {
      battery_holder_cell(plist=plist,
                          align_x=align_x,
                          align_y=align_y,
                          thickness=thickness,
                          spin=spin,
                          slot_mode=slot_mode,
                          cell_size=cell_size);
    } else if (slot_type == "rpi_5") {
      let (full_size = [rpi_width, rpi_len]) {
        align_children_with_spin(parent_size=cell_size,
                                 size=full_size,
                                 align_x=align_x,
                                 align_y=align_y,
                                 spin=spin) {
          rpi_5(slot_mode=true);
        }
      }
    }
  }
}

module slot_placeholder_grid_builder(grid,
                                     debug=false,
                                     mode="slot",
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

    placeholder = $placeholder;

    placeholder_type = plist_get("placeholder_type", placeholder);
    slot_type = plist_get("slot_type", placeholder, placeholder_type);

    spin = plist_get("spin", $cell, 0);
    align_x = plist_get("align_x", $cell, 0);
    align_y = plist_get("align_y", $cell, 0);

    $align_x = align_x;
    $align_y = align_y;
    $type = slot_type;
    $plist = placeholder;
    $thickness = thickness;
    $spin = spin;
    $placeholder = placeholder;
    if (mode == "slot") {

      if (!is_undef(slot_type) || !is_undef(placeholder_type)) {
        slot_renderer(slot_type=is_undef(slot_type) ? placeholder_type : slot_type,
                      plist=placeholder,
                      thickness=thickness,
                      placeholder=placeholder,
                      placeholder_size=is_undef(placeholder)
                      ? placeholder
                      : plist_get("placeholder_size", placeholder),
                      spin=spin,
                      align_x=align_x,
                      align_y=align_y,
                      cell_size=$cell_size) {
          if ($children > 0) {
            children(0);
          }
        }
      }
    } else if (mode == "placeholder") {
      if (!is_undef(placeholder_type)&& !is_undef(placeholder)) {
        if ($children > 1) {
          children(1);
        }
      }
    }
  }
}

module slot_or_placeholder_grid(grid,
                                debug=false,
                                mode="slot",
                                thickness=2,
                                debug_spec=["gap", 10,
                                            "color", yellow_3,
                                            "text_h", 1,
                                            "border_h", 2,
                                            "border_w", 0.5,
                                            "size", 2]) {
  slot_placeholder_grid_builder(grid,
                                mode=mode,
                                debug=debug,
                                thickness=thickness,
                                debug_spec=debug_spec) {
    slot_or_placeholder(slot_mode=true);
    slot_or_placeholder(slot_mode=false);
  }
}

specs = ["type", "grid",
         "size", [chassis_body_w, chassis_body_len],
         "rows",
         maybe_add_battery_holders_rows_h([["cells",
                                            [["w", 0.5,
                                              "placeholder",
                                              ["placeholder_type", "battery_holder",
                                               "mount_type", battery_holder_mount_type,
                                               "count", 3,
                                               "show_battery", true,
                                               "terminal_type", battery_holder_terminal_type,
                                               "side_wall_cutout_type", battery_holder_side_wall_type,]],
                                             ["w", 0.5,
                                              "placeholder",
                                              ["placeholder_type", "battery_holder",
                                               "terminal_type", "coil_spring",
                                               "side_wall_cutout_type", "enclosed",
                                               "battery_len", 70,
                                               "battery_dia", 21,
                                               "show_battery", true,
                                               "mount_type", "under_cell",
                                               "battery_color", "pink",
                                               "color", "black"]]]],
                                           ["cells",
                                            [["w", 1,
                                              "spin", 90,
                                              "align_y", 1,
                                              "placeholder",
                                              ["placeholder_type", "battery_holder",
                                               "show_battery", true,
                                               "count", 1,
                                               "mount_type", battery_holder_mount_type,
                                               "terminal_type", battery_holder_terminal_type,
                                               "side_wall_cutout_type", battery_holder_side_wall_type,]]],]])];

translate([-chassis_body_w / 2, 0, 0]) {
  slot_or_placeholder_grid(mode="placeholder",
                           grid=specs,
                           debug=true,
                           debug_spec=["border_w", 0]);
}

// translate([-chassis_body_w / 2, 0, 0]) {
//   slot_or_placeholder_grid(mode="slot",
//                            grid=chassis_body_battery_holders_specs,
//                            debug=true);
// }