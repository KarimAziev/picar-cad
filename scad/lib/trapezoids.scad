
// Creates an isosceles trapezoid.
module trapezoid(b=20, t=10, h=15, center=false) {
  m = (b - t) / 2;

  pts = [[0, 0],
         [b, 0],
         [b - m, h],
         [m, h]];

  polygon(points = center ?
          [for (p = pts) [p[0] - b/2, p[1] - h/2]] :
          pts);
}

// Creates an isosceles trapezoid with rounded corners
module trapezoid_rounded(b=20, t=10, h=15, r=undef, center=false) {
  rad = is_undef(r) ? min(b, t, h) * 0.1 : r;
  offset(r=rad, chamfer=false) {
    offset(r=-rad, chamfer=false) {
      trapezoid(b=b, t=t, h=h, center=center);
    }
  }
}

// Creates an trapezoid with rounded bottom corners
module trapezoid_rounded_bottom(b=20,
                                t=10,
                                h=15,
                                r=undef,
                                r_factor=0.1,
                                center=false,
                                $fn=20) {
  rad = (is_undef(r) ? min(b, t, h) * r_factor : r);
  m = (b - t) / 2;
  n = $fn;

  left_fillet = [for (i = [0 : n])
      let (theta = 180 + i * (90 / n))
        [rad + rad * cos(theta), rad + rad * sin(theta)]];

  right_fillet = [for (i = [1 : n])
      let (theta = -90 + i * (90 / n))
        [(b - rad) + rad * cos(theta), rad + rad * sin(theta)]];

  pts = concat(left_fillet,
               [[b - rad, 0]],
               right_fillet,
               [[b, rad], [b - m, h]],
               [[m, h]],
               [[0, rad]]);

  polygon(points = center ? [for (p = pts) [p[0] - b/2, p[1] - h/2]] : pts);
}

module trapezoid_rounded_top(b=20,
                             t=10,
                             h=15,
                             r=undef,
                             r_factor=0.1,
                             center=false,
                             $fn=20) {
  translate([0, center ? 0 : h, 0]) {
    scale([1, -1]) {
      trapezoid_rounded_bottom(b=t,
                               t=b,
                               h=h,
                               r=r,
                               r_factor=r_factor,
                               center=center,
                               $fn=$fn);
    }
  }
}
