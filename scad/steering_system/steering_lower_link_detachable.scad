include <../parameters.scad>

use <../util.scad>

// Creates the two mounting holes for attaching the steering knuckle
// components. Two pairs of circular holes are generated with an X-offset
// relative to the wheel distance using a specified screw_offset and the
// defined screw diameter.
module steering_knuckle_mount_holes(w=steering_short_linkage_len,
                                    d=steering_knuckle_screws_dia,
                                    screw_offset=4) {
  for (x_offsets = [[-w/2 + screw_offset],
                    [w/2 - screw_offset]]) {
    x1 = x_offsets[0];
    translate([x1, 0, 0]) {
      circle(d=d, $fn=360);
    }
  }
}

//  Generates a 2D shape of the lower detachable steering link.
module steering_lower_link_detachable_2d() {
  difference() {
    rounded_rect([wheels_distance, steering_link_width], r=steering_link_width/2, center=true);

    neckline_width=wheels_distance / 1.8;
    neckline_height=steering_link_width;

    translate([0, -steering_link_width * 0.75, 0]) {
      rounded_rect([neckline_width, neckline_height], center=true);
    }

    translate([0, steering_link_width * 0.2, 0]) {
      rounded_rect([wheels_distance * 0.5, steering_link_width * 0.13], r=1, center=true);
    }

    steering_knuckle_mount_holes(wheels_distance);

    step = 10;
    amount = floor(steering_link_width / step);
    cutoff_w = wheels_distance * 0.65;

    for (i = [0:amount-1]) {
      translate([0, 0 + -i * step]) {
        rounded_rect([cutoff_w, 4], r=2, center=true);
      }
    }

    translate([0, 9]) {
      rounded_rect([cutoff_w, 4], r=2, center=true);
    }
  }
}

//  A 3D shape of the upper detachable steering link. Each side should be connected to the bottom of the knuckle.
module steering_lower_link_detachable(thickness=2) {
  linear_extrude(thickness, center=true) {
    steering_lower_link_detachable_2d();
  }
}

color("white") {
  steering_lower_link_detachable();
}
