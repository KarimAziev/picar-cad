/**
 * Module: Steering Pinion
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
use <../util.scad>
use <rack_util.scad>
use <../gear.scad>

function steering_pinion_tooth_pitch() =
  calc_circular_pitch(r_pitch=steering_pinion_d / 2,
                      teeth_count=steering_pinion_teeth_count);

function steering_pinion_tooth_height() =
  calc_tooth_height(r_pitch=steering_pinion_d / 2,
                    teeth_count=steering_pinion_teeth_count,
                    clearance=steering_pinion_clearance);

module steering_pinion_screws_2d(r_pitch,
                                 thickness,
                                 servo_dia=steering_pinion_center_hole_dia,
                                 screw_dia=steering_pinion_screw_dia,
                                 offst_c=steering_pinion_screws_servo_distance,
                                 spacing=steering_pinion_screws_spacing) {
  union() {
    initial_pos = servo_dia / 2 + screw_dia / 2;
    total_width = r_pitch;
    directions = [[1, 0],
                  [-1, 0],
                  [0, -1],
                  [0, 1]];

    specs = [[[initial_pos, 0], [offst_c, 0], 1, false],
             [[-initial_pos, 0], [offst_c, 0], -1, false],
             [[0, initial_pos], [0, offst_c], 1, true],
             [[0, -initial_pos], [0, offst_c], -1, true]];

    for (spec = specs) {
      translate(spec[0]) {
        row_of_circles(starts=spec[1],
                       direction=spec[2],
                       vertical=spec[3],
                       spacing=spacing,
                       total_width=r_pitch,
                       d=screw_dia);
      }
    }
  }
}

module steering_pinion() {
  r_pitch = steering_pinion_d / 2;
  gear(r_pitch=r_pitch,
       teeth_count=steering_pinion_teeth_count,
       servo_dia=steering_pinion_center_hole_dia,
       thickness=steering_pinion_thickness,
       pressure_angle=steering_pinion_pressure_angle,
       clearance=steering_pinion_clearance,
       backlash=steering_pinion_backlash) {
    steering_pinion_screws_2d(r_pitch=r_pitch / 2,
                              servo_dia=steering_pinion_center_hole_dia,
                              thickness=steering_pinion_thickness,
                              screw_dia=steering_pinion_screw_dia,
                              offst_c=steering_pinion_screws_servo_distance,
                              spacing=steering_pinion_screws_spacing);
  }
}

steering_pinion();