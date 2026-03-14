include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/debug.scad>
use <../../lib/functions.scad>
use <../../lib/holes.scad>
use <../../lib/shapes2d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>

front_shock_tower_l                        = 68;
front_shock_tower_total_h                  = 30.5;
front_shock_tower_leg_w                    = 8.5;

front_shock_tower_corner_r                 = 0;
front_shock_tower_damper_holes_gap         = 1.7;
front_shock_tower_damper_holes_pad_x       = 1.8;
front_shock_tower_damper_holes_pad_y       = 1.8;
front_shock_tower_damper_holes_amount      = 3;
front_shock_tower_damper_holes_angle       = 150;
front_shock_tower_shock_damper_spacing_x   = 45;
front_shock_tower_shock_damper_bolt_d      = m3_hole_dia;
front_shock_tower_shock_mount_bolt_spacing = [33.3, 9.6];
front_shock_tower_bolt_d                   = m3_hole_dia;
front_shock_tower_thickness                = 6.0;
front_shock_tower_lower_thickness          = 2.7;
front_shock_tower_hinge_pin_bolt_spacing   = 55.8;
front_shock_tower_hinge_pin_bolt_y_offset  = 3;

function xs(ps) = [for (p = ps) p[0]];
function ys(ps) = [for (p = ps) p[1]];

function front_shock_damper_holes_poses(tilt_angle=front_shock_tower_damper_holes_angle,
                                        damper_holes_n=front_shock_tower_damper_holes_amount,
                                        bolt_d=front_shock_tower_shock_damper_bolt_d,
                                        gap=front_shock_tower_damper_holes_gap) =
  let (angle_cos=cos(tilt_angle),
       angle_sin=sin(tilt_angle),
       step=bolt_d + gap)
  [for (i = [0 : damper_holes_n - 1])
      let (base_offst = i * step,
           x = base_offst * angle_cos,
           y = base_offst * angle_sin)
        [x, y]];

function bbox_holder_hull_samepads(tilt_angle,
                                   damper_holes_n,
                                   bolt_d,
                                   gap,
                                   pad_x,
                                   pad_y) =
  let (ps = front_shock_damper_holes_poses(tilt_angle=tilt_angle,
                                           damper_holes_n=damper_holes_n,
                                           bolt_d=bolt_d, gap=gap),
       rx = bolt_d/2 + pad_x,
       ry = bolt_d/2 + pad_y,
       x  = xs(ps),
       y  = ys(ps))
  [[min(x) - rx, min(y) - ry],
   [max(x) + rx, max(y) + ry]];

function bbox2d_of_circles(ps, r) =
  let (x = xs(ps),
       y = ys(ps),
       minx = min(x),
       maxx = max(x),
       miny = min(y),
       maxy = max(y))
  [[minx - r, miny - r], [maxx + r, maxy + r]];

function size2d_from_bbox(b) = [b[1][0] - b[0][0],
                                b[1][1] - b[0][1]];

function front_shock_damper_holes_size2d(tilt_angle,
                                         damper_holes_n,
                                         bolt_d,
                                         gap) =
  let (ps = front_shock_damper_holes_poses(tilt_angle, damper_holes_n, bolt_d, gap),
       r  = bolt_d/2,
       bb = bbox2d_of_circles(ps, r))
  size2d_from_bbox(bb);

module front_shock_holder_2d(tilt_angle=front_shock_tower_damper_holes_angle,
                             damper_holes_n=front_shock_tower_damper_holes_amount,
                             bolt_d=front_shock_tower_shock_damper_bolt_d,
                             gap=front_shock_tower_damper_holes_gap,
                             pad_x=front_shock_tower_damper_holes_pad_x,
                             pad_y=front_shock_tower_damper_holes_pad_y,
                             $fn=180) {
  ps = front_shock_damper_holes_poses(tilt_angle, damper_holes_n, bolt_d, gap);

  rx = bolt_d/2 + pad_x;
  ry = bolt_d/2 + pad_y;

  hull() {
    for (p = ps) {
      translate([p[0], p[1]]) {
        scale([rx, ry]) {
          circle(r=1);
        }
      }
    }
  }
}

module front_shock_tower_damper_holes_2d(tilt_angle=front_shock_tower_damper_holes_angle,
                                         damper_holes_n=front_shock_tower_damper_holes_amount,
                                         bolt_d=front_shock_tower_shock_damper_bolt_d,
                                         gap=front_shock_tower_damper_holes_gap) {
  holes_poses = front_shock_damper_holes_poses(tilt_angle=tilt_angle,
                                               damper_holes_n=damper_holes_n,
                                               bolt_d=bolt_d,
                                               gap=gap);

  for (poses = holes_poses) {
    let (x = poses[0],
         y = poses[1]) {
      translate([x, y, 0]) {
        circle(r = bolt_d / 2, $fn = 360);
      }
    }
  }
}

module front_shock_tower_hinge_pin_holes_2d(bolt_spacing=front_shock_tower_hinge_pin_bolt_spacing,
                                            pin_d=upper_arm_hinge_barrel_hole_d) {

  translate([0, pin_d / 2, 0]) {
    two_x_bolts_2d(x=bolt_spacing / 2,
                   d=pin_d);
  }
}

module front_shock_tower_mount_holes_2d(bolt_spacing=front_shock_tower_shock_mount_bolt_spacing,
                                        bolt_d=front_shock_tower_bolt_d) {

  translate([0, bolt_spacing[1] / 2 + bolt_d / 2, 0]) {

    four_corner_holes_2d(size=bolt_spacing,
                         d=bolt_d,

                         center=true);
  }
}

module front_shock_tower_damper_mount(tilt_angle=front_shock_tower_damper_holes_angle,
                                      damper_holes_n=front_shock_tower_damper_holes_amount,
                                      bolt_d=front_shock_tower_shock_damper_bolt_d,
                                      gap=front_shock_tower_damper_holes_gap,
                                      offst_from_center=front_shock_tower_shock_damper_spacing_x) {
  difference() {
    #rounded_rect(size=[front_shock_tower_l, front_shock_tower_total_h],
                  center=true,
                  r=0.5);
    mirror_copy([1, 0, 0]) {
      translate([-offst_from_center / 2, bolt_d / 2, 0]) {
        front_shock_tower_damper_holes_2d(tilt_angle=tilt_angle,
                                          damper_holes_n=damper_holes_n,
                                          bolt_d=bolt_d,
                                          gap=gap);
      }
    }
  }
}

module front_shock_tower_holes(total_h=front_shock_tower_total_h,
                               tilt_angle=front_shock_tower_damper_holes_angle,
                               damper_holes_n=front_shock_tower_damper_holes_amount,
                               bolt_d=front_shock_tower_shock_damper_bolt_d,
                               gap=front_shock_tower_damper_holes_gap,
                               pin_holes_spacing=front_shock_tower_hinge_pin_bolt_spacing,
                               offst_from_center=front_shock_tower_shock_damper_spacing_x,
                               pad_x=front_shock_tower_damper_holes_pad_x,
                               pad_y=front_shock_tower_damper_holes_pad_y) {
  bb = bbox_holder_hull_samepads(tilt_angle=tilt_angle,
                                 damper_holes_n=damper_holes_n,
                                 bolt_d=bolt_d,
                                 gap=gap,
                                 pad_x=pad_x,
                                 pad_y=pad_y);
  size = size2d_from_bbox(bb);
  size_y = size[1];

  rect_size_y = total_h - size_y;

  module _holes(hull_mode=false) {
    translate([0, rect_size_y, 0]) {
      mirror_copy([1, 0, 0]) {
        translate([-offst_from_center / 2, pad_y, 0]) {
          front_shock_tower_damper_holes_2d();
        }
      }
    }
    translate([0, pad_y, 0]) {
      front_shock_tower_mount_holes_2d();
      translate([0, front_shock_tower_hinge_pin_bolt_y_offset, 0]) {
        front_shock_tower_hinge_pin_holes_2d(bolt_spacing=pin_holes_spacing
                                             +  (hull_mode ? pad_x * 2  : 0));
      }
    }
  }

  _holes();
}

module front_shock_tower(color=cobalt_blue_metallic,
                         thickness=front_shock_tower_thickness,
                         lower_thickness=front_shock_tower_lower_thickness,
                         total_h=front_shock_tower_total_h,
                         tilt_angle=front_shock_tower_damper_holes_angle,
                         damper_holes_n=front_shock_tower_damper_holes_amount,
                         bolt_d=front_shock_tower_shock_damper_bolt_d,
                         mount_bolt_spacing=front_shock_tower_shock_mount_bolt_spacing,
                         mount_bolt_d=front_shock_tower_bolt_d,
                         pin_holes_spacing=front_shock_tower_hinge_pin_bolt_spacing,
                         pin_d=upper_arm_hinge_barrel_hole_d,
                         pin_holes_y_offset=front_shock_tower_hinge_pin_bolt_y_offset,
                         pin_holes_pad=2,
                         damper_spacing_x=front_shock_tower_shock_damper_spacing_x,
                         gap=front_shock_tower_damper_holes_gap,
                         leg_w=front_shock_tower_leg_w,
                         corner_r=front_shock_tower_corner_r,
                         pad_x=front_shock_tower_damper_holes_pad_x,
                         pad_y=front_shock_tower_damper_holes_pad_y,
                         debug=false) {
  size_2d = front_shock_damper_holes_size2d(tilt_angle=tilt_angle,
                                            damper_holes_n=damper_holes_n,
                                            bolt_d=bolt_d,
                                            gap=gap);

  half_of_x = mount_bolt_spacing[0] / 2;
  bb = bbox_holder_hull_samepads(tilt_angle=tilt_angle,
                                 damper_holes_n=damper_holes_n,
                                 bolt_d=bolt_d,
                                 gap=gap,
                                 pad_x=pad_x,
                                 pad_y=pad_y);
  size = size2d_from_bbox(bb);
  size_y = size[1];

  rect_size_y = total_h - size_y;

  start_y = mount_bolt_spacing[1]
    + mount_bolt_d + pad_y * 2;

  _pin_holes_y_offset = pin_holes_y_offset + pin_holes_pad;

  common_pts = [[pin_holes_spacing / 2 + pin_holes_pad + pin_d / 2,
                 _pin_holes_y_offset - pin_d / 2 + pin_holes_pad],
                [pin_holes_spacing / 2 + pin_holes_pad,
                 _pin_holes_y_offset + pin_d / 2 + pin_holes_pad],
                [pin_holes_spacing / 2 - pin_holes_pad,
                 _pin_holes_y_offset + pin_d / 2 + leg_w],
                [damper_spacing_x / 2 + bolt_d / 2 + pad_x,
                 start_y + leg_w / 2],
                [damper_spacing_x / 2 - bolt_d + pad_x + size_2d[0],
                 start_y + size_2d[1]],
                [damper_spacing_x / 2 + pad_x + size_2d[0],
                 start_y + size_2d[1] + bolt_d / 2 + pad_y],
                [damper_spacing_x / 2 + pad_x + size_2d[0],
                 start_y + size_2d[1] + bolt_d
                 + pad_y],
                [damper_spacing_x / 2 + size_2d[0] + bolt_d / 2,
                 start_y + size_2d[1] + bolt_d
                 + pad_y],
                [damper_spacing_x / 2 - pad_x * 2,
                 start_y + leg_w],
                [-corner_r, start_y + leg_w]];

  pts_1 = concat([[-corner_r, start_y],
                  [half_of_x - bolt_d / 2 - pad_x * 2, start_y],
                  [half_of_x - bolt_d / 2 - pad_x,
                   start_y - pad_y - bolt_d],
                  [half_of_x + bolt_d / 2 + pad_x,
                   start_y - ((start_y - _pin_holes_y_offset) / 2)
                   - pin_holes_pad],
                  [pin_holes_spacing / 2 - pin_d / 2 - pin_holes_pad,
                   _pin_holes_y_offset],
                  [pin_holes_spacing / 2,
                   _pin_holes_y_offset -  pin_holes_pad],],
                 common_pts);

  pts_2 = concat([[-corner_r, start_y],
                  [half_of_x - bolt_d / 2 - pad_x * 2, start_y],
                  [half_of_x - bolt_d / 2 - pad_x,
                   start_y - pad_y - bolt_d],
                  [half_of_x - bolt_d / 2 - pad_x, 0],
                  [pin_holes_spacing / 2,
                   _pin_holes_y_offset -  pin_holes_pad]],
                 common_pts);

  module _shape(points=pts_1) {
    translate([0, rect_size_y, 0]) {
      mirror_copy([1, 0, 0]) {
        translate([-damper_spacing_x / 2, pad_y, 0]) {
          difference() {
            front_shock_holder_2d(tilt_angle=tilt_angle,
                                  damper_holes_n=damper_holes_n,
                                  bolt_d=bolt_d,
                                  gap=gap,
                                  pad_x=pad_x,
                                  pad_y=pad_y);
            front_shock_tower_damper_holes_2d(tilt_angle=tilt_angle,
                                              damper_holes_n=damper_holes_n,
                                              bolt_d=bolt_d,
                                              gap=gap);
          };
        }
      }
    }

    difference() {
      union() {
        mirror_copy([1, 0, 0]) {
          translate([pin_holes_spacing / 2,
                     _pin_holes_y_offset + pin_d / 2,
                     0]) {
            circle(d=pin_d + pin_holes_pad * 2, $fn=$preview ? 16 : 360);
          }
        }

        mirror_copy([1, 0, 0]) {
          offset_vertices_2d(r=corner_r, fn=$preview ? 100 : 360) {
            polygon(points);
          }
        }
      }
      front_shock_tower_holes(total_h=total_h,
                              tilt_angle=tilt_angle,
                              damper_holes_n=damper_holes_n,
                              bolt_d=bolt_d,
                              gap=gap,
                              pin_holes_spacing=pin_holes_spacing,
                              offst_from_center=damper_spacing_x,
                              pad_x=pad_x,
                              pad_y=pad_y);
    }
  }

  maybe_color(color, alpha=1) {
    linear_extrude(height=thickness, center=false) {
      _shape(pts_1);
    }
    linear_extrude(height=lower_thickness, center=false) {
      _shape(pts_2);
    }
  }
  if (debug) {
    translate([0, 0, thickness]) {
      debug_polygon_text(pts_2);
    }
  }
}

union() {
  front_shock_tower(debug=true);
  let (w = front_shock_tower_l + front_shock_tower_corner_r / 2,
       h = front_shock_tower_total_h - front_shock_tower_corner_r / 2) {
    translate([0, h / 2, 0]) {
      %cube([w, h, 10], center=true);
    }
  }
}