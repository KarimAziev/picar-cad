/**
 * Module: Double-wishbone suspension knuckle with ball joints.
 *
 * Adds upper/lower M6 ball-joint bosses and a rear steering arm with an M3
 * ball-joint boss, tied to a narrow spindle that fits between the paired front
 * hubs and washers on the shoulder bolt.
 */

include <../colors.scad>
include <../parameters.scad>


// ─────────────────────────────────────────────────────────────────────────────
// Suspension knuckle (double wishbone)
// ─────────────────────────────────────────────────────────────────────────────

// Vertical spacing between upper and lower ball joint centers on the knuckle
suspension_knuckle_arm_spacing            = 34;

// Caster angle for the ball-joint line (top leaned back relative to bottom)
suspension_knuckle_caster_deg             = 6;

// Thickness available for the spindle between hubs and washers on the shoulder
// bolt. Uses the two front wheel hubs and a washer on each side.
suspension_knuckle_washer_thickness       = 1.6;

suspension_knuckle_spindle_w              = wheel_shoulder_bolt_unthreaded_l
                                             - (wheel_hub_h
                                             + wheel_hub_inner_rim_h * 2) * 2
                                             - suspension_knuckle_washer_thickness
                                             * 2;

// Outer diameter of the spindle boss that sits between hubs
suspension_knuckle_spindle_outer_d        = wheel_bearing_shoulder_d + 2;

// Clearance to add to the spindle bore for the shoulder bolt
suspension_knuckle_spindle_bore_clearance = 0.2;

// M6 ball joints for upper/lower arms
suspension_knuckle_m6_ball_head_d         = 20;
suspension_knuckle_m6_bolt_dia            = 6;
suspension_knuckle_m6_ear_thickness       = 10;
suspension_knuckle_m6_relief_depth        = 4;
suspension_knuckle_m6_relief_clearance    = 1;

// M3 ball joint for steering arm
suspension_knuckle_m3_ball_head_d         = 10;
suspension_knuckle_m3_bolt_dia            = 3;
suspension_knuckle_m3_ear_thickness       = 6;
suspension_knuckle_m3_relief_depth        = 3;
suspension_knuckle_m3_relief_clearance    = 1;

// Steering arm placement relative to the lower joint (positive is upward/back)
suspension_knuckle_steering_y_offset      = 1;
suspension_knuckle_steering_back_offset   = 6;

// Thickness of the ribs/webs tying the bosses to the spindle
suspension_knuckle_web_d                  = 6;

function _rot_z(v, a) = [v[0] * cos(a) - v[1] * sin(a),
                         v[0] * sin(a) + v[1] * cos(a),
                         v[2]];

module _spindle(spindle_color="white", alpha=1) {
  bore_d = wheel_shoulder_bolt_d + suspension_knuckle_spindle_bore_clearance;
  color(spindle_color, alpha=alpha) {
    difference() {
      cylinder(d=suspension_knuckle_spindle_outer_d,
               h=suspension_knuckle_spindle_w,
               center=true,
               $fn=120);
      cylinder(d=bore_d,
               h=suspension_knuckle_spindle_w + 1,
               center=true,
               $fn=90);
    }
  }
}

module _ball_boss(head_d,
                  bolt_d,
                  ear_t,
                  relief_depth,
                  relief_clearance,
                  boss_d,
                  boss_color="white",
                  alpha=1) {
  color(boss_color, alpha=alpha) {
    // Rotate so the bolt axis runs along +Y (fore-aft), keeping the boss centered
    rotate([90, 0, 0]) {
      difference() {
        cylinder(d=boss_d, h=ear_t, center=true, $fn=120);
        cylinder(d=bolt_d + 0.25, h=ear_t + 1, center=true, $fn=90);
        translate([0, 0, ear_t / 2 - relief_depth]) {
          sphere(d=head_d + relief_clearance, $fn=120);
        }
        translate([0, 0, -ear_t / 2 + relief_depth]) {
          sphere(d=head_d + relief_clearance, $fn=120);
        }
      }
    }
  }
}

module _web_to_spindle(pos,
                       web_d=suspension_knuckle_web_d,
                       web_color="white",
                       alpha=1) {
  color(web_color, alpha=alpha) {
    hull() {
      translate(pos) {
        sphere(d=web_d, $fn=60);
      }
      cylinder(d=web_d,
               h=suspension_knuckle_spindle_w,
               center=true,
               $fn=60);
    }
  }
}

module _web_between(a,
                    b,
                    web_d=suspension_knuckle_web_d,
                    web_color="white",
                    alpha=1) {
  color(web_color, alpha=alpha) {
    hull() {
      translate(a) {
        sphere(d=web_d, $fn=60);
      }
      translate(b) {
        sphere(d=web_d, $fn=60);
      }
    }
  }
}

module suspension_knuckle(show_spindle=true,
                          show_steering_arm=true,
                          knuckle_color="white",
                          spindle_color="white",
                          alpha=0.9) {

  half_span = suspension_knuckle_arm_spacing / 2;
  caster_deg = suspension_knuckle_caster_deg;

  upper_pos = _rot_z([0, half_span, 0], caster_deg);
  lower_pos = _rot_z([0, -half_span, 0], caster_deg);
  steer_pos = _rot_z([-suspension_knuckle_steering_back_offset,
                      -half_span + suspension_knuckle_steering_y_offset,
                      0],
                     caster_deg);

  boss_m6_d = suspension_knuckle_m6_ball_head_d + 4;
  boss_m3_d = suspension_knuckle_m3_ball_head_d + 3;

  union() {
    if (show_spindle) {
      _spindle(spindle_color=spindle_color, alpha=alpha);
    }

    // Structural webs tying bosses to the spindle and to each other
    _web_to_spindle(upper_pos, web_color=knuckle_color, alpha=alpha);
    _web_to_spindle(lower_pos, web_color=knuckle_color, alpha=alpha);
    if (show_steering_arm) {
      _web_to_spindle(steer_pos, web_color=knuckle_color, alpha=alpha);
      _web_between(lower_pos, steer_pos, web_color=knuckle_color, alpha=alpha);
    }
    _web_between(upper_pos, lower_pos, web_color=knuckle_color, alpha=alpha);

    // Upper and lower M6 ball-joint bosses
    translate(upper_pos) {
      _ball_boss(head_d=suspension_knuckle_m6_ball_head_d,
                 bolt_d=suspension_knuckle_m6_bolt_dia,
                 ear_t=suspension_knuckle_m6_ear_thickness,
                 relief_depth=suspension_knuckle_m6_relief_depth,
                 relief_clearance=suspension_knuckle_m6_relief_clearance,
                 boss_d=boss_m6_d,
                 boss_color=knuckle_color,
                 alpha=alpha);
    }

    translate(lower_pos) {
      _ball_boss(head_d=suspension_knuckle_m6_ball_head_d,
                 bolt_d=suspension_knuckle_m6_bolt_dia,
                 ear_t=suspension_knuckle_m6_ear_thickness,
                 relief_depth=suspension_knuckle_m6_relief_depth,
                 relief_clearance=suspension_knuckle_m6_relief_clearance,
                 boss_d=boss_m6_d,
                 boss_color=knuckle_color,
                 alpha=alpha);
    }

    // Rear steering arm with M3 ball-joint boss
    if (show_steering_arm) {
      translate(steer_pos) {
        _ball_boss(head_d=suspension_knuckle_m3_ball_head_d,
                   bolt_d=suspension_knuckle_m3_bolt_dia,
                   ear_t=suspension_knuckle_m3_ear_thickness,
                   relief_depth=suspension_knuckle_m3_relief_depth,
                   relief_clearance=suspension_knuckle_m3_relief_clearance,
                   boss_d=boss_m3_d,
                   boss_color=knuckle_color,
                   alpha=alpha);
      }
    }
  }
}

suspension_knuckle();
