/**
  * Module: Front suspension shock mounts and hardware placement.
  *
  * Coordinates use the front assembly frame: +X right, +Y forward, +Z up.
  * Tower positions follow the HSP on-road assembly diagram, page 13.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../rc_params.scad>

use <../lib/functions.scad>
use <../lib/plist.scad>
use <../placeholders/bolt.scad>
use <../placeholders/hsp_shock_absorber.scad>
use <bulkhead/util.scad>
use <front_linkage.scad>
use <wishbone_arms/util.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_shock_mounts
  ─────────────────────────────────────────────────────────────────────────────
  Resolve a shock's mounting faces, aligned eye centers and spacer lengths.
  **Parameters:**
  - `settings`: `front_shock_settings` in `scad/rc_params.scad`.
  - `shock`: `front_shock_spec` in `scad/rc_params.scad`.
  - `side`: -1 left or +1 right.
  - `pose`: `front_linkage_pose()` result, or undef for the unrotated arm.
  **Returns:** Plist containing `faces` and `eyes`, each ordered lower then
  upper, `spacers` in the same order, and `eye_distance` in millimeters.
  **Behavior:** `upper_position` uses the manual's numbering: 1 outer/high,
  3 inner/low. The lower point follows the arm's single modeled boss bore.
 */
function front_shock_mounts(settings, shock, side, pose=undef) =
  assert(side == -1 || side == 1, "Front shock side must be -1 or 1")
  assert(is_undef(pose) || plist_get("side", pose) == side,
         "Shock side must match the linkage pose")
  let (position = plist_get("upper_position", settings),
       count = front_shock_tower_damper_holes_amount)
  assert(position >= 1 && position <= count && position == floor(position),
         "Front shock upper position must select a numbered tower hole")
  let (holes = front_shock_damper_holes_poses(),
       hole = holes[count - position],
       lower_y = lower_damper_hole_y_pos(front_shock_tower_damper_holes_angle, count, front_shock_tower_h,
                                         front_shock_tower_shock_damper_bolt_d, front_shock_tower_damper_holes_gap,
                                         front_shock_tower_damper_holes_pad_x, front_shock_tower_damper_holes_pad_y),
       upper_face = [front_shock_tower_damper_spacing_x / 2 - hole[0],
                     front_bulkhead_len / 2
                     + front_bulkhead_shock_tower_mount_thickness / 2
                     + front_shock_tower_thickness,
                     front_bulkhead_housing_h + front_bulkhead_shock_tower_mount_offset
                     + lower_y + front_shock_tower_damper_holes_pad_y + hole[1]],
       datums = is_undef(pose) ? front_linkage_datums() : plist_get("datums", pose),
       arm = plist_get("lower", datums),
       hinge = plist_get("hinge", arm),
       angle = is_undef(pose) ? 0 : plist_get("lower_angle", pose),
       lower_face = hinge + rotY(plist_get("origin", arm)
                                 + front_lower_arm_shock_mount() - hinge, angle),
       faces = [for (p = [lower_face, upper_face]) [side * p[0], p[1], p[2]]],
       gap = plist_get("mount_gap", settings),
       eye_w = plist_get("eye_w", shock),
       eye_y = max(lower_face[1], upper_face[1]) + gap + eye_w / 2,
       eyes = [for (p = faces) [p[0], eye_y, p[2]]],
       spacers = [for (p = faces) eye_y - eye_w / 2 - p[1]])
  assert(gap >= 0 && eye_w > 0, "Shock mounting gap and eye width are invalid")
  ["faces", faces,
   "eyes", eyes,
   "spacers", spacers,
   "eye_distance", norm(eyes[1] - eyes[0])];

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_shock_mount_hardware
  ─────────────────────────────────────────────────────────────────────────────
  Show the spacers, lower boss screw and upper through-bolt with retaining nut.
  **Parameters:**
  - `mounts`: `front_shock_mounts()` result in the front assembly frame.
  - `settings`: `front_shock_settings` in `scad/rc_params.scad`.
  - `shock`: `front_shock_spec` in `scad/rc_params.scad`.
 */
module front_shock_mount_hardware(mounts, settings, shock) {
  faces = plist_get("faces", mounts);
  spacers = plist_get("spacers", mounts);
  eye_w = plist_get("eye_w", shock);
  d = plist_get("bolt_d", settings);
  epsilon = plist_get("csg_epsilon", settings);
  hardware_color = plist_get("hardware_color", settings);
  nut_h = plist_get("nut_h", settings);
  $fn = plist_get("fn", settings);
  assert(d <= front_lower_arm_damper_boss_hole_d
         && d <= front_shock_tower_shock_damper_bolt_d
         && d <= plist_get("eye_bore_d", shock));
  for (i = [0:1]) {
    engagement = i == 0
                 ? plist_get("lower_engagement", settings)
                 : front_shock_tower_thickness + nut_h
                   + plist_get("thread_projection", settings);
    assert(engagement > 0);
    if (spacers[i] > 0) {
      color(hardware_color) {
        translate(faces[i]) {
          rotate([-90, 0, 0]) {
            difference() {
              cylinder(d=plist_get("spacer_d", settings), h=spacers[i]);
              translate([0, 0, -epsilon]) {
                cylinder(d=d, h=spacers[i] + 2 * epsilon);
              }
            }
          }
        }
      }
    }
    translate(faces[i] - [0, engagement, 0]) {
      rotate([-90, 0, 0]) {
        bolt(d=d,
             h=engagement + spacers[i] + eye_w,
             head_type="socket",
             head_d=plist_get("head_d", settings),
             head_h=plist_get("head_h", settings),
             threaded=false,
             thread_depth=0,
             thread_clearance=0,
             show_nut=false,
             bolt_color=hardware_color,
             head_color=hardware_color,
             anchor=[0, 0, 1],
             $fn=plist_get("fn", settings));
      }
    }
    if (i == 1) {
      color(hardware_color) {
        translate(faces[i] - [0, front_shock_tower_thickness + nut_h, 0]) {
          rotate([-90, 0, 0]) {
            difference() {
              cylinder(d=plist_get("nut_af", settings) / cos(30),
                       h=nut_h,
                       $fn=6);
              translate([0, 0, -epsilon]) {
                cylinder(d=d, h=nut_h + 2 * epsilon);
              }
            }
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_suspension_shock
  ─────────────────────────────────────────────────────────────────────────────
  Place one front shock and its optional mounting hardware.
  **Parameters:**
  - `settings`: `front_shock_settings` in `scad/rc_params.scad`; controls upper
    position, face gap, spring/hardware visibility and strict travel checking.
  - `shock`: `front_shock_spec` in `scad/rc_params.scad`.
  - `side`: -1 left or +1 right.
  - `pose`: `front_linkage_pose()` result, or undef for the unrotated arm.
 */
module front_suspension_shock(settings, shock, side, pose=undef) {
  mounts = front_shock_mounts(settings, shock, side, pose);
  eyes = plist_get("eyes", mounts);
  hsp_shock_between(start=eyes[0],
                    end=eyes[1],
                    pl=shock,
                    show_spring=plist_get("show_spring", settings),
                    require_travel=plist_get("require_travel", settings));
  if (plist_get("show_fasteners", settings)) {
    front_shock_mount_hardware(mounts, settings, shock);
  }
}
