include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/debug.scad>
use <../../lib/functions.scad>
use <../../lib/holes.scad>
use <../../lib/shapes2d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../lib/trapezoids.scad>

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
       rx = bolt_d / 2 + pad_x,
       ry = bolt_d / 2 + pad_y,
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
       r  = bolt_d / 2,
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
  bolt_r = bolt_d / 2;

  rx = bolt_r + pad_x;
  ry = bolt_r + pad_y;

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

  bolt_r = bolt_d / 2;

  for (poses = holes_poses) {
    let (x = poses[0],
         y = poses[1]) {
      translate([x, y, 0]) {
        circle(r = bolt_r, $fn = 360);
      }
    }
  }
}

module front_shock_tower_mount_holes_2d(spacing=front_shock_tower_bolt_spacing,
                                        bolt_d=front_shock_tower_bolt_d) {

  translate([0, spacing[1] / 2 + bolt_d / 2, 0]) {
    four_corner_holes_2d(size=spacing,
                         d=bolt_d,
                         center=true);
  }
}

module front_shock_tower_holes(total_h=front_shock_tower_h,
                               tilt_angle=front_shock_tower_damper_holes_angle,
                               bolt_spacing=front_shock_tower_bolt_spacing,
                               bolt_d=front_shock_tower_bolt_d,
                               damper_bolt_d=front_shock_tower_shock_damper_bolt_d,
                               damper_holes_n=front_shock_tower_damper_holes_amount,
                               gap=front_shock_tower_damper_holes_gap,
                               pin_hole_spacing=front_shock_tower_pin_spacing,
                               pin_d=upper_arm_hinge_barrel_hole_d,
                               damper_spacing=front_shock_tower_damper_spacing_x,
                               pad_x=front_shock_tower_damper_holes_pad_x,
                               pad_y=front_shock_tower_damper_holes_pad_y) {
  bb = bbox_holder_hull_samepads(tilt_angle=tilt_angle,
                                 damper_holes_n=damper_holes_n,
                                 bolt_d=damper_bolt_d,
                                 gap=gap,
                                 pad_x=pad_x,
                                 pad_y=pad_y);
  size = size2d_from_bbox(bb);
  size_y = size[1];

  rect_size_y = total_h - size_y;

  translate([0, rect_size_y, 0]) {
    mirror_copy([1, 0, 0]) {
      translate([-damper_spacing / 2, pad_y, 0]) {
        front_shock_tower_damper_holes_2d(tilt_angle=tilt_angle,
                                          damper_holes_n=damper_holes_n,
                                          bolt_d=bolt_d,
                                          gap=gap);
      }
    }
  }
  translate([0, pad_y, 0]) {
    translate([0, bolt_spacing[1] / 2 + bolt_d / 2, 0]) {
      four_corner_holes_2d(size=bolt_spacing,
                           d=bolt_d,
                           center=true);
    }
    translate([0, front_shock_tower_pin_y_offset, 0]) {
      translate([0, pin_d / 2, 0]) {
        two_x_bolts_2d(x=pin_hole_spacing / 2,
                       d=pin_d);
      }
    }
  }
}

module front_shock_tower(color=cobalt_blue_metallic,
                         corner_r=front_shock_tower_corner_r,
                         cutout_corner_r=front_shock_tower_cutout_corner_r,
                         mount_corner_r=front_shock_tower_mount_corner_r,
                         total_h=front_shock_tower_h,
                         thickness=front_shock_tower_thickness,
                         lower_thickness=front_shock_tower_lower_thickness,
                         bolt_d=front_shock_tower_bolt_d,
                         bolt_spacing=front_shock_tower_bolt_spacing,
                         tilt_angle=front_shock_tower_damper_holes_angle,
                         damper_holes_n=front_shock_tower_damper_holes_amount,
                         damper_spacing_x=front_shock_tower_damper_spacing_x,
                         damper_bolt_d=front_shock_tower_shock_damper_bolt_d,
                         damper_spacing=front_shock_tower_damper_spacing_x,
                         pin_hole_spacing=front_shock_tower_pin_spacing,
                         pin_d=upper_arm_hinge_barrel_hole_d,
                         pin_hole_y_offset=front_shock_tower_pin_y_offset,
                         pin_hole_pad=front_shock_tower_pin_hole_pad,
                         gap=front_shock_tower_damper_holes_gap,
                         bridge_w=front_shock_tower_bridge_w,
                         pad_x=front_shock_tower_damper_holes_pad_x,
                         pad_y=front_shock_tower_damper_holes_pad_y,
                         debug=false) {
  damper_ear_size_2d =
    front_shock_damper_holes_size2d(tilt_angle=tilt_angle,
                                    damper_holes_n=damper_holes_n,
                                    bolt_d=damper_bolt_d,
                                    gap=gap);

  damper_ear_size_x = damper_ear_size_2d[0];
  damper_ear_size_y = damper_ear_size_2d[1];

  half_of_x = bolt_spacing[0] / 2;
  bb = bbox_holder_hull_samepads(tilt_angle=tilt_angle,
                                 damper_holes_n=damper_holes_n,
                                 bolt_d=damper_bolt_d,
                                 gap=gap,
                                 pad_x=pad_x,
                                 pad_y=pad_y);
  size = size2d_from_bbox(bb);

  size_y = size[1];

  rect_size_y = total_h - size_y;

  start_y = bolt_spacing[1] + bolt_d + pad_y * 2;

  _pin_hole_y_offset = pin_hole_y_offset + pin_hole_pad;
  pin_hole_x = pin_hole_spacing / 2;

  damper_bolt_r = damper_bolt_d / 2;
  bolt_r = bolt_d / 2;

  cutout_x = half_of_x - bolt_r - pad_x;

  common_start_pts = [[-corner_r, start_y],
                      [cutout_x - cutout_corner_r, start_y],
                      [cutout_x,
                       start_y - pad_y - bolt_d]];

  common_pin_y = _pin_hole_y_offset + pin_d / 2 - pin_hole_pad;

  common_end_pts = [[pin_hole_x + pin_d / 2 + pin_hole_pad / 2,
                     common_pin_y],
                    [pin_hole_x - pin_hole_pad,
                     _pin_hole_y_offset + bridge_w + pad_x],
                    [damper_spacing_x / 2 + damper_bolt_r + pad_x,
                     start_y + bridge_w],
                    [damper_spacing_x / 2 - damper_bolt_d + pad_x
                     + damper_ear_size_x,
                     start_y + damper_ear_size_y],
                    [damper_spacing_x / 2, start_y + damper_ear_size_y + pad_y],
                    [damper_spacing_x / 2 - pad_x * 2, start_y + bridge_w],
                    [-corner_r, start_y + bridge_w]];

  pts_1 = concat(common_start_pts,
                 [[half_of_x + bolt_r + pad_x * 2,
                   start_y - ((start_y - _pin_hole_y_offset) / 2) - pin_hole_pad],
                  [pin_hole_x + pin_d / 2, common_pin_y]] ,
                 common_end_pts);

  pin_pts = concat(take(drop(pts_1, 1), 8));

  pts_2_start = concat(common_start_pts,
                       [[cutout_x, 0],
                        [cutout_x + pad_x + bolt_d, 0],
                        [pin_hole_x, common_pin_y]]);

  mount_pts = [[cutout_x,
                start_y - pad_y - bolt_d],
               [cutout_x + bolt_d / 2, 0],
               [pin_hole_x, common_pin_y]];

  pts_2 = concat(pts_2_start,
                 take(common_end_pts, 2));

  module _shape(points=pts_1, r=corner_r) {
    translate([0, rect_size_y, 0]) {
      mirror_copy([1, 0, 0]) {
        translate([-damper_spacing_x / 2, pad_y, 0]) {
          difference() {
            translate([0, 0, 0]) {
              front_shock_holder_2d(tilt_angle=tilt_angle,
                                    damper_holes_n=damper_holes_n,
                                    bolt_d=bolt_d,
                                    gap=gap,
                                    pad_x=pad_x,
                                    pad_y=pad_y);
              translate([0, -bridge_w / 2, 0]) {
                square(size=[damper_spacing_x / 2, bridge_w]);
              }
            }
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
          let (d = pin_d + pin_hole_pad * 2) {
            difference() {
              hull() {
                polygon(pin_pts);
                translate([pin_hole_x,
                           pin_hole_y_offset + pin_d,
                           0]) {
                  circle(d=d, $fn=$preview ? 30 : 360);
                }
              }
            }
          }
        }

        mirror_copy([1, 0, 0]) {
          offset_vertices_2d(r=r, fn=$preview ? 100 : 360) {
            polygon(points);
          }
        }
        children();
      }

      front_shock_tower_holes(total_h=total_h,
                              tilt_angle=tilt_angle,
                              bolt_spacing=bolt_spacing,
                              bolt_d=bolt_d,
                              damper_bolt_d=damper_bolt_d,
                              damper_holes_n=damper_holes_n,
                              gap=gap,
                              pin_hole_spacing=pin_hole_spacing,
                              pin_d=pin_d,
                              damper_spacing=damper_spacing,
                              pad_x=pad_x,
                              pad_y=pad_y)
        ;
    }
  }

  maybe_color(color, alpha=1) {

    linear_extrude(height=thickness, center=false) {
      _shape(pts_1);
    }

    linear_extrude(height=lower_thickness, center=false) {

      _shape(pts_2, r=mount_corner_r) {
        mirror_copy([1, 0, 0]) {
          let (d = bolt_d) {
            union() {
              polygon(mount_pts);
              translate([mount_pts[1][0] + bolt_d / 2,
                         mount_pts[1][1] + d / 2,
                         0]) {
                circle(r=d / 2, $fn=100);
              }
            }
          }
        }
      }
    }
  }
  if (debug) {
    translate([0, 0, thickness]) {
      debug_polygon_text(pts_1, font_color=red_1, circle_r=0.5, font_size=2);
    }
    translate([0, 0, thickness]) {
      debug_polygon_text(pin_pts,
                         circle_r=0,
                         font_color="yellow",
                         font_size=2);
    }

    translate([0, 0, thickness]) {

      debug_polygon_text(mount_pts,
                         circle_r=0,
                         font_color="green",
                         font_size=2);
      debug_polygon_text(pts_2,
                         circle_r=0,
                         font_size=2);
    }
  }
}

union() {
  front_shock_tower(debug=false);
}