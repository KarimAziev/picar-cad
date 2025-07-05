include <../parameters.scad>
use <../util.scad>
use <rack_util.scad>

servo_dia       = 6.5;
servo_screw_dia = 1.5;

module pinion_screw(r_pitch, d, height, start_offst, x_offst) {
  linear_extrude(height=height, center=true) {
    row_of_circles(total_width=r_pitch,
                   starts=[start_offst, 0],
                   spacing=x_offst,
                   d=d);
  }
}

module pinion_screws(r_pitch,
                     thickness,
                     servo_dia=servo_dia,
                     screw_dia=servo_screw_dia,
                     x_offst=0.5,
                     offst_from_center_hole=1.5) {
  union() {
    start_offst = servo_dia / 2 + offst_from_center_hole;
    height = thickness + 1;

    for (pairs = [[[0, 1, 0], [0, 0, 90]],
                  [[1, 0, 0], [0, 0, 0]],
                  [[0, 0, 0], [0, 0, 90]],
                  [[0, 0, 0], [0, 0, 0]]]) {
      mirr_args = pairs[0];
      rotate_args = pairs[1];
      mirror(mirr_args) {
        rotate(rotate_args) {
          pinion_screw(r_pitch=r_pitch,
                       height=height,
                       start_offst=start_offst,
                       x_offst=x_offst,
                       d=screw_dia);
        }
      }
    }
  }
}

module pinion(d=pinion_d,
              tooth_height=tooth_h,
              thickness=pinion_thickness,
              servo_dia=servo_dia,
              tooth_pitch=tooth_pitch,
              screw_dia=servo_screw_dia,
              rack_len=80) {
  shared_params = pinion_sync_params(d, tooth_pitch, rack_len);
  gear_teeth       = shared_params[0];

  r_pitch = d / 2;
  addendum   = tooth_height;
  dedendum   = 1.25 * tooth_height;
  r_addendum = r_pitch + addendum;
  r_dedendum = r_pitch - dedendum;

  tooth_angle = 360 / gear_teeth;
  half_tooth  = tooth_angle / 2;
  difference() {
    linear_extrude(height=thickness, center=true) {
      for (i = [0 : gear_teeth - 1]) {
        rotate(i * tooth_angle) {
          offset(r = 0.5) {
            polygon(points=[[r_dedendum * cos(half_tooth),  r_dedendum * sin(half_tooth)],
                            [r_pitch    * cos(half_tooth),  r_pitch    * sin(half_tooth)],
                            [r_addendum,                    0],
                            [r_pitch    * cos(-half_tooth), r_pitch    * sin(-half_tooth)],
                            [r_dedendum * cos(-half_tooth), r_dedendum * sin(-half_tooth)]]);
          }
        }
      }

      difference() {
        circle(r = abs(r_dedendum), $fn = 100);
        circle(r = servo_dia / 2, $fn = 100);
      }
    }

    offst = abs(r_dedendum) / 2;

    pinion_screws(r_pitch=r_pitch / 2,
                  servo_dia=servo_dia,
                  thickness=thickness,
                  screw_dia=servo_screw_dia);
  }
}

union() {
  pinion(d=pinion_d,
         tooth_height=tooth_h,
         thickness=pinion_thickness,
         servo_dia=servo_dia,
         tooth_pitch=tooth_pitch,
         rack_len=80);
}