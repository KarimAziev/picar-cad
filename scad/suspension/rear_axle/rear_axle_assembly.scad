/**
  * Module: HSP-inspired rear axle inspection assembly.
  *
  * Vehicle +X is right, +Y points to the motor and +Z is up. The origin is
  * the differential axis projected onto the mounting plane. Hardware lengths
  * remain fixed; orange endpoint markers expose dogbone fit discrepancies.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../rc_params.scad>
include <arm_hub_params.scad>
include <hardware_params.scad>
include <structure_params.scad>

use <../../lib/plist.scad>
use <../../placeholders/bolt.scad>
use <../../placeholders/hsp_rear_drivetrain.scad>
use <../../placeholders/hsp_shock_absorber.scad>
use <../../placeholders/rc_driveshaft.scad>
use <../rear_chassis/computed_params.scad>
use <../rear_suspension/rear_suspension_mount.scad>
use <rear_bulkhead.scad>
use <rear_camber_link.scad>
use <rear_hub.scad>
use <rear_lower_arm.scad>
use <rear_shock_tower.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_axle_arm_origin
  ─────────────────────────────────────────────────────────────────────────────
  Return the right arm origin at zero hinge rotation in the vehicle axle frame.
  **Parameters:**
  - `housing`: `rear_housing_spec` in `structure_params.scad`.
  - `arm`: `rear_lower_arm_spec` in `arm_hub_params.scad`.
 */
function rear_axle_arm_origin(housing, arm) =
  rear_bulkhead_hinge_axis(housing, arm) - rear_lower_arm_inner_pivot(arm);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_axle_rest_pose
  ─────────────────────────────────────────────────────────────────────────────
  Position an upright rear hub at the configured wheel-center height.
  **Parameters:**
  - `settings`: `rear_axle_settings` in `structure_params.scad`, including
    `wheel_center_z` above the mounting face and zero `hub_camber_angle`.
  - `housing`: `rear_housing_spec` in `structure_params.scad`; fixed hinge datums.
  - `arm`: `rear_lower_arm_spec` in `arm_hub_params.scad`; hinge and ball geometry.
  - `hub`: `rear_hub_spec` in `arm_hub_params.scad`; lower-ball and axle geometry.
  **Returns:** Property list containing `hinge`, OpenSCAD Y `arm_angle`,
  `arm_rotation` matrix, `arm_translation`, `lower_pivot`, and `hub_origin`.
  **Behavior:** The hub camber must be zero. The arm rotates rigidly about its
  inner hinge; the outward-pointing branch sets its lower ball height from the
  wheel-center target and measured hub offset. Camber rods and dogbones retain
  their own dimensions, and their closure is evaluated separately.
 */
function rear_axle_rest_pose(settings, housing, arm, hub) =
  assert(plist_has("wheel_center_z", settings),
         "Missing rear wheel-center height")
  assert(plist_has("hub_camber_angle", settings),
         "Missing rear hub camber setting")
  assert(plist_get("hub_camber_angle", settings) == 0,
         "Rear upright rest pose requires zero hub camber")
  let (hinge = rear_bulkhead_hinge_axis(housing, arm),
       inner = rear_lower_arm_inner_pivot(arm),
       delta = rear_lower_arm_outer_pivot(arm) - inner,
       hub_pivot = rear_hub_pivot(hub),
       axle_offset = rear_hub_axle(hub) - hub_pivot,
       radius = norm([delta[0], delta[2]]),
       rise = plist_get("wheel_center_z", settings) - axle_offset[2] - hinge[2])
  assert(delta[0] > 0 && radius > 0,
         "Rear arm must extend outward from its hinge")
  assert(abs(rise) <= radius, "Rear wheel-center height is outside arm travel")
  let (angle = atan2(delta[2], delta[0]) - asin(rise / radius),
       rotation = [[cos(angle), 0, sin(angle)],
                   [0, 1, 0],
                   [-sin(angle), 0, cos(angle)]],
       translation = hinge - rotation * inner,
       ball = hinge + rotation * delta)
  ["hinge", hinge,
   "arm_angle", angle,
   "arm_rotation", rotation,
   "arm_translation", translation,
   "lower_pivot", ball,
   "hub_origin", ball - hub_pivot];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_axle_arm_point
  ─────────────────────────────────────────────────────────────────────────────
  Transform a point from the arm's construction frame into its assembled pose.
  **Parameters:**
  - `point`: Arm-local XYZ point.
  - `settings`, `housing`: `rear_axle_settings` and `rear_housing_spec` in
    `structure_params.scad`.
  - `arm`, `hub`: `rear_lower_arm_spec` and `rear_hub_spec` in `arm_hub_params.scad`.
 */
function rear_axle_arm_point(point, settings, housing, arm, hub) =
  let (pose = rear_axle_rest_pose(settings, housing, arm, hub))
  plist_get("arm_translation", pose) + plist_get("arm_rotation", pose) * point;

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_axle_place_arm
  ─────────────────────────────────────────────────────────────────────────────
  Place arm-local children at the configured right rear suspension rest pose.
  **Parameters:**
  - `settings`, `housing`: `rear_axle_settings` and `rear_housing_spec` in
    `structure_params.scad`.
  - `arm`, `hub`: `rear_lower_arm_spec` and `rear_hub_spec` in `arm_hub_params.scad`.
  **Behavior:** Mirror the resulting vehicle-frame geometry for the left side.
 */
module rear_axle_place_arm(settings, housing, arm, hub) {
  pose = rear_axle_rest_pose(settings, housing, arm, hub);
  translate(plist_get("hinge", pose)) {
    rotate([0, plist_get("arm_angle", pose), 0]) {
      translate(-rear_lower_arm_inner_pivot(arm)) {
        children();
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_axle_hub_origin
  ─────────────────────────────────────────────────────────────────────────────
  Return the right hub origin with both lower ball centers aligned.
  **Parameters:**
  - `housing`: `rear_housing_spec` in `structure_params.scad`.
  - `arm`, `hub`: `rear_lower_arm_spec`, `rear_hub_spec` in `arm_hub_params.scad`.
  - `settings`: `rear_axle_settings` in `structure_params.scad`.
 */
function rear_axle_hub_origin(housing, arm, hub, settings=rear_axle_settings) =
  plist_get("hub_origin", rear_axle_rest_pose(settings, housing, arm, hub));

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_axle_wheel_shaft_origin
  ─────────────────────────────────────────────────────────────────────────────
  Return the right wheel cup-mouth center, with shaft axis along +X.
  **Parameters:**
  - `housing`: `rear_housing_spec` in `structure_params.scad`.
  - `arm`, `hub`: `rear_lower_arm_spec`, `rear_hub_spec` in `arm_hub_params.scad`.
  - `axle`: `rear_wheel_axle_spec` in `hardware_params.scad`.
  - `settings`: `rear_axle_settings` in `structure_params.scad`.
 */
function rear_axle_wheel_shaft_origin(housing,
                                      arm,
                                      hub,
                                      axle,
                                      settings=rear_axle_settings) =
  let (p = rear_axle_hub_origin(housing, arm, hub, settings),
       a = rear_hub_axle(hub),
       b = hsp_rear_wheel_axle_bearing_positions(axle)[0],
       bearing_start = b[2] - plist_get("inner_bearing_w", hub) / 2)
  p + [-bearing_start, a[1], a[2]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_axle_cup_centers
  ─────────────────────────────────────────────────────────────────────────────
  Return differential and wheel cup ball centers for the right side.
  **Parameters:**
  - `housing`: `rear_housing_spec` in `structure_params.scad`.
  - `arm`, `hub`: `rear_lower_arm_spec`, `rear_hub_spec` in `arm_hub_params.scad`.
  - `differential`, `axle`: `rear_differential_spec`, `rear_wheel_axle_spec` in
    `hardware_params.scad`.
  - `settings`: `rear_axle_settings` in `structure_params.scad`.
 */
function rear_axle_cup_centers(housing,
                               arm,
                               hub,
                               differential,
                               axle,
                               settings=rear_axle_settings) =
  let (d = hsp_rear_differential_output_positions(differential)[1]
           - hsp_rear_differential_axis(differential)
           + rear_bulkhead_axis(housing, differential),
       p = rear_axle_wheel_shaft_origin(housing, arm, hub, axle, settings),
       b = hsp_rear_wheel_axle_ball_position(axle))
  [d, p + [b[2], 0, 0]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_axle_fit
  ─────────────────────────────────────────────────────────────────────────────
  Report static ride-height shaft fit without resizing the selected hardware.
  **Parameters:** `housing`, `settings`: `rear_housing_spec`,
  `rear_axle_settings` in `structure_params.scad`. `arm`, `hub`:
  `rear_lower_arm_spec`, `rear_hub_spec` in `arm_hub_params.scad`.
  `differential`, `axle`, `dogbone`: `rear_differential_spec`,
  `rear_wheel_axle_spec`, `rear_dogbone_spec` in `hardware_params.scad`.
  **Returns:** Property list with required and stock pin-center lengths,
  signed length error (positive means stock too long) and joint angle degrees.
 */
function rear_axle_fit(housing,
                       arm,
                       hub,
                       differential,
                       axle,
                       dogbone,
                       settings=rear_axle_settings) =
  let (p = rear_axle_cup_centers(housing, arm, hub, differential, axle, settings),
       v = p[1] - p[0],
       required = norm(v),
       stock = plist_get("pin_center_l", dogbone))
  ["required_dogbone_l", required,
   "stock_dogbone_l", stock,
   "dogbone_length_error", stock - required,
   "dogbone_angle", acos(abs(v[0]) / required)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_axle_camber_link_centers
  ─────────────────────────────────────────────────────────────────────────────
  Return the requested right camber-link bushing centers at the mounting faces.
  **Parameters:**
  - `settings`, `housing`, `tower`: `rear_axle_settings`, `rear_housing_spec`,
    `rear_tower_spec` in `structure_params.scad`. The settings' `camber_link`
    preset is defined in `rear_camber_link_params.scad`.
  - `arm`, `hub`: `rear_lower_arm_spec`, `rear_hub_spec` in `arm_hub_params.scad`.
  - `differential`: `rear_differential_spec` in `hardware_params.scad`.
  **Returns:** Inboard and outboard XYZ centers in the vehicle axle frame.
 */
function rear_axle_camber_link_centers(settings,
                                       housing,
                                       arm,
                                       hub,
                                       differential,
                                       tower) =
  let (link = plist_get("camber_link", settings),
       bushing_half = plist_get("bushing_h", link) / 2,
       gap = plist_get("link_standoff", settings),
       inner = rear_bulkhead_link_position(housing, differential, tower),
       outer = rear_axle_hub_origin(housing, arm, hub, settings) + rear_hub_link(hub))
  [inner + [0, plist_get("link_ear_w", housing) / 2 + bushing_half + gap, 0],
   outer + [0, plist_get("link_l", hub) / 2 + bushing_half + gap, 0]];

module _rear_axle_side(side) {
  scale([side, 1, 1]) {
    children();
  }
}

// Start is the underside of the head; end is the threaded tip.
module _rear_axle_fastener(start, end, pl, show_nut) {
  d = plist_get("d", pl);
  l = norm(end - start);
  head_h = plist_get("head_h", pl);
  nut_h = plist_get("nut_h", pl);
  $fn = plist_get("fn", pl);
  translate(start) {
    rc_driveshaft_axis(end - start) {
      color(plist_get("color", pl)) {
        cylinder(d=d, h=l);
        translate([0, 0, -head_h]) {
          bolt_head(type="socket",
                    head_d=plist_get("head_d", pl),
                    head_h=head_h,
                    shaft_r=d / 2,
                    $fn=plist_get("fn", pl));
        }
        if (show_nut) {
          translate([0, 0, l - nut_h - plist_get("thread_projection", pl)]) {
            difference() {
              cylinder(d=plist_get("nut_af", pl) / cos(30), h=nut_h, $fn=6);
              cylinder(d=d, h=nut_h);
            }
          }
        }
      }
    }
  }
}

module _rear_axle_spacer(start, end, pl) {
  assert(norm(end - start) > 0, "Spacer needs positive length");
  translate(start) {
    rc_driveshaft_axis(end - start) {
      color(plist_get("color", pl)) {
        difference() {
          cylinder(d=plist_get("washer_d", pl), h=norm(end - start));
          cylinder(d=plist_get("d", pl), h=norm(end - start));
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_axle_assembly
  ─────────────────────────────────────────────────────────────────────────────
  Assemble the printable parts and metal hardware at shared mechanical datums.
  **Parameters:**
  - `settings`: `rear_axle_settings` in `structure_params.scad`; includes
    visibility, upright wheel-center height and fit diagnostics.
    `shock_tower_side` selects the rear face (-1) or front boss (+1) for the
    upper shock eye; both shock eyes retain parallel transverse axes. Its
    `camber_link` entry uses `rear_camber_link_spec` in
    `rear_camber_link_params.scad`.
  - `housing`, `tower`: `rear_housing_spec`, `rear_tower_spec` in
    `structure_params.scad`.
  - `arm`, `hub`: `rear_lower_arm_spec`, `rear_hub_spec` in `arm_hub_params.scad`.
  - `differential`, `pinion`, `dogbone`, `axle`, `sleeve`, `shock`:
    `rear_differential_spec`, `rear_pinion_spec`, `rear_dogbone_spec`,
    `rear_wheel_axle_spec`, `rear_motor_sleeve_spec`, `rear_shock_spec`, all in
    `hardware_params.scad`.
  - `fastener`: `rear_fastener_spec` in `structure_params.scad`.
  - `layout`: Existing rear chassis layout, used only for mounting-hole datums.
  **Behavior:** Lower arms rotate around their housing hinges to place upright
  wheels at `wheel_center_z`; hubs, shocks and shaft endpoints follow that pose.
  Fixed-length camber links report their remaining fit error. The assembly does
  not resize the chassis. `require_stock_fit`
  rejects unresolved dogbone fits. Orange markers identify requested wheel-cup
  centers when the selected dogbone does not reach them within fit_tolerance.
 */
module rear_axle_assembly(settings,
                          housing,
                          arm,
                          hub,
                          tower,
                          differential,
                          pinion,
                          dogbone,
                          axle,
                          sleeve,
                          shock,
                          fastener,
                          layout) {
  mounts = rear_bulkhead_mount_positions(layout,
                                         rear_bulkhead_bolt_spacing_x,
                                         rear_bulkhead_bolt_spacing_2[1]);
  axis = rear_bulkhead_axis(housing, differential);
  pose = rear_axle_rest_pose(settings, housing, arm, hub);
  hub_pos = plist_get("hub_origin", pose);
  cups = rear_axle_cup_centers(housing, arm, hub, differential, axle, settings);
  fit = rear_axle_fit(housing, arm, hub, differential, axle, dogbone, settings);
  error = plist_get("dogbone_length_error", fit);
  tolerance = plist_get("fit_tolerance", settings);
  tower_pos = rear_bulkhead_tower_origin(housing, differential, tower);
  tower_thickness = plist_get("thickness", tower);
  pinion_pos = rear_bulkhead_pinion_origin(housing, differential, pinion);
  shock_p = rear_axle_arm_point(rear_lower_arm_shock_positions(arm)[0],
                                settings,
                                housing,
                                arm,
                                hub);
  shock_rail = (plist_get("outer_span", arm) - plist_get("outer_gap", arm)) / 2;
  shock_y = shock_p[1] - shock_rail / 2 - plist_get("eye_w", shock) / 2
            - plist_get("shock_mount_gap", settings);
  upper_shock = rear_shock_tower_shocks(tower,
                                        plist_get("shock_hole", settings))[1];
  shock_top = [tower_pos[0] + upper_shock[0], shock_y,
               tower_pos[2] + upper_shock[1]];
  shock_bottom = [shock_p[0], shock_y, shock_p[2]];
  assert(!plist_get("require_stock_fit", settings) || abs(error) <= tolerance,
         str("Dogbone fit unresolved: stock minus required = ", error, " mm"));
  echo(rear_axle_fit=fit);
  echo(rear_arm_hinge_angle=plist_get("arm_angle", pose));
  echo(rear_shock_eye_distance=norm(shock_top - shock_bottom));
  $fn = plist_get("fn", settings);
  if (plist_get("show_mount", settings)) {
    translate([0,
               plist_get("bulkhead_2_y", layout),
               -suspension_chassis_mount_h]) {
      rotate([0, 0, 180]) {
        rear_suspension_mount(layout=layout, debug=false);
      }
    }
  }
  for (part = ["lower", "lid"]) {
    if ((part == "lower" && plist_get("show_housing", settings))
        || (part == "lid" && plist_get("show_lid", settings))) {
      translate([0, 0, part == "lid" ? plist_get("lid_lift", settings) : 0]) {
        rear_bulkhead(housing,
                      differential,
                      pinion,
                      arm,
                      tower,
                      mounts,
                      part=part,
                      show_hardware=false);
      }
    }
  }
  if (plist_get("show_tower", settings)) {
    translate(tower_pos - [0, tower_thickness, 0]) {
      multmatrix([[1, 0, 0, 0], [0, 0, 1, 0],
                  [0, 1, 0, 0], [0, 0, 0, 1]]) {
        rear_shock_tower(tower);
      }
    }
  }
  if (plist_get("show_fasteners", settings)) {
    for (p = rear_bulkhead_fastener_positions(housing, mounts)) {
      _rear_axle_fastener(p - [0, 0, suspension_chassis_mount_h],
                          p + [0, 0, plist_get("mount_nut_floor", housing)
                                     + plist_get("nut_h", fastener)
                                     + plist_get("thread_projection", fastener)],
                          fastener,
                          show_nut=false);
      translate(p + [0, 0, plist_get("mount_nut_floor", housing)]) {
        color(plist_get("color", fastener)) {
          difference() {
            cylinder(d=plist_get("nut_af", fastener) / cos(30),
                     h=plist_get("nut_h", fastener),
                     $fn=6);
            cylinder(d=plist_get("d", fastener),
                     h=plist_get("nut_h", fastener));
          }
        }
      }
    }
    for (p = rear_shock_tower_mounts(tower)) {
      _rear_axle_fastener(tower_pos + [p[0], -tower_thickness, p[1]],
                          tower_pos + [p[0], plist_get("tower_insert_l", housing), p[1]],
                          fastener,
                          show_nut=false);
    }
  }
  if (plist_get("show_drivetrain", settings)) {
    translate(axis - hsp_rear_differential_axis(differential)) {
      hsp_rear_differential(differential,
                            show_bearings=plist_get("show_bearings", settings));
    }
    translate(pinion_pos) {
      rotate([-90, 0, 0]) {
        hsp_rear_pinion(pinion,
                        anchor=[0, 0, 1],
                        show_bearings=plist_get("show_bearings", settings));
      }
    }
  }
  assert(pinion_pos[1] + hsp_rear_pinion_shaft_end(pinion)[2]
         - plist_get("pinion_engagement", sleeve)
         >= rear_bulkhead_pinion_neck_end(housing, pinion)
         + plist_get("coupling_axial_gap", settings),
         "Sleeve engagement overlaps the pinion neck");
  if (plist_get("show_sleeve", settings)) {
    sleeve_l = hsp_motor_sleeve_size(sleeve)[2];
    sleeve_motor_end = pinion_pos[1] + hsp_rear_pinion_shaft_end(pinion)[2]
                       - plist_get("pinion_engagement", sleeve) + sleeve_l;
    translate([pinion_pos[0], sleeve_motor_end, pinion_pos[2]]) {
      rotate([90, 0, 0]) {
        hsp_motor_sleeve(sleeve, anchor=[0, 0, 1]);
      }
    }
  }
  for (side = [-1, 1]) {
    _rear_axle_side(side) {
      if (plist_get("show_arms", settings)) {
        rear_axle_place_arm(settings, housing, arm, hub) {
          rear_lower_arm(arm, show_pins=true, show_ball_studs=true);
        }
      }
      if (plist_get("show_hubs", settings)) {
        translate(hub_pos) {
          rear_hub(hub,
                   show_bearings=plist_get("show_bearings", settings),
                   show_socket_hardware=true);
        }
      }
      if (plist_get("show_drivetrain", settings)) {
        translate(rear_axle_wheel_shaft_origin(housing, arm, hub, axle, settings)) {
          rotate([0, 90, 0]) {
            hsp_rear_wheel_axle(axle,
                                anchor=[0, 0, 1],
                                show_bearings=false,
                                show_hex=true);
          }
        }
        translate(cups[0]) {
          rc_driveshaft_axis(cups[1] - cups[0]) {
            hsp_wheel_dogbone(dogbone);
          }
        }
      }
      if (plist_get("show_fit_markers", settings) && abs(error) > tolerance) {
        color("DarkOrange") {
          translate(cups[1]) {
            sphere(d=plist_get("fit_marker_d", settings));
          }
        }
      }
      if (plist_get("show_shocks", settings)) {
        hsp_shock_between(shock_bottom, shock_top, shock);
        if (plist_get("show_fasteners", settings)) {
          eye_half = plist_get("eye_w", shock) / 2;
          nut_tail = plist_get("nut_h", fastener)
                     + plist_get("thread_projection", fastener);
          assert(plist_has("shock_tower_side", settings),
                 "Rear shock tower mounting side must be explicit");
          tower_side = plist_get("shock_tower_side", settings);
          assert(tower_side == -1 || tower_side == 1,
                 "Shock tower side must be -1 or +1");
          rear_face_y = tower_pos[1] - tower_thickness;
          front_face_y = tower_pos[1] + plist_get("shock_boss_h", tower);
          upper_face_y = tower_side == 1 ? front_face_y : rear_face_y;
          upper_far_face_y = tower_side == 1 ? rear_face_y : front_face_y;
          assert(tower_side * (shock_y - upper_face_y) > eye_half,
                 "Upper shock eye needs clearance from the selected tower face");
          _rear_axle_fastener(shock_top + [0, tower_side * eye_half, 0],
                              [shock_top[0], upper_far_face_y - tower_side * nut_tail,
                               shock_top[2]],
                              fastener,
                              show_nut=true);
          _rear_axle_spacer([shock_top[0], upper_face_y, shock_top[2]],
                            shock_top - [0, tower_side * eye_half, 0],
                            fastener);
          _rear_axle_fastener(shock_bottom - [0, eye_half, 0],
                              [shock_bottom[0], shock_p[1] + shock_rail / 2 + nut_tail,
                               shock_bottom[2]],
                              fastener,
                              show_nut=true);
          _rear_axle_spacer(shock_bottom + [0, eye_half, 0],
                            [shock_bottom[0], shock_p[1] - shock_rail / 2,
                             shock_bottom[2]],
                            fastener);
        }
      }
      if (plist_get("show_links", settings)) {
        link = plist_get("camber_link", settings);
        link_points = rear_axle_camber_link_centers(settings,
                                                    housing,
                                                    arm,
                                                    hub,
                                                    differential,
                                                    tower);
        link_fit = rear_camber_link_fit(link_points[0], link_points[1], link);
        bushing_half = plist_get("bushing_h", link) / 2;
        link_error = plist_get("length_error", link_fit);
        if (side == 1) {
          echo(rear_camber_link_fit=link_fit);
        }
        rear_camber_link_between(link_points[0], link_points[1], link);
        if (plist_get("show_fit_markers", settings) && abs(link_error) > tolerance) {
          color("DarkOrange") {
            translate(link_points[1]) {
              sphere(d=plist_get("fit_marker_d", settings));
            }
          }
        }
        if (plist_get("show_fasteners", settings)) {
          for (i = [0, 1]) {
            p = link_points[i];
            ear_w = i == 0
                    ? plist_get("link_ear_w", housing)
                    : plist_get("link_l", hub);
            ear_center_y = p[1] - ear_w / 2 - bushing_half
                           - plist_get("link_standoff", settings);
            _rear_axle_spacer([p[0], ear_center_y + ear_w / 2, p[2]],
                              p - [0, bushing_half, 0],
                              fastener);
            _rear_axle_fastener(p + [0, bushing_half, 0],
                                [p[0], ear_center_y - ear_w / 2
                                       - plist_get("nut_h", fastener)
                                       - plist_get("thread_projection", fastener), p[2]],
                                fastener,
                                show_nut=true);
          }
        }
      }
    }
  }
}

rear_axle_assembly(settings=rear_axle_settings,
                   housing=rear_housing_spec,
                   arm=rear_lower_arm_spec,
                   hub=rear_hub_spec,
                   tower=rear_tower_spec,
                   differential=rear_differential_spec,
                   pinion=rear_pinion_spec,
                   dogbone=rear_dogbone_spec,
                   axle=rear_wheel_axle_spec,
                   sleeve=rear_motor_sleeve_spec,
                   shock=rear_shock_spec,
                   fastener=rear_fastener_spec,
                   layout=rear_chassis_layout());
