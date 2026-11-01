
/**
  * Module: Rear wheel hub with paired lower ball sockets.
  *
  * The axle runs along X, with its larger bearing at minimum X. The lower
  * sockets open toward maximum X and share a Y-directed pivot line. Their
  * ball studs enter through minimum X. Positive Z points toward the camber
  * link. Dimensions describe a configurable design, not a measured HSP mold.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../../lib/plist.scad>
use <../../lib/threading/threads.scad>
use <../../lib/transforms.scad>

function _rear_hub_value(pl, key) =
  assert(plist_is(pl), "rear_hub requires a complete property list")
  assert(plist_has(key, pl), str("rear_hub missing property: ", key))
  plist_get(key, pl);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_hub_size
  ─────────────────────────────────────────────────────────────────────────────
  Return the hub's `[X width, Y length, Z height]` reference box.
  **Parameters:**
  - `pl`: Hub dimensions and display settings: `rear_hub_spec` from
    `scad/suspension/rear_axle/arm_hub_params.scad`.
 */
function rear_hub_size(pl) =
  [_rear_hub_value(pl, "socket_l"),
   _rear_hub_value(pl, "ball_spacing") + _rear_hub_value(pl, "socket_d"),
   _rear_hub_value(pl, "socket_d") / 2
   + _rear_hub_value(pl, "link_pivot_height")
   + _rear_hub_value(pl, "link_boss_d") / 2];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_hub_bearing_wall
  ─────────────────────────────────────────────────────────────────────────────
  Return the minimum radial wall around the larger bearing seat.
  **Parameters:**
  - `pl`: Hub dimensions and display settings: `rear_hub_spec` from
    `scad/suspension/rear_axle/arm_hub_params.scad`.
  **Returns:**
  Half the difference between the measured housing diameter and the larger
  bearing outside diameter including its diametral seat clearance.
 */
function rear_hub_bearing_wall(pl) =
  (_rear_hub_value(pl, "bearing_housing_d")
   - max(_rear_hub_value(pl, "inner_bearing_od"),
         _rear_hub_value(pl, "outer_bearing_od"))
   - _rear_hub_value(pl, "bearing_d_clearance")) / 2;

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_hub_pivot
  ─────────────────────────────────────────────────────────────────────────────
  Return the midpoint of the two lower ball centers `[x, y, z]`.
  **Parameters:**
  - `pl`: Hub dimensions and display settings: `rear_hub_spec` from
    `scad/suspension/rear_axle/arm_hub_params.scad`.
 */
function rear_hub_pivot(pl) =
  [_rear_hub_value(pl, "ball_x"), rear_hub_size(pl)[1] / 2,
   _rear_hub_value(pl, "socket_d") / 2];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_hub_ball_positions
  ─────────────────────────────────────────────────────────────────────────────
  Return the two lower ball centers, ordered from minimum to maximum Y.
  **Parameters:**
  - `pl`: Hub dimensions and display settings: `rear_hub_spec` from
    `scad/suspension/rear_axle/arm_hub_params.scad`.
 */
function rear_hub_ball_positions(pl) =
  [for (side = [-1, 1])
    rear_hub_pivot(pl) + [0, side * _rear_hub_value(pl, "ball_spacing") / 2, 0]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_hub_axle
  ─────────────────────────────────────────────────────────────────────────────
  Return the axle axis at the bearing stack's X midpoint `[x, y, z]`.
  **Parameters:**
  - `pl`: Hub dimensions and display settings: `rear_hub_spec` from
    `scad/suspension/rear_axle/arm_hub_params.scad`.
  The inner bearing occupies X=0..`inner_bearing_w`; the outer bearing occupies
  X=`inner_bearing_w+bearing_separation` through one outer bearing width.
  This point is not a dogbone cup center.
 */
function rear_hub_axle(pl) =
  let (s = rear_hub_size(pl))
  [(_rear_hub_value(pl, "inner_bearing_w")
    + _rear_hub_value(pl, "bearing_separation")
    + _rear_hub_value(pl, "outer_bearing_w")) / 2,
   s[1] / 2, rear_hub_pivot(pl)[2] + _rear_hub_value(pl, "axle_pivot_height")];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_hub_bearing_positions
  ─────────────────────────────────────────────────────────────────────────────
  Return minimum-X face centers of the inner and outer bearings.
  **Parameters:**
  - `pl`: Hub dimensions and display settings: `rear_hub_spec` from
    `scad/suspension/rear_axle/arm_hub_params.scad`.
 */
function rear_hub_bearing_positions(pl) =
  let (p = rear_hub_axle(pl))
  [[0, p[1], p[2]],
   [_rear_hub_value(pl, "inner_bearing_w")
    + _rear_hub_value(pl, "bearing_separation"), p[1], p[2]]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_hub_link
  ─────────────────────────────────────────────────────────────────────────────
  Return the upper camber-link eye center `[x, y, z]`, with its bore along Y.
  **Parameters:**
  - `pl`: Hub dimensions and display settings: `rear_hub_spec` from
    `scad/suspension/rear_axle/arm_hub_params.scad`.
 */
function rear_hub_link(pl) =
  let (s = rear_hub_size(pl))
  [s[0] / 2 - _rear_hub_value(pl, "link_inboard_offset"),
   s[1] / 2, rear_hub_pivot(pl)[2] + _rear_hub_value(pl, "link_pivot_height")];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_hub_socket_plug
  ─────────────────────────────────────────────────────────────────────────────
  Create one socket retention plug, oriented for printing along positive Z.
  **Parameters:**
  - `pl`: Hub dimensions and display settings: `rear_hub_spec` from
    `scad/suspension/rear_axle/arm_hub_params.scad`.
  The origin is the center of the plug's outer end face. The thread follows
  the repository metric thread helper; the specified plug diameter is M10.
 */
module rear_hub_socket_plug(pl) {
  eps = _rear_hub_value(pl, "cut_eps");
  l = _rear_hub_value(pl, "socket_plug_l");
  hex_d = (_rear_hub_value(pl, "socket_plug_hex_d")
           + _rear_hub_value(pl, "socket_hex_clearance")) / cos(30);
  color(_rear_hub_value(pl, "body_color")) {
    difference() {
      screw_thread(od=_rear_hub_value(pl, "socket_plug_d"),
                   height=l,
                   pitch=_rear_hub_value(pl, "socket_thread_pitch"),
                   tooth_angle=_rear_hub_value(pl, "socket_thread_angle"),
                   tolerance=_rear_hub_value(pl, "socket_thread_tolerance"),
                   tip_height=_rear_hub_value(pl, "socket_plug_tip_h"),
                   tooth_height=_rear_hub_value(pl, "socket_thread_tooth_h"),
                   tip_min_fract=_rear_hub_value(pl, "socket_plug_tip_fraction"));
      translate([0, 0, -eps]) {
        cylinder(d=hex_d, h=l + 2 * eps, $fn=6);
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_hub_socket_bushing
  ─────────────────────────────────────────────────────────────────────────────
  Create a ball-seat bushing with its flat base at Z=0 and bowl facing up.
  **Parameters:**
  - `pl`: Hub dimensions and display settings: `rear_hub_spec` from
    `scad/suspension/rear_axle/arm_hub_params.scad`.
 */
module rear_hub_socket_bushing(pl) {
  s = rear_hub_size(pl);
  l = _rear_hub_value(pl, "bushing_l");
  plug_x = s[0] - _rear_hub_value(pl, "socket_plug_l");
  ball_z = plug_x - _rear_hub_value(pl, "ball_x");
  eps = _rear_hub_value(pl, "cut_eps");
  fn = _rear_hub_value(pl, "fn");
  color(_rear_hub_value(pl, "bushing_color")) {
    difference() {
      cylinder(d=_rear_hub_value(pl, "bushing_d"), h=l, $fn=fn);
      translate([0, 0, ball_z]) {
        sphere(d=_rear_hub_value(pl, "ball_d")
                 + _rear_hub_value(pl, "ball_clearance"),
               $fn=fn);
      }
      translate([0, 0, -eps]) {
        cylinder(d=_rear_hub_value(pl, "bushing_hole_d"),
                 h=l + 2 * eps,
                 $fn=fn);
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_hub
  ─────────────────────────────────────────────────────────────────────────────
  Create a rear hub with unequal bearing seats and two retained ball sockets.
  **Parameters:**
  - `pl`: Hub dimensions and display settings: `rear_hub_spec` from
    `scad/suspension/rear_axle/arm_hub_params.scad`.
  - `anchor`: Reference-box anchor, default `[1, 1, 1]`.
  - `slot_mode`: Emit bearing seats, socket cavities and camber-link bore.
  - `show_bearings`: Display the inner and outer metal bearing envelopes.
  - `show_socket_hardware`: Display the removable bushings and threaded plugs.

  **Examples:**
  Save this example at the repository root.
  ```scad
  include <scad/suspension/rear_axle/arm_hub_params.scad>
  use <scad/suspension/rear_axle/rear_hub.scad>
  rear_hub(pl=rear_hub_spec, anchor=[1, 1, 1], slot_mode=false,
           show_bearings=true, show_socket_hardware=true);
  ```
 */
module rear_hub(pl,
                anchor=[1, 1, 1],
                slot_mode=false,
                show_bearings=false,
                show_socket_hardware=false) {
  s = rear_hub_size(pl);
  axle = rear_hub_axle(pl);
  link = rear_hub_link(pl);
  balls = rear_hub_ball_positions(pl);
  socket_d = _rear_hub_value(pl, "socket_d");
  ball_d = _rear_hub_value(pl, "ball_d");
  ball_clearance = _rear_hub_value(pl, "ball_clearance");
  plug_d = _rear_hub_value(pl, "socket_plug_d");
  plug_l = _rear_hub_value(pl, "socket_plug_l");
  plug_x = s[0] - plug_l;
  bearing_ods = [_rear_hub_value(pl, "inner_bearing_od"),
                 _rear_hub_value(pl, "outer_bearing_od")];
  bearing_ids = [_rear_hub_value(pl, "inner_bearing_id"),
                 _rear_hub_value(pl, "outer_bearing_id")];
  bearing_ws = [_rear_hub_value(pl, "inner_bearing_w"),
                _rear_hub_value(pl, "outer_bearing_w")];
  bearing_xs = [0, bearing_ws[0] + _rear_hub_value(pl, "bearing_separation")];
  bearing_l = bearing_xs[1] + bearing_ws[1];
  clearance = _rear_hub_value(pl, "bearing_d_clearance");
  barrel_d = _rear_hub_value(pl, "bearing_housing_d");
  link_d = _rear_hub_value(pl, "link_boss_d");
  link_l = _rear_hub_value(pl, "link_l");
  web_w = _rear_hub_value(pl, "web_w");
  web_l = _rear_hub_value(pl, "web_l");
  rib = _rear_hub_value(pl, "rib_w");
  eps = _rear_hub_value(pl, "cut_eps");
  fn = _rear_hub_value(pl, "fn");
  assert(socket_d > plug_d && plug_l > 0);
  assert(rear_hub_bearing_wall(pl) > 0,
         "bearing seat must leave a positive radial housing wall");
  assert(socket_d > max(plug_d + 2 * _rear_hub_value(pl, "socket_thread_tolerance"),
                        _rear_hub_value(pl, "bushing_d") + ball_clearance,
                        ball_d + ball_clearance),
         "socket cavities must fit inside the measured boss envelope");
  assert(bearing_l <= s[0]);
  assert(ball_d > _rear_hub_value(pl, "ball_mouth_d"));
  assert(_rear_hub_value(pl, "ball_x") > ball_d / 2);
  assert(plug_x > _rear_hub_value(pl, "ball_x") + ball_d / 2);
  assert(_rear_hub_value(pl, "bushing_l") >
         plug_x - _rear_hub_value(pl, "ball_x") - ball_d / 2);
  assert(_rear_hub_value(pl, "ball_spacing") > socket_d);
  assert(axle[2] - barrel_d / 2 > balls[0][2]);
  assert(link[0] >= link_d / 2 && link[0] + link_d / 2 <= s[0]);
  assert(link[2] - link_d / 2 > axle[2] + barrel_d / 2);
  assert(web_w > 0 && web_w < s[0] && web_l > 0 && rib > 0);
  assert(_rear_hub_value(pl, "inner_shoulder_d") > bearing_ids[0]);
  assert(_rear_hub_value(pl, "inner_shoulder_d") < bearing_ods[0]);
  assert(_rear_hub_value(pl, "outer_shoulder_d") > bearing_ids[1]);
  assert(_rear_hub_value(pl, "outer_shoulder_d") < bearing_ods[1]);
  assert(eps > 0 && fn >= 16);

  module along_x(p, d, l) {
    translate(p) {
      rotate([0, 90, 0]) {
        cylinder(d=d, h=l, $fn=fn);
      }
    }
  }

  module link_barrel(p, d, l) {
    translate(p - [0, l / 2, 0]) {
      rotate([-90, 0, 0]) {
        cylinder(d=d, h=l, $fn=fn);
      }
    }
  }

  module cuts() {
    for (i = [0, 1]) {
      x = i == 0 ? -eps : bearing_xs[i];
      along_x([x, axle[1], axle[2]],
              bearing_ods[i] + clearance,
              bearing_ws[i] + eps);
    }
    along_x([-eps, axle[1], axle[2]],
            _rear_hub_value(pl, "outer_shoulder_d"),
            s[0] + 2 * eps);
    along_x([-eps, axle[1], axle[2]],
            _rear_hub_value(pl, "inner_shoulder_d"),
            bearing_ws[0] + _rear_hub_value(pl, "bearing_separation") / 2 + eps);
    link_barrel(link,
                _rear_hub_value(pl, "link_bolt_d")
                + _rear_hub_value(pl, "link_d_clearance"),
                link_l + 2 * eps);
    for (p = balls) {
      translate(p) {
        sphere(d=ball_d + ball_clearance, $fn=fn);
      }
      along_x([-eps, p[1], p[2]],
              _rear_hub_value(pl, "ball_mouth_d"),
              p[0] + eps);
      along_x(p,
              _rear_hub_value(pl, "bushing_d") + ball_clearance,
              plug_x - p[0] + eps);
      translate([plug_x, p[1], p[2]]) {
        rotate([0, 90, 0]) {
          screw_hole_thread(d=plug_d,
                            h=plug_l + eps,
                            pitch=_rear_hub_value(pl, "socket_thread_pitch"),
                            tooth_angle=_rear_hub_value(pl, "socket_thread_angle"),
                            tolerance=_rear_hub_value(pl, "socket_thread_tolerance"),
                            tooth_height=_rear_hub_value(pl, "socket_thread_tooth_h"));
        }
      }
    }
  }

  with_anchor(size=s, anchor=anchor) {
    if (slot_mode) {
      cuts();
    } else {
      color(_rear_hub_value(pl, "body_color")) {
        difference() {
          union() {
            along_x([0, axle[1], axle[2]], barrel_d, bearing_l);
            for (p = balls) {
              along_x([0, p[1], p[2]], socket_d, s[0]);
              hull() {
                along_x([0, p[1], p[2]], socket_d, web_w);
                along_x([0, axle[1], axle[2]], barrel_d, web_w);
              }
            }
            hull() {
              link_barrel(axle, web_w, web_l);
              link_barrel(link, link_d, link_l);
            }
            for (side = [-1, 1]) {
              hull() {
                link_barrel(link, rib, web_l);
                link_barrel(axle + [0, side * (barrel_d - rib) / 2, 0],
                            rib,
                            rib);
              }
            }
          }
          cuts();
        }
      }
      if (show_bearings) {
        for (i = [0, 1]) {
          color(_rear_hub_value(pl, "bearing_color")) {
            difference() {
              along_x([bearing_xs[i], axle[1], axle[2]],
                      bearing_ods[i],
                      bearing_ws[i]);
              along_x([bearing_xs[i] - eps, axle[1], axle[2]],
                      bearing_ids[i],
                      bearing_ws[i] + 2 * eps);
            }
          }
        }
      }
      if (show_socket_hardware) {
        for (p = balls) {
          translate([plug_x, p[1], p[2]]) {
            rotate([0, -90, 0]) {
              rear_hub_socket_bushing(pl);
            }
            rotate([0, 90, 0]) {
              rear_hub_socket_plug(pl);
            }
          }
        }
      }
    }
  }
}
