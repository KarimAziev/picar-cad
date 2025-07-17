include <../parameters.scad>

tire_offset    = 0.8;
fillet_gap     = 1;

tire_thickness = 4;

tire_width     = wheel_w + 0.4;

tire_fn        = 360;

module tire() {
  inner_r = wheel_dia / 2 + tire_offset - wheel_rim_h;
  outer_r = inner_r + tire_thickness;
  rotate_extrude(convexity = 10, $fn=tire_fn)
    children();

  difference() {
    rotate_extrude(convexity = 10, $fn=tire_fn) {
      offset(r=fillet_gap) {
        polygon(points=[[inner_r, -tire_width/2],
                        [inner_r,  tire_width/2],
                        [outer_r,  tire_width/2],
                        [outer_r, -tire_width/2]]);
      }
    }
    cylinder(h=wheel_w - wheel_rim_w * 2, r = wheel_dia / 2 + tire_offset, center=true, $fn=360);
  }
}

tire();