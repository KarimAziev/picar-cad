// front_panel.scad - Defines the front panel of the vehicle.

// This module includes:
//
//  - The main chassis-integrated front panel with integrated slots for mounting the HC-SR04 ultrasonic sensor.
//  - A detachable back panel that secures the ultrasonic sensor from behind.
//  - A separate sensor fixation detail which is secured using either two R3090 rivets, or M2.5 bolts.
//
// Sensor and Attachment Information:
//
//  - Sensor: HC-SR04 ultrasonic sensor
//  - Attachment Hardware: M2.5 bolts

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/holes.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <../placeholders/smd/smd_chip.scad>
use <../placeholders/ultrasonic.scad>

show_front_panel             = true;
show_ultrasonic              = false;
show_front_rear_panel        = false;
show_front_rear_panel_bolts  = false;
show_front_rear_panel_nuts   = false;
show_front_panel_mount_bolts = false;
show_front_panel_mount_nuts  = false;
echo_front_panel_bolts_info  = false;

rear_panel_z                 = ultrasonic_pin_len_b
                                - ultrasonic_thickness
                                - ultrasonic_pin_protrusion_h
                                + ultrasonic_pin_thickness;

function front_rear_panel_boss_height() = rear_panel_z
  + front_panel_thickness / 2
  - front_panel_ultrasonic_cutout_depth;

function front_rear_panel_full_thickness() = front_rear_panel_boss_height()
  + front_panel_rear_panel_thickness;

module ultrasonic_sensor_mounts_2d(d=front_panel_ultrasonic_sensor_dia) {
  rad = d / 2;
  x_offset = rad + front_panel_ultrasonic_sensors_offset / 2;

  for (x = [-x_offset, x_offset]) {
    translate([x, front_panel_ultrasonic_y_offset, 0]) {
      circle(r=rad, $fn=100);
    }
  }
}

module ultrasonic_rect_slots_2d(h=front_panel_height,
                                oscilator_w=ultrasonic_oscillator_w + 2,
                                oscilator_h=ultrasonic_oscillator_h + 2,
                                jack_w=ultrasonic_pins_jack_w + 2,
                                jack_h=ultrasonic_pins_jack_h + 2) {

  union() {
    if (oscilator_h > 0 && oscilator_w > 0) {
      translate([0,
                 h / 2 - oscilator_h / 2
                 - ultrasonic_oscillator_y_offset]) {
        rounded_rect([oscilator_w, oscilator_h],
                     center=true,
                     r=min(2,
                           min(oscilator_h, oscilator_w) * 0.3),
                     fn=20);
      }
    }

    if (jack_h > 0 && jack_w > 0) {
      translate([0, -h / 2 + jack_h / 2]) {
        rounded_rect([jack_w, jack_h],
                     center=true,
                     r=min(2,
                           min(jack_h, jack_w) * 0.3),
                     fn=20);
      }
    }
  }
}

module ultrasonic_bolts_2d(size=ultrasonic_bolt_spacing,
                           d=ultrasonic_bolt_dia) {

  four_corner_holes_2d(size=size, center=true, d=d);
}

module front_panel_connector_bolts(reverse_y=false,
                                   use_counterbore=false) {
  half_len = front_panel_connector_len / 2;
  half_w   = front_panel_connector_width / 2;
  bolt_r  = front_panel_connector_bolt_dia / 2;

  s_x = half_w - bolt_r;
  s_y = half_len - bolt_r;

  function bolt_x(dx) = sign(dx) * s_x - dx;
  function bolt_y(dy) = s_y - abs(dy);

  for (off = front_panel_connector_bolt_offsets) {
    x = bolt_x(off[0]);
    y = bolt_y(off[1]);
    translate([x, reverse_y ? -y : y, 0]) {
      if (!use_counterbore) {
        circle(r = bolt_r, $fn = 360);
      } else {
        counterbore(d=front_panel_connector_bolt_dia,
                    h=front_panel_thickness,
                    bore_d=front_panel_connector_bolt_bore_dia,
                    bore_h=front_panel_connector_bolt_bore_h,
                    autoscale_step=0.1,
                    reverse=true);
      }
    }
  }
}

function front_panel_bolt_y_offset(x, y) =
  - max(front_panel_connector_bolt_bore_dia,
        front_panel_connector_bolt_dia) / 2
  - front_panel_connector_bolts_padding_y;

module front_panel_connector(w=front_panel_connector_width,
                             h=front_panel_connector_len,
                             thickness=front_panel_thickness,
                             show_bolts=show_front_panel_mount_bolts,
                             show_nuts=show_front_panel_mount_nuts,
                             colr="white",
                             echo_bolts_info=echo_front_panel_bolts_info) {
  bolt_y = h / 2 + front_panel_bolt_y_offset();
  union() {
    color(colr) {
      difference() {
        linear_extrude(height=thickness,
                       center=false) {
          difference() {
            rounded_rect_two(size = [w,
                                     h],
                             center=true,
                             r=front_panel_connector_offset_rad);
            if (front_panel_connector_rect_cutout_size[0] > 0
                && front_panel_connector_rect_cutout_size[1] > 0) {
              translate([0,
                         -h / 2 +
                         front_panel_connector_rect_cutout_size[1] / 2
                         + rear_panel_z
                         + thickness,
                         0]) {
                square(front_panel_connector_rect_cutout_size, center=true);
              }
            }
          }
        }
        translate([0, bolt_y, 0]) {
          four_corner_children(front_panel_connector_bolt_spacing, center=true) {
            counterbore(d=front_panel_connector_bolt_dia,
                        h=front_panel_thickness,
                        bore_d=front_panel_connector_bolt_bore_dia,
                        bore_h=front_panel_connector_bolt_bore_h,
                        autoscale_step=0.1,
                        reverse=true);
          }
        }
      }
    }

    if (show_bolts || echo_bolts_info) {
      let (base_d = front_panel_connector_bolt_dia,
           d = snap_bolt_d(base_d),
           nut_h = find_nut_prop(prop="height", inner_d=d, lock=false),
           bolt_h = ceil(front_panel_thickness
                         + chassis_thickness
                         - chassis_upper_front_pan_slot_depth)) {
        if (echo_bolts_info) {
          echo(str("Front panel chassis mount bolt: M", d, "x", bolt_h, "mm"));
        }
        if (show_bolts) {
          translate([0, bolt_y, bolt_h + front_panel_connector_bolt_bore_h]) {

            four_corner_children(front_panel_connector_bolt_spacing,
                                 center=true) {
              rotate([0, 180, 0]) {
                bolt(h=bolt_h,
                     d=d,
                     nut_head_distance=bolt_h - nut_h,
                     lock_nut=false,
                     show_nut=show_nuts);
              }
            }
          }
        }
      }
    }
  }
}

module front_panel_main(w=front_panel_width,
                        h=front_panel_height,
                        bolts_x_offset=front_panel_bolts_x_offset,
                        thickness=front_panel_thickness,
                        angle=front_panel_rotation_angle,
                        show_front_rear_panel=show_front_rear_panel,
                        show_ultrasonic=show_ultrasonic,
                        show_front_rear_panel_bolts=show_front_rear_panel_bolts,
                        show_front_rear_panel_nuts=show_front_rear_panel_nuts,
                        echo_bolts_info=echo_front_panel_bolts_info,
                        colr="white",
                        center=true) {
  ultrasonic_rect_cutout_w = ultrasonic_w + 1;
  ultrasonic_rect_cutout_h = ultrasonic_h + 1.5;
  ultrasonic_z = front_panel_thickness
    + ultrasonic_thickness;
  translate([center ? 0 : w / 2, center ? 0 : h / 2, 0]) {
    if (show_ultrasonic) {
      translate([ultrasonic_w / 2,
                 -ultrasonic_h / 2,
                 ultrasonic_z]) {
        rotate([angle, 0, 0]) {
          rotate([0, 180, 0]) {
            ultrasonic(center=false);
          }
        }
      }
    }

    translate([-w / 2, -h / 2, 0]) {
      rotate([angle, 0, 0]) {
        translate([w / 2, h / 2, 0]) {
          if (show_front_rear_panel) {
            rotate([0, 0, 0]) {
              translate([0,
                         0,
                         front_panel_thickness
                         + ultrasonic_thickness
                         + rear_panel_z]) {
                rotate([180, 0, 0]) {
                  color(colr, alpha=1) {
                    front_panel_back_mount();
                  }
                }
              }
            }
          }

          difference() {
            color(colr) {
              linear_extrude(thickness, convexity=2) {
                difference() {
                  rounded_rect(size=[w, h],
                               r=front_panel_offset_rad,
                               center=true);
                  translate([0, front_panel_bolts_y_offst, 0]) {
                    two_x_bolts_2d(x=bolts_x_offset,
                                   d=front_panel_bolt_dia);
                    ultrasonic_bolts_2d();
                  }

                  ultrasonic_sensor_mounts_2d();
                  ultrasonic_rect_slots_2d(h=ultrasonic_h);
                }
              }
            }

            translate([0,
                       0,
                       thickness -
                       front_panel_ultrasonic_cutout_depth + 0.1]) {
              linear_extrude(height=front_panel_ultrasonic_cutout_depth,
                             center=false) {
                rounded_rect([ultrasonic_rect_cutout_w,
                              ultrasonic_rect_cutout_h],
                             r=ultrasonic_offset_rad,
                             center=true);
              }
            }

            translate([0, 0, thickness / 2]) {
              linear_extrude(height=rear_panel_z, center=false) {
                mirror_copy([1, 0, 0]) {
                  translate([bolts_x_offset, front_panel_bolts_y_offst, 0]) {
                    circle(r=front_panel_bolt_dia / 2
                           + front_panel_rear_panel_ring_width + 0.4,
                           $fn=100);
                  }
                }
              }
            }
          }
          if (show_front_rear_panel_bolts || echo_bolts_info) {
            let (base_d = front_panel_bolt_dia,
                 d = snap_bolt_d(base_d),
                 nut_h = find_nut_prop(prop="height", inner_d=d, lock=true),
                 bolt_h = ceil(ultrasonic_thickness + thickness + rear_panel_z
                               + front_rear_panel_boss_height())) {
              if (echo_bolts_info) {
                echo(str("Front panel ultrasonic bolt: M", d, "x", bolt_h, "mm"));
              }
              if (show_front_rear_panel_bolts) {
                translate([0, front_panel_bolts_y_offst, bolt_h]) {
                  mirror_copy([1, 0, 0]) {
                    translate([bolts_x_offset, 0, 0]) {

                      rotate([180, 0, 0]) {
                        bolt(h=bolt_h,
                             d=d,
                             nut_head_distance=bolt_h - nut_h,
                             lock_nut=true,
                             show_nut=show_front_rear_panel_nuts);
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
}

module front_panel(w=front_panel_width,
                   h=front_panel_height,
                   bolts_x_offset=front_panel_bolts_x_offset,
                   thickness=front_panel_thickness,
                   angle=front_panel_rotation_angle,
                   colr="white",
                   connector_len=front_panel_connector_len,
                   show_ultrasonic=show_ultrasonic,
                   show_front_rear_panel=show_front_rear_panel,
                   show_front_rear_panel_bolts=show_front_rear_panel_bolts,
                   show_front_rear_panel_nuts=show_front_rear_panel_nuts,
                   show_front_panel_mount_bolts=show_front_panel_mount_bolts,
                   show_front_panel_mount_nuts=show_front_panel_mount_nuts,
                   echo_front_panel_bolts_info=echo_front_panel_bolts_info) {
  bbox = rot_x_bbox_align([w, h, thickness], angle=angle);
  bbox_w = bbox[0];
  bbox_h = bbox[1];
  connector_y = h / 2 + thickness - 0.1;
  connector_z = connector_len / 2;
  y = bbox_w - connector_y;

  rotate([90, 180, 0]) {
    translate([-w / 2, -y, -bbox_h]) {
      front_panel_main(w=w,
                       h=h,
                       bolts_x_offset=bolts_x_offset,
                       thickness=thickness,
                       show_ultrasonic=show_ultrasonic,
                       show_front_rear_panel=show_front_rear_panel,
                       show_front_rear_panel_bolts=show_front_rear_panel_bolts,
                       show_front_rear_panel_nuts=show_front_rear_panel_nuts,
                       echo_bolts_info=echo_front_panel_bolts_info,
                       colr=colr,
                       center=false);
    }

    translate([0,
               connector_y,
               connector_z]) {
      rotate([90, 0, 0]) {
        front_panel_connector(w=front_panel_connector_width,
                              h=front_panel_connector_len
                              + thickness,
                              thickness=thickness,
                              colr=colr,
                              show_bolts=show_front_panel_mount_bolts,
                              show_nuts=show_front_panel_mount_nuts,
                              echo_bolts_info=echo_front_panel_bolts_info);
      }
    }
  }
}

module front_panel_back_mount(h=front_panel_height,
                              w=front_panel_width,
                              bolts_x_offset=front_panel_bolts_x_offset,
                              thickness=front_panel_rear_panel_thickness) {

  union() {
    linear_extrude(thickness) {
      difference() {
        rounded_rect(size=[w, h],
                     center=true,
                     r=front_panel_offset_rad);
        four_corner_holes_2d(size=ultrasonic_bolt_spacing,
                             d=ultrasonic_bolt_dia + 0.2,
                             center=true);

        ultrasonic_smd_slots(half_of_board_w=ultrasonic_w / 2,
                             length=ultrasonic_smd_len,
                             w=ultrasonic_smd_w,
                             thickness=ultrasonic_smd_h,
                             x_offset=ultrasonic_smd_x_offst) {
          smd_chip_slot_2d(length=ultrasonic_smd_len,
                           total_w=ultrasonic_smd_w,
                           center=true);
        }

        translate([0, -front_panel_bolts_y_offst, 0]) {
          two_x_bolts_2d(x=bolts_x_offset,
                         d=front_panel_bolt_dia);
        }
        four_corner_holes_2d(size=ultrasonic_solder_blobs_positions,
                             d=front_panel_solder_blob_dia,
                             center=true);
        ultrasonic_rect_slots_2d(h=ultrasonic_h,
                                 jack_w=ultrasonic_pins_jack_w + 2,
                                 jack_h=0,
                                 oscilator_h=ultrasonic_oscillator_h,
                                 oscilator_w=ultrasonic_oscillator_w);
        pw = ultrasonic_pins_jack_w + 2;
        ph = h - ultrasonic_h + ultrasonic_pins_jack_h;

        translate([0, -h / 2 + ph / 2]) {
          square([pw, ph], center=true);
        }
      }
    }
    translate([0, 0, thickness]) {
      linear_extrude(height=front_rear_panel_boss_height(),
                     center=false,
                     convexity=2) {
        mirror_copy([1, 0, 0]) {
          translate([bolts_x_offset,
                     -front_panel_bolts_y_offst,
                     0]) {
            ring_2d(r=front_panel_bolt_dia / 2,
                    fn=100,
                    w=front_panel_rear_panel_ring_width,
                    outer=true);
          }
        }
      }
    }
  }
}

module front_panel_printable(panel_color="white",
                             spacing=2,
                             show_front_panel=true,
                             show_front_rear_panel=true) {
  if (show_front_panel) {
    rotate([-90 + front_panel_rotation_angle, 0, 0]) {
      front_panel(colr=panel_color,
                  show_ultrasonic=false,
                  show_front_rear_panel=false,
                  show_front_rear_panel_bolts=false,
                  show_front_rear_panel_nuts=false,
                  show_front_panel_mount_bolts=false,
                  show_front_panel_mount_nuts=false,
                  echo_front_panel_bolts_info=false);
    }
  }
  if (show_front_rear_panel) {
    translate([0, show_front_panel ? front_panel_height + spacing : 0 , 0]) {
      color(panel_color, alpha=1) {
        front_panel_back_mount();
      }
    }
  }
}

module front_panel_assembly(panel_color="white",
                            show_front_panel=show_front_panel,
                            show_ultrasonic=show_ultrasonic,
                            show_front_rear_panel=show_front_rear_panel,
                            show_front_rear_panel_bolts=show_front_rear_panel_bolts,
                            show_front_rear_panel_nuts=show_front_rear_panel_nuts,
                            show_front_panel_mount_bolts=show_front_panel_mount_bolts,
                            show_front_panel_mount_nuts=show_front_panel_mount_nuts,
                            echo_front_panel_bolts_info=echo_front_panel_bolts_info) {
  bbox = rot_x_bbox_align([front_panel_width,
                           front_panel_height,
                           front_panel_thickness],
                          angle=front_panel_rotation_angle);

  if (show_front_panel) {
    translate([0,
               front_panel_connector_len + front_panel_thickness / 2,
               -bbox[0] / 2]) {
      rotate([0, 180, 0]) {
        rotate([0, 0, 0]) {
          front_panel(colr=panel_color,
                      show_ultrasonic=show_ultrasonic,
                      show_front_rear_panel=show_front_rear_panel,
                      show_front_rear_panel_bolts=show_front_rear_panel_bolts,
                      show_front_rear_panel_nuts=show_front_rear_panel_nuts,
                      show_front_panel_mount_bolts=show_front_panel_mount_bolts,
                      show_front_panel_mount_nuts=show_front_panel_mount_nuts,
                      echo_front_panel_bolts_info=echo_front_panel_bolts_info);
        }
      }
    }
  }
}

front_panel_assembly();
// front_panel_printable();
