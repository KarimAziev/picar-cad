/**
  * Module: Rear lower suspension arm.
  *
  * The inner fork is at minimum X, the hub fork at maximum X. The inner hinge
  * axis runs along Y; the two outer M5 ball-stud pilot bores run along X. All solid bounds start at zero; mounting cutouts and
  * optional pins share the same anchor reference.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

use <../../lib/plist.scad>
use <../../lib/transforms.scad>
use <../../placeholders/ball_stud.scad>
use <../../placeholders/suspension_arm_pin.scad>

function _rear_arm_value(pl, key) =
  assert(plist_is(pl), "rear_lower_arm requires a complete property list")
  assert(plist_has(key, pl), str("rear_lower_arm missing property: ", key))
  plist_get(key, pl);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_lower_arm_size
  ─────────────────────────────────────────────────────────────────────────────
  Return the solid reference bounds as `[X width, Y length, Z height]`.
  **Parameters:**
  - `pl`: Complete arm property list, such as `rear_lower_arm_spec`.
 */
function rear_lower_arm_size(pl) =
  [_rear_arm_value(pl, "w"), _rear_arm_value(pl, "inner_span"),
   _rear_arm_value(pl, "h")];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_lower_arm_inner_pivot
  ─────────────────────────────────────────────────────────────────────────────
  Return the inner hinge center `[x, y, z]`; its axis is parallel to Y.
  **Parameters:**
  - `pl`: Complete arm property list.
 */
function rear_lower_arm_inner_pivot(pl) =
  [_rear_arm_value(pl, "hinge_d") / 2,
   _rear_arm_value(pl, "inner_span") / 2, _rear_arm_value(pl, "h") / 2];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_lower_arm_outer_pivot
  ─────────────────────────────────────────────────────────────────────────────
  Return the midpoint of the two installed lower ball centers `[x, y, z]`.
  This point lies beyond the printable arm envelope by `ball_projection`.
  **Parameters:**
  - `pl`: Complete arm property list.
 */
function rear_lower_arm_outer_pivot(pl) =
  [_rear_arm_value(pl, "w") + _rear_arm_value(pl, "ball_projection"),
   _rear_arm_value(pl, "inner_span") / 2, _rear_arm_value(pl, "h") / 2];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_lower_arm_ball_positions
  ─────────────────────────────────────────────────────────────────────────────
  Return the paired lower ball centers, ordered from minimum to maximum Y.
  **Parameters:**
  - `pl`: Complete arm property list.
 */
function rear_lower_arm_ball_positions(pl) =
  let (p = rear_lower_arm_outer_pivot(pl))
  [for (side = [-1, 1])
    p + [0, side * _rear_arm_value(pl, "outer_bolt_spacing") / 2, 0]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_lower_arm_shock_positions
  ─────────────────────────────────────────────────────────────────────────────
  Return front and rear shock boss centers; each bore axis is parallel to Y.
  **Parameters:**
  - `pl`: Complete arm property list.
  **Returns:**
  Two `[x, y, z]` points ordered from minimum Y to maximum Y. They describe
  opposite sides of the arm, not two radial motion-ratio adjustment positions.
 */
function rear_lower_arm_shock_positions(pl) =
  let (s = rear_lower_arm_size(pl),
       span = _rear_arm_value(pl, "shoulder_span"),
       rail = (_rear_arm_value(pl, "outer_span")
               - _rear_arm_value(pl, "outer_gap")) / 2)
  [for (side = [-1, 1])
    [_rear_arm_value(pl, "shock_x"),
     s[1] / 2 + side * (span - rail) / 2, s[2] / 2]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_lower_arm
  ─────────────────────────────────────────────────────────────────────────────
  Create a ribbed lower arm with an inner pin fork and outer ball-stud mounts.
  Outer pilot bores are sized for tapping M5; they do not contain threads.
  **Parameters:**
  - `pl`: Complete dimensional and rendering property list. See
    `rear_lower_arm_spec` in scad/suspension/rear_axle/arm_hub_params.scad.
  - `anchor`: Reference-box anchor, default `[1, 1, 1]`.
  - `slot_mode`: Emit hinge and shock bores instead of printable material.
  - `show_pins`: Include the metal inner hinge pin and retaining clips.
  - `show_ball_studs`: Include the two metal M5 lower ball studs.
 */
module rear_lower_arm(pl,
                      anchor=[1, 1, 1],
                      slot_mode=false,
                      show_pins=false,
                      show_ball_studs=false) {
  s = rear_lower_arm_size(pl);
  root = rear_lower_arm_inner_pivot(pl);
  tip = [s[0], s[1] / 2, s[2] / 2];
  hinge_d = _rear_arm_value(pl, "hinge_d");
  inner_gap = _rear_arm_value(pl, "inner_gap");
  outer_span = _rear_arm_value(pl, "outer_span");
  outer_gap = _rear_arm_value(pl, "outer_gap");
  shoulder_span = _rear_arm_value(pl, "shoulder_span");
  shoulder_x = _rear_arm_value(pl, "shoulder_x");

  root_depth = _rear_arm_value(pl, "inner_fork_depth");
  tip_depth = _rear_arm_value(pl, "outer_fork_depth");
  rib = _rear_arm_value(pl, "rib_w");
  corner = _rear_arm_value(pl, "window_corner_r");
  pin_d = _rear_arm_value(pl, "pin_d");
  clearance = _rear_arm_value(pl, "pin_d_clearance");
  shock_d = _rear_arm_value(pl, "shock_boss_d");
  shock_bolt_d = _rear_arm_value(pl, "shock_bolt_d");
  eps = _rear_arm_value(pl, "cut_eps");
  fn = _rear_arm_value(pl, "fn");
  outer_y = (s[1] - outer_span) / 2;
  shoulder_y = (s[1] - shoulder_span) / 2;
  rail = (outer_span - outer_gap) / 2;
  window_x0 = root_depth + rib;
  window_x1 = shoulder_x - shock_d / 2;
  window_mid = [(window_x0 + window_x1) / 2, s[1] / 2];
  window_corners = [[window_x0, rib],
                    [window_x1, shoulder_y + rib],
                    [window_x1, s[1] - shoulder_y - rib],
                    [window_x0, s[1] - rib]];
  assert(s[0] > 0 && s[1] > 0 && s[2] > 0);
  assert(hinge_d == s[2], "hinge diameter must equal arm height");
  assert(pin_d > 0 && clearance >= 0 && hinge_d > pin_d + clearance);
  assert(inner_gap > 0 && inner_gap < s[1]);
  assert(outer_gap > 0 && outer_gap < outer_span);
  assert(outer_span <= shoulder_span && shoulder_span <= s[1]);
  assert(root_depth > hinge_d && tip_depth > hinge_d);
  assert(window_x1 - window_x0 > 2 * rib && rib > 2 * corner);
  assert(shoulder_x + shock_d / 2 <= s[0] - tip_depth);
  assert(shock_d <= s[2] && shock_d > shock_bolt_d + clearance);
  assert(_rear_arm_value(pl, "shock_x") + (shock_bolt_d + clearance) / 2
         < s[0] - _rear_arm_value(pl, "ball_pilot_depth"),
         "shock bolt bore must not intersect ball-stud pilot bores");
  assert(eps > 0 && fn >= 16);

  module y_bore(p, d, l) {
    translate(p - [0, l / 2, 0]) {
      rotate([-90, 0, 0]) {
        cylinder(d=d, h=l, $fn=fn);
      }
    }
  }

  module bores() {
    y_bore(root, pin_d + clearance, s[1] + 2 * eps);
    for (p = rear_lower_arm_ball_positions(pl)) {
      translate([s[0] - _rear_arm_value(pl, "ball_pilot_depth"), p[1], p[2]]) {
        rotate([0, 90, 0]) {
          cylinder(d=_rear_arm_value(pl, "ball_pilot_d"),
                   h=_rear_arm_value(pl, "ball_pilot_depth") + eps,
                   $fn=fn);
        }
      }
    }
    y_bore([_rear_arm_value(pl, "shock_x"), s[1] / 2, s[2] / 2],
           shock_bolt_d + clearance,
           s[1] + 2 * eps);
  }

  module blank() {
    linear_extrude(height=s[2]) {
      polygon([[root[0], 0], [root_depth, 0],
               [shoulder_x, shoulder_y],
               [s[0] - tip_depth, outer_y], [tip[0], outer_y],
               [tip[0], s[1] - outer_y],
               [s[0] - tip_depth, s[1] - outer_y],
               [shoulder_x, s[1] - shoulder_y],
               [root_depth, s[1]], [root[0], s[1]]]);
    }
    y_bore(root, hinge_d, s[1]);
    for (p = rear_lower_arm_shock_positions(pl)) {
      y_bore(p, shock_d, rail);
    }
  }

  with_anchor(size=s, anchor=anchor) {
    if (slot_mode) {
      bores();
    } else {
      color(_rear_arm_value(pl, "body_color")) {
        difference() {
          blank();
          bores();
          translate([-eps, (s[1] - inner_gap) / 2, -eps]) {
            cube([root_depth + eps, inner_gap, s[2] + 2 * eps]);
          }
          translate([s[0] - tip_depth, (s[1] - outer_gap) / 2, -eps]) {
            cube([tip_depth + eps, outer_gap, s[2] + 2 * eps]);
          }
          translate([0, 0, -eps]) {
            linear_extrude(height=s[2] + 2 * eps) {
              for (i = [0:len(window_corners) - 1]) {
                offset(r=corner, $fn=fn) {
                  offset(delta=-rib / 2 - corner) {
                    polygon([window_corners[i],
                             window_corners[(i + 1) % len(window_corners)],
                             window_mid]);
                  }
                }
              }
            }
          }
        }
      }
      if (show_ball_studs) {
        shank_d = _rear_arm_value(pl, "ball_shank_d");
        ball_d = _rear_arm_value(pl, "ball_d");
        shank_l = _rear_arm_value(pl, "ball_shank_l");
        ball_z = ball_stud_center_z(shank_d, ball_d, shank_l);
        for (p = rear_lower_arm_ball_positions(pl)) {
          translate(p - [ball_z, 0, 0]) {
            rotate([0, 90, 0]) {
              ball_stud(d=shank_d,
                        h=shank_l,
                        ball_d=ball_d,
                        unthreaded_len=_rear_arm_value(pl, "ball_unthreaded_l"),
                        ball_hole_d=_rear_arm_value(pl, "ball_hex_d"),
                        ball_hole_depth=_rear_arm_value(pl, "ball_hex_depth"),
                        ball_fn=fn,
                        fn=fn,
                        color=_rear_arm_value(pl, "pin_color"));
            }
          }
        }
      }
      if (show_pins) {
        overhang = _rear_arm_value(pl, "pin_end_overhang");
        for (p = [root]) {
          l = s[1] + 2 * overhang;
          translate(p - [0, l / 2, 0]) {
            rotate([-90, 0, 0]) {
              suspension_arm_pin(d=pin_d,
                                 l=l,
                                 fn=fn,
                                 color=_rear_arm_value(pl, "pin_color"),
                                 show_e_clip=true,
                                 e_clip_thickness=_rear_arm_value(pl, "clip_thickness"),
                                 groove_d=_rear_arm_value(pl, "pin_groove_d"),
                                 groove_side="all",
                                 pad_side="all",
                                 pad_horizontal_one_side=false,
                                 pad_l=0,
                                 pad_w=0,
                                 groove_w=_rear_arm_value(pl, "pin_groove_w"),
                                 groove_offset=_rear_arm_value(pl, "pin_groove_offset"));
            }
          }
        }
      }
    }
  }
}
