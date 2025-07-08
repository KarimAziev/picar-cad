include <../parameters.scad>
use <rack_connector.scad>
use <rack_util.scad>
use <ring_connector.scad>
use <bracket.scad>
use <../util.scad>

module rack(size=[rack_len, rack_width, rack_base_h],
            pinion_d=25,
            tooth_pitch=tooth_pitch,
            tooth_height=tooth_h,
            r=rack_rad,
            connector_screws_dia=m2_hole_dia,
            connector_z_offst=0,
            screws_d=m2_hole_dia,
            show_brackets=false) {
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
        linear_extrude(height=h, center=true) {
          offset(r=r) {
            polygon(points = pts);
          }
        }
      }
    }

    offst = [-rack_len / 2 + rack_margin / 2 - rack_outer_connector_d / 2, 0, 0];
    translate(offst) {

      if (show_brackets) {
        rack_connector_assembly();
      } else {
        rack_connector();
      }
    }
    mirror([1, 0, 0]) {
      translate(offst) {
        if (show_brackets) {
          rack_connector_assembly();
        } else {
          rack_connector();
        }
      }
    }
  }
}

module rack_mount() {
  rotate([0, 0, 180]) {
    rack(size=[rack_len, rack_width, rack_base_h],
         pinion_d=pinion_d,
         tooth_pitch=tooth_pitch,
         tooth_height=tooth_h,
         r=rack_rad,
         connector_screws_dia=rack_side_connector_screws_dia,
         connector_z_offst=0,
         screws_d=rack_side_connector_screws_dia);
  }
}

module bracket_assembly() {
  shared_params = pinion_sync_params(pinion_d, tooth_pitch, rack_len);
  gear_teeth       = shared_params[0];
  actual_pitch     = shared_params[1];
  rack_teeth       = shared_params[2];
  rack_margin      = shared_params[3];
  x_offst = -rack_len / 2 - rack_margin / 2 - rack_outer_connector_d / 2 - rack_bracket_width;
  y_offst = bracket_rack_side_h_length;
  z_offst = lower_knuckle_h / 2 + steering_servo_panel_thickness / 2 + rack_bracket_connector_h;

  offst = [x_offst,
           -y_offst - 1,
           z_offst + 2];

  // translate([bracket_rack_side_w_length / 2,
  //              bracket_rack_side_h_length - rack_bracket_width / 2,
  //              -rack_knuckle_total_connector_h -
  //              (rack_bracket_connector_h * 0.7) / 2]) {
  //     rack_connector();
  //   }
  translate(offst) {
    bracket();
  }
}

module rack_assembly(show_brackets=true) {
  rotate([0, 0, 180]) {
    rack(size=[rack_len, rack_width, rack_base_h],
         pinion_d=pinion_d,
         tooth_pitch=tooth_pitch,
         tooth_height=tooth_h,
         r=rack_rad,
         connector_screws_dia=rack_side_connector_screws_dia,
         connector_z_offst=0,
         screws_d=rack_side_connector_screws_dia,
         show_brackets=true);
  }
}

rack_mount();