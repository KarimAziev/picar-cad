include <../colors.scad>

use <../lib/debug.scad>
use <../lib/transforms.scad>

module e_clip(shaft_d,
              color=matte_black,
              clip_radial = undef,
              thickness=0.4,
              fn,
              debug=false) {

  fn = is_undef(fn) ? ($preview ? 20 : 30) : fn;

  tr = is_undef(clip_radial) ? shaft_d * 0.18 : clip_radial;

  outer_r = shaft_d / 2 + tr;

  d = outer_r * 2;
  r = d / 2;

  round_r = r * 0.05;

  echo("d", d);

  x1 = r * 0.45;
  y1 = r * 0.15;

  pts = [[-r * 0.6, -r],
         [-x1, -y1],
         [-x1 - r * 0.1, -y1],
         [-x1 - r * 0.1, y1],
         [-x1, y1 + r * 0.05],
         [-r * 0.70, r * 0.35],
         [-r * 0.45, r * 0.7],
         [-r * 0.2, r * 0.8],
         [-r * 0.15, r * 0.6],
         [round_r, r * 0.6],
         [0, -r * 1.1]];

  color(color) {
    linear_extrude(height=thickness, center=false) {
      difference() {
        circle(r=d / 2, $fn=fn);
        mirror_copy([1, 0, 0]) {
          offset_vertices_2d(r=round_r) {
            polygon(pts);
          }
        }
      }
    }
  }
  if (debug) {
    translate([0, 0, thickness]) {
      debug_polygon_text(pts, font_size=r * 0.15, circle_r=r * 0.02);
    }
  }
}

// module e_clip(shaft_d,
//               color=matte_black,
//               clip_radial = undef,
//               thickness=0.4,
//               bore_clearance=0.15,
//               fn,
//               debug=true) {

//   fn = is_undef(fn) ? ($preview ? 20 : 30) : fn;

//   tr = is_undef(clip_radial) ? shaft_d * 0.18 : clip_radial;

//   outer_r = shaft_d / 2 + tr;
//   inner_r = shaft_d / 2 + bore_clearance;

//   d = outer_r * 2;
//   r = d / 2;

//   round_r = r * 0.05;

//   x1 = r * 0.45;
//   y1 = r * 0.15;

//   pts = [[-r * 0.6, -r],
//          [-x1, -y1],
//          [-x1 - r * 0.1, -y1],
//          [-x1 - r * 0.1, y1],
//          [-x1, y1 + r * 0.05],
//          [-r * 0.70, r * 0.35],
//          [-r * 0.45, r * 0.7],
//          [-r * 0.2, r * 0.8],
//          [-r * 0.15, r * 0.6],
//          [round_r, r * 0.6],
//          [0, -r * 1.1]];

//   color(color) {
//     linear_extrude(height=thickness, center=false) {
//       difference() {
//         circle(r=outer_r, $fn=fn);
//         circle(r=inner_r, $fn=fn);

//         mirror_copy([1, 0, 0]) {
//           offset_vertices_2d(r=round_r) {
//             polygon(pts);
//           }
//         }
//       }
//     }
//   }

//   if (debug) {
//     translate([0, 0, thickness]) {
//       debug_polygon_text(pts, font_size=r * 0.15, circle_r=r * 0.02);
//     }
//   }
// }

e_clip(shaft_d=10);
