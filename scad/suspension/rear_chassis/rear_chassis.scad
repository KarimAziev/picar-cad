/**
  * Module: Rear chassis plate with its shaft-centered motor and controls.
  * The default origin is the center of the flat joining edge, below the plate.
  */
include <../../rc_params.scad>
include <computed_params.scad>

use <../../lib/plist.scad>
use <../../lib/transforms.scad>
use <../../motor_brackets/rc/gearbox_bracket.scad>
use <../../panel_stack/panel_stack.scad>
use <../../placeholders/step-down-voltage-d24vxf5.scad>
use <../../placeholders/voltmeter.scad>
use <../../wago/wago_mounts.scad>
use <../rear_suspension/rear_suspension_mount.scad>
use <rear_chassis_frame.scad>
use <rear_equipment.scad>
use <rear_payload.scad>
use <rear_power_wiring.scad>

rear_suspension_joint_spacing = 0;
show_rear_suspension_mount    = true;

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
function rear_chassis_size(layout=rear_chassis_layout()) =
  rear_suspension_chassis_size(layout);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_chassis
  ─────────────────────────────────────────────────────────────────────────────

  Render the rear chassis and the components at their shared mounting datums.

  **Parameters:**
  - `show_panel_stack`: Display all configured control, fuse and combined panels.
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
  - `show_motor_encoder_bracket`: Display the removable shaft encoder mount.
  - `show_motor_encoder`: Display its PCB.
  - `show_motor_encoder_magnet`: Display its shaft-end magnet.
  - `show_power_case`: Display the raised battery case.
  - `show_lipo_packs`: Display batteries within the case.
  - `show_power_standoffs`: Display the four supporting columns.
  - `show_lidar`: Display the lidar on the raised payload.
  - `show_lidar_lid`: Display its sliding power-case lid.
  - `show_wago_brackets`: Display configured deck brackets; holes remain present.
  - `show_wagos`: Display connectors in those brackets.
  - `show_power_wiring`: Undef follows lid/lidar visibility; true shows the
    configured battery and rear fuse/converter harnesses in a roof-hidden view.
    Wiring passages remain present when the harness is hidden.
  - `show_equipment`: Display configured deck electronics; holes remain present.
  - `show_equipment_zones`: Overlay available side corridors for placement.
  - `front_joint`: Include the direct front-frame tongue; false retains a flat edge.
 */
module rear_chassis(show_panel_stack=true,
                    show_gearbox_bracket=true,
                    show_gearbox=true,
                    show_motor=true,
                    show_bearing=true,
                    show_drive_shaft=true,
                    show_mount_bolts=true,
                    show_nuts=true,
                    show_drive_shaft_seeve=true,
                    show_extra_drive_shaft=true,
                    anchor=[0, 1, 1],
                    layout=rear_chassis_layout(),
                    show_motor_encoder_bracket=true,
                    show_motor_encoder=true,
                    show_motor_encoder_magnet=true,
                    show_power_case=true,
                    show_lipo_packs=true,
                    show_power_standoffs=true,
                    show_lidar=false,
                    show_lidar_lid=true,
                    show_wago_brackets=true,
                    show_wagos=false,
                    show_power_wiring=undef,
                    show_equipment=true,
                    show_equipment_zones=false,
                    rear_suspension_joint_spacing=rear_suspension_joint_spacing,
                    show_rear_suspension_mount=show_rear_suspension_mount,
                    front_joint=true) {
  size = rear_chassis_size(layout);
  center_y = (plist_get("min_y", layout) + plist_get("max_y", layout)) / 2;
  with_anchor(is_undef(anchor) ? [0, 0, 1] : anchor, size, centered=true) {
    translate([0, is_undef(anchor) ? 0 : -center_y, 0]) {
      union() {
        rear_chassis_frame(layout=layout, front_joint=front_joint);
        if (show_rear_suspension_mount) {
          translate([0, rear_suspension_joint_spacing, 0]) {
            rear_suspension_mount(layout=layout);
          }
        }
      }
      rear_power_harness(layout,
                           show_wiring=is_undef(show_power_wiring)
                               ? show_lidar_lid || show_lidar : show_power_wiring);
      rear_equipment(layout,
                     show_hardware=show_equipment,
                     show_zones=show_equipment_zones);
      if (show_wago_brackets) {
        wago_mounts(plist_get("wago_mounts", layout, []),
                    show_wago=show_wagos,
                    parent_t=size[2]);
      }
      rear_power_payload(plist_get("power_case", layout),
                         show_case=show_power_case,
                         show_packs=show_lipo_packs,
                         show_standoffs=show_power_standoffs,
                         show_lidar=show_lidar,
                         show_lid=show_lidar_lid,
                         show_wiring=show_power_wiring);
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
                              show_shaft_seeve=show_drive_shaft_seeve,
                              show_extra_drive_shaft=show_extra_drive_shaft,
                              show_encoder_bracket=show_motor_encoder_bracket,
                              show_encoder=show_motor_encoder,
                              show_encoder_magnet=show_motor_encoder_magnet);
          }
        }
        if (show_panel_stack) {
          for (panel = plist_get("panels", layout)) {
            translate(plist_get("pos", panel)) {
              panel_component(type=plist_get("type", panel),
                              orientation=plist_get("orientation", panel));
            }
          }
        }
      }
    }
  }
}

rear_chassis();
