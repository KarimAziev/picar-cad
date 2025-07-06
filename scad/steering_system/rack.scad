include <../parameters.scad>
use <rack_connector.scad>
use <rack_util.scad>

module rack(size=[rack_len, rack_width, rack_base_h],
            pinion_d=25,
            tooth_pitch=tooth_pitch,
            tooth_height=tooth_h,
            r=rack_rad,
            connector_screws_dia=m2_hole_dia,
            connector_z_offst=0,
            connector_size=[rack_width, rack_base_h, m2_hole_dia * 4],
            connector_thickness=1,
            screws_d=m2_hole_dia) {
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
    translate([-rack_len * 0.5, 0, 0]) {
      rotate([90, 0, 0]) {
        linear_extrude(height=h, center=true) {
          offset(r=r) {
            polygon(points = pts);
          }
        }
      }
    }
    connector_z_offset = connector_size[1] / 2 + connector_thickness + connector_z_offst - rack_rad;
    translate([rack_len / 2 - rack_margin, 0, connector_z_offset]) {
      rack_side_connector(thickness=connector_thickness,
                          size=[connector_size[0], connector_size[1],
                                connector_size[2] + rack_margin],
                          screws_d=screws_d);
    }

    mirror([1, 0, 0]) {
      translate([rack_len / 2 - rack_margin , 0, connector_z_offset]) {
        rack_side_connector(thickness=connector_thickness,
                            size=[connector_size[0],
                                  connector_size[1],
                                  connector_size[2] + rack_margin],
                            screws_d=screws_d);
      }
    }
  }
}

union() {
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
