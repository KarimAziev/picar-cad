/**
  * Module: Removable encoder mount at the gearmotor's unused shaft end.
  * Uses the motor bracket's native shaft-centered coordinates.
  */
include <../../steering_params.scad>

use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>
use <../../placeholders/bolt.scad>
use <../../placeholders/motors/rc/gearbox.scad>
use <../../placeholders/nut.scad>
use <../../placeholders/rotary_encoder.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  gearmotor_encoder_params
  ─────────────────────────────────────────────────────────────────────────────

  Size a removable encoder mount with a continuous base and underside nut pockets.

  **Parameters:**
  - `motor`: Complete motor hardware plist.
  - `base_h`: Gearbox bracket's base thickness and encoder mounting surface Z.
  - `encoder_plist`: Encoder PCB specification; `undef` disables the feature.
  - `chassis_holes`: Existing bracket-to-chassis XY hole centers to keep accessible.
  - `chassis_bolt_d`: Diameter used to derive their pan-head clearance pockets.
  - `bottom_thickness`: Encoder foot thickness.
  - `side_thickness`: Upright wall thickness behind the PCB.
  - `pcb_padding`: Material beyond the PCB's side and upper edges.
  - `mount_bolt_d`: Two removable mount fasteners' through-hole diameter.
  - `mount_wall`: Minimum material outside the captive nuts' circumcircles.
  - `nut_clearance`: Radial and axial clearance around the underside nuts.
  - `clearance`: Separation from bolt heads and the encoder PCB.
  - `magnet_distance`: Gap between the magnet and sensor IC package faces.
  - `magnet_d`: Shaft-end magnet diameter.
  - `magnet_h`: Shaft-end magnet thickness; modeled bonded directly to the end.

  **Returns:**
  `undef`, or a plist in the gearbox bracket's native coordinates. `shaft_tip`
  is on the unused end at +Y; `sensor_face` and `magnet_face` share its X/Z axis.
  The PCB uses its shorter dimension vertically to conserve mounting height.
  `bounds` encloses the separate printed part. `base_extension_bounds` describes
  its supporting land on the main bracket. `mount_holes` are the two vertical
  fasteners into captive nuts loaded from below before installation on a chassis.
 */
function gearmotor_encoder_params(motor,
                                  base_h,
                                  encoder_plist=motor_encoder_plist,
                                  chassis_holes=[],
                                  chassis_bolt_d=m3_hole_dia,
                                  bottom_thickness=motor_encoder_bottom_thickness,
                                  side_thickness=motor_encoder_side_thickness,
                                  pcb_padding=motor_encoder_pcb_padding,
                                  mount_bolt_d=motor_encoder_mount_bolt_d,
                                  mount_wall=motor_encoder_mount_wall,
                                  nut_clearance=motor_encoder_nut_clearance,
                                  clearance=motor_encoder_clearance,
                                  magnet_distance=motor_encoder_magnet_distance,
                                  magnet_d=motor_encoder_magnet_d,
                                  magnet_h=motor_encoder_magnet_h) =
  is_undef(encoder_plist) ? undef :
  let (gearbox = gearbox_compute_params(motor),
       pcb = plist_get("size", encoder_plist),
       rotated = pcb[0] < pcb[1],
       pcb_w = max(pcb[0], pcb[1]),
       pcb_h = min(pcb[0], pcb[1]),
       axis_h = plist_get("outer_shaft_y_center", gearbox),
       shaft_tip_y = plist_get("outer_shaft_l", gearbox)
       - plist_get("thickness", gearbox)
       - plist_get("outer_shaft_rear_len", gearbox),
       axis_z = base_h + axis_h,
       ic_h = plist_get("chip_size", plist_get("sensor_ic", encoder_plist))[2],
       pcb_back_y = shaft_tip_y + magnet_h + magnet_distance + pcb[2] + ic_h,
       wall_y = pcb_back_y + side_thickness,
       nut_af = find_nut_prop("outer_dia", mount_bolt_d),
       nut_h = find_nut_prop("height", mount_bolt_d),
       nut_d = nut_af / cos(30),
       pocket_d = nut_d + 2 * nut_clearance,
       pocket_h = nut_h + nut_clearance,
       foot_r = max(pocket_d / 2,
                    find_bolt_head_d(mount_bolt_d, "pan") / 2) + mount_wall,
       foot_x = pcb_w / 2 + find_bolt_head_d(mount_bolt_d, "pan") / 2 + clearance,
       half_w = foot_x + foot_r,
       foot_y = wall_y - foot_r,
       min_y = wall_y - 2 * foot_r,
       max_z = axis_z + pcb_h / 2 + pcb_padding,
       head_clearance_d = find_bolt_head_d(chassis_bolt_d, "pan") + 2 * clearance,
       head_clearance_h = find_bolt_head_h(chassis_bolt_d, "pan") + clearance,
       bounds = [[-half_w, min_y, base_h], [half_w, wall_y, max_z]])
       assert(base_h > pocket_h && bottom_thickness > 0 && side_thickness > 0,
              "Encoder nut pockets must leave a solid roof in the gearbox base")
       assert(min(pcb_padding, mount_wall, nut_clearance, clearance, magnet_distance) >= 0
              && magnet_d > 0 && magnet_h > 0 && shaft_tip_y > 0,
              "Invalid encoder mount dimensions or unused shaft length")
       assert(axis_h - pcb_h / 2 >= bottom_thickness + clearance,
              "Encoder PCB is too low for a separate foot; reduce foot thickness or revise the mount")
       ["encoder", encoder_plist,
        "rotated", rotated,
        "pcb_w", pcb_w,
        "pcb_h", pcb_h,
        "pcb_padding", pcb_padding,
        "base_h", base_h,
        "bottom_thickness", bottom_thickness,
        "side_thickness", side_thickness,
        "shaft_tip", [0, shaft_tip_y, axis_z],
        "magnet_d", magnet_d,
        "magnet_h", magnet_h,
        "magnet_face", [0, shaft_tip_y + magnet_h, axis_z],
        "sensor_face", [0, shaft_tip_y + magnet_h + magnet_distance, axis_z],
        "pcb_back", [0, pcb_back_y, axis_z],
        "wall_y", wall_y,
        "foot_r", foot_r,
        "foot_x", foot_x,
        "mount_bolt_d", mount_bolt_d,
        "mount_holes", [[-foot_x, foot_y], [foot_x, foot_y]],
        "nut_d", nut_d,
        "nut_h", nut_h,
        "nut_pocket_d", pocket_d,
        "nut_pocket_h", pocket_h,
        "chassis_holes", chassis_holes,
        "head_clearance_d", head_clearance_d,
        "head_clearance_h", head_clearance_h,
        "bounds", bounds,
        "size", bounds[1] - bounds[0],
        "base_extension_bounds", [[-half_w, min_y, 0], [half_w, wall_y, base_h]]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  gearmotor_encoder_bracket
  ─────────────────────────────────────────────────────────────────────────────

  Render the removable encoder bracket or its mounting holes in the gearbox base.

  **Parameters:**
  - `params`: Result of `gearmotor_encoder_params()`.
  - `anchor`: Anchor of the printed bracket box; `undef` retains native motor
    coordinates. `[0, 0, 1]` places the separate part flat on the print bed.
  - `slot_mode`: Emit holes and underside nut pockets for the main gearbox base.
  - `show_bracket`: Display the separate printed part.
  - `show_encoder`: Display the encoder PCB facing the shaft.
  - `show_mount_bolts`: Display PCB bolts and two foot bolts with captive nuts.
  - `color`: Printed-part color.

  The continuous base joins the two lateral mounting holes beneath the PCB.
  Chassis-bolt head reliefs follow the supplied hole positions when needed.
  Load the captive nuts before installing the main bracket on the chassis.
  Body and slot modes share the same anchor reference.
 */
module gearmotor_encoder_bracket(params,
                                 anchor=undef,
                                 slot_mode=false,
                                 show_bracket=true,
                                 show_encoder=false,
                                 show_mount_bolts=false,
                                 color=white_off_1) {
  bounds = plist_get("bounds", params);
  size = plist_get("size", params);
  shift = is_undef(anchor) ? [0, 0, 0]
    : to_anchor(normalize_anchor(anchor), size)
    - bounds[0];
  base_h = plist_get("base_h", params);
  foot_h = plist_get("bottom_thickness", params);
  wall_h = bounds[1][2] - base_h;
  wall_y = plist_get("wall_y", params);
  wall_t = plist_get("side_thickness", params);
  foot_r = plist_get("foot_r", params);
  foot_x = plist_get("foot_x", params);
  wall_w = plist_get("pcb_w", params) + 2 * plist_get("pcb_padding", params);
  bolt_d = plist_get("mount_bolt_d", params);
  holes = plist_get("mount_holes", params);
  pcb_back = plist_get("pcb_back", params);
  pcb_rotation = plist_get("rotated", params) ? 90 : 0;

  translate(shift) {
    if (slot_mode) {
      for (p = holes) {
        translate([p[0], p[1], -0.1]) {
          cylinder(d=bolt_d, h=base_h + foot_h + 0.2, $fn=32);
          cylinder(d=plist_get("nut_pocket_d", params),
                   h=plist_get("nut_pocket_h", params) + 0.1,
                   $fn=6);
        }
      }
    } else {
      if (show_bracket) {
        color(color) {
          difference() {
            union() {
              translate([0, wall_y, base_h]) {
                rotate([90, 0, 0]) {
                  cuboid([wall_w, wall_h, wall_t],
                         anchor=[0, 1, 1],
                         r_factor=0.5,
                         side="top");
                }
              }
              hull() {
                for (i = [0 : len(holes) - 1]) {
                  let (p = holes[i],
                       side = i == 0 ? "left" : "right") {
                    translate([p[0] - foot_r, bounds[0][1], base_h]) {
                      cuboid(size=[2 * foot_r, 2 * foot_r, foot_h],
                             anchor=[1, 1, 1],
                             r_factor=0.5,
                             side=side);
                      translate([0, foot_r, 0]) {
                        cuboid(size=[2 * foot_r, foot_r, foot_h],
                               side="top",
                               r_factor=0.5,
                               anchor=[1, 1, 1]);
                      }
                    }
                  }
                }
              }
            }
            for (p = holes) {
              translate([p[0], p[1], base_h - 0.1]) {
                cylinder(d=bolt_d, h=foot_h + 0.2, $fn=32);
              }
            }
            translate([pcb_back[0], wall_y, pcb_back[2]]) {
              rotate([90, 0, 0]) {
                rotate([0, 0, pcb_rotation]) {
                  encoder(plist=plist_get("encoder", params),
                          parent_thickness=wall_t,
                          slot_mode=true);
                }
              }
            }
            for (p = plist_get("chassis_holes", params)) {
              translate([p[0], p[1], base_h - 0.1]) {
                cylinder(d=plist_get("head_clearance_d", params),
                         h=plist_get("head_clearance_h", params) + 0.1,
                         $fn=32);
              }
            }
          }
        }
      }
      if (show_encoder) {
        translate(pcb_back) {
          rotate([90, 0, 0]) {
            rotate([0, 0, pcb_rotation]) {
              encoder(plist=plist_get("encoder", params),
                      parent_thickness=wall_t,
                      show_bolt=show_mount_bolts,
                      show_nut=show_mount_bolts);
            }
          }
        }
      }
      if (show_mount_bolts) {
        for (p = holes) {
          translate([p[0], p[1], 0]) {
            bolt(d=bolt_d, h=base_h + foot_h, head_type="pan", show_nut=false);
          }
          translate([p[0],
                     p[1],
                     plist_get("nut_pocket_h", params)
                     - plist_get("nut_h", params)]) {
            nut(d=bolt_d,
                outer_d=plist_get("nut_d", params),
                h=plist_get("nut_h", params),
                show_text=false);
          }
        }
      }
    }
  }
}
