/**
  * Module: Reference-pose RC chassis measurements and preview annotations.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../colors.scad>
include <../rc_params.scad>
include <front_chassis/computed_params.scad>

use <../lib/plist.scad>
use <../placeholders/rc_touring_wheel.scad>
use <computed.scad>
use <front_chassis/front_frame_util.scad>
use <front_bumper/common.scad>
use <rc_wheels.scad>
use <rear_chassis/computed_params.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  chassis_dimensions
  ─────────────────────────────────────────────────────────────────────────────
  Compute nominal dimensions in the assembled, unsteered reference pose.
  **Parameters:**
  - `layout`: Rear equipment and suspension layout.
  - `bumper_top_plate`: Include the rigid bumper plate in overall bounds.
  - `bumper_foam`: Include the TPU bumper in overall bounds.
  - `bumper_pl`: Bumper dimension overrides; see `front_bumper_params`.
  **Returns:** A plist of millimeter measurements and their vehicle datums.
  **Behavior:** Rear axle locations use the rear-wheel preview settings. Ground
  is the lower upright tire tangent; clearance is to the flat chassis underside.
  Overall bounds include the deck, upright tires and selected bumper parts.
  Chassis-only bounds include the head-frame extension. Elevated payloads,
  other accessories, exploded spacing and articulated poses are excluded.
 */
function chassis_dimensions(layout=rear_chassis_layout(
                              min_width=suspension_chassis_width()),
                            bumper_top_plate=false,
                            bumper_foam=false,
                            bumper_pl=front_bumper_plist) =
  let (front = rc_front_wheel_reference_center()
               + [0, 0, suspension_chassis_mount_h],
       rear = rc_rear_wheel_reference_center(layout),
       rear_y = front_chassis_y_joint_2_end + plist_get("min_y", layout) - rear[1],
       wheel = rc_touring_wheel_spec(rc_wheel_plist),
       radius = plist_get("tire_d", wheel) / 2,
       tire_w = plist_get("width", wheel),
       bounds = front_chassis_front_frame_bounds(),
       chassis_front = bounds[1][1],
       chassis_rear = front_chassis_y_joint_2_end
                      + plist_get("min_y", layout) - plist_get("max_y", layout),
       chassis_w = max(bounds[1][0] * 2, plist_get("size", layout)[0]),
       ground = min(front[2], rear[2]) - radius,
       bumper_parts = concat(bumper_top_plate ? ["plate"] : [],
                             bumper_foam ? ["foam"] : []),
       bumper_fronts = [for (part = bumper_parts)
         front_bumper_position(bumper_pl, part)[1]
         + front_bumper_size(bumper_pl, part)[1]],
       bumper_widths = [for (part = bumper_parts)
         front_bumper_size(bumper_pl, part)[0]],
       front_y = max(concat([chassis_front, front[1] + radius], bumper_fronts)),
       back_y = min(chassis_rear, rear_y - radius),
       overall_w = max(concat([chassis_w, 2 * front[0] + tire_w,
                               2 * rear[0] + tire_w], bumper_widths)))
  ["wheelbase", front[1] - rear_y,
   "front_track", 2 * front[0],
   "rear_track", 2 * rear[0],
   "ground_clearance", -ground,
   "ground_z", ground,
   "chassis_width", chassis_w,
   "chassis_length", chassis_front - chassis_rear,
   "overall_length", front_y - back_y,
   "overall_width", overall_w,
   "front_axle_y", front[1],
   "rear_axle_y", rear_y,
   "front_y", front_y,
   "rear_y", back_y,
   "chassis_front_y", chassis_front,
   "chassis_rear_y", chassis_rear];

// A planar dimension along local X, with end ticks and a centered label.
module _chassis_dimension_line(length, label, text_size) {
  linear_extrude(height=0.3) {
    translate([0, -0.25]) {
      square([length, 0.5]);
    }
    for (x = [0, length]) {
      translate([x - 0.25, -2]) {
        square([0.5, 4]);
      }
    }
    translate([length / 2, 2]) {
      text(str(label, ": ", round(length * 10) / 10, " mm"),
           size=text_size,
           halign="center");
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  chassis_dimension_annotations
  ─────────────────────────────────────────────────────────────────────────────
  Show preview-only dimensions around the assembled reference envelope.
  **Parameters:**
  - `wheelbase`: Axle-to-axle distance using the estimated rear axle.
  - `track`: Front and rear tire-center spacing.
  - `clearance`: Nominal upright-tire ground plane to chassis underside.
  - `length`: Overall deck/tire/selected-bumper length and chassis-only length.
  - `width`: Maximum chassis width and overall envelope width.
  - `text_size`: Label size in millimeters.
  - `color`: Color for the borders and text.
  - `bumper_top_plate`: Include the rigid bumper plate in overall bounds.
  - `bumper_foam`: Include the TPU bumper in overall bounds.
  - `bumper_pl`: Bumper dimension overrides; see `front_bumper_params`.
  **Behavior:** Top-view labels lie above the chassis; clearance is read from
  the right side. Annotations never enter STL or 3MF geometry exports.
 */
module chassis_dimension_annotations(wheelbase=false,
                                     track=false,
                                     clearance=false,
                                     length=false,
                                     width=false,
                                     text_size=6,
                                     color=green_4,
                                     bumper_top_plate=false,
                                     bumper_foam=false,
                                     bumper_pl=front_bumper_plist) {
  d = chassis_dimensions(bumper_top_plate=bumper_top_plate,
                         bumper_foam=bumper_foam,
                         bumper_pl=bumper_pl);
  envelope = bumper_top_plate || bumper_foam
    ? "deck/tires/bumper"
    : "deck/tires";
  half_w = plist_get("overall_width", d) / 2;
  z = chassis_thickness + 2;
  front_y = plist_get("front_y", d);
  rear_y = plist_get("rear_y", d);
  if ($preview) {
    %color(color) {
      if (wheelbase) {
        translate([half_w + 15, plist_get("rear_axle_y", d), z]) {
          rotate([0, 0, 90]) {
            _chassis_dimension_line(plist_get("wheelbase", d),
                                    "Wheelbase (rear preview)",
                                    text_size);
          }
        }
      }
      if (track) {
        for (axle = ["front", "rear"]) {
          span = plist_get(str(axle, "_track"), d);
          axle_y = plist_get(str(axle, "_axle_y"), d);
          label_y = axle == "front" ? front_y + 45 : rear_y - 15;
          translate([-span / 2, label_y, z]) {
            _chassis_dimension_line(span,
                                    str(axle, " track (ref.)"),
                                    text_size);
          }
          for (side = [-1, 1]) {
            translate([side * span / 2 - 0.15, min(axle_y, label_y), z]) {
              cube([0.3, abs(label_y - axle_y), 0.3]);
            }
          }
        }
      }
      if (length) {
        translate([-half_w - 15, rear_y, z]) {
          rotate([0, 0, 90]) {
            _chassis_dimension_line(plist_get("overall_length", d),
                                    str("Overall length (", envelope, ")"),
                                    text_size);
          }
        }
        translate([-half_w - 30, plist_get("chassis_rear_y", d), z]) {
          rotate([0, 0, 90]) {
            _chassis_dimension_line(plist_get("chassis_length", d),
                                    "Chassis length",
                                    text_size);
          }
        }
      }
      if (width) {
        for (i = [0:1]) {
          key = i == 0 ? "chassis_width" : "overall_width";
          span = plist_get(key, d);
          translate([-span / 2, front_y + 15 + i * 15, z]) {
            _chassis_dimension_line(span,
                                    i == 0
                                      ? "Chassis width"
                                      : str("Overall width (", envelope, ")"),
                                    text_size);
          }
        }
      }
      if (clearance) {
        translate([half_w + 30,
                   (front_y + rear_y) / 2,
                   plist_get("ground_z", d)]) {
          rotate([90, 0, 90]) {
            h = plist_get("ground_clearance", d);
            linear_extrude(height=0.3) {
              square([0.5, h]);
              for (end = [0, h]) {
                translate([-2, end - 0.25]) {
                  square([4, 0.5]);
                }
              }
              translate([4, h / 2]) {
                text(str("Chassis clearance (nominal): ",
                         round(h * 10) / 10, " mm"),
                     size=text_size,
                     valign="center");
              }
            }
          }
        }
        translate([-half_w, rear_y, plist_get("ground_z", d)]) {
          difference() {
            cube([2 * half_w, front_y - rear_y, 0.1]);
            translate([0.4, 0.4, -0.1]) {
              cube([2 * half_w - 0.8, front_y - rear_y - 0.8, 0.3]);
            }
          }
        }
      }
    }
  }
}
