/**
 * Module: Shared power case modules
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/transforms.scad>

module with_power_case_mounting_holes(bolt_spacing=power_case_bottom_bolt_spacing,
                                      offsets=[power_case_bolt_spacing_offset_x,
                                               power_case_bolt_spacing_offset_y]) {
  translate([with_default(offsets[0], 0),
             with_default(offsets[1], 0),
             0]) {

    four_corner_children(size=bolt_spacing,
                         center=true) {
      children();
    }
  }
}