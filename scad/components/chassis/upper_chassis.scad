/**
 * Module: Upper Frame, that holds cameras and steering system.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../colors.scad>
include <../../parameters.scad>

use <../../head/head_mount.scad>
use <../../head/head_neck.scad>
use <../../lib/debug.scad>
use <../../lib/functions.scad>
use <../../lib/holes.scad>
use <../../lib/placement.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/text.scad>
use <../../lib/transforms.scad>
use <../../lib/trapezoids.scad>
use <../../placeholders/bolt.scad>
use <../../placeholders/motor.scad>
use <../../placeholders/pan_servo.scad>
use <../../placeholders/ups_hat.scad>
use <../../steering_system/knuckle_shaft.scad>
use <../../steering_system/rack_and_pinion_assembly.scad>
use <../../steering_system/steering_panel.scad>
use <../front_panel.scad>
use <chassis_connector.scad>
use <util.scad>

upper_side_hole_pts     =  scale_upper_trapezoid_pts(x=chassis_trapezoid_hole_width,
                                                     y=chassis_trapezoid_hole_len);

front_pan_y             = chassis_upper_len + front_panel_bolt_y_offset();
effective_front_pan_dia = max(front_panel_connector_bolt_bore_dia,
                              front_panel_connector_bolt_dia) / 2;
front_pan_end           = front_pan_y - effective_front_pan_dia;
top_ribbon_hole_pos     = front_pan_end
                           - chassis_pan_servo_top_ribbon_cuttout_h
                           - chassis_upper_front_padding_y;

head_pos                = -chassis_upper_holes_border_w * 2
                           - chassis_pan_servo_recesess_y_len
                           - chassis_pan_servo_recesess_thickness / 2
                           + top_ribbon_hole_pos
                           - chassis_upper_holes_border_w
                           - chassis_head_zone_y_offset;

hole_h                  = chassis_thickness + 1;
steering_pan_pos        = chassis_upper_len
                           - steering_panel_distance_from_top;

trapezoid_rows_params   = calc_cols_params(gap=chassis_pan_servo_side_trapezoid_gap
                                           + chassis_upper_holes_border_w,
                                           cols=chassis_pan_servo_side_trapezoid_rows,
                                           w=chassis_trapezoid_hole_len);
trapezoid_step          = trapezoid_rows_params[0];
trapezoid_total_y       = trapezoid_rows_params[1];

top_most_row_params = calc_cols_params(cols=chassis_top_most_holes_rows,
                                       w=chassis_top_most_holes_side_len,
                                       gap=chassis_top_most_holes_gap);

top_most_rects_start    = top_ribbon_hole_pos
                           - top_most_row_params[1]
                           - chassis_top_most_holes_side_y_offset;

top_rib_hole_pts        = scale_upper_trapezoid_pts(x=chassis_pan_servo_top_ribbon_cuttout_len / 2,
                                                    y=chassis_pan_servo_top_ribbon_cuttout_h);

show_knuckle_bolts      = false;

show_bolts_info         = false;
show_kingpin_bolt       = false;
show_hinges_bolts       = false;
show_panel_bolt         = false;

fasten_kingpin_bolt     = false;
fasten_hinges_bolts     = false;
fasten_panel_bolt       = false;

module holes_row_along_slanted_side(trapezoid_pts,
                                    rows,
                                    l,
                                    w,
                                    gap,
                                    margin=0,
                                    border_w,
                                    start=0,
                                    parallelogram=false,
                                    eps=1e-9) {
  step = l + gap;

  for (i=[0:rows-1]) {
    if (is_undef(border_w)) {
      hole_along_slanted_side(trapezoid_pts,
                              s = start + i * step,
                              l = l,
                              w = w,
                              margin = margin,
                              eps=eps,
                              parallelogram=parallelogram);
    } else {
      offset_vertices_2d(r=0.3) {
        difference() {
          offset(delta=border_w) {
            hole_along_slanted_side(trapezoid_pts,
                                    s = start + i*step,
                                    l = l,
                                    w = w,
                                    margin = margin,
                                    eps=eps,
                                    parallelogram=parallelogram);
          }
          hole_along_slanted_side(trapezoid_pts,
                                  s = start + i*step,
                                  l = l,
                                  w = w,
                                  margin = margin,
                                  eps=eps,
                                  parallelogram=parallelogram);
        }
      }
    }
  }
}

module chassis_transition_side_holes_2d(border_mode=false,
                                        parallelogram=false) {

  holes_row_along_slanted_side(trapezoid_pts = chassis_transition_pts,
                               rows  = chassis_upper_side_hole_rows,
                               l     = chassis_upper_side_hole_len,
                               w     = chassis_upper_side_hole_w,
                               gap   = chasssis_upper_side_hole_gap,
                               margin= chassis_upper_side_hole_margin,
                               start = chassis_upper_side_hole_start,
                               parallelogram=parallelogram,
                               border_w = border_mode
                               ? chassis_side_hole_border_w
                               : undef);
}
module chassis_transition_side_holes(border_mode=false,
                                     parallelogram=false) {
  mirror_copy([1, 0, 0]) {
    translate([0, -chassis_transition_len, 0]) {
      chassis_side_holes_3d(border_mode=border_mode) {
        chassis_transition_side_holes_2d(border_mode=border_mode,
                                         parallelogram=parallelogram);
      }
    }
  }
}

module chassis_upper_side_rect_holes(start=0,
                                     rows  = chassis_upper_side_hole_rows,
                                     l     = chassis_upper_side_hole_len,
                                     w = chassis_upper_side_hole_w,
                                     gap   = chasssis_upper_side_hole_gap,
                                     margin = chassis_upper_side_hole_margin,
                                     border_mode=false,
                                     parallelogram=true) {
  holes_row_along_slanted_side(trapezoid_pts = chassis_upper_pts,
                               rows  = rows,
                               l     = l,
                               w     = w,
                               gap   = gap,
                               margin = margin,
                               start = start,
                               parallelogram=parallelogram,
                               border_w = border_mode
                               ? chassis_side_hole_border_w
                               : undef);
}

module chassis_side_holes_3d(border_mode=false) {
  translate([0,
             0,
             border_mode
             ? chassis_thickness
             : -0.5]) {
    linear_extrude(height=border_mode
                   ? chassis_side_hole_border_h
                   : chassis_thickness + 1,
                   center=false) {

      children();
    }
  }
}

module pan_servo_slot_3d() {
  trap_pts_x =
    scale_upper_trapezoid_pts(x=chassis_pan_servo_recesess_x_len,
                              y=chassis_pan_servo_recesess_thickness);
  trap_pts_y =
    scale_upper_trapezoid_pts(x=chassis_pan_servo_recesess_thickness,
                              y=chassis_pan_servo_recesess_y_len);

  step = chassis_pan_servo_screw_d + chassis_pan_servo_screws_gap;

  slot_rad = chassis_pan_servo_slot_dia / 2;
  total_x = round((chassis_pan_servo_recesess_x_len / 2) / step);
  total_y = round((chassis_pan_servo_recesess_y_len / 2) / step);
  hole_h = chassis_thickness + 1;
  union() {
    translate([0, 0, chassis_thickness - chassis_pan_servo_slot_recess + 0.5]) {
      linear_extrude(height=chassis_pan_servo_slot_recess + 0.5,
                     center=false,
                     convexity=2) {

        offset_vertices_2d(r=0.9) {
          translate([0, -chassis_pan_servo_recesess_thickness / 2, 0]) {
            mirror_copy([1, 0, 0]) {
              polygon(trap_pts_x);
            }
          }
          mirror_copy([0, 1, 0]) {
            mirror_copy([1, 0, 0]) {
              polygon(trap_pts_y);
            }
          }
        }
      }
    }
    translate([0, 0, -0.5]) {
      cylinder(r=slot_rad, h=hole_h, $fn=60);
      mirror_copy([1, 0, 0]) {
        translate([slot_rad
                   + chassis_pan_servo_screws_gap,
                   0,
                   0]) {
          columns_children(gap=chassis_pan_servo_screws_gap,
                           cols=total_x,
                           w=chassis_pan_servo_screw_d) {
            cylinder(r=chassis_pan_servo_screw_d / 2, h=hole_h, $fn=60);
          }
        }
      }
      mirror_copy([0, 1, 0]) {
        translate([0,
                   slot_rad
                   + chassis_pan_servo_screws_gap,
                   0]) {
          rows_children(gap=chassis_pan_servo_screws_gap,
                        rows=total_y,
                        w=chassis_pan_servo_screw_d) {
            cylinder(r=chassis_pan_servo_screw_d / 2, h=hole_h, $fn=60);
          }
        }
      }

      let (row_params = calc_cols_params(cols=chassis_pan_servo_rib_slots_rows,
                                         w=chassis_pan_servo_rib_slots_thickness,
                                         gap=chassis_pan_servo_rib_slots_gap)) {
        translate([0,
                   - chassis_pan_servo_recesess_y_len
                   - row_params[1]
                   - chassis_pan_servo_rib_slots_distance_from_recess,

                   0]) {
          rows_children(gap=chassis_pan_servo_rib_slots_gap,
                        rows=chassis_pan_servo_rib_slots_rows,
                        w=chassis_pan_servo_rib_slots_thickness) {
            cube_3d([chassis_pan_servo_rib_slots_len,
                     chassis_pan_servo_rib_slots_thickness,
                     hole_h]);
          }
        }
      }
    }
  }
}

module head_zone_slot() {
  mirror_copy([1, 0, 0]) {
    translate([0, head_pos, 0]) {
      pan_servo_slot_3d();
    }
  }
}

module chassis_upper_2d() {
  union() {
    offset_vertices_2d(r=chassis_offset_rad) {
      mirror_copy([1, 0, 0]) {
        polygon(points=chassis_upper_pts);
      }
      mirror_copy([1, 0, 0]) {
        translate([0, -chassis_transition_len, 0]) {
          polygon(chassis_transition_pts);
        }
      }
    }
    difference() {
      mirror_copy([1, 0, 0]) {
        translate([0, -chassis_transition_len, 0]) {
          polygon(chassis_transition_pts);
        }
      }
      translate([0, chassis_offset_rad + 1, 0]) {
        mirror_copy([1, 0, 0]) {
          translate([0, -chassis_transition_len, 0]) {
            polygon(chassis_transition_pts);
          }
        }
      }
    }
  }
}

module chassis_upper_rib_hole_base_2d() {
  mirror_copy([1, 0, 0]) {
    polygon(points=top_rib_hole_pts);
  }
}

module chassis_upper_rib_hole(border_mode=false) {
  translate([0,
             0,
             border_mode
             ? chassis_thickness
             : -0.5]) {
    linear_extrude(height=border_mode
                   ? chassis_side_hole_border_h
                   : chassis_thickness + 1,
                   center=false,
                   convexity=2) {

      if (border_mode) {
        translate([0, chassis_upper_holes_border_w, 0]) {
          difference() {
            offset(delta=chassis_upper_holes_border_w) {
              chassis_upper_rib_hole_base_2d();
            }
            chassis_upper_rib_hole_base_2d();
          }
        }
      } else {
        chassis_upper_rib_hole_base_2d();
      }
    }
  }
}

module chassis_upper_rib_hole_slot(border_mode=false) {
  translate([0,
             top_ribbon_hole_pos
             - (border_mode ? chassis_upper_holes_border_w : 0) ,
             0]) {
    chassis_upper_rib_hole(border_mode=border_mode);
  }
}

module chassis_mid_side_trapezoids(border_mode=false) {
  mirror_copy([1, 0, 0]) {
    translate([-chassis_upper_side_hole_margin,
               head_pos - trapezoid_total_y,
               border_mode
               ? chassis_thickness
               : -0.5]) {
      linear_extrude(height=border_mode
                     ?
                     chassis_side_hole_border_h
                     : hole_h,
                     center=false) {
        for (i = [0 : chassis_pan_servo_side_trapezoid_rows - 1]) {
          let (by = i * trapezoid_step,
               available_w =
               poly_width_at_y(pts=chassis_upper_pts,
                               y_target=by + head_pos)) {
            translate([0,
                       by -(border_mode
                            ? chassis_upper_holes_border_w
                            : 0),
                       0]) {

              translate([available_w -
                         chassis_trapezoid_hole_x_distance,
                         -chassis_trapezoid_hole_len / 2,
                         0]) {
                if (border_mode) {
                  translate([0, chassis_upper_holes_border_w, 0]) {
                    difference() {
                      offset(delta=chassis_upper_holes_border_w) {
                        polygon(upper_side_hole_pts);
                      }
                      polygon(upper_side_hole_pts);
                    }
                  }
                } else {
                  polygon(upper_side_hole_pts);
                }
              }
            }
          }
        }
      }
    }
  }
}

module chassis_bottom_side_holes(border_mode=false) {
  mirror_copy([1, 0, 0]) {
    translate([-steering_panel_hinge_w -
               steering_panel_hinge_x_offset
               -chassis_side_hole_border_w,
               0,
               0]) {
      chassis_side_holes_3d(border_mode=border_mode) {
        chassis_upper_side_rect_holes(start=0, border_mode=border_mode);
      }
    }
  }
}

module chassis_upper_transition_rect_slots(border_mode=false) {
  translate([0, -chassis_transition_len, -0.05]) {
    for (specs=chassis_upper_rect_holes_specs) {
      if (border_mode) {
        rounded_rect_slots(specs=specs,
                           center=true,
                           thickness=chassis_thickness + 0.1) {
          let (spec = $spec,
               size = spec[0]) {

            translate([0, 0, chassis_thickness]) {
              difference() {
                scale([1.0, 1.0, 1]) {
                  linear_extrude(height=chassis_trapezoid_border_height,
                                 center=false) {
                    rounded_rect(size=[size[0] + 1,
                                       size[1] + 1],
                                 r=size[2],
                                 center=true);
                  }
                }
                translate([0, 0, -0.5]) {
                  linear_extrude(height=chassis_trapezoid_border_height
                                 + 1,
                                 center=false) {
                    rounded_rect(size=[size[0], size[1]],
                                 r=size[2],
                                 center=true);
                  }
                }
              }
            }
          }
        }
      } else {
        rounded_rect_slots(specs=specs,
                           center=true,
                           thickness=chassis_thickness + 0.1);
      }
    }
  }
}

module chassis_top_most_side_holes(border_mode=false,
                                   parallelogram=true) {
  mirror_copy([1, 0, 0]) {
    chassis_side_holes_3d(border_mode=border_mode) {
      chassis_upper_side_rect_holes(l=chassis_top_most_holes_side_len,
                                    rows=chassis_top_most_holes_rows,
                                    margin=chassis_top_most_holes_margin
                                    + chassis_side_hole_border_w,
                                    w=chassis_top_most_holes_side_w,
                                    gap=chassis_top_most_holes_gap,
                                    start=top_most_rects_start,
                                    border_mode=border_mode,
                                    parallelogram=parallelogram);
    }
  }
}

module chassis_upper_front_panel_slot() {
  translate([0,
             + chassis_upper_len
             + front_panel_bolt_y_offset(),
             0]) {
    translate([0,
               front_panel_connector_len / 2
               - effective_front_pan_dia,
               chassis_upper_front_pan_slot_depth + 0.1]) {
      translate([0, front_panel_connector_offset_rad, 0]) {
        linear_extrude(height=chassis_upper_front_pan_slot_depth + 0.1,
                       center=false) {
          square(size = [front_panel_connector_width + 0.4,
                         front_panel_connector_len + 0.4],
                 center=true);
        }
      }
      rotate([0, 0, 180]) {
        linear_extrude(height=chassis_upper_front_pan_slot_depth + 0.1,
                       center=false) {
          rounded_rect_two(size = [front_panel_connector_width + 0.4,
                                   front_panel_connector_len + 0.4],
                           center=true,
                           r=front_panel_connector_offset_rad);
        }
      }
    }
    translate([0, front_panel_connector_bolts_padding_y, 0]) {
      four_corner_children(front_panel_connector_bolt_spacing, center=true) {
        counterbore(d=front_panel_connector_bolt_dia,
                    h=front_panel_thickness,
                    bore_d=0,
                    bore_h=front_panel_connector_bolt_bore_h,
                    autoscale_step=0.1,
                    reverse=true);
      }
    }
  }
}

module chassis_upper_steering_hinges() {
  translate([0, steering_pan_pos - steering_rack_support_width / 2, 0]) {
    steering_hinges(slot_mode=true);
  }
}

module chassis_upper_3d(panel_color=white_snow_1,
                        bracket_color,
                        head_color,
                        rack_color=white_snow_1,
                        steering_panel_color=white_snow_1,
                        show_front_panel=false,
                        show_ultrasonic=false,
                        show_front_rear_panel=false,
                        show_front_rear_panel_bolts=false,
                        show_front_rear_panel_nuts=false,
                        show_front_panel_mount_bolts=false,
                        show_front_panel_mount_nuts=false,
                        echo_front_panel_bolts_info=false,
                        show_head_assembly=false,
                        show_head=false,
                        show_tilt_servo_bolts=false,
                        show_tilt_servo_nuts=false,
                        show_pan_servo=false,
                        show_pan_servo_bolts=false,
                        show_pan_servo_nuts=false,
                        show_head_servo_horn=false,
                        show_camera=false,
                        show_camera_bolts=false,
                        show_camera_nuts=false,
                        show_ir_case=false,
                        show_ir_case_bolts=false,
                        show_ir_case_nuts=false,
                        show_ir_led=false,
                        show_ir_case_rail=false,
                        show_ir_case_rail_bolts=false,
                        show_ir_case_rail_nuts=false,
                        show_tilt_servo=false,
                        show_steering_panel=true,
                        pinion_color=matte_black,
                        show_wheels=false,
                        show_bearing=false,
                        show_servo_mount_panel=false,
                        show_brackets=false,
                        show_rack=true,
                        show_kingpin_posts=false,
                        show_pinion=false,
                        show_tie_rod=false,
                        show_servo=false,
                        show_knuckles=false,
                        pan_servo_rotation=0,
                        tilt_servo_rotation=0,
                        show_distance=false,
                        show_upper_chassis=true,
                        show_knuckle_bolts=show_knuckle_bolts,
                        show_bolts_info=show_bolts_info,
                        show_kingpin_bolt=show_kingpin_bolt,
                        show_hinges_bolts=show_hinges_bolts,
                        show_panel_bolt=show_panel_bolt,
                        fasten_kingpin_bolt=fasten_kingpin_bolt,
                        fasten_hinges_bolts=fasten_hinges_bolts,
                        fasten_panel_bolt=fasten_panel_bolt) {

  if (show_upper_chassis) {
    difference() {
      color(panel_color, alpha=1) {
        union() {
          linear_extrude(height=chassis_thickness,
                         center=false) {
            chassis_upper_2d();
          }
          translate([0, steering_pan_pos, 0]) {
            steering_chassis_bar_3d(center_y=false);
          }
        }
      }

      chassis_upper_front_panel_slot();
      head_zone_slot();
      chassis_upper_steering_hinges();

      chassis_upper_rib_hole_slot(border_mode=false);
      chassis_top_most_side_holes(border_mode=false);
      chassis_mid_side_trapezoids(border_mode=false);
      chassis_bottom_side_holes(border_mode=false);
      chassis_transition_side_holes(border_mode=false);
      chassis_upper_transition_rect_slots(border_mode=false);
    }
  }

  if (show_upper_chassis) {
    // borders
    chassis_upper_rib_hole_slot(border_mode=true);
    chassis_top_most_side_holes(border_mode=true);
    chassis_mid_side_trapezoids(border_mode=true);
    chassis_bottom_side_holes(border_mode=true);
    chassis_transition_side_holes(border_mode=true);
    chassis_upper_transition_rect_slots(border_mode=true);
  }

  // assembly
  if (show_steering_panel) {
    translate([0, steering_pan_pos, chassis_thickness]) {
      steering_system_assembly(rack_color=rack_color,
                               pinion_color=pinion_color,
                               panel_color=steering_panel_color,
                               show_wheels=show_wheels,
                               show_bearing=show_bearing,
                               show_servo_mount_panel=show_servo_mount_panel,
                               show_brackets=show_brackets,
                               show_rack=show_rack,
                               show_distance=show_distance,
                               show_kingpin_posts=show_kingpin_posts,
                               show_pinion=show_pinion,
                               show_tie_rod=show_tie_rod,
                               show_servo=show_servo,
                               show_knuckles=show_knuckles,
                               show_knuckle_bolts=show_knuckle_bolts,
                               show_bolts_info=show_bolts_info,
                               show_kingpin_bolt=show_kingpin_bolt,
                               show_hinges_bolts=show_hinges_bolts,
                               show_panel_bolt=show_panel_bolt,
                               fasten_kingpin_bolt=fasten_kingpin_bolt,
                               fasten_hinges_bolts=fasten_hinges_bolts,
                               fasten_panel_bolt=fasten_panel_bolt,
                               center_y=false);
    }
  }

  if (show_head_assembly || show_head || show_pan_servo) {
    translate([0,
               head_pos,
               chassis_thickness - chassis_pan_servo_slot_recess]) {
      head_neck(center_pan_servo_slot=true,
                show_pan_servo=show_pan_servo,
                show_tilt_servo=show_tilt_servo,
                show_ir_case=show_ir_case,
                show_camera=show_camera,
                show_ir_led=show_ir_led,
                show_head=show_head,
                pan_servo_rotation=pan_servo_rotation,
                tilt_servo_rotation=tilt_servo_rotation,
                bracket_color=with_default(bracket_color, panel_color),
                head_color=with_default(head_color, panel_color),
                show_tilt_servo_bolts=show_tilt_servo_bolts,
                show_tilt_servo_nuts=show_tilt_servo_nuts,
                show_pan_servo_bolts=show_pan_servo_bolts,
                show_pan_servo_nuts=show_pan_servo_nuts,
                show_servo_horn=show_head_servo_horn,
                show_camera_bolts=show_camera_bolts,
                show_camera_nuts=show_camera_nuts,
                show_ir_case_bolts=show_ir_case_bolts,
                show_ir_case_nuts=show_ir_case_nuts,
                show_ir_case_rail=show_ir_case_rail,
                show_ir_case_rail_bolts=show_ir_case_rail_bolts,
                show_ir_case_rail_nuts=show_ir_case_rail_nuts);
    }
  }

  if (show_front_panel || show_ultrasonic || show_front_rear_panel) {
    translate([0,
               front_pan_y -
               max(front_panel_connector_bolt_bore_dia,
                   front_panel_connector_bolt_dia) / 2,
               chassis_thickness
               - chassis_upper_front_pan_slot_depth]) {

      front_panel_assembly(show_ultrasonic=show_ultrasonic,
                           show_front_panel=true,
                           show_front_rear_panel=show_front_rear_panel,
                           show_front_rear_panel_bolts=show_front_rear_panel_bolts,
                           show_front_rear_panel_nuts=show_front_rear_panel_nuts,
                           show_front_panel_mount_bolts=show_front_panel_mount_bolts,
                           show_front_panel_mount_nuts=show_front_panel_mount_nuts,
                           echo_front_panel_bolts_info=echo_front_panel_bolts_info);
    }
  }
}

module chassis_upper(panel_color=white_snow_1,
                     bracket_color,
                     head_color,
                     rack_color=white_snow_1,
                     steering_panel_color=white_snow_1,
                     show_front_panel=true,
                     show_ultrasonic=true,
                     show_front_rear_panel_bolts=true,
                     show_front_rear_panel_nuts=true,
                     show_front_panel_mount_bolts=true,
                     show_front_panel_mount_nuts=true,
                     echo_front_panel_bolts_info=true,
                     show_front_rear_panel=true,
                     show_tilt_servo=true,
                     show_head_assembly=true,
                     show_head=true,
                     show_tilt_servo_bolts=true,
                     show_tilt_servo_nuts=true,
                     show_pan_servo=true,
                     show_pan_servo_bolts=true,
                     show_pan_servo_nuts=true,
                     show_head_servo_horn=true,
                     show_camera=true,
                     show_camera_bolts=true,
                     show_camera_nuts=true,
                     show_ir_case=true,
                     show_ir_case_bolts=true,
                     show_ir_case_nuts=true,
                     show_ir_led=true,
                     show_ir_case_rail=true,
                     show_ir_case_rail_bolts=true,
                     show_ir_case_rail_nuts=true,
                     show_steering_panel=true,
                     pinion_color=matte_black,
                     show_wheels=false,
                     show_bearing=true,
                     show_servo_mount_panel=true,
                     show_brackets=true,
                     show_rack=true,
                     show_kingpin_posts=true,
                     show_pinion=true,
                     show_tie_rod=true,
                     show_servo=true,
                     show_knuckles=true,
                     tilt_servo_rotation=0,
                     show_distance=false,
                     show_upper_chassis=true,
                     show_knuckle_bolts=show_knuckle_bolts,
                     show_bolts_info=show_bolts_info,
                     show_kingpin_bolt=show_kingpin_bolt,
                     show_hinges_bolts=show_hinges_bolts,
                     show_panel_bolt=show_panel_bolt,
                     fasten_kingpin_bolt=fasten_kingpin_bolt,
                     fasten_hinges_bolts=fasten_hinges_bolts,
                     fasten_panel_bolt=fasten_panel_bolt,
                     pan_servo_rotation=0) {
  union() {
    translate([0, chassis_transition_len, 0]) {
      chassis_upper_3d(panel_color=panel_color,
                       bracket_color=bracket_color,
                       head_color=head_color,
                       rack_color=rack_color,
                       steering_panel_color=steering_panel_color,
                       show_front_panel=show_front_panel,
                       show_ultrasonic=show_ultrasonic,
                       show_front_rear_panel=show_front_rear_panel,
                       show_head_assembly=show_head_assembly,
                       show_head=show_head,
                       show_tilt_servo=show_tilt_servo,
                       show_tilt_servo_bolts=show_tilt_servo_bolts,
                       show_tilt_servo_nuts=show_tilt_servo_nuts,
                       show_pan_servo=show_pan_servo,
                       show_pan_servo_bolts=show_pan_servo_bolts,
                       show_pan_servo_nuts=show_pan_servo_nuts,
                       show_head_servo_horn=show_head_servo_horn,
                       show_camera=show_camera,
                       show_camera_bolts=show_camera_bolts,
                       show_camera_nuts=show_camera_nuts,
                       show_ir_case=show_ir_case,
                       show_ir_case_bolts=show_ir_case_bolts,
                       show_ir_case_nuts=show_ir_case_nuts,
                       show_ir_led=show_ir_led,
                       show_ir_case_rail=show_ir_case_rail,
                       show_ir_case_rail_bolts=show_ir_case_rail_bolts,
                       show_ir_case_rail_nuts=show_ir_case_rail_nuts,
                       show_steering_panel=show_steering_panel,
                       pinion_color=pinion_color,
                       show_wheels=show_wheels,
                       show_bearing=show_bearing,
                       show_servo_mount_panel=show_servo_mount_panel,
                       show_brackets=show_brackets,
                       show_rack=show_rack,
                       show_kingpin_posts=show_kingpin_posts,
                       show_pinion=show_pinion,
                       show_tie_rod=show_tie_rod,
                       show_servo=show_servo,
                       tilt_servo_rotation=tilt_servo_rotation,
                       pan_servo_rotation=pan_servo_rotation,
                       show_knuckles=show_knuckles,
                       show_distance=show_distance,
                       show_upper_chassis=show_upper_chassis,
                       show_knuckle_bolts=show_knuckle_bolts,
                       show_bolts_info=show_bolts_info,
                       show_kingpin_bolt=show_kingpin_bolt,
                       show_hinges_bolts=show_hinges_bolts,
                       show_panel_bolt=show_panel_bolt,
                       fasten_kingpin_bolt=fasten_kingpin_bolt,
                       fasten_hinges_bolts=fasten_hinges_bolts,
                       fasten_panel_bolt=fasten_panel_bolt,
                       show_front_rear_panel_bolts=show_front_rear_panel_bolts,
                       show_front_rear_panel_nuts=show_front_rear_panel_nuts,
                       show_front_panel_mount_bolts=show_front_panel_mount_bolts,
                       show_front_panel_mount_nuts=show_front_panel_mount_nuts,
                       echo_front_panel_bolts_info=echo_front_panel_bolts_info);
    }
    if (chassis_use_connector && show_upper_chassis) {
      color(panel_color, alpha=1) {
        chassis_connector_tongue();
      }
    }
  }
}

module chassis_upper_printable() {
  color("white", alpha=1) {
    chassis_upper(panel_color="white",
                  show_front_panel=false,
                  show_ultrasonic=false,
                  show_front_rear_panel_bolts=false,
                  show_front_rear_panel_nuts=false,
                  show_front_panel_mount_bolts=false,
                  show_front_panel_mount_nuts=false,
                  echo_front_panel_bolts_info=false,
                  show_front_rear_panel=false,
                  show_tilt_servo=false,
                  show_head_assembly=false,
                  show_head=false,
                  show_tilt_servo_bolts=false,
                  show_tilt_servo_nuts=false,
                  show_pan_servo=false,
                  show_pan_servo_bolts=false,
                  show_pan_servo_nuts=false,
                  show_head_servo_horn=false,
                  show_camera=false,
                  show_camera_bolts=false,
                  show_camera_nuts=false,
                  show_ir_case=false,
                  show_ir_case_bolts=false,
                  show_ir_case_nuts=false,
                  show_ir_led=false,
                  show_ir_case_rail=false,
                  show_ir_case_rail_bolts=false,
                  show_ir_case_rail_nuts=false,
                  show_steering_panel=false,
                  pinion_color=matte_black,
                  show_wheels=false,
                  show_bearing=false,
                  show_servo_mount_panel=false,
                  show_brackets=false,
                  show_rack=false,
                  show_kingpin_posts=false,
                  show_pinion=false,
                  show_tie_rod=false,
                  show_servo=false,
                  show_knuckles=false,
                  show_distance=false,
                  show_upper_chassis=false,
                  show_knuckle_bolts=false,
                  show_bolts_info=false,
                  show_kingpin_bolt=false,
                  show_hinges_bolts=false,
                  show_panel_bolt=false,
                  fasten_kingpin_bolt=false,
                  fasten_hinges_bolts=false,
                  fasten_panel_bolt=false);
  }
}

chassis_upper();
