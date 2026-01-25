
include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>

module bent(angle, d, fn=360) {
  rotate([0, 90, 0]) {
    #rotate_extrude(angle=angle) {
      translate([d / 2, 0, 0]) {
        circle(r=d / 2, $fn=fn);
      }
    }
  }
}

function m_id() = [[1, 0, 0, 0],
                   [0, 1, 0, 0],
                   [0, 0, 1, 0],
                   [0, 0, 0, 1]];

function m_mul(A, B) = [for (i=[0:3]) [for (j=[0:3])
      A[i][0]*B[0][j] + A[i][1]*B[1][j] + A[i][2]*B[2][j] + A[i][3]*B[3][j]]];

function m_t(x, y, z) = [[1, 0, 0, x],
                         [0, 1, 0, y],
                         [0, 0, 1, z],
                         [0, 0, 0, 1]];

// your bbox helper must exist:
// function rot_x_bbox_align(size, angle, pos=[0,0]) = ...

// compute the same "y" and "z" as old_polyarm did
function seg_yz(w, l, t, angle) =
  let (b = is_num(angle) ? rot_x_bbox_align([w, l, t], angle=angle) : [])
  // b[0]=rot_y_size, b[1]=rot_z_size
  [is_num(angle) ? b[0] : l,
   is_num(angle) ? b[1] : 0];

function build_tfs_bboxwalk(specs,
                            thickness,
                            w_default,
                            i=0,
                            tf=m_id(),
                            acc=[]) =
  (i >= len(specs))
  ? concat(acc, [tf])
  : let (spec  = specs[i],
         ww    = plist_get("w", spec, w_default),
         l     = plist_get("l", spec, 0),
         t     = plist_get("thickness", spec, with_default(thickness, w_default)),
         angle = plist_get("angle", spec, 0),
         yz    = seg_yz(ww, l, t, angle),
         ystep = yz[0],
         zstep = yz[1])
  build_tfs_bboxwalk(specs,
                     thickness,
                     w_default,
                     i + 1,
                     m_mul(tf, m_t(0, ystep, zstep)),
                     concat(acc, [tf]));

function step_vec(l, angle) = [0, l*cos(angle), l*sin(angle)];

function build_tfs_kinematic(specs, i=0, tf=m_id(), acc=[]) =
  (i >= len(specs))
  ? concat(acc, [tf])
  : let (l     = plist_get("l", specs[i], 0),
         angle = plist_get("angle", specs[i], 0),
         dv    = step_vec(l, angle))
  build_tfs_kinematic(specs,
                      i + 1,
                      m_mul(tf, m_t(dv[0], dv[1], dv[2])),
                      concat(acc, [tf]));

module segment_center_x(size,
                        type,
                        slot,
                        r_factor,
                        r,
                        side,
                        fn,
                        slot_mode=false) {
  module _segment() {
    if (!slot_mode) {
      if (type == "cylinder") {
        translate([0, 0, 0]) {
          rotate([-90, 0, 0]) {
            cylinder(d=size[0], h=size[1], $fn=with_default(fn, 40));
          }
        }
      } else if ((is_num(r) && r != 0) || (is_num(r_factor) && r_factor != 0)) {
        translate([0, size[1] / 2, 0]) {
          linear_extrude(height=size[2], center=false) {
            rounded_rect([size[0], size[1]],
                         center=true,
                         r_factor=r_factor,
                         fn=with_default(fn, 40),
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
      let (slot_type = plist_get("type", slot),
           l = size[1],
           y =  plist_get("y", slot, 0),
           d =  plist_get("d", slot),
           h = size[2]) {
        if (slot_mode) {
          if (slot_type == "counterbore") {
            translate([0, l - d / 2 - y, 0]) {
              counterbore_from_plist(plist_merge(slot, ["h", h]));
            }
          }
        }
      }
    }
  } else {
    _segment();
  }
}

function add_bbox(spec=[], w=0, thickness=0) =
  let (angle = plist_get("angle", spec, 0),
       l = plist_get("l", spec, 0),
       w = plist_get("w", spec, w),
       t = plist_get("thickness", spec, thickness),
       bbox = is_num(angle)
       ? rot_x_bbox_align([w, l, t], angle=angle)
       : [],
       bbox_l = bbox[0],
       bbox_h = bbox[1],
       y = is_num(bbox_l) ? bbox_l : l,
       z = is_num(bbox_h) ? bbox_h : 0)
  echo("angle",
       angle,
       "y",
       y,
       "bbox_l",
       bbox_l,
       "bbox_h",
       bbox_h,
       "l",
       l,
       "bbox",
       bbox)
  plist_merge(spec,
              ["y", y, "z", z, "bbox", bbox, "w", w, "t", t, "angle", angle]);

module old_polyarm(specs, thickness, w=7, type) {
  plists = [for (spec = specs) add_bbox(spec,
                                        thickness=with_default(thickness, w),
                                        w=w)];
  y_sizes = [for (v = plists) plist_get("y", v)];
  z_sizes = [for (v = plists) plist_get("z", v)];
  widths = [for (v = plists) plist_get("w", v)];
  max_w = max(widths);
  max_z = max(z_sizes);

  module _slots_or_cubes(slot_mode=false, offset_mode=false) {
    for (i = [0 : len(plists) - 1]) {
      let (plist = plists[i],
           item_type = plist_get("type", plist, type),
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
                segment_center_x([max_w + 1, l, t],
                                 slot_mode=slot_mode,
                                 r_factor=r_factor,
                                 r=r,
                                 side=side,
                                 fn=fn,
                                 slot=slot,
                                 type=item_type);
              } else {
                segment_center_x([w, l, t],
                                 slot_mode=slot_mode,
                                 r_factor=r_factor,
                                 r=r,
                                 side=side,
                                 fn=fn,
                                 slot=slot,
                                 type=item_type);
              }
              // if (item_type == "cylinder" && is_num(angle)) {
              //   translate([0, 0, 0]) {
              //     bent(angle=angle, d=w);
              //   }
              // }
            }
          }
        }
      }
    }
  }
  // difference() {
  //   difference() {
  //     hull() {
  //       _slots_or_cubes(slot_mode=false);
  //     }
  //     hull() {
  //       _slots_or_cubes(offset_mode=true);
  //     }
  //   }
  //   _slots_or_cubes(slot_mode=true);
  // }

  _slots_or_cubes(slot_mode=false);
}

module polyarm(specs, thickness, w=7, type="cube") {

  widths = [for (spec = specs) plist_get("w", spec, w)];
  max_w = max(widths);

  tfs = build_tfs_bboxwalk(specs, thickness, w);

  module _segments(slot_mode=false, offset_mode=false) {
    for (i=[0:len(specs)-1]) {
      let (spec      = specs[i],
           item_type = plist_get("type", spec, type),
           ww        = plist_get("w", spec, w),
           l         = plist_get("l", spec, 0),
           t         = plist_get("thickness", spec, with_default(thickness, w)),
           r_factor  = plist_get("r_factor", spec),
           slot      = plist_get("slot", spec),
           r         = plist_get("r", spec),
           side      = plist_get("side", spec),
           fn        = plist_get("fn", spec),
           angle     = plist_get("angle", spec, 0)) {
        multmatrix(tfs[i]) {
          // identical to old: rotate only affects the segment geometry, not the stepping direction
          maybe_translate([0, offset_mode ? -t : 0, offset_mode ?  t : 0]) {
            maybe_rotate([angle, 0, 0]) {
              segment_center_x(offset_mode ? [max_w + 1, l, t] : [ww, l, t],
                               type=item_type,
                               slot=slot,
                               r_factor=r_factor,
                               r=r,
                               side=side,
                               fn=fn,
                               slot_mode=slot_mode);
            }
          }
        }
      }
    }
  }

  _segments(slot_mode=false);
}

polyarm([["l", 10,
          "w", 10],
         ["l", 8,
          "w", 10,
          "angle", 30],
         ["l", 20,
          "angle", 40],
         ["l", 50,
          "w", 10,
          "angle", 90],
         ["l", 50,
          "angle", 0,
          "w", 10,],
         ["l", 15,
          "r_factor", 0.5,
          "side", "top",
          "angle", 90,
          "slot", ["type", "counterbore",
                   "d", m3_hole_dia,
                   "y", 1]],],
        w=7,
        thickness=2);

// old_polyarm([["l", 10,
//                "w", 10],
//               ["l", 8,
//                "w", 10,
//                "angle", 30],
//               ["l", 20,
//                "angle", 40],
//              ["l", 50,
//               "w", 10,
//               "angle", 90],
//   ["l", 50,
//    "angle", 0,
//    "w", 10,],
//   ["l", 15,
//    "r_factor", 0.5,
//    "side", "top",
//    "angle", 90,
//    "slot", ["type", "counterbore",
//             "d", m3_hole_dia,
//             "y", 1]],],
//   w=7,
//   thickness=2);
