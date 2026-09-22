/**
  * Module: Rear chassis plate with its shaft-centered motor and controls.
  * The default origin is the center of the flat joining edge, below the plate.
  */
include <../../steering_params.scad>
include <../rear_suspension/computed_params.scad>

use <../../lib/plist.scad>
use <../../lib/transforms.scad>
use <../../motor_brackets/rc/gearbox_bracket.scad>
use <../../panel_stack/panel_stack.scad>
use <../rear_suspension/rear_suspension_chassis.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_chassis_size
  ─────────────────────────────────────────────────────────────────────────────

  Return `[width, length, thickness]` of the rear chassis plate for assembly.

  **Parameters:**
  - `layout`: Resolved rear layout, shared with `rear_chassis`.

  Hardware above the plate is excluded. With the default `[0, 1, 1]` anchor,
  the joining edge is at Y=0 and the suspension extends toward +Y.
 */
function rear_chassis_size(layout=rear_suspension_layout()) =
  rear_suspension_chassis_size(layout);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_chassis
  ─────────────────────────────────────────────────────────────────────────────

  Render the rear chassis and the components at their shared mounting datums.

  **Parameters:**
  - `show_panel_stack`: Display the controls and fuse stack.
  - `show_gearbox_bracket`: Display the printed motor bracket.
  - `show_gearbox`: Display the gearbox.
  - `show_motor`: Display the motor.
  - `show_bearing`: Display drive-shaft bearings.
  - `show_drive_shaft`: Display the gearbox's drive shaft.
  - `show_mount_bolts`: Display motor mounting bolts.
  - `show_nuts`: Display motor mounting nuts.
  - `show_shaft_seeve`: Display the shaft sleeve.
  - `show_extra_drive_shaft`: Display the shaft extending from the sleeve.
  - `anchor`: Plate envelope anchor, or `undef` for native holder-row coordinates.
  - `layout`: Resolved rear layout; display toggles do not change its dimensions.
 */
module rear_chassis(show_panel_stack=true,
                    show_gearbox_bracket=true,
                    show_gearbox=true,
                    show_motor=true,
                    show_bearing=true,
                    show_drive_shaft=true,
                    show_mount_bolts=true,
                    show_nuts=true,
                    show_shaft_seeve=true,
                    show_extra_drive_shaft=true,
                    anchor=[0, 1, 1],
                    layout=rear_suspension_layout()) {
  size = rear_chassis_size(layout);
  center_y = (plist_get("min_y", layout) + plist_get("max_y", layout)) / 2;
  with_anchor(is_undef(anchor) ? [0, 0, 1] : anchor, size, centered=true) {
    translate([0, is_undef(anchor) ? 0 : -center_y, 0]) {
      rear_suspension_chassis(layout=layout);
      translate([0, 0, size[2]]) {
        translate(plist_get("motor_pos", layout)) {
          rotate(plist_get("motor_rotation", layout)) {
            gearmotor_bracket(params=plist_get("bracket", layout),
                              anchor=plist_get("motor_anchor", layout),
                              show_bracket=show_gearbox_bracket,
                              show_gearbox=show_gearbox,
                              show_motor=show_motor,
                              show_bearing=show_bearing,
                              show_drive_shaft=show_drive_shaft,
                              show_mount_bolts=show_mount_bolts,
                              show_nuts=show_nuts,
                              show_shaft_seeve=show_shaft_seeve,
                              show_extra_drive_shaft=show_extra_drive_shaft);
          }
        }
        if (show_panel_stack) {
          translate(plist_get("panel_pos", layout)) {
            panel_stack(orientation=plist_get("panel_orientation", layout),
                        anchor=plist_get("panel_anchor", layout),
                        anchor_mode="size");
          }
        }
      }
    }
  }
}

rear_chassis();
