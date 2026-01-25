include <../colors.scad>

use <../lib/functions.scad>
use <../lib/shapes3d.scad>
use <../lib/transforms.scad>

function circle_point(theta, radius_val, section_height) =
  [radius_val * cos(theta),
   radius_val * sin(theta),
   section_height / 2];

module ball_bearing(bore_d,
                    shoulder_d,
                    outer_d,
                    outer_recess_d,
                    w,
                    rubber_seal_color=metallic_silver_9,
                    ring_color=metallic_silver_3,
                    ball_d,
                    balls_n=7,
                    ball_clearance=0.2,
                    fn=20) {

  ball_d = with_default(ball_d, (outer_recess_d - shoulder_d) / 2);
  outer_rad = outer_d / 2;
  ball_rad = ball_d / 2;

  bore_rad = bore_d / 2;
  gap_d   = shoulder_d + ball_d/2;
  gap_rad = gap_d / 2;
  ball_positions = [for (i = [0 : (fn / balls_n) : fn - 1])
      let (angle_deg = i * 360 / fn)
        circle_point(angle_deg, gap_rad, w)];

  union() {
    render() {
      color(ring_color, alpha=1) {
        difference() {
          rotate_extrude(angle = 360, $fn=50) {
            difference() {
              union() {
                translate([bore_rad, 0, 0]) {
                  square([gap_rad - bore_rad - (ball_rad / 2), w]);
                }
                translate([gap_rad + (ball_rad / 2), 0, 0]) {
                  square([outer_rad - gap_rad - (ball_rad / 2), w]);
                }
              }

              translate([gap_rad, w / 2, 0]) {
                circle(ball_rad);
              }
            }
          }

          let (d = outer_recess_d - ball_rad,
               h = w / 2) {
            translate([0, 0, h + 0.1]) {
              ring(d=d,
                   outer_d2=outer_recess_d,
                   outer_d1=outer_recess_d / 2,
                   h=h);
            }

            translate([0, 0, h - 0.1]) {
              rotate([180, 0, 0]) {
                ring(d=d,
                     outer_d2=outer_recess_d,
                     outer_d1=0,
                     h=h);
              }
            }
          }
        }
      }
    }
    translate([0, 0, 0.1]) {

      ring(d=shoulder_d,
           outer_d=outer_recess_d - ball_rad,
           h=1,
           color=rubber_seal_color);
    }

    for (idx = [0 : len(ball_positions) - 1]) {
      translate(ball_positions[idx])
        sphere(r = ball_rad + ball_clearance, $fn=fn);
    }
  }
}

ball_bearing(bore_d=8, shoulder_d=12.15, outer_recess_d=19.2, w=7, outer_d=22);