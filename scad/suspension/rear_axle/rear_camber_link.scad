/**
  * Module: Rear camber link with spherical rod-end bushings.
  *
  * Hardware dimensions remain fixed when the link is aimed at mounting points.
  * Mounting-eye axes are parallel to vehicle Y; the spherical bushings account
  * for the angular difference between those axes and the rod-end bodies.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../../lib/plist.scad>
use <../../placeholders/tie_rod_end.scad>
use <../../placeholders/tie_rod_shaft.scad>
use <../knuckle/steering_link.scad>

function _rear_link_value(pl, key) =
  assert(plist_is(pl), "Camber-link settings must be a property list")
  assert(plist_has(key, pl), str("Missing camber-link setting: ", key))
  plist_get(key, pl);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_camber_link_ball_spacing
  ─────────────────────────────────────────────────────────────────────────────
  Return the fixed installed distance between the two spherical bushing centers.
  **Parameters:**
  - `pl`: Rod-end and shaft settings: `rear_camber_link_spec` from
    `scad/suspension/rear_axle/rear_camber_link_params.scad`.
 */
function rear_camber_link_ball_spacing(pl) =
  steering_link_ball_spacing(eye_od=_rear_link_value(pl, "eye_od"),
                             shank_len=_rear_link_value(pl, "shank_len"),
                             center_link_len=_rear_link_value(pl, "center_link_len"));

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_camber_link_frame
  ─────────────────────────────────────────────────────────────────────────────
  Return an orthonormal frame for a camber link aimed between two mount centers.
  **Parameters:**
  - `start`: Inboard mounting-eye center `[x, y, z]`.
  - `end`: Requested outboard mounting-eye center `[x, y, z]`.
  **Returns:** `[along, lateral, eye_normal]`, as three unit vectors.
  The rod runs along `along`; `eye_normal` is the projection of vehicle Y onto
  the plane perpendicular to the rod. A link parallel to Y is rejected.
 */
function rear_camber_link_frame(start, end) =
  let (delta = end - start, distance = norm(delta))
  assert(distance > 0, "Camber-link mounting centers must differ")
  let (along = delta / distance, lateral = cross([0, 1, 0], along))
  assert(norm(lateral) > 0,
         "Camber link cannot run along its mounting-bolt axis")
  let (side = lateral / norm(lateral))
  [along, side, cross(along, side)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_camber_link_fit
  ─────────────────────────────────────────────────────────────────────────────
  Report mounting distance and fixed-hardware endpoint error without scaling.
  **Parameters:**
  - `start`: Inboard mounting-eye center `[x, y, z]`.
  - `end`: Requested outboard mounting-eye center `[x, y, z]`.
  - `pl`: Rod-end and shaft settings: `rear_camber_link_spec` from
    `scad/suspension/rear_axle/rear_camber_link_params.scad`.
  **Returns:** Property list containing required and installed lengths,
  `length_error` (positive means hardware too long), and `hardware_end` vec3.
 */
function rear_camber_link_fit(start, end, pl) =
  let (length = rear_camber_link_ball_spacing(pl),
       frame = rear_camber_link_frame(start, end),
       required = norm(end - start))
  ["required_l", required,
   "hardware_l", length,
   "length_error", length - required,
   "hardware_end", start + frame[0] * length];

module _rear_camber_link_end(pl, direction, bushing_angle) {
  tie_rod_end(eye_od=_rear_link_value(pl, "eye_od"),
              eye_h=_rear_link_value(pl, "eye_h"),
              eye_flat_d=_rear_link_value(pl, "eye_flat_d"),
              bushing_od=_rear_link_value(pl, "bushing_od"),
              bushing_d=_rear_link_value(pl, "bushing_d"),
              bushing_h=_rear_link_value(pl, "bushing_h"),
              bushing_flat_d=_rear_link_value(pl, "bushing_flat_d"),
              bushing_color=_rear_link_value(pl, "bushing_color"),
              color=_rear_link_value(pl, "end_color"),
              shank_od=_rear_link_value(pl, "shank_od"),
              direction=direction,
              shank_len=_rear_link_value(pl, "shank_len"),
              shank_bolt_d=_rear_link_value(pl, "shank_bolt_d"),
              neck_len=_rear_link_value(pl, "neck_len"),
              neck_h=_rear_link_value(pl, "neck_h"),
              fn=_rear_link_value(pl, "end_fn"),
              show_eye_bolt=false,
              show_eye_bolt_nut=false,
              eye_bolt_h=_rear_link_value(pl, "eye_bolt_h"),
              eye_bolt_head_d=_rear_link_value(pl, "eye_bolt_head_d"),
              eye_bolt_through_h=_rear_link_value(pl, "eye_bolt_through_h"),
              eye_bolt_head_type="pan",
              eye_bolt_lock_nut=false,
              eye_bolt_color=_rear_link_value(pl, "eye_bolt_color"),
              eye_head_color=_rear_link_value(pl, "eye_bolt_color"),
              x_angle=0,
              y_angle=0,
              bushing_cap_d=_rear_link_value(pl, "bushing_cap_d"),
              bushing_cap_h=_rear_link_value(pl, "bushing_cap_h"),
              reverse_bolt=false,
              bushing_rotation=[0, bushing_angle, 0],
              center_z=true,
              sync_bushing_rotation=false);
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_camber_link_between
  ─────────────────────────────────────────────────────────────────────────────
  Aim fixed-length steering-link hardware from one camber mount toward another.
  **Parameters:**
  - `start`: Installed inboard spherical-bushing center `[x, y, z]`.
  - `end`: Requested outboard spherical-bushing center `[x, y, z]`.
  - `pl`: Rod-end and shaft settings: `rear_camber_link_spec` from
    `scad/suspension/rear_axle/rear_camber_link_params.scad`.
  **Behavior:** The first eye remains at `start`; the second eye is at the
  `hardware_end` reported by `rear_camber_link_fit()`. Both bushing bores run
  along vehicle Y. A mismatched mount distance does not resize the shaft or ends.

  **Examples:**
  Save this example at the repository root.
  ```scad
  include <scad/suspension/rear_axle/rear_camber_link_params.scad>
  use <scad/suspension/rear_axle/rear_camber_link.scad>
  link_l = rear_camber_link_ball_spacing(rear_camber_link_spec);
  rear_camber_link_between(start=[0, 0, 0], end=[link_l, 0, 0],
                           pl=rear_camber_link_spec);
  ```
 */
module rear_camber_link_between(start, end, pl) {
  frame = rear_camber_link_frame(start, end);
  along = frame[0];
  lateral = frame[1];
  eye_normal = frame[2];
  length = rear_camber_link_ball_spacing(pl);
  bushing_angle = atan2(along[1], eye_normal[1]);
  shank_len = _rear_link_value(pl, "shank_len");
  thread_l = _rear_link_value(pl, "center_link_thread_l");
  shaft_body_l = _rear_link_value(pl, "center_link_len");
  eye_od = _rear_link_value(pl, "eye_od");
  assert(length > 0 && shank_len > thread_l && thread_l > 0);
  assert(shaft_body_l > 2 * _rear_link_value(pl, "center_link_end_len"));
  translate(start) {
    multmatrix([[along[0], lateral[0], eye_normal[0], 0],
                [along[1], lateral[1], eye_normal[1], 0],
                [along[2], lateral[2], eye_normal[2], 0],
                [0, 0, 0, 1]]) {
      _rear_camber_link_end(pl, direction="right", bushing_angle=bushing_angle);
      translate([length, 0, 0]) {
        _rear_camber_link_end(pl,
                              direction="left",
                              bushing_angle=bushing_angle);
      }
      translate([eye_od / 2 + shank_len - thread_l, 0, 0]) {
        rotate([0, 90, 0]) {
          tie_rod_shaft(body_len=shaft_body_l,
                        body_d=_rear_link_value(pl, "center_link_od"),
                        body_end_len=_rear_link_value(pl, "center_link_end_len"),
                        thread_len=thread_l,
                        thread_d=_rear_link_value(pl, "center_link_thread_d"),
                        fn=_rear_link_value(pl, "shaft_fn"),
                        nut_h=_rear_link_value(pl, "shaft_nut_h"),
                        color=_rear_link_value(pl, "center_link_color"),
                        show_nuts=_rear_link_value(pl, "show_shaft_nuts"),
                        show_len=_rear_link_value(pl, "show_shaft_text"),
                        extra_text=_rear_link_value(pl, "shaft_extra_text"),
                        text_color=_rear_link_value(pl, "shaft_text_color"));
        }
      }
    }
  }
}
