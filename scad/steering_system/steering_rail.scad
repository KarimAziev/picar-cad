include <../parameters.scad>

use <../lib/slider.scad>

module steering_rack_anti_tilt_key() {
  translate([-steering_panel_rail_len / 2,
             steering_rack_width / 2
             - steering_rack_anti_tilt_key_thickness
             - steering_rack_anti_tilt_rack_x_offset,
             0]) {
    cube([steering_panel_rail_len,
          steering_rack_anti_tilt_key_thickness,
          steering_rack_anti_tilt_key_height], center=false);
  }
}

module steering_rail(h=steering_panel_rail_height,
                     w=steering_panel_rail_thickness,
                     l=steering_panel_rail_len,
                     angle=steering_panel_rail_angle,
                     r=steering_panel_rail_rad) {
  translate([0, -w / 2, 0]) {
    rotate([90, 0, 90]) {
      linear_extrude(height=l,
                     center=true) {
        dovetail_rib(w=w,
                     h=h,
                     angle=angle,
                     r=r,
                     center=false);
      }
    }
  }
}

module steering_rail_relief_cutter(h=steering_panel_rail_height,
                                   w=steering_panel_rail_thickness
                                   + steering_rack_rail_tolerance,
                                   l=steering_panel_rail_len,
                                   angle=steering_panel_rail_angle,
                                   r=steering_panel_rail_rad,
                                   edge_land=steering_rail_edge_land,
                                   relief_depth=steering_rail_relief_depth) {
  d_parallel = relief_depth / cos(angle);
  translate([0, 0, h / 2]) {
    rotate([90, 0, 90]) {
      linear_extrude(height=l,
                     center=true,
                     convexity=2) {
        intersection() {
          offset(r=d_parallel) {
            dovetail_rib(w=w, h=h, angle=angle, r=r, center=true);
          }

          offset(r=-edge_land) {
            offset(r = edge_land) {
              dovetail_rib(w=w, h=h, angle=angle, r=r, center=true);
            }
          }
        }
      }
    }
  }
}

union() {
  // translate([0, 0, 0]) {
  //   color("green", alpha=1) {
  //     steering_rail();
  //   }
  // }
  steering_rail();
  // color("red", alpha=1) {
  //   steering_rail_relief_cutter();
  // }
}
// steering_rail();