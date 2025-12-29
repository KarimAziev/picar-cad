/**
 * Module: Placeholder for voltmeter, default parameters as for DSN-DVM-368
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <./pins.scad>
use <./rpi_5.scad>
use <../wire.scad>
use <standoff.scad>
use <../lib/shapes3d.scad>
use <../lib/transforms.scad>
use <../lib/plist.scad>
use <../lib/text.scad>
use <../lib/functions.scad>

module voltemeter_text(txt, text_props) {
  let (rotation=plist_get("rotation", text_props, [0, 0, 0]),
       translation=plist_get("translation", text_props, [0, 0, 0]),
       merged_pl = plist_merge(with_default(text_props, []),
                               ["rotation", [0, 0, -90]])) {
    translate(translation) {
      rotate(rotation) {
        rotate([0, 0, 180]) {
          text_from_plist(txt=txt,
                          plist=merged_pl,
                          default_halign = "center",
                          default_valign = "center",
                          default_font="DSEG14 Classic:style=Italic",
                          default_size=4,
                          default_spacing=1,
                          default_color=red_1);
        }
      }
    }
  }
}

module voltmeter_display(txt, display, text_props) {
  let (size=plist_get("size",
                      display,
                      [voltmeter_display_w,
                       voltmeter_display_len,
                       voltmeter_display_h]),
       display_w=size[0],
       display_len=size[1],
       display_h=size[2],
       txt=with_default(txt, plist_get("text", with_default(text_props, []))),
       upper_thickness=plist_get("upper_thickness", display, 1),
       upper_color=plist_get("upper_color", display, matte_black),
       bottom_color=plist_get("bottom_color", display, "white")) {
    main_h = display_h - upper_thickness;
    union() {
      color(bottom_color, alpha=1) {
        cube_3d([display_w,
                 display_len,
                 main_h]);
      }
      translate([0, 0, main_h]) {
        color(upper_color, alpha=1) {
          cube_3d([display_w, display_len, upper_thickness]);
        }

        if (!is_undef(txt)) {
          translate([0, 0, upper_thickness]) {
            voltemeter_text(txt, text_props);
          }
        }
      }
    }
  }
}
module voltmeter_board(show_standoffs=true,
                       size=[voltmeter_board_w,
                             voltmeter_board_len,
                             voltmeter_board_h],
                       pins=voltmeter_default_pins_spec,
                       wiring=["d", voltmeter_wiring_d,
                               "distance", voltmeter_wiring_distance,
                               "path", []],
                       bolt_dia=voltmeter_bolt_dia,
                       bolt_spacing=voltmeter_bolt_spacing,
                       standoff_body_h=voltmeter_pin_h) {

  board_w = size[0];
  board_len = size[1];
  board_h = size[2];

  wiring_d = plist_get("d", wiring, 3);
  wiring_r = wiring_d / 2;
  wiring_distance = plist_get("distance", wiring, voltmeter_wiring_distance);
  wiring_gap = plist_get("gap", wiring, voltmeter_wiring_gap);
  wpath = plist_get("path", wiring, []);
  pin_size = plist_get("size",
                       pins,
                       [voltmeter_pin_thickness, voltmeter_pin_h]);

  pins_count = plist_get("count", pins, 0);
  pins_len = plist_get("total_len", pins, 0);
  pin_thickness = pin_size[0];
  pin_h = pin_size[1];

  union() {
    difference() {
      union() {
        union() {
          color(green_2, alpha=1) {
            cube_3d([board_w,
                     board_len,
                     board_h]);
          }
          four_corner_children(size=bolt_spacing) {
            color(green_2, alpha=1) {
              cube_3d(size=[bolt_dia + 2,
                            bolt_dia + 2,
                            board_h],
                      center=true);
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
                         -wiring_d - wiring_gap,
                         0]) {
                cylinder(h=wiring_pin_h,
                         r1=wiring_r * 0.3,
                         r2=wiring_r * 1.2,
                         $fn=10);
              }
            }
            if (!is_undef(wpath) && len(wpath) > 0) {
              translate([0, 0, -wiring_r]) {
                wire_path(concat([[0, 0, 0]],
                                 wpath),
                          d=wiring_d,
                          colr=red_1);

                translate([0, -wiring_gap - wiring_r, 0]) {
                  wire_path(concat([[0, 0, 0]],
                                   wpath),
                            d=wiring_d,
                            colr=black_1);
                }
              }
            }
          }
        }
      }
      four_corner_children(size=bolt_spacing) {
        translate([0, 0, -0.5]) {
          cylinder(h=board_h + 1,
                   r=bolt_dia / 2,
                   center = false,
                   $fn=15);
        }
      }
    }

    if (show_standoffs) {
      four_corner_children(size=bolt_spacing) {
        translate([0, 0, -standoff_body_h]) {
          standoffs_stack(d=bolt_dia,
                          min_h=standoff_body_h);
        }
      }
    }
  }
}
module voltmeter(show_standoffs=true,
                 show_board=true,
                 show_display=true,
                 stand_up=true,
                 center=true,
                 standoff_body_h=voltmeter_pin_h,
                 board_size=[voltmeter_board_w,
                             voltmeter_board_len,
                             voltmeter_board_h],
                 bolt_spacing=voltmeter_bolt_spacing,
                 bolt_dia=voltmeter_bolt_dia,
                 display=plist_get("display", voltmeter_default_spec),
                 text=plist_get("text", voltmeter_default_spec, ""),
                 text_props=plist_get("text_props", voltmeter_default_spec,
                                      ["font", "DSEG14 Classic:style=Italic", "size", 6]),
                 pins=voltmeter_default_pins_spec,
                 wiring=["d", voltmeter_wiring_d,
                         "distance", voltmeter_wiring_distance,
                         "path", []]) {
  standoff_params = calc_standoff_params(min_h=standoff_body_h, d=bolt_dia);
  standoff_real_h = len(standoff_params[1]) > 0 ? sum(standoff_params[1]) : 0;
  translate([center ? 0 : max(board_size[0], bolt_spacing[0]) / 2,
             center ? 0 : max(board_size[1], bolt_spacing[1] + bolt_dia) / 2,
             stand_up ? standoff_real_h : 0]) {
    union() {
      if (show_board) {
        voltmeter_board(show_standoffs=show_standoffs,
                        size=board_size,
                        pins=pins,
                        wiring=wiring,
                        bolt_dia=bolt_dia,
                        bolt_spacing=bolt_spacing,
                        standoff_body_h=standoff_real_h);
      }
      if (show_display && !is_undef(display)) {
        translate([0, 0, board_size[2]]) {
          voltmeter_display(txt=text, display=display, text_props=text_props);
        }
      }
    }
  }
}

module voltmeter_from_plist(plist,
                            center=true,
                            debug=false,
                            stand_up=false,
                            show_standoffs=true) {
  if (debug) {
    echo("voltmeter_from_plist plist: ", plist);
  }
  data = plist;
  text_props = plist_get("text_props", plist);
  text = plist_get("text", plist);
  board_size = plist_get("placeholder_size",
                         plist,
                         [voltmeter_board_w,
                          voltmeter_board_len,
                          voltmeter_board_h]);
  slot_size = plist_get("slot_size",
                        data,
                        voltmeter_bolt_spacing);
  bolt_dia = plist_get("d", data, voltmeter_bolt_dia);
  display = plist_get("display", data, []);
  wiring = plist_get("wiring", data, []);
  pins = plist_get("pins", data, []);

  show_standoffs = plist_get("show_standoffs", data, show_standoffs);
  standoff_body_h = plist_get("standoff_body_h",
                              data,
                              voltmeter_pin_h);
  hide_board = plist_get("hide_board", plist, false);
  hide_display = plist_get("hide_display", plist, false);
  voltmeter(show_standoffs=show_standoffs,
            show_board=!hide_board,
            show_display=!hide_display,
            standoff_body_h=standoff_body_h,
            board_size=board_size,
            bolt_spacing=slot_size,
            bolt_dia=bolt_dia,
            display=display,
            pins=pins,
            wiring=wiring,
            text=text,
            text_props=text_props,
            stand_up=stand_up,
            center=center);
}

voltmeter_from_plist(center=false,
                     debug=false,
                     stand_up=true,
                     plist=plist_merge(voltmeter_default_spec,
                                       ["wiring", plist_merge(plist_get("wiring", voltmeter_default_spec),
                                                              ["path", []])],));
