/**
  * Module: Removable motor encoder bracket, feet flat on the print bed.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../steering_params.scad>

use <../../lib/plist.scad>
use <gearbox_bracket.scad>
use <gearmotor_encoder_bracket.scad>

module grearbox_encoder_bracket_printable(plist=motor_plist,
                                          bolt_pad_x=gearbox_bracket_bolt_pad_x,
                                          bolt_pad_y=gearbox_bracket_bolt_pad_y,
                                          ear_bolt_pad=gearbox_bracket_ear_bolt_pad,
                                          bolt_d=gearbox_bracket_bolt_d,
                                          bracket_thickness=bracket_thickness,
                                          corner_r=gearbox_bracket_corner_r,
                                          fillet_x_w=gearbox_bracket_fillet_x_w,
                                          fillet_y_w=gearbox_bracket_fillet_y_w,
                                          encoder_plist=motor_encoder_plist) {
  params = gearmotor_bracket_compute_params(plist=plist,
                                            bolt_pad_x=bolt_pad_x,
                                            bolt_pad_y=bolt_pad_y,
                                            ear_bolt_pad=ear_bolt_pad,
                                            bolt_d=bolt_d,
                                            bracket_thickness=bracket_thickness,
                                            corner_r=corner_r,
                                            fillet_x_w=fillet_x_w,
                                            fillet_y_w=fillet_y_w,
                                            encoder_plist=encoder_plist);
  encoder_mount = plist_get("encoder_mount", params);
  if (!is_undef(encoder_mount)) {
    rotate([-90, 0, 0]) {
      gearmotor_encoder_bracket(encoder_mount, anchor=[0, 0, 1]);
    }
  }
}

grearbox_encoder_bracket_printable();