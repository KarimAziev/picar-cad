/**
 * Module: Case for IR LED. This file contains an enclosure for a modified
 * Waveshare Infrared LED Light Board Module.
 *
 * The original LED board is incompatible with the Raspberry Camera Module 3,
 * and the quality of Waveshare’s original camera is unsatisfactory.
 *
 * Nevertheless, this LED board can be used with Camera Module 3 and other
 * Raspberry Pi cameras. To do so, solder two wires (GND and V+) to the bolt
 * holes on the LED board (the bolt holes serve both for mechanical attachment
 * and for power). Then connect the positive wire to 3.3V and the ground wire to
 * GND.
 *
 * Two key modules in this file:

 * ir_case_printable: provides the LED housing and a “rail” that secures it with
 * two M2 bolts. The housing also includes a bracket for mounting to the robot
 * head.
 *
 * ir_case_assembly: renders the assembled unit. (In head/head_mount.scad you
 * can also call head_mount(show_ir_case=true) to view the assembly mounted on
 * the head.)
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/debug.scad>
use <../lib/functions.scad>
use <../lib/l_bracket.scad>
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/slider.scad>
use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <../placeholders/ir_led.scad>

function is_ir_case_light_detector_enabled(name) =
  ir_light_detector_position == "both"
  || ir_light_detector_position == name;

function is_ir_case_bracket_enabled(name) = ir_case_bracket_position == "both"
                                            || ir_case_bracket_position == name;

function ir_case_face_thickness() = ir_case_thickness
                                    + ir_case_led_boss_thickness;

function ir_case_optical_opening_height() = ir_case_led_dia
                                  + ir_light_detector_dia
                                  + ir_light_offset_from_led_y;

function ir_case_back_depth() =
  ir_case_face_thickness() + ir_case_carriage_h
  + ir_case_rail_h + ir_case_rail_protrusion_h;

function ir_case_carriage_center_y() =
  ir_case_height
  + ir_light_offset_from_led_y
  - ir_light_detector_dia
  - ir_case_led_dia / 2;

function ir_case_rail_edge_y() =
  ir_case_carriage_center_y()
  - ir_case_rail_w / 2
  + ir_case_rail_clearance / 2;

/**
  ─────────────────────────────────────────────────────────────────────────────
  ir_case_mount_interface
  ─────────────────────────────────────────────────────────────────────────────
  Describe the bottom mounting foot in its X/Z mounting plane.
  **Returns:**
  Property list with `size` [width, depth, thickness], `bolt_spacing` [X, Z]
  center spacing, `bolt_origin` [X, Z] of the first hole, `bolt_d` clearance
  diameter, and `hardware_r` enclosing the bolt head and ordinary nut.
  The front row clears the enclosure face; the side rows clear the gussets.
  `ir_case_mount_rear_pad` is the rear hole-center to foot-edge distance.
 */
function ir_case_mount_interface() =
  let (d=ir_case_mount_bolt_d,
       nominal_d=snap_bolt_d(d),
       head_r=find_bolt_head_d(nominal_d, "pan") / 2,
       nut_r=plist_get("outer_dia", find_nut_spec(nominal_d)) / 2,
       side=ir_case_mount_gusset_width + head_r + ir_case_mount_side_pad,
       front=ir_case_face_thickness() + head_r + ir_case_mount_front_pad,
       spacing=[ir_case_width - 2 * side, ir_case_mount_bolt_spacing_y],
       depth=front + spacing[1] + ir_case_mount_rear_pad)
  assert(d > 0 && spacing[0] > 2 * max(head_r, nut_r)
         && spacing[1] > 2 * max(head_r, nut_r),
         "IR mounting bolts must have separate bearing areas")
  assert(ir_case_mount_side_pad >= 0 && ir_case_mount_front_pad >= 0,
         "IR mounting hardware clearances must be nonnegative")
  assert(ir_case_mount_rear_pad >= max(head_r, nut_r),
         "IR rear pad must support the mounting hardware")
  ["size", [ir_case_width, depth, ir_case_mount_foot_thickness],
   "bolt_spacing", spacing,
   "bolt_origin", [side, front],
   "bolt_d", d,
   "hardware_r", max(head_r, nut_r)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  ir_case_mount_foot_size
  ─────────────────────────────────────────────────────────────────────────────
  Return the mounting footprint [width, depth, thickness] in millimeters.
 */
function ir_case_mount_foot_size() = plist_get("size", ir_case_mount_interface());

function ir_case_mount_foot_corner_r() =
  min(ir_case_mount_foot_size()[0], ir_case_mount_foot_size()[1]) / 4;

/**
  ─────────────────────────────────────────────────────────────────────────────
  ir_case_mount_bolt_length
  ─────────────────────────────────────────────────────────────────────────────
  Return an even-millimeter bolt length covering the foot, support, and nut.
  **Parameters:**
  - `mount_thickness`: Supporting plate thickness below the foot.
 */
function ir_case_mount_bolt_length(mount_thickness=3) =
  let (nut=find_nut_spec(snap_bolt_d(ir_case_mount_bolt_d)),
       grip=ir_case_mount_foot_size()[2] + mount_thickness)
  assert(mount_thickness > 0)
  ceil((grip + plist_get("height", nut) + ir_case_mount_thread_allowance) / 2) * 2;

/**
  ─────────────────────────────────────────────────────────────────────────────
  at_ir_case_mount_bolts
  ─────────────────────────────────────────────────────────────────────────────
  Place children at the four mounting centers in the case's X/Z plane.
  Children use +Z as their bolt axis, pointing toward the case's negative Y.
 */
module at_ir_case_mount_bolts() {
  mount = ir_case_mount_interface();
  origin = plist_get("bolt_origin", mount);
  translate([origin[0], 0, origin[1]]) {
    rotate([90, 0, 0]) {
      four_corner_children(size=plist_get("bolt_spacing", mount), center=false) {
        children();
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  ir_case_mount_foot
  ─────────────────────────────────────────────────────────────────────────────
  Gusseted mounting foot below the enclosure, extending toward positive Z.
  **Parameters:**
  - `slot_mode`: Emit the foot's vertical mounting holes only.
  - `show_bolts`, `show_nuts`: Mounting hardware visibility.
  - `mount_thickness`: Thickness of the supporting plate beneath the foot.
  - `debug`: Label the gusset profile vertices.
  - `color`: Printed part color.
  **Behavior:**
  The foot spans X=0..size[0], Y=-size[2]..0, Z=0..size[1], where
  size is ir_case_mount_foot_size(). Gussets meet the slider's lower edge.
 */
module ir_case_mount_foot(slot_mode=false,
                        show_bolts=false,
                        show_nuts=false,
                        mount_thickness=3,
                        debug=false,
                        color="white") {
  mount = ir_case_mount_interface();
  size = plist_get("size", mount);
  t = size[2];
  bolt_l = ir_case_mount_bolt_length(mount_thickness);
  depth = size[1];
  rib = ir_case_mount_gusset_width;

  full_thickness = ir_case_back_depth();

  rail_w = 2 * ir_case_carriage_wall_thickness
           + ir_case_rail_w - ir_case_rail_clearance;
  corner_r = ir_case_mount_foot_corner_r();

  rail_y = ir_case_carriage_center_y() - rail_w / 2;

  rib_pts = [[0, 0],
             [-depth + corner_r, 0],
             [-full_thickness, rail_y],
             [0, rail_y]];

  module slots() {
    at_ir_case_mount_bolts() {
      translate([0, 0, -0.1]) {
        cylinder(d=plist_get("bolt_d", mount), h=t + 0.2, $fn=40);
      }
    }
  }
  if (slot_mode) {
    slots();
  } else {
    difference() {
      color(color, alpha=1) {
        union() {
          translate([0, -t, 0]) {
            cuboid([ir_case_width, t, depth],
                   anchor=[1, 1, 1],
                   r=corner_r,
                   side="top",
                   axis="y");
          }
          for (x=[0, ir_case_width - rib]) {
            translate([x, 0, 0]) {
              rotate([0, 90, 0]) {
                linear_extrude(height=rib) {
                  polygon(rib_pts);
                }
              }
            }
          }
        }
      }
      slots();
    }
    if (debug) {
      for (x=[0, ir_case_width - rib]) {
        translate([x - 1, 0, 0]) {
          rotate([0, 90, 0]) {
            debug_polygon_text(rib_pts,
                               rotation=[0, 180, 90],
                               font_size=2,
                               h=5);
          }
        }
      }
    }

    if (show_bolts) {
      at_ir_case_mount_bolts() {
        translate([0, 0, bolt_l]) {
          rotate([180, 0, 0]) {
            bolt(d=plist_get("bolt_d", mount),
                 h=bolt_l,
                 nut_head_distance=t + mount_thickness,
                 show_nut=show_nuts);
          }
        }
      }
    }
  }
}

module ir_case_rail_bolt_holes() {
  y_pos = ir_case_carriage_center_y();
  translate([ir_case_carriage_len / 2,
             y_pos,
             0]) {
    circle(r=ir_case_rail_bolt_dia / 2, $fn=360);
  }
  translate([ir_case_width
             - ir_case_carriage_len / 2,
             y_pos,
             0]) {
    circle(r=ir_case_rail_bolt_dia / 2, $fn=360);
  }
}

module ir_case_rail(color,
                    show_ir_case_rail_bolts=false,
                    show_ir_case_rail_nuts=false,
                    echo_bolts_info=false) {
  full_thickness = ir_case_back_depth();

  inner_w = ir_case_rail_w - ir_case_rail_clearance;

  base_w = (ir_case_carriage_wall_thickness * 2) + inner_w;

  union() {
    difference() {
      translate([ir_case_width,
                 ir_case_rail_edge_y()
                 - ir_case_carriage_wall_thickness,
                 full_thickness]) {

        color(color, alpha=1) {
          rotate([0, 0, 90]) {
            rotate([-90, 0, 0]) {
              slider_dovetail_rail(l=ir_case_width,
                                   base_h=ir_case_rail_protrusion_h,
                                   base_w=base_w,
                                   center=false,
                                   reverse=true,
                                   base_angle=ir_case_rail_protrusion_angle,
                                   h=ir_case_rail_h,
                                   w=inner_w,
                                   angle=ir_case_rail_angle,
                                   r=ir_case_rail_offset_rad,
                                   base_r=ir_case_rail_protrusion_offset_rad);
            }
          }
        }
      }
      linear_extrude(height=full_thickness + 1,
                     center=false,
                     convexity=2) {
        ir_case_rail_bolt_holes();
      }
    }
    if (show_ir_case_rail_bolts) {
      let (y_pos = ir_case_carriage_center_y(),
           nut_spec = find_nut_spec(inner_d=ir_case_rail_bolt_dia,
                                    lock=true),
           nut_h = plist_get("height", nut_spec, 2),
           bolt_h = ceil(nut_h + full_thickness)) {
        if (echo_bolts_info) {
          echo(str("IR case rail bolt: M", snap_bolt_d(ir_case_rail_bolt_dia),
                   "x",
                   bolt_h, "mm"));
        }

        translate([ir_case_carriage_len / 2,
                   y_pos,
                   bolt_h]) {

          rotate([180, 0, 0]) {
            bolt(h=bolt_h,
                 lock_nut=true,
                 d=ir_case_rail_bolt_dia,
                 show_nut=show_ir_case_rail_nuts,
                 nut_head_distance=full_thickness);
          }
        }
        translate([ir_case_width
                   - ir_case_carriage_len / 2,
                   y_pos,
                   bolt_h]) {
          rotate([180, 0, 0]) {
            bolt(h=bolt_h,
                 lock_nut=true,
                 d=ir_case_rail_bolt_dia,
                 nut_head_distance=full_thickness,
                 show_nut=show_ir_case_rail_nuts);
          }
        }
      }
    }
  }
}

module ir_case_carriages() {
  thickness = ir_case_face_thickness();
  full_w = ir_case_rail_w + (ir_case_carriage_wall_thickness * 2);

  difference() {
    translate([0,
               ir_case_carriage_center_y()
               - full_w / 2,
               0]) {
      rotate([0, 0, 90]) {
        translate_copy([0, -ir_case_width + ir_case_carriage_len, 0]) {
          rotate([90, 0, 0]) {
            slider_carriage(l=ir_case_carriage_len,
                            h=ir_case_rail_h,
                            w=ir_case_rail_w,
                            base_h=thickness + ir_case_carriage_h,
                            angle=ir_case_rail_angle,
                            wall=ir_case_carriage_wall_thickness,
                            r=ir_case_carriage_offset_rad,
                            trapezoid_rad=ir_case_rail_offset_rad);
          }
        }
      }
    }

    linear_extrude(height=thickness
                          + ir_case_carriage_h + 1,
                   center=false,
                   convexity=2) {
      ir_case_rail_bolt_holes();
    }
  }
}

module ir_case_holes_2d() {
  ir_rad = ir_case_led_dia / 2;
  ir_light_rad = ir_light_detector_dia / 2;
  ir_light_x = ir_rad - ir_light_rad + ir_light_offset_from_led_x;
  ir_light_y = ir_rad + ir_light_rad + ir_light_offset_from_led_y;

  translate([ir_case_width / 2,
             ir_rad,
             0]) {
    circle(r=ir_rad, $fn=200);

    for (pos = [is_ir_case_light_detector_enabled("right")
                ? [ir_light_x, ir_light_y, 0]
                : undef,
                is_ir_case_light_detector_enabled("left")
                ? [-ir_light_x, ir_light_y, 0]
                : undef]) {
      if (!is_undef(pos)) {
        translate(pos) {
          circle(r=ir_light_rad, $fn=100);
        }
      }
    }
  }
}

module ir_case_outline_2d(center=false, fn, mount="side") {
  w = ir_case_width;
  h = ir_case_height;
  rad1 = (ir_light_detector_dia / 2);
  rad2 = ir_case_led_dia / 2;

  offst = center ? [-w/2, -h/2] : [0, 0];

  hull() {
    if (mount == "top") {
      translate(offst) {
        square([w, h - rad1]);
      }
    } else {
      translate([rad2, rad2] + offst) {
        circle(rad2, $fn=fn);
      }
      translate([w - rad2, rad2] + offst) {
        circle(rad2, $fn=fn);
      }
    }

    translate([rad1, h - rad1] + offst) {
      circle(rad1, $fn=fn);
    }
    translate([w - rad1, h - rad1] + offst) {
      circle(rad1, $fn=fn);
    }
  }
}

module ir_case_base_plate(h=ir_case_thickness, mount="side") {
  linear_extrude(height=h, center=false, convexity=2) {
    difference() {
      ir_case_outline_2d(mount=mount);
      translate([0,
                 ir_case_height
                 - ir_case_optical_opening_height()
                 - ir_case_holes_distance_from_top,
                 0]) {
        ir_case_holes_2d();
      }
      ir_case_rail_bolt_holes();
    }
  }
}

module ir_case_side_bolt_holes() {
  for (x=ir_case_side_bolt_offsets) {
    translate([0, x, 0]) {
      circle(r=ir_case_side_bolt_d / 2, $fn=360);
    }
  }
}

module ir_case_bracket(show_bolts=false,
                       show_nuts=false,
                       color,
                       mount_thickness=2,
                       echo_bolts_info=false) {
  thickness = ir_case_face_thickness();
  l_bracket(size=[ir_case_l_bracket_w,
                  ir_case_l_bracket_h,
                  ir_case_l_bracket_len],
            center=false,
            bracket_color=color,
            thickness=thickness,
            children_modes=[["difference", "horizontal"],
                            ["union", "horizontal"]],
            y_r=min(ir_case_l_bracket_h, ir_case_l_bracket_w) * 0.5,
            z_r=0) {
    ir_case_side_bolt_holes();

    if (show_bolts) {
      let (nut_spec = find_nut_spec(inner_d=ir_case_side_bolt_d,
                                    lock=false),
           nut_h = plist_get("height", nut_spec, 2),
           bolt_h = ceil(nut_h + mount_thickness + thickness)) {
        union() {
          if (echo_bolts_info) {
            echo(str("IR case bracket bolt: M", snap_bolt_d(ir_case_side_bolt_d),
                     "x",
                     bolt_h, "mm"));
          }
          for (x=ir_case_side_bolt_offsets) {
            translate([0, x, thickness / 2 - bolt_h]) {
              bolt(d=ir_case_side_bolt_d,
                   h=bolt_h,
                   nut_head_distance=mount_thickness + thickness,
                   show_nut=show_nuts);
            }
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  ir_case
  ─────────────────────────────────────────────────────────────────────────────
  IR enclosure with a selectable mounting interface.
  **Parameters:**
  - `show_bolts`, `show_nuts`: Mount fastener visibility.
  - `mount`: "side" for lateral brackets, "top" for a gusseted bottom foot.
  - `mount_thickness`: Supporting panel thickness for hardware placement.
  - `echo_bolts_info`: Print side-bracket fastener dimensions.
  - `center`: Center the enclosure face in X/Y; the foot extends below it.
  - `color`: Enclosure color.
  **Behavior:**
  The enclosure face occupies X/Y and its back extends along positive Z.
  A top foot extends below Y=0. ir_case_printable places it on the print bed.
 */
module ir_case(show_bolts=false,
               mount="side",
               show_nuts=false,
               mount_thickness=2,
               echo_bolts_info=false,
               center=false,
               color) {
  assert(mount == "side" || mount == "top", "Unknown IR mounting interface");
  full_thickness = ir_case_face_thickness();

  y_offst = ir_case_height - ir_case_holes_distance_from_top
            - ir_light_detector_dia;
  maybe_translate([center ? -ir_case_width / 2 : 0,
                   center ? -ir_case_height / 2 : 0,
                   0]) {
    union() {
      color(color, alpha=1) {
        difference() {
          ir_case_base_plate(h=full_thickness, mount=mount);
          translate([0,
                     y_offst,
                     ir_case_led_boss_thickness]) {
            linear_extrude(height=ir_case_thickness
                                  + ir_case_led_boss_thickness,
                           center=false,
                           convexity=2) {
              square([ir_case_width + 1, ir_case_height], center=false);
            }
          }
        }
      }

      color(color, alpha=1) {
        ir_case_carriages();
      }

      if (mount == "top") {
        ir_case_mount_foot(show_bolts=show_bolts,
                         show_nuts=show_nuts,
                         color=color,
                         mount_thickness=mount_thickness);
      }
      if (mount == "side") {
        for (spec = [["right",
                      [ir_case_l_bracket_len + ir_case_width, y_offst, 0],
                      [90, 0, -90]],
                     ["left",
                      [-ir_case_l_bracket_len, y_offst - ir_case_l_bracket_w, 0],
                      [90, 0, 90]]]) {
          let (name = spec[0],
               offst = spec[1],
               rotation = spec[2]) {
            if (is_ir_case_bracket_enabled(name)) {
              translate(offst) {
                rotate(rotation) {
                  ir_case_bracket(show_bolts=show_bolts,
                                  show_nuts=show_nuts,
                                  color=color,
                                  mount_thickness=mount_thickness,
                                  echo_bolts_info=echo_bolts_info);
                }
              }
            }
          }
        }
      }
    }
  }
}

module ir_case_assembly(show_rail=true,
                        mount="side",
                        show_ir_led=true,
                        show_ir_case_bolts=true,
                        show_ir_case_nuts=true,
                        show_ir_case_rail_bolts=true,
                        show_ir_case_rail_nuts=true,
                        echo_bolts_info=true,
                        mount_thickness=2,
                        case_color="white",
                        rail_color="white") {
  union() {
    ir_case(mount=mount,
            show_bolts=show_ir_case_bolts,
            show_nuts=show_ir_case_nuts,
            mount_thickness=mount_thickness,
            color=case_color,
            echo_bolts_info=echo_bolts_info);
    if (show_rail) {
      ir_case_rail(color=rail_color,
                   show_ir_case_rail_bolts=show_ir_case_rail_bolts,
                   show_ir_case_rail_nuts=show_ir_case_rail_nuts,
                   echo_bolts_info=echo_bolts_info);
    }
    if (show_ir_led) {
      translate([ir_led_board_w +
                 ((ir_case_width - ir_led_board_w) / 2),
                 0,
                 ir_case_face_thickness()
                 + ir_led_thickness]) {
        rotate([0, 180, 0]) {
          ir_led_board();
        }
      }
    }
  }
}

module ir_case_printable(show_rail=true,
                         mount="side",
                         show_case=true,
                         spacing=2,
                         case_color="white",
                         rail_color="white") {
  union() {
    if (show_case) {
      translate([0, mount == "top" ? ir_case_mount_foot_thickness : 0, 0]) {
        color(case_color, alpha=1) {
          ir_case(mount=mount);
        }
      }
    }

    if (show_rail) {
      rotate([180, 0, 0]) {
        translate([0,
                   spacing,
                   -ir_case_face_thickness()
                   - ir_case_carriage_h
                   - ir_case_rail_protrusion_h
                   - ir_case_rail_h]) {
          color(rail_color) {
            ir_case_rail();
          }
        }
      }
    }
  }
}

// ir_case_printable(show_case=true, show_rail=true, mount="top");
ir_case_assembly(mount="top");

// ir_case_mount_foot(show_bolts=false,
//                  show_nuts=false,
//                  mount_thickness=3);
