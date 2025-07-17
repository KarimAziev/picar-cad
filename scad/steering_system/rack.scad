include <../parameters.scad>
include <../colors.scad>
use <rack_connector.scad>
use <rack_util.scad>
use <ring_connector.scad>
use <bracket.scad>
use <../util.scad>

module rack(size=[rack_len, rack_width, rack_base_h],
            pinion_d=pinion_d,
            tooth_pitch=tooth_pitch,
            tooth_height=tooth_h,
            r=rack_rad,
            show_brackets=false,
            bracket_color=blue_grey_carbon,
            rack_color=blue_grey_carbon) {
  rack_len = size[0];
  shared_params = pinion_sync_params(pinion_d, tooth_pitch, rack_len);
  gear_teeth       = shared_params[0];
  actual_pitch     = shared_params[1];
  rack_teeth       = shared_params[2];
  rack_margin      = shared_params[3];

  h = size[1];
  base_h = size[2];

  function gen_tooth(i, pitch, base, tooth) =
    [[i * pitch + pitch/2, base + tooth],
     [(i + 1) * pitch,     base]];

  function gen_teeth(i, n, pitch, base, tooth) =
    i >= n ? [] : concat(gen_tooth(i, pitch, base, tooth),
                         gen_teeth(i + 1, n, pitch, base, tooth));

  pts = concat([[rack_margin, 0], [rack_margin, base_h]],
               gen_teeth(0, rack_teeth, actual_pitch, base_h, tooth_height),
               [[rack_margin + rack_teeth * actual_pitch, 0]]);

  union() {
    translate([-rack_len * 0.5, 0, r]) {
      rotate([90, 0, 0]) {
        color(rack_color) {
          linear_extrude(height=h, center=true) {
            offset(r=r) {
              polygon(points = pts);
            }
          }
        }
      }
    }

    offst = [-rack_len / 2 + rack_margin / 2 - bracket_bearing_outer_d / 2, 0, 0];

    translate(offst) {
      if (show_brackets) {
        rack_connector_assembly(bracket_color=bracket_color);
      } else {
        color(rack_color) {
          rack_connector();
        }
      }
    }
    mirror([1, 0, 0]) {
      translate(offst) {
        if (show_brackets) {
          rack_connector_assembly(bracket_color=bracket_color);
        } else {
          color(rack_color) {
            rack_connector();
          }
        }
      }
    }
  }
}

module rack_mount(show_brackets=false) {
  rotate([0, 0, 180]) {
    rack(size=[rack_len, rack_width, rack_base_h],
         pinion_d=pinion_d,
         tooth_pitch=tooth_pitch,
         tooth_height=tooth_h,
         r=rack_rad,
         show_brackets=show_brackets);
  }
}

module rack_assembly(show_brackets=true, rack_color=blue_grey_carbon) {
  rack_mount(show_brackets=show_brackets);
}

rack_mount();
