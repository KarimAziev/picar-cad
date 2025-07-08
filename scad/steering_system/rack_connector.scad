include <../parameters.scad>
use <../util.scad>
use <ring_connector.scad>
use <bracket.scad>

/**
 * +-----------------------------+
 * |*              <screw_d>      *------size[0]
 * | * +----------------------------+
 * |   |                            |
 * |   |      thickness             |
 * | s |      +---------------------+
 * | i |      |
 * | z |      |                        ^
 * | e |      |                        |---------- size[1] (empty distance between brackets)
 * |[0]|      |                        v
 * |   |      |------------------+
 * |   |      |    <screw_d>      *-----size[0]
 * |   +------|---------------------+
 * +   |                            |
 *  *  |     thickness              |
 *   * +----------------------------+
 *
 *       <--------- size[2]----------->
 *              overall length
 *
 *
 */
module rack_side_connector(size=[4, 3, 5], thickness=1, screws_d=m2_hole_dia) {
  rotate([90, 0, 90]) {
    union() {
      rack_side_connector_bracket(size=size,
                                  thickness=thickness,
                                  screws_d=screws_d);
      mirror([0, 1, 0]) {
        rack_side_connector_bracket(size=size,
                                    thickness=thickness,
                                    screws_d=screws_d);
      }
    }
  }
}

module rack_side_connector_bracket(size=[4, 3, 5], thickness=1, screws_d=m2_hole_dia) {
  difference() {
    l_bracket(size=size,
              thickness=thickness,
              y_r=0,
              z_r=size[0] / 2,
              center=true);
    translate([0, 0, size[2] - screws_d]) {
      rotate([90, 0, 0]) {
        linear_extrude(height = size[0]) {
          circle(r=screws_d / 2, $fn=360);
        }
      }
    }
  }
}

union() {
  // mirror([1, 0, 0]) {
  //   rotate([0, 0, 180]) {
  //     bracket();
  //   }
  // }

  // translate([0, 35, 0]) {
  //   rotate([0, 0, 180]) {
  //     bracket();
  //   }
  // }

  rotate([0, 0, 180]) {
    translate([bracket_rack_side_w_length / 2,
               bracket_rack_side_h_length - rack_bracket_width / 2,
               -rack_knuckle_total_connector_h -
               (rack_bracket_connector_h * 0.7) / 2 -6]) {
      rack_connector();
    }

    color([1, 0, 0], alpha = 0.9) {
      bracket(connector_height=rack_bracket_connector_h);
    }
  }
}
