/**
  * Module: L-bracket for rotary encoders
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../colors.scad>
include <../parameters.scad>
include <../steering_params.scad>

use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../placeholders/rotary_encoder.scad>

function encoder_full_h(plist,
                        target_h,
                        bottom_thickness,
                        top_bolt_min_padding,
                        top_up_padding) =
  let (size=plist_get("size", plist),
       bolt_spacing=plist_get("bolt_spacing", plist),
       bolt_d=plist_get("bolt_d", plist),
       pcb_w=size[0],
       pcb_l=size[1],
       diff_val_1=(target_h - ((pcb_l / 2) + bottom_thickness)),
       should_rotate=diff_val_1 <= 0,
       w_val=max(bolt_spacing[0] + bolt_d + top_bolt_min_padding, pcb_w),
       l_val=max(bolt_spacing[1] + bolt_d + top_bolt_min_padding, pcb_l),
       effective_l=target_h
       + (should_rotate ? w_val : l_val) / 2
       + top_up_padding)
  effective_l;

function encoder_should_rotate(plist,
                               target_h,
                               bottom_thickness,
                               top_bolt_min_padding,
                               top_up_padding) =
  let (size=plist_get("size", plist),
       pcb_l=size[1],
       diff_val_1=(target_h - ((pcb_l / 2) + bottom_thickness)),
       should_rotate=diff_val_1 <= 0)
  should_rotate;

module encoder_l_bracket_bottom_pan_bolt_children(bottom_pan_bolt_spacing=10,
                                                  bottom_pan_bolt_d=m3_hole_dia,
                                                  bottom_pan_bolt_pad=8) {
  bottom_pan_l = bottom_pan_bolt_pad + bottom_pan_bolt_d;

  for (x = [-bottom_pan_bolt_spacing / 2, bottom_pan_bolt_spacing / 2]) {
    translate([x, bottom_pan_l / 2, 0]) {
      children();
    }
  }
}

module encoder_l_bracket(plist,
                         target_h,
                         bottom_thickness=1.6,
                         side_thickness=3,
                         top_side_padding=0,
                         extra_left_w=10,
                         extra_right_w=0,
                         top_up_padding=0,
                         top_bolt_min_padding=1.5,
                         top_corner_r=1,
                         bottom_pan_bolt_spacing=10,
                         bottom_pan_bolt_d=m3_hole_dia,
                         bottom_pan_bolt_pad=8,
                         bottom_corner_r=3,
                         show_encoder=false,
                         color=white_smoke_1,
                         slot_mode=false) {
  size = plist_get("size", plist);
  bottom_pan_l = bottom_pan_bolt_pad + bottom_pan_bolt_d;
  bolt_spacing = plist_get("bolt_spacing", plist);
  bolt_d = plist_get("bolt_d", plist);
  pcb_w = size[0];
  pcb_l = size[1];

  diff_val_1 = (target_h - ((pcb_l / 2) + bottom_thickness));
  diff_val_2 = (target_h - ((pcb_w / 2) + bottom_thickness));

  should_rotate = diff_val_1 <= 0;

  if (diff_val_1 < 0 && diff_val_2 < 0) {
    echo("diff_val_1", diff_val_1, "diff_val_2", diff_val_2);
    assert(diff_val_1 >= 0 || diff_val_2 >= 0, "To small target height");
  }

  w_val = max(bolt_spacing[0] + bolt_d + top_bolt_min_padding, pcb_w);
  l_val = max(bolt_spacing[1] + bolt_d + top_bolt_min_padding, pcb_l);

  effective_l = target_h
    + (should_rotate ? w_val : l_val) / 2
    + top_up_padding;

  effective_w = (should_rotate ? l_val : w_val) + top_side_padding;

  left_x = -effective_w / 2 - extra_left_w;

  module _encoder(slot_mode=true) {
    translate([0,
               target_h,
               side_thickness]) {
      echo("should_rotate", should_rotate);
      rotate([0, 0, should_rotate ? 90 : 0]) {
        encoder(plist=plist,
                parent_thickness=side_thickness,
                slot_mode=slot_mode);
      }
    }
  }

  module _upper_pan() {
    if (!slot_mode) {
      union() {
        if (show_encoder) {
          _encoder(slot_mode=false);
        }
        maybe_color(color) {
          difference() {
            translate([left_x, 0, 0]) {
              cuboid(size=[effective_w
                           + extra_left_w
                           + extra_right_w,
                           effective_l,
                           side_thickness],
                     anchor=[1, 1],
                     r=top_corner_r,
                     side="top");
            }
            translate([0, 0, -side_thickness]) {
              _encoder(slot_mode=true);
            }
          }
        }
      }
    }
  }
  module _lower_pan() {
    maybe_color(color) {
      difference() {
        translate([left_x, bottom_pan_l / 2, 0]) {
          cuboid(size=[effective_w
                       + extra_left_w
                       + extra_right_w,
                       bottom_pan_l,
                       bottom_thickness],
                 r=bottom_corner_r,
                 anchor=[1, 0],
                 side="top");
        }
        encoder_l_bracket_bottom_pan_bolt_children(bottom_pan_bolt_spacing=bottom_pan_bolt_spacing,
                                                    bottom_pan_bolt_d=bottom_pan_bolt_d,
                                                    bottom_pan_bolt_pad=bottom_pan_bolt_pad) {
          rotate([0, 0, 90]) {
            counterbore(h=bottom_thickness,
                        teardrop_both_sides=true,
                        teardrop_angle=45,
                        d=bottom_pan_bolt_d);
          }
        }
      }
    }
  }
  union() {
    rotate([90, 0, 0]) {
      _upper_pan();
    }
    _lower_pan();
  }
}

target_h = dsservo_size[1] / 2;
encoder_l_bracket(plist=steering_encoder_plist,
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
                  show_encoder=true);
