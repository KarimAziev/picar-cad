/**
 * Module: Common 3D slots
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

use <transforms.scad>
use <functions.scad>
use <shapes2d.scad>

function is_no_bore(no_bore,
                    bore_h,
                    bore_d) =
  no_bore == true
  || is_undef(bore_h)
  || is_undef(bore_d)
  || bore_d == 0
  || bore_h == 0;

function four_corner_counterbores_full_size(size,
                                            d,
                                            bore_d,
                                            bore_h,
                                            no_bore = false) =
  let (inhibit_bore = is_no_bore(no_bore=no_bore, bore_h=bore_h, bore_d=bore_d),
       max_d = inhibit_bore ? d : (is_undef(bore_d) ? d * 2.8 : bore_d))
  [for (v = size) v + max_d];

module counterbore(h,
                   d,
                   bore_d,
                   bore_h,
                   center=true,
                   sink=false,
                   fn=60,
                   no_bore=false,
                   autoscale_step = 0.1,
                   reverse=false) {

  inhibit_bore = is_no_bore(no_bore=no_bore, bore_h=bore_h, bore_d=bore_d);
  bore_h = is_undef(bore_h) ? h * 0.3 : bore_h;
  bore_r = (is_undef(bore_d) ? d * 2.8 : bore_d) / 2;
  auto_scale = !is_undef(autoscale_step) && autoscale_step != 0;
  cbore_h = auto_scale ? bore_h + autoscale_step : bore_h;

  max_d = inhibit_bore ? d : bore_r * 2;

  module main_slot() {
    cylinder(h=auto_scale
             ? h + (autoscale_step * 2)
             : h,
             r=d / 2,
             center=false,
             $fn=fn);
  }

  module cbore_hole() {
    if (sink) {
      r1 = !reverse ? d / 2 : bore_r;
      r2 = !reverse ? bore_r : d / 2;
      cylinder(h=cbore_h,
               r1=r1,
               r2=r2,
               center=false,
               $fn=fn);
    } else {
      cylinder(h=cbore_h,
               r=bore_r,
               center=false,
               $fn=fn);
    }
  }

  module _counterbore() {
    if (!auto_scale) {
      main_slot();
    } else {
      translate([0, 0, -autoscale_step]) {
        main_slot();
      }
    }
    if (!inhibit_bore) {
      translate([0,
                 0,
                 !reverse ? h - bore_h
                 : auto_scale
                 ? -autoscale_step
                 : 0]) {
        cbore_hole();
      }
    }
  }

  if (center) {
    _counterbore();
  } else {
    translate([max_d / 2, max_d / 2, 0]) {
      _counterbore();
    }
  };
}

module rect_slot(h,
                 recess_h,
                 size,
                 recess_size,
                 autoscale_step = 0.1,
                 recess_corner_r,
                 r,
                 r_factor=0.3,
                 fn=40,
                 side,
                 reverse=false,
                 center=false,
                 spin) {

  slot_x = size[0];
  slot_y = size[1];

  recess_size = with_default(recess_size, []);

  recess_enabled = (!is_undef(recess_size[0])
                    || !is_undef(recess_size[1])) &&
    (with_default(recess_size[0], 0) > slot_x
     || with_default(recess_size[1], 0) > slot_y);

  auto_scale = !is_undef(autoscale_step) && autoscale_step != 0;
  recess_x = recess_enabled
    ? max(with_default(recess_size[0], 0), slot_x)
    : recess_size[0];
  recess_y = recess_enabled
    ? max(with_default(recess_size[1], 0), slot_y)
    : recess_size[1];

  recess_base_h = with_default(recess_h, max(1, h / 2.2));

  recess_z = !reverse
    ? h - recess_base_h
    : auto_scale
    ? -autoscale_step
    : 0;

  module main_slot() {
    linear_extrude(height=auto_scale
                   ? h + (autoscale_step * 2)
                   : h,
                   center=false) {
      rounded_rect(size=[slot_x, slot_y],
                   r_factor=r_factor,
                   fn=fn,
                   side=side,
                   r=r,
                   center=true);
    }
  }

  module _rect_slot() {
    union() {
      if (!auto_scale) {
        main_slot();
      } else {
        translate([0, 0, -autoscale_step]) {
          main_slot();
        }
      }

      if (recess_enabled) {
        translate([0, 0, recess_z]) {

          linear_extrude(height=recess_base_h +
                         (auto_scale ? autoscale_step : 0),
                         center=false) {
            rounded_rect(size=[recess_x, recess_y],
                         r_factor=r_factor,
                         r=with_default(recess_corner_r, r),
                         side=side,
                         fn=fn,
                         center=true);
          }
        }
      }
    }
  }

  if (center) {
    maybe_rotate([0, 0, spin]) {
      _rect_slot();
    }
  } else {
    params = calc_rotated_bbox(recess_enabled ? recess_x : slot_x,
                               recess_enabled ? recess_y : slot_y,
                               with_default(spin, 0));
    sx = params[2];
    sy = params[3];
    maybe_translate((is_undef(spin) || abs(spin) == 0) ? undef : [sx, sy, 0]) {
      maybe_rotate([0, 0, spin]) {
        translate([(recess_enabled ? recess_x / 2 : slot_x / 2),
                   (recess_enabled ? recess_y / 2 : slot_y / 2),
                   0]) {
          _rect_slot();
        }
      }
    }
  }
}

module four_corner_counterbores(size,
                                h,
                                d,
                                bore_d,
                                bore_h,
                                center=true,
                                sink=false,
                                fn=60,
                                no_bore=false,
                                autoscale_step = 0.1,
                                reverse=false,
                                spin) {

  full_size = four_corner_counterbores_full_size(size=size,
                                                 d=d,
                                                 bore_d=bore_d,
                                                 bore_h=bore_h,
                                                 no_bore=no_bore);

  full_x = full_size[0];
  full_y = full_size[1];

  module _cbores() {
    four_corner_children(size=size,
                         center=true) {
      counterbore(d=d,
                  bore_d=bore_d,
                  h=h,
                  sink=sink,
                  bore_h=bore_h,
                  reverse=reverse,
                  fn=fn,
                  no_bore=no_bore,
                  autoscale_step=autoscale_step);
    }
  }

  if (center) {
    maybe_rotate([0, 0, spin]) {
      _cbores();
    }
  } else {
    spin_keep_bbox_at_origin(size=full_size, spin) {
      translate([full_x / 2, full_y / 2, 0]) {
        _cbores();
      }
    }
  }
}

translate([-10, 0, 0]) {
  counterbore(h=3,
              d=3,
              bore_d=6,
              bore_h=2,
              sink=true,
              fn=100,
              center=false,
              reverse=true);
}

w = 20;
h = 10;
thickness = 3;
angle = 15;

rect_slot(size=[w, h],
          h=thickness,
          reverse=true,
          recess_h=1.5,
          recess_size=[w + 10, 15],
          r_factor=0,
          spin=80,
          center=false);

dia = 3;
bore_dia = 6;
bore_h = 1;
rect_size = [20, 30];
single_hole_d = 8;
four_corner_holes_size = [40, 60];

four_corner_holes_size_full_size =
  four_corner_counterbores_full_size(size=four_corner_holes_size,
                                     d=dia,
                                     bore_d=bore_dia,
                                     bore_h=bore_h);
gap = 2;

four_corner_counterbores(size=four_corner_holes_size,
                         center=false,
                         spin=30,
                         d=dia,
                         bore_d=bore_dia,
                         h=thickness,
                         bore_h=bore_h,
                         reverse=true);