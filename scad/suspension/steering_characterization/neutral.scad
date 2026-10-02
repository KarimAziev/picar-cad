/**
  * Module: Steering neutral-closure inspection.
  *
  * Cyan marks mounting-hole axes, orange marks displayed rod centers.
  * Magenta lines expose top-view mismatch without assuming ball stack height.
  * This is an audit overlay, not an animated or corrected mechanism.
  */
include <../../rc_params.scad>
use <../../lib/plist.scad>
use <datums.scad>
use <../front_suspension_assembly.scad>
use <../bellcrank_steering_assembly.scad>

show_components = true;
show_datums = true;
marker_d = 1.5;
axis_h = 12;

/**
  ─────────────────────────────────────────────────────────────────────────────
  steering_neutral_inspection
  ─────────────────────────────────────────────────────────────────────────────

  Overlay neutral hole axes and displayed ball centers on the existing mechanism.

  **Parameters:**
  - `show_components`: Display production suspension and steering components.
  - `show_datums`: Display audit markers and endpoint-to-axis discrepancy lines.
  - `marker_d`: Display-only marker diameter, in mm.
  - `axis_h`: Display-only axis-marker length, in mm.
 */
module steering_neutral_inspection(show_components=show_components,
                                    show_datums=show_datums,
                                    marker_d=marker_d, axis_h=axis_h) {
  data = steering_audit_datums();
  module point(p, col) {
    color(col) {
      translate(p) {
        sphere(d=marker_d, $fn=24);
      }
    }
  }
  module segment(a, b, col) {
    color(col) {
      hull() {
        point(a, col);
        point(b, col);
      }
    }
  }
  if (show_components) {
    translate([0, bellcrank_y_distance_from_bulkhead, 0]) {
      front_suspension_assembly();
    }
    bellcrank_steering_assembly();
  }
  if (show_datums) {
    for (key = ["center_mounts", "outer_mounts", "servo_lever_holes"]) {
      for (p = plist_get(key, data)) {
        segment(p - [0, 0, axis_h / 2], p + [0, 0, axis_h / 2], "cyan");
      }
    }
    for (holes = plist_get("knuckle_holes", data), p = holes) {
      segment(p - [0, 0, axis_h / 2], p + [0, 0, axis_h / 2], "cyan");
    }
    for (i = [0:1]) {
      a = plist_get("wheel_rod_a", data)[i];
      b = plist_get("wheel_rod_b", data)[i];
      target = plist_get("outer_mounts", data)[i];
      segment(a, b, "orange");
      segment(b, [target[0], target[1], b[2]], "magenta");
      point(a, "orange");
      point(b, "orange");
    }
    segment(plist_get("servo_rod_a", data), plist_get("servo_rod_b", data), "orange");
    for (p = plist_get("center_plate_holes", data)) {
      point(p, "orange");
    }
  }
}

steering_neutral_inspection();
