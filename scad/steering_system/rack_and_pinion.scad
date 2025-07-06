include <../parameters.scad>
use <pinion.scad>
use <rack_connector.scad>
use <rack_util.scad>
use <rack.scad>

module rack_mount() {
  rack(size=[rack_len, rack_width, rack_base_h],
       pinion_d=pinion_d,
       tooth_pitch=tooth_pitch,
       tooth_height=tooth_h,
       r=rack_rad,
       connector_screws_dia=rack_side_connector_screws_dia,
       connector_z_offst=0,
       connector_size=rack_side_connector_size,
       connector_thickness=rack_side_connector_thickness,
       screws_d=rack_side_connector_screws_dia);
}

module pinion_mount() {
  pinion(d=pinion_d,
         tooth_height=tooth_h,
         thickness=pinion_thickness,
         servo_dia=pinion_servo_dia,
         tooth_pitch=tooth_pitch,
         rack_len=rack_len);
}

module rack_and_pinion(pinion_color="#fa8072", rack_color="#b0c4de") {
  pinion_full_h = pinion_d + rack_rad + tooth_h * 2;
  rack_full_h = rack_base_h + rack_rad + tooth_h;

  translate([0, rack_width / 2, pinion_full_h / 2 + rack_full_h - tooth_h / 2 + 2.0]) {
    rotate([90, 88, 0]) {
      if (is_undef(pinion_color)) {
        pinion_mount();
      } else {
        color(pinion_color) {
          pinion_mount();
        }
      }
    }
  }

  translate([0, 0, rack_rad]) {
    if (is_undef(rack_color)) {
      pinion_mount();
    } else {
      color(rack_color) {
        rack_mount();
      }
    }
  }
}

union() {
  rack_and_pinion();
}
