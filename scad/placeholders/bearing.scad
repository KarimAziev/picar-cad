include <../parameters.scad>
include <../colors.scad>
use <../util.scad>

bearing_shaft_d        = 8;
bearing_section_height = 7;
outer_ring_w           = 2;
shaft_ring_w           = 2;
outer_bearing_d        = 22;
rings                  = [[2, metalic_yellow_silver],
                          [1, onyx]];

module bearing(rings = [[0]],
               d = outer_bearing_d,
               outer_ring_w = outer_ring_w,
               outer_col = metalic_grey,
               shaft_d = bearing_shaft_d,
               shaft_ring_w = shaft_ring_w,
               shaft_ring_col = metalic_silver_2,
               h = bearing_section_height,
               flanged_h=0,
               flanged_w=0,
               fn=100) {
  ring_widths = [for (x = rings) x[0]];
  ring_colors = [for (x = rings) x[1]];
  num_rings = len(rings);

  d_first = shaft_d + 2 * shaft_ring_w;

  ring_width_last = ring_widths[num_rings - 1];
  d_last = d - 2 * outer_ring_w - 2 * ring_width_last;

  union() {

    color(outer_col) {
      linear_extrude(height = h) {
        ring_2d(w = outer_ring_w, d = d, outer = false, fn=fn);
      }

      if (flanged_w > 0 && flanged_h > 0) {
        linear_extrude(height = flanged_h) {
          ring_2d(w = flanged_w, d = d, outer = true, fn=fn);
        }
      }
    }

    color(shaft_ring_col)
      linear_extrude(height = h) {
      ring_2d(w=shaft_ring_w, d=shaft_d, outer = true, fn=fn);
    }

    for (i = [1 : num_rings]) {

      d_ring = (num_rings > 1)
        ? d_first + (d_last - d_first) * ((i - 1) / (num_rings - 1))
        : d_first;

      col_ring = ring_colors[i - 1];
      w_ring   = ring_widths[i - 1];

      color(col_ring) {
        linear_extrude(height = h) {
          ring_2d(w = w_ring, d = d_ring, outer = true, fn=40);
        }
      }
    }
  }
}

bearing();