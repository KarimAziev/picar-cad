// Dimensions for inner features
ball_bearing_inner_rad = 4;
bearing_section_height = 7;
inner_gap_rad          = 7.2;
outer_bearing_rad      = 11;

// Dimensions for the balls
ball_radius_mm         = 2.35;
ball_count             = 7;
carrier_ring_rad       = 1.6;
ball_insert_clearance  = 0.2;

// Resolution for circle approximations
fn                     = 100;

// Return a 3D coordinate given an angle and a radius,
// with z coordinate centered to ball section height.
function circle_point(theta, radius_val, section_height) =
  [radius_val * cos(theta),
   radius_val * sin(theta),
   section_height / 2];

module ball_bearing(inner_rad        = ball_bearing_inner_rad,
                    gap_rad          = inner_gap_rad,
                    h                = bearing_section_height,
                    outer_rad        = outer_bearing_rad,
                    ball_rad         = ball_radius_mm,
                    num_balls        = ball_count,
                    ring_rad         = carrier_ring_rad,
                    fn               = fn) {

  $fn = fn;

  difference() {
    rotate_extrude(angle = 360) {
      difference() {
        union() {

          translate([inner_rad, 0, 0])
            square([gap_rad - inner_rad - (ball_rad / 2), h]);

          translate([gap_rad + (ball_rad / 2), 0, 0])
            square([outer_rad - gap_rad - (ball_rad / 2), h]);
        }

        translate([gap_rad, h / 2, 0])
          circle(ball_rad);
      }
    }

    translate([gap_rad, 0, h / 2])
      cylinder(h = h / 2 + 1, r = ball_rad);
  }

  ball_positions = [for (i = [0 : (fn / num_balls) : fn - 1])
      let (angle_deg = i * 360 / fn)
        circle_point(angle_deg, gap_rad, h)];

  difference() {
    rotate_extrude(angle = 360) {
      translate([gap_rad - (ring_rad / 2), 0, 0])
        square([ring_rad, h / 2 + 0.5 * ball_rad]);
    }

    for (idx = [0 : len(ball_positions) - 1]) {
      translate(ball_positions[idx])
        sphere(r = ball_rad + ball_insert_clearance);
    }
  }
}

ball_bearing();
