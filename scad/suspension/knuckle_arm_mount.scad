include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/l_bracket.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../lib/trapezoids.scad>
use <../placeholders/bolt.scad>
use <../wheels/front_wheel.scad>
use <../wheels/wheel_hub_new.scad>

arm_specs = [["l", 10,
              "w", 10,],
             ["l", 8,
              "w", 10,
              "angle", 30],
             ["l", 20,
              "angle", 40],
             ["l", 15,
              "r_factor", 0.5,
              "angle", 90,
              "slot", ["type", "counterbore",
                       "d", m3_hole_dia,
                       "y", 1]]];

module cuboid_center_x(size, slot, r_factor, r, side, fn, slot_mode=false) {
  module _cube() {
    if (!slot_mode) {
      if ((is_num(r) && r != 0) || (is_num(r_factor) && r_factor != 0)) {
        translate([0, size[1] / 2, 0]) {
          linear_extrude(height=size[2], center=false) {
            rounded_rect([size[0], size[1]],
                         center=true,
                         r_factor=r_factor,
                         fn=fn,
                         side=side);
          }
        }
      } else {
        cube_center_x(size);
      }
    }
  }

  if (slot_mode) {
    if (!is_undef(slot)) {
      let (type = plist_get("type", slot),
           l = size[1],
           y =  plist_get("y", slot, 0),
           d =  plist_get("d", slot),
           h = size[2]) {
        if (slot_mode) {
          if (type == "counterbore") {
            translate([0, l - d / 2 - y, 0]) {
              counterbore_from_plist(plist_merge(slot, ["h", h + 1]));
            }
          }
        }
      }
    }
  } else {
    _cube();
  }
}

function add_bbox(spec=[], w=0, thickness=0) =
  let (angle = plist_get("angle", spec),
       l = plist_get("l", spec, 0),
       w = plist_get("w", spec, w),
       t = plist_get("thickness", spec, thickness),
       bbox = is_num(angle) && angle != 0
       ? rot_x_bbox_align([w, l, t], angle=angle)
       : [],
       bbox_l = bbox[0],
       bbox_h = bbox[1],
       y = is_num(bbox_l) ? bbox_l : l,
       z = is_num(bbox_h) ? bbox_h : 0)
  plist_merge(spec, ["y", y, "z", z, "bbox", bbox, "w", w, "t", t]);

module knuckle_arm_generic(specs=arm_specs, thickness=3, w=7) {
  plists = [for (i = [0 : len(specs) - 1])
      let (spec = add_bbox(arm_specs[i], thickness=thickness, w=w))
        spec];

  y_sizes = [for (v = plists) plist_get("y", v)];
  z_sizes = [for (v = plists) plist_get("z", v)];
  widths = [for (v = plists) plist_get("w", v)];
  max_w = max(widths);

  module _slots_or_cubes(slot_mode=false, offset_mode=false) {
    for (i = [0 : len(plists) - 1]) {
      let (plist = plists[i],
           w = plist_get("w", plist),
           l = plist_get("l", plist),
           t = plist_get("t", plist),
           r_factor = plist_get("r_factor", plist),
           slot=plist_get("slot", plist),
           r=plist_get("r", plist),
           side=plist_get("side", plist),
           fn=plist_get("fn", plist),
           angle = plist_get("angle", plist),
           prev_y_acc = sum(y_sizes, i),
           prev_z_acc = sum(z_sizes, i)) {

        translate([0, prev_y_acc, prev_z_acc]) {
          maybe_translate([0, offset_mode ? -t : 0, offset_mode ? t : 0]) {
            maybe_rotate([angle, 0, 0]) {
              if (offset_mode) {
                cuboid_center_x([max_w + 1, l, t],
                                slot_mode=slot_mode,
                                r_factor=r_factor,
                                r=r,
                                side=side,
                                fn=fn,
                                slot=slot);
              } else {
                cuboid_center_x([w, l, t],
                                slot_mode=slot_mode,
                                r_factor=r_factor,
                                r=r,
                                side=side,
                                fn=fn,
                                slot=slot);
              }
            }
          }
        }
      }
    }
  }
  difference() {
    difference() {
      hull() {
        _slots_or_cubes(slot_mode=false);
      }
      hull() {
        _slots_or_cubes(offset_mode=true);
      }
    }
    _slots_or_cubes(slot_mode=true);
  }
}

module knuckle_arm_mount(d=m3_hole_dia,
                         knuckle_d=0,
                         w,
                         l1=10,
                         offset_r=1,
                         l2=8,
                         l3=10,
                         l4=15,
                         thickness=3,
                         bolt_distance=2,
                         angle1=30,
                         use_hull=true,
                         angle2=50) {
  w = with_default(w, d * 2.5);

  bbox1 = rot_x_bbox_align([w, l2, thickness], angle=angle1);
  bbox2 = rot_x_bbox_align([w, l3, thickness], angle=angle2);

  bbox_w1 = bbox1[0];
  bbox_h1 = bbox1[1];
  bbox_w2 = bbox2[0];
  bbox_h2 = bbox2[1];
  module _forms(w=w) {
    cube([w, l1 + knuckle_d, thickness]);

    translate([0, l1 + knuckle_d, 0]) {
      rotate([angle1, 0, 0]) {
        cube([w, l2, thickness]);
      }
      translate([0, bbox_w1 - thickness, bbox_h1]) {
        rotate([angle2, 0, 0]) {
          cube([w, l3, thickness]);
        }
        translate([0, bbox_w2 - thickness, bbox_h2]) {
          rotate([90, 0, 0]) {
            linear_extrude(height=thickness, center=false) {
              rounded_rect([w, l4],
                           center=false,
                           r_factor=0.5,
                           fn=150,
                           side="top");
            }
          }
        }
      }
    }
  }
  module main_debug(w=w) {
    union() {
      _forms(w=w);
    }
  }
  module main(w=w) {
    hull() {
      _forms(w=w);
    }
  }

  translate([-w / 2, -knuckle_d / 2, 0]) {
    difference() {
      offset_3d(r=offset_r) {
        difference() {
          main();
          translate([-0.5, -thickness, thickness]) {
            main(w=w + 1);
          }
        }
      }
      translate([0, l1 + knuckle_d, 0]) {

        translate([0, bbox_w1 - thickness, bbox_h1]) {

          translate([0, bbox_w2 - thickness, bbox_h2]) {
            translate([w / 2, 0.5 + offset_r, l4 - d - bolt_distance]) {
              rotate([90, 0, 0]) {
                cylinder(d=d, h=thickness + 1 + offset_r * 2, $fn=200);
              }
            }
          }
        }
      }
    }
  }
}

// knuckle_arm_mount(angle1=90, angle2=90, offset_r=0);

knuckle_arm_generic();