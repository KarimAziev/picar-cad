/**
  * Module: Upper steering bridge with bulkhead and suspension-holder mounts.
  *
  * The flat web clears rotating bellcranks. Integral feet bear on the two
  * stationary posts, two bulkhead bosses, and two holder lugs.
  * Dimensions are millimeters.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../rc_params.scad>

use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <bellcrank/bellcrank_drive.scad>
use <bellcrank/util.scad>
use <bulkhead/front_upper_suspension_holder.scad>
use <bulkhead/util.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  upper_steering_plate_mounts
  ─────────────────────────────────────────────────────────────────────────────
  Return the support faces in bellcrank assembly coordinates.
  **Returns:** Six [x, y, z] centers: two post tops, two bulkhead bosses,
  then two suspension-holder lugs.
  Z=0 is the chassis top; +Y points toward the front bulkhead.
 */
function upper_steering_plate_mounts() =
  let (holder = front_bulkhead_upper_holder_position()
                + [0, bellcrank_y_distance_from_bulkhead + front_bulkhead_len / 2,
                   front_bulkhead_housing_h])
  concat([for (side = [-1, 1])
    [side * chassis_bellcrank_spacing / 2, 0, bellcrank_post_h]],
         [for (side = [-1, 1])
           [side * upper_steering_panel_bulkhead_spacing / 2,
            bellcrank_y_distance_from_bulkhead + front_bulkhead_len / 2
            + front_bulkhead_upper_steering_mount_y(),
            bellcrank_idler_full_mount_h() + bellcrank_post_flang_h]],
         [for (p = front_upper_suspension_holder_steering_mounts())
           holder + [-p[0], p[2], p[1]]]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  upper_steering_plate_base_z
  ─────────────────────────────────────────────────────────────────────────────
  Return the lowest contact height above the chassis.
 */
function upper_steering_plate_base_z() =
  min([for (p = upper_steering_plate_mounts()) p[2]]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  upper_steering_plate_web_z
  ─────────────────────────────────────────────────────────────────────────────
  Return the web underside height above the chassis, including running clearance.
 */
function upper_steering_plate_web_z() =
  let (housing_top = bellcrank_idler_full_mount_h() + bellcrank_post_flang_h,
       // The cap is translated by the drive-ring thickness in bellcrank_drive.
       cap_top = housing_top + bellcrank_arm_thickness
                 - bellcrank_servo_lever_thickness,
       lever_top = bellcrank_servo_lever_z_coords()[1],
       // Highest upper-holder barrel after its assembly rotation about X.
       holder_top = front_bulkhead_housing_h
                    + front_bulkhead_shock_tower_mount_offset
                    + front_shock_tower_pin_y_offset
                    + front_upper_arm_hinge_barrel_hole_d
                    + front_upper_suspension_holder_pin_barrel_d / 2)
  max(housing_top, cap_top, lever_top, holder_top)
  + upper_steering_plate_running_clearance;

/**
  ─────────────────────────────────────────────────────────────────────────────
  upper_steering_plate_size
  ─────────────────────────────────────────────────────────────────────────────
  Return the canonical [width, length, height], including integral feet.
 */
function upper_steering_plate_size() =
  [max(chassis_bellcrank_spacing,
       front_upper_suspension_holder_steering_bolt_spacing)
   + upper_steering_plate_pad_d,
   max([for (p = upper_steering_plate_mounts()) p[1]])
   + upper_steering_plate_pad_d,
   upper_steering_plate_web_z() - upper_steering_plate_base_z()
   + upper_steering_plate_thickness];

/**
  ─────────────────────────────────────────────────────────────────────────────
  upper_steering_plate_position
  ─────────────────────────────────────────────────────────────────────────────
  Translate a canonical plate into the bellcrank assembly frame.
  **Behavior:** Apply outside upper_steering_plate(anchor=[1, 1, 1]).
 */
module upper_steering_plate_position() {
  size = upper_steering_plate_size();
  translate([-size[0] / 2,
             -upper_steering_plate_pad_d / 2,
             upper_steering_plate_base_z()]) {
    children();
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  upper_steering_plate
  ─────────────────────────────────────────────────────────────────────────────
  Create the bridge, its mounting cutters, or optional screw placeholders.
  **Parameters:**
  - `anchor`: Reference box anchor; [1, 1, 1] preserves positive XYZ bounds.
  - `slot_mode`: Emit the six through-hole cutters instead of the plate.
  - `slot_h`: Cutter height from local Z=0; undef spans the whole reference box.
  - `show_bolts`: Display six M3-style screws selected from the hole diameter.
  - `bolt_l`: Screw length below the head; default 12 mm.
  - `color`: Body color, or undef for no explicit color.
  **Behavior:** Print top face down using the separate printable entry. The
  narrow rear feet contact stationary posts inside the bearing bores, avoiding
  the rotating housings. This is a fit model, not a strength certification.

  **Example**:
  ```scad
  upper_steering_plate();
  ```
  */
module upper_steering_plate(anchor=[1, 1, 1],
                            slot_mode=false,
                            slot_h=undef,
                            show_bolts=false,
                            bolt_l=12,
                            color=cobalt_blue_light_1) {
  size = upper_steering_plate_size();
  mounts = upper_steering_plate_mounts();
  pad_r = upper_steering_plate_pad_d / 2;
  web = upper_steering_plate_web_w;
  corner_r = upper_steering_plate_window_r;
  thickness = upper_steering_plate_thickness;
  web_z = upper_steering_plate_web_z() - upper_steering_plate_base_z();
  post_r = chassis_bellcrank_spacing / 2;
  holder_r = abs(mounts[4][0]);
  holder_y = mounts[4][1];
  holder_d = front_upper_suspension_holder_steering_bolt_d
             + 2 * front_upper_suspension_holder_steering_mount_pad;
  nose_r = upper_steering_panel_bulkhead_spacing / 2;
  length = mounts[2][1];
  waist_y = length * upper_steering_plate_rear_scallop;
  bolt_d = upper_steering_panel_bolt_d;
  fn = $preview ? 64 : 120;

  assert(thickness > 0 && upper_steering_plate_running_clearance > 0);
  assert(web > 0 && web < 2 * pad_r && corner_r > 0);
  assert(pad_r > bolt_d / 2 && length > 4 * web);
  assert(post_r > nose_r && nose_r > pad_r);
  assert(holder_r >= nose_r && holder_y > pad_r && holder_y < length - pad_r);
  assert(holder_d > front_upper_suspension_holder_steering_bolt_d
         && holder_d <= upper_steering_plate_pad_d,
         "Holder feet must fit within the plate mounting pads");
  assert(web_z > max([for (p = mounts) p[2] - upper_steering_plate_base_z()]));
  assert(upper_steering_plate_rear_scallop > 0
         && upper_steering_plate_rear_scallop < 0.4);
  assert(bellcrank_post_od > bolt_d && upper_steering_panel_boss_od > bolt_d);
  assert(is_undef(slot_h) || (is_num(slot_h) && slot_h > 0));
  assert(bellcrank_post_od < bellcrank_idler_bearing_d,
         "Plate feet must fit inside the bearing bores");

  module pads_2d() {
    for (p = mounts) {
      translate([p[0], p[1]]) {
        circle(r=pad_r, $fn=fn);
      }
    }
  }

  module profile() {
    difference() {
      // Closing the union rounds concave joins between ribs and screw lands.
      offset(delta=-corner_r) {
        offset(r=corner_r, $fn=fn) {
          union() {
            offset(r=web / 2, $fn=fn) {
              polygon([[-post_r, 0], [0, waist_y], [post_r, 0],
                       [holder_r, holder_y], [nose_r, length],
                       [-nose_r, length], [-holder_r, holder_y]]);
            }
            pads_2d();
          }
        }
      }
      difference() {
        for (side = [-1, 1]) {
          scale([side, 1]) {
            offset(r=corner_r, $fn=fn) {
              offset(delta=-corner_r - web / 2) {
                polygon([[0, waist_y], [post_r, 0],
                         [holder_r, holder_y], [nose_r, length], [0, length]]);
              }
            }
          }
        }
        // Keep full circular mounting pads around the screw bores.
        pads_2d();
      }
    }
  }

  module holes(h) {
    for (i = [0:len(mounts) - 1]) {
      p = mounts[i];
      translate([p[0], p[1], -0.01]) {
        cylinder(d=i < 4 ? bolt_d : front_upper_suspension_holder_steering_bolt_d,
                 h=h + 0.02,
                 $fn=fn);
      }
    }
  }

  with_anchor(size=size, anchor=anchor) {
    translate([size[0] / 2, pad_r, 0]) {
      if (slot_mode) {
        holes(is_undef(slot_h) ? size[2] : slot_h);
      } else {
        maybe_color(color) {
          difference() {
            union() {
              translate([0, 0, web_z]) {
                linear_extrude(height=thickness) {
                  profile();
                }
              }
              for (i = [0:len(mounts) - 1]) {
                p = mounts[i];
                start_z = p[2] - upper_steering_plate_base_z();
                translate([p[0], p[1], start_z]) {
                  foot_d = i < 2
                           ? bellcrank_post_od
                           : i < 4
                             ? upper_steering_panel_boss_od
                             : holder_d;
                  cylinder(d=foot_d,
                           h=web_z - start_z + 0.01,
                           $fn=fn);
                }
              }
            }
            holes(size[2]);
          }
        }
        if (show_bolts) {
          for (i = [0:len(mounts) - 1]) {
            p = mounts[i];
            hole_d = i < 4
                     ? bolt_d
                     : front_upper_suspension_holder_steering_bolt_d;
            translate([p[0], p[1], size[2] - bolt_l]) {
              bolt(d=snap_bolt_d(hole_d),
                   h=bolt_l,
                   head_type="socket",
                   threaded=false);
            }
          }
        }
      }
    }
  }
}
