use <holes.scad>
module fillet(r) {
  offset(r = -r) {
    offset(delta = r) {
      children();
    }
  }
}

// Generates the mirrored object in addition to the original one.
module mirror_copy(v = [1, 0, 0]) {
  children();
  mirror(v) {
    children();
  }
}

module translate_copy(v) {
  children();
  translate(v) {
    children();
  }
}

module offset_3d(r=1, size=20, fn=12) {
  if (r == 0) {
    children();
  } else if (r > 0) {
    minkowski(convexity=5) {
      children();
      sphere(r, $fn=fn);
    }
  }
  else {
    size2 = size * [1, 1, 1];
    size1 = size2 * 2;

    difference() {
      cube(size2, center=true);
      minkowski(convexity=5) {
        difference() {
          cube(size1, center=true);
          children();
        }
        sphere(-r, $fn=fn);
      }
    }
  }
}

module offset_vertices_2d(r, fn) {
  offset(-r, $fn=fn) {
    offset(r, $fn=fn) {
      offset(r, $fn=fn) {
        offset(-r, $fn=fn) {
          children();
        }
      }
    }
  }
}

module four_corner_children(size=[10, 10],
                            center=true) {
  for (x_ind = [0, 1])
    for (y_ind = [0, 1]) {
      x_pos = (center ? -size[0] / 2 : 0) + x_ind * size[0];
      y_pos = (center ? -size[1] / 2 : 0) + y_ind * size[1];
      translate([x_pos, y_pos]) {
        children();
      }
    }
}

module four_corner_holes_2d(size=[10, 10],
                            center=false,
                            hole_dia=3,
                            fn_val=60) {
  for (x_ind = [0, 1])
    for (y_ind = [0, 1]) {
      x_pos = (center ? -size[0] / 2 : 0) + x_ind * size[0];
      y_pos = (center ? -size[1] / 2 : 0) + y_ind * size[1];
      translate([x_pos, y_pos]) {
        circle(r=hole_dia / 2, $fn=fn_val);
        children();
      }
    }
}
