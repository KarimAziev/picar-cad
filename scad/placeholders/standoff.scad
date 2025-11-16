/**
 * Module: Standoff placeholder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

module standoff(thread_d=3,
                thread_h=6,
                body_h=4,
                body_d,
                colr=yellow_2,
                thread_at_top=true) {
  module standoff_body() {
    difference() {
      color(colr, alpha=1) {
        cylinder(d=is_undef(body_d) ?
                 thread_d * 2
                 : body_d,
                 h=body_h, $fn=6);
      }

      translate([0, 0, -0.1]) {
        cylinder(d=thread_d, h=body_h + 0.2, $fn=8);
      }
    }
  }
  module standoff_thread() {
    color(colr, alpha=1) {
      cylinder(d=thread_d, h=thread_h, $fn=10);
    }
  }
  if (thread_at_top) {
    standoff_body();
    translate([0, 0, body_h]) {
      standoff_thread();
    }
  } else {
    standoff_thread();
    translate([0, 0, thread_h]) {
      standoff_body();
    }
  }
}

standoff();
