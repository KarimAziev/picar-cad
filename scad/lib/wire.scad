/**
 * Module: Wiring

 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>

use <catmull_rom.scad>
use <functions.scad>

/**
 Returns a 3D object representing a wire that follow a given path
  **Example:**
 ```scad
 wire_path(points=concat([[0, 0, 0]],
                        [[0, -5, -2],
                        [-22, -15, -1],
                        [-22, 10, -60],
                        [-70, 10, -60]]),
                        d=1.5,
          print_wire_len=true,
          colr="red",
          put_joints=true);
 ```

 */
module wire_path(points,
                 d=2,
                 put_joints=false,
                 $fn_sph=32,
                 print_wire_len=false,
                 cut_len=5,
                 colr) {
  for (i = [0 : len(points) -  2]) {
    let (cut_l = (is_num(cut_len) && (len(points) - 1 == i + 1))
         ? cut_len : undef) {
      wire_segment_capsule(points[i],
                           points[i + 1],
                           colr=colr,
                           cut_len=cut_l,
                           d=d,
                           $fn_sph=$fn_sph);
    }
  }

  if (print_wire_len) {
    echo("Total wire length: ", total_wire_length(points));
  }

  if (put_joints)
    for (i = [0 : len(points) - 2]) {
      translate(points[i]) {
        color(colr, alpha=1) {
          sphere(d=d, $fn=$fn_sph);
        }
      }
    }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  wire_bundle
  ─────────────────────────────────────────────────────────────────────────────

  **Example**:
  ```scad
  wire_bundle(points=concat([[0, 0, 0]],
                            [[0, -5, -2],
                            [-22, -15, -1],
                            [-22, 10, -60],
                            [-70, 10, -60]]),
             colors=["black", "red", "white"],
             d=1.5,
             print_wire_len=true,
             put_joints=true);


  ```
  */
module wire_bundle(points,
                   d=1.5,
                   gap=0.2,
                   colors=["black", "red", "white"],
                   put_joints=true,
                   print_wire_len=false,
                   cut_len=5,
                   up=[0, 0, 1]) {

  n = len(colors);
  pitch = d + gap;

  for (i = [0:n-1]) {
    offset = (i - (n - 1) / 2) * pitch;
    pts = offset_path(points, offset, up);

    wire_path(points=pts,
              d=d,
              put_joints=put_joints,
              print_wire_len=print_wire_len,
              cut_len=cut_len,
              colr=colors[i]);
  }
}

function total_wire_length(points) =
  len(points) < 2 ? 0 :
  sum([for (i = [0 : len(points) - 2]) vlen(points[i + 1] - points[i])]);

module wire_segment_hull(d, p1, p2, $fn_sph=32) {
  hull() {
    translate(p1) {
      sphere(d=d, $fn=$fn_sph);
    }
    translate(p2) {
      sphere(d=d, $fn=$fn_sph);
    }
  }
}

module wire_endpoint_sphere(d, p1, $fn_sph=32) {
  translate(p1) {
    sphere(d=d, $fn=$fn_sph);
  }
}

module wire_segment(d, p1, p2, colr) {
  color(colr, alpha=1) {
    if (vlen(p2 - p1) > 1e-6) {
      wire_segment_hull(d=d, p1=p1, p2=p2);
    }
    else {
      wire_endpoint_sphere(d=d, p1=p1);
    }
  }
}

module wire_segment_capsule(p1,
                            p2,
                            d=2,
                            colr,
                            $fn_sph=32,
                            wire_lead_color=metallic_silver_1,
                            cut_len) {

  if (is_num(cut_len)) {
    let (dir = vunit(p2 - p1)) {
      union() {
        difference() {
          wire_segment(p1=p1, p2=p2, d=d, colr=colr);

          wire_segment(p1=p2,
                       p2=p2 - dir * cut_len,
                       d=d + 1,
                       colr=colr,
                       $fn_sph=$fn_sph);
        }

        color(wire_lead_color, alpha=1) {
          wire_segment(p1=p1,
                       p2=p2,
                       d=d / 2,
                       colr=wire_lead_color,
                       $fn_sph=$fn_sph);
        }
      }
    }
  } else {
    wire_segment(p1=p1, p2=p2, d=d, colr=colr, $fn_sph=$fn_sph);
  }
}

module wire(p1=[0, 0, 0], p2=[10, 0, 0], d=2, $fn_sph=32) {
  wire_segment_capsule(p1, p2, d=d, $fn_sph=$fn_sph);
}

module show_case(pts = [[0, 0, 0],
                        [0, -5, -2],
                        [-22, -15, -1],
                        [-22, 10, -60],
                        [-70, 10, -60]],
                 d=1.5,
                 x_spacing=5,
                 y_spacing=5,
                 samples_per_seg=30,
                 step=2,
                 alpha=0.5) {

  smooth_pts_1 = cr_resample_adaptive(pts, step=step);
  smooth_pts_2 = cr_resample(pts, samples_per_seg);
  smooth_pts_centripetal = cr_c_resample_adaptive(pts, step=step, alpha=alpha);

  examples = [["blue", smooth_pts_1],
              ["green", smooth_pts_2],
              ["red", smooth_pts_centripetal]];

  union() {
    for (i = [0 : len(examples) - 1]) {
      let (x = i * x_spacing,
           y = i * y_spacing,
           colr = examples[i][0],
           pts = examples[i][1]) {
        translate([x, y, 0]) {
          wire_path(points=pts,
                    d=d,
                    colr=colr,
                    put_joints=false);
        }
      }
    }
  }
}

d=1.5;
x_spacing=5;
y_spacing=5;
step = 0.5;

pts=[[0, 0, 0],
     [0, -5, -2],
     [-22, -15, -1],
     [-22, 10, -60],
     [-70, 10, -60]];

              // [...["centripetal" | "uniform" | "chordal", step, color]]
examples = [["uniform", step, "blue"],
            ["centripetal", step, "green"],
            ["chordal", step, "red"]];

union() {
  for (i = [0 : len(examples) - 1]) {
    let (mode=examples[i][0],
         st = examples[i][1],
         points = smooth_path(pts, mode=mode, step=st),
         colr = examples[i][2],
         x = i * x_spacing,
         y = i * y_spacing) {

      translate([x, y, 0]) {
        wire_bundle(points=points,
                    colors=["black", "red", "white"],
                    d=1.5,

                    put_joints=false);
      }
    }
  }
}