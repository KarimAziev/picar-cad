/**
 * Module: Wire
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

use <lib/functions.scad>

function total_wire_length(points) =
  len(points) < 2 ? 0 :
  sum([for (i = [0 : len(points) - 2]) vlen(points[i + 1] - points[i])]);

function vlen(v) = sqrt(v.x * v.x + v.y * v.y + v.z * v.z);

module wire_capsule(p1, p2, d=2, $fn_sph=32) {
  if (vlen(p2 - p1) > 1e-6) {
    hull() {
      translate(p1) {
        sphere(d=d, $fn=$fn_sph);
      }
      translate(p2) {
        sphere(d=d, $fn=$fn_sph);
      }
    }
  }
  else {
    translate(p1) {
      sphere(d=d, $fn=$fn_sph);
    }
  }
}

module wire(p1=[0, 0, 0], p2=[10, 0, 0], d=2, $fn_sph=32) {
  wire_capsule(p1, p2, d=d, $fn_sph=$fn_sph);
}

/**
 * Returns a 3D object representing a wire that follow a given path
 */
module wire_path(points, d=2, put_joints=true, $fn_sph=32, print_wire_len=false) {
  for (i = [0 : len(points) -  2]) {
    wire_capsule(points[i], points[i + 1], d=d, $fn_sph=$fn_sph);
  }

  if (print_wire_len) {
    echo("Total wire length: ", total_wire_length(points));
  }

  if (put_joints)
    for (i = [0 : len(points) - 1]) {
      translate(points[i]) {
        sphere(d=d, $fn=$fn_sph);
      }
    }
}

wire_path(points=[[50, 0, -150],
                  [50, 50,-50],
                  [0, 50, -50],
                  [0, 0, -50],
                  [0, 0, 0]],
          d=1.5,
          print_wire_len=true,
          put_joints=true);