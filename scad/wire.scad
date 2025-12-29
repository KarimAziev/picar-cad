/**
 * Module: Wire
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <colors.scad>
use <lib/functions.scad>

function total_wire_length(points) =
  len(points) < 2 ? 0 :
  sum([for (i = [0 : len(points) - 2]) vlen(points[i + 1] - points[i])]);

function vlen(v) = sqrt(v.x * v.x + v.y * v.y + v.z * v.z);

function vunit(v) = let (L=vlen(v)) (L < 1e-9 ? [0, 0, 0] : v/L);

module caps_hull(d, p1, p2, $fn_sph=32) {
  hull() {
    translate(p1) {
      sphere(d=d, $fn=$fn_sph);
    }
    translate(p2) {
      sphere(d=d, $fn=$fn_sph);
    }
  }
}

module caps_sphere(d, p1, $fn_sph=32) {
  translate(p1) {
    sphere(d=d, $fn=$fn_sph);
  }
}

module caps(d, p1, p2, colr) {
  color(colr, alpha=1) {
    if (vlen(p2 - p1) > 1e-6) {
      caps_hull(d=d, p1=p1, p2=p2);
    }
    else {
      caps_sphere(d=d, p1=p1);
    }
  }
}

module wire_capsule(p1,
                    p2,
                    d=2,
                    colr,
                    $fn_sph=32,
                    wire_lead_color=metallic_silver_1,
                    cut_len) {

  if (is_num(cut_len)) {
    let (dir = vunit(p2 - p1))
      union() {
      difference() {
        caps(p1=p1, p2=p2, d=d, colr=colr);

        caps(p1=p2,
             p2=p2 - dir * cut_len,
             d=d + 1,
             colr=colr,
             $fn_sph=$fn_sph);
      }

      color(wire_lead_color, alpha=1)
        caps(p1=p1, p2=p2, d=d / 2, colr=wire_lead_color, $fn_sph=$fn_sph);
    }
  } else {
    caps(p1=p1, p2=p2, d=d, colr=colr, $fn_sph=$fn_sph);
  }
}

module wire(p1=[0, 0, 0], p2=[10, 0, 0], d=2, $fn_sph=32) {
  wire_capsule(p1, p2, d=d, $fn_sph=$fn_sph);
}

/**
 * Returns a 3D object representing a wire that follow a given path
 */
module wire_path(points,
                 d=2,
                 put_joints=true,
                 $fn_sph=32,
                 print_wire_len=false,
                 cut_len=5,
                 colr) {
  for (i = [0 : len(points) -  2]) {
    wire_capsule(points[i],
                 points[i + 1],
                 colr=colr,
                 cut_len=((is_num(cut_len) && (len(points) - 1 == i + 1)) ? cut_len : undef),
                 d=d,
                 $fn_sph=$fn_sph);
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

wire_path(points=concat([[0, 0, 0]],
                        [[0, -5, -2],
                        [-22, -15, -1],
                        [-22, 10, -60],
                        [-70, 10, -60]]),
                        d=1.5,
          print_wire_len=true,
          colr="red",
          put_joints=true);