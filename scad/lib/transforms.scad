use <functions.scad>

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

module rotate_copy(v) {
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
        $x_i = x_ind;
        $y_i = y_ind;
        children();
      }
    }
}

module four_corner_holes_2d(size=[10, 10],
                            center=false,
                            hole_dia=3,
                            fn=60) {
  for (x_ind = [0, 1])
    for (y_ind = [0, 1]) {
      x_pos = (center ? -size[0] / 2 : 0) + x_ind * size[0];
      y_pos = (center ? -size[1] / 2 : 0) + y_ind * size[1];
      translate([x_pos, y_pos]) {
        circle(r=hole_dia / 2, $fn=fn);
        children();
      }
    }
}

module maybe_rotate(rotation) {
  if (is_list(rotation) &&
      len([for (v = rotation) if (is_num(v)) v]) == 3 &&
      len([for (v = rotation) if (v != 0) v]) > 0) {
    rotate(rotation) {
      children();
    }
  } else {
    children();
  }
}

module maybe_translate(v) {
  if (is_list(v)
      && len([for (n = v) if (is_num(n)) n]) == 3
      && len([for (n = v) if (n != 0) n]) > 0) {
    translate(v) {
      children();
    }
  } else {
    children();
  }
}

module spin_keep_bbox_at_origin(size, a) {
  if (is_undef(a) || a == 0) {
    children();
  } else {
    p = calc_rotated_bbox(size[0], size[1], a);
    translate([p[2], p[3], 0]) {
      rotate([0, 0, a]) {
        children();
      }
    }
  }
}

module align_children(parent_size,
                      size,
                      align_x=-1,
                      align_y=-1) {
  if (!is_list(parent_size)
      || !is_num(parent_size[0])
      || !is_num(parent_size[1])) {
    children();
  } else {
    cell_x = parent_size[0];
    cell_y = parent_size[1];
    full_x = size[0];
    full_y = size[1];

    dx = cell_x - full_x;
    dy = cell_y - full_y;

    x = align_x == -1
      ? 0
      : align_x == 0
      ? dx / 2
      : dx;

    y = align_y == 0
      ? dy / 2
      : align_y == 1
      ? dy
      : 0;

    translate([x, y, 0]) {
      children();
    }
  }
}

module align_children_with_spin(parent_size,
                                size,
                                align_x=-1,
                                align_y=-1,
                                spin=0) {
  if (!is_undef(spin) && spin != 0) {
    let (params = calc_rotated_bbox(size[0], size[1],
                                    spin),
         full_x = params[0],
         full_y = params[1],
         sx = params[2],
         sy = params[3]) {
      align_children(parent_size=parent_size,
                     size=[full_x, full_y],
                     align_x=align_x,
                     align_y=align_y) {
        translate([sx, sy, 0]) {
          rotate([0, 0, spin]) {
            children();
          }
        }
      }
    }
  } else {
    align_children(parent_size=parent_size,
                   size=size,
                   align_x=align_x,
                   align_y=align_y) {
      children();
    }
  }
}
