/**
 * Module: Utility modules that simplify common 2D geometric constructions.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

module rounded_rect(size, r=undef, center=false, fn, r_factor=0.3) {
  w = size[0];
  h = size[1];
  rad = is_undef(r) ? (min(h, w)) * r_factor : r;
  if (rad == 0) {
    square(size, center=center);
  } else {
    offst = center ? [-w/2, -h/2] : [0, 0];

    hull() {
      translate([rad, rad] + offst) {
        circle(rad, $fn=fn);
      }
      translate([w - rad, rad] + offst) {
        circle(rad, $fn=fn);
      }
      translate([rad, h - rad] + offst) {
        circle(rad, $fn=fn);
      }
      translate([w - rad, h - rad] + offst)
        circle(rad, $fn=fn);
    }
  }
}

module rounded_rect_two(size, r=undef, center=false, segments=10) {
  w = size[0];
  h = size[1];
  rad = is_undef(r) ? (min(h, w)) / 2 : r;
  offst = center ? [-w/2, -h/2] : [0, 0];

  pts_bottom = [[0, 0], [w, 0]];
  pts_right = [[w, 0], [w, h - rad]];
  arc_top_right = [for (i = [1 : segments])
      let (a = i * (90 / segments))
        [(w - rad) + rad * cos(a), (h - rad) + rad * sin(a)]];
  pts_top_edge = [[w - rad, h], [rad, h]];

  arc_top_left = [for (i = [1 : segments])
      let (a = 90 + i * (90 / segments))
        [rad + rad * cos(a), (h - rad) + rad * sin(a)]];

  pts_left = [[0, h - rad], [0, 0]];

  pts = concat(pts_bottom,
               pts_right,
               arc_top_right,
               pts_top_edge,
               arc_top_left,
               pts_left);

  translate(offst) {
    polygon(points = pts);
  }
}

/*
  - size: full width/height of the square (centered at origin)
  - chamfer: how much to cut from each corner along each axis (must be <= size/2)
  Produces an 8-vertex chamfered square (a common octagon shape).
*/
module chamfered_square(size, chamfer) {
  chamfer = is_undef(chamfer) ? size / 4 : chamfer;
  h = size / 2;
  c = chamfer > h ? h : chamfer;
  pts = [[h - c,  h],
         [h,      h - c],
         [h,     -h + c],
         [h - c, -h],
         [-h + c, -h],
         [-h,     -h + c],
         [-h,      h - c],
         [-h + c,  h]];
  polygon(points = pts);
}

module ring_2d_outer(r, w, d, fn) {
  r = is_undef(r) ? d / 2 : r;
  difference() {
    circle(r=r + w, $fn=fn);
    circle(r=r, $fn=fn);
  }
}

module ring_2d_inner(r, w, d, fn) {
  r = is_undef(r) ? d / 2 : r;
  difference() {
    circle(r=r, $fn=fn);
    circle(r=r - w, $fn=fn);
  }
}

module ring_2d(r, w, d, fn, outer) {
  if (outer) {
    ring_2d_outer(r, w, d, fn);
  } else {
    ring_2d_inner(r, w, d, fn);
  }
}

module star_2d(n=5, r_outer=20, r_inner=10) {
  pts = [for (i = [0 : 2 * n - 1])
      let (angle = 360 / (2*n) * i,
           r = (i % 2 == 0) ? r_outer : r_inner)
        [r * cos(angle), r * sin(angle)]];
  polygon(points = pts);
}
