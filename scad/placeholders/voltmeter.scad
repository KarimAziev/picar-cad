/**
 * Module: Placeholder for voltmeter, default parameters as for DSN-DVM-368
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
;
use <./pins.scad>
use <./rpi_5.scad>
use <../wire.scad>
use <standoff.scad>
use <../lib/shapes3d.scad>
use <../lib/transforms.scad>

module voltmeter_display(display_w=voltmeter_display_w,
                         display_len=voltmeter_display_len,
                         display_h=voltmeter_display_h,
                         display_indicators_len=voltmeter_display_indicators_len,
                         display_top_h=1,
                         use_textmetrics=true,
                         text_spec=voltemeter_text_spec) {
  main_h = display_h - display_top_h;
  union() {
    color("white", alpha=1) {
      cube_3d([display_w,
               display_len,
               main_h]);
    }
    translate([0, 0, main_h]) {
      color(matte_black, alpha=1) {
        cube_3d([display_w, display_len, display_top_h]);
      }
      if (use_textmetrics && !is_undef(text_spec)) {
        translate([0, 0, display_top_h]) {
          let (txt=text_spec[0],
               size=text_spec[1],
               font=text_spec[2],
               spacing=text_spec[3],
               colr=text_spec[4],
               tm=textmetrics(text=txt,
                              size=text_spec[1],
                              font=font),
               trans_spec=is_undef(text_spec[5]) ? [0, 0] : text_spec[5],
               text_len = tm.size[0],
               text_w = tm.size[1]) {
            translate(trans_spec) {
              translate([text_w / 2,
                         - display_len / 2,
                         0]) {
                color(colr, alpha=1) {
                  rotate([0, 0, 180]) {
                    rotate([0, 0, -90]) {
                      linear_extrude(height=0.01, center=false) {
                        text(txt,
                             size=size,
                             font=font);
                      }
                    }
                  }
                }
              }
            }
          }
        }
      } else {
        color(metallic_silver_3, alpha=1) {
          let (allowed_w = display_w * 0.9,
               total_inner_w = allowed_w * 0.92,
               L = display_len * 0.90,
               n = display_indicators_len,
               t = (L / n) - 1,
               g = (L - n * t) / (n - 1),
               margin = (display_len - L) / 2,
               step = t + g,
               start = margin + t/2) {
            translate([0, -display_len / 2, 0]) {
              for (i = [0 : n - 1]) {
                let (y = start + i * step,
                     inner_t = t * 0.8,
                     inner_w = (total_inner_w / 2)) {
                  translate([0, y, 0])
                    union() {
                    difference() {
                      rounded_cube(size=[allowed_w, t, display_top_h + 0.01],
                                   center=true,
                                   r_factor=0.1);
                      translate([inner_w / 2, 0, 0]) {
                        rounded_cube(size=[inner_w - 0.5, inner_t, display_top_h + 0.1],
                                     center=true,
                                     r_factor=0.3);
                      }
                      translate([-inner_w / 2, 0, 0]) {
                        rounded_cube(size=[inner_w - 0.5, inner_t, display_top_h + 0.1],
                                     center=true,
                                     r_factor=0.3);
                      }
                    }
                    translate([allowed_w / 2 - 0.5, t / 2 + g / 3, 0]) {
                      cylinder(h = display_top_h + 0.01, r = 0.5, center = false, $fn=10);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

module voltmeter_board(show_standoffs=true,
                       standoff_thread_h=voltmeter_standoff_thread_h,
                       snandoff_body_h=voltmeter_pin_h,
                       screw_dia=voltmeter_screw_dia,
                       board_w=voltmeter_board_w,
                       board_len=voltmeter_board_len,
                       board_h=voltmeter_board_h,
                       screw_size=voltmeter_screw_size,
                       wiring_d=voltmeter_wiring_d,
                       wiring_gap=voltmeter_wiring_gap,
                       pin_h=voltmeter_pin_h,
                       pins_len=voltmeter_pins_len,
                       pin_thickness=voltmeter_pin_thickness,
                       pins_count=voltmeter_pins_count,
                       wiring_distance=voltmeter_wiring_distance,
                       standoff_body_d=voltmeter_standoff_body_d,
                       wiring=[[50, -80, 0]]) {
  wiring_r = wiring_d / 2;

  union() {
    difference() {
      union() {
        union() {
          color(green_2, alpha=1) {
            cube_3d([board_w,
                     board_len,
                     board_h]);
          }
          four_corner_children(size=screw_size) {
            color(green_2, alpha=1) {
              cube_3d(size=[screw_dia + 2,
                            screw_dia + 2,
                            board_h], center=true);
            }
          }
        }

        gap = (pins_len -
               pins_count * pin_thickness)
          / (pins_count - 1);
        step = pin_thickness + gap;

        color(metallic_silver_1, alpha=1) {
          mirror_copy([1, 0, 0]) {
            translate([-board_w / 2 + pin_thickness / 2,
                       -board_len / 2 + pins_len / 2,
                       -pin_h]) {
              translate([0,
                         -pins_len / 2 + pin_thickness / 2,
                         0]) {
                for (i = [0 : pins_count - 1]) {
                  let (y = i * step) {

                    translate([0, y, 0]) {
                      cylinder(h = pin_h,
                               r1 = pin_thickness * 0.1,
                               r2 = pin_thickness / 2,
                               center = false);
                    }
                  }
                }
              }
            }
          }
        }

        let (wiring_pin_h=1) {

          translate([board_w / 2 - wiring_r,
                     board_len / 2
                     - wiring_r
                     - wiring_distance,
                     0]) {
            translate([0, 0, -wiring_pin_h]) {
              cylinder(h=wiring_pin_h,
                       r1=wiring_r * 0.3,
                       r2=wiring_r * 1.2,
                       $fn=10);
              translate([0,
                         -wiring_d -
                         wiring_gap, 0]) {
                cylinder(h=wiring_pin_h,
                         r1=wiring_r * 0.3,
                         r2=wiring_r * 1.2,
                         $fn=10);
              }
            }
            translate([0, 0, -wiring_r]) {
              color(red_1, alpha=1) {
                wire_path(concat([[0, 0, 0]],
                                 wiring),
                          d=wiring_d);
              }
              translate([0, -wiring_gap - wiring_r, 0]) {
                color(black_1, alpha=1) {
                  wire_path(concat([[0, 0, 0]],
                                   wiring),
                            d=wiring_d);
                }
              }
            }
          }
        }
      }
      four_corner_children(size=screw_size) {
        translate([0, 0, -0.5]) {
          cylinder(h=board_h + 1,
                   r=screw_dia / 2,
                   center = false,
                   $fn=15);
        }
      }
    }

    if (show_standoffs) {
      four_corner_children(size=screw_size) {
        translate([0, 0, -snandoff_body_h]) {
          standoff(thread_h=standoff_thread_h,
                   thread_d=screw_dia,
                   body_h=snandoff_body_h,
                   body_d=standoff_body_d);
        }
      }
    }
  }
}

module voltmeter(show_standoffs=true,
                 show_board=true,
                 show_display=true,
                 standoff_thread_h=voltmeter_standoff_thread_h,
                 snandoff_body_h=voltmeter_pin_h,
                 standoff_body_d=voltmeter_standoff_body_d,
                 board_w=voltmeter_board_w,
                 board_len=voltmeter_board_len,
                 board_h=voltmeter_board_h,
                 screw_size=voltmeter_screw_size,
                 screw_dia=voltmeter_screw_dia,
                 display_w=voltmeter_display_w,
                 display_len=voltmeter_display_len,
                 display_h=voltmeter_display_h,
                 display_indicators_len=voltmeter_display_indicators_len,
                 display_top_h=1,
                 pin_h=voltmeter_pin_h,
                 pins_len=voltmeter_pins_len,
                 pin_thickness=voltmeter_pin_thickness,
                 pins_count=voltmeter_pins_count,
                 wiring_d=voltmeter_wiring_d,
                 wiring=[[-5, -5, -2],
                         [-15, -10, -1],
                         [10, -15, -2],
                         [20, 0, 0]],
                 wiring_gap=voltmeter_wiring_gap,
                 wiring_distance=voltmeter_wiring_distance,
                 text_spec=voltemeter_text_spec) {
  union() {
    if (show_board) {
      voltmeter_board(show_standoffs=show_standoffs,
                      standoff_thread_h=standoff_thread_h,
                      snandoff_body_h=snandoff_body_h,
                      board_w=board_w,
                      board_len=board_len,
                      board_h=board_h,
                      screw_size=screw_size,
                      screw_dia=screw_dia,
                      wiring_d=wiring_d,
                      wiring=wiring,
                      wiring_gap=wiring_gap,
                      pin_h=pin_h,
                      pins_len=pins_len,
                      pin_thickness=pin_thickness,
                      pins_count=pins_count,
                      wiring_distance=wiring_distance,
                      standoff_body_d=standoff_body_d);
    }
    if (show_display) {
      translate([0, 0, board_h]) {
        voltmeter_display(display_w=display_w,
                          display_len=display_len,
                          display_h=display_h,
                          display_indicators_len=display_indicators_len,
                          display_top_h=display_top_h,
                          text_spec=text_spec);
      }
    }
  }
}

rotate([0, 0, 0]) {
  voltmeter(wiring=[[0, -5, -2],
                    [-22, -15, -1],
                    [-22, 10, -60],
                    [-70, 10, -60]]);
}