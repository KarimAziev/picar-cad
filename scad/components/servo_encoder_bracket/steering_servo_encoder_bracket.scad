/**
  * Module: Steering Servo Encoder Bracket
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../rc_params.scad>

use <../encoder_l_bracket.scad>

module steering_servo_encoder_bracket(plist=steering_encoder_plist,
                                      target_h=dsservo_size[1] / 2,
                                      show_encoder=false) {

  encoder_l_bracket(plist=plist,
                    target_h=target_h,
                    bottom_thickness=steering_encoder_bottom_thickness,
                    side_thickness=steering_encoder_side_thickness,
                    top_side_padding=steering_encoder_top_side_padding,
                    extra_left_w=steering_encoder_extra_left_w,
                    extra_right_w=steering_encoder_extra_right_w,
                    top_up_padding=steering_encoder_top_up_padding,
                    top_bolt_min_padding=steering_encoder_top_bolt_min_padding,
                    top_corner_r=steering_encoder_top_corner_r,
                    bottom_pan_bolt_spacing=steering_encoder_bottom_pan_bolt_spacing,
                    bottom_pan_bolt_d=steering_encoder_bottom_pan_bolt_d,
                    bottom_pan_bolt_pad=steering_encoder_bottom_pan_bolt_pad,
                    bottom_corner_r=steering_encoder_bottom_corner_r,
                    show_encoder=show_encoder);
}
