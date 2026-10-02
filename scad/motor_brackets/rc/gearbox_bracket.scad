/**
  * Module: Gearbox bracket in the style of MN82/MN78 gearboxes
  *
  * This gearbox is quite complex and has asymetric shape.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../rc_params.scad>

use <../../lib/debug.scad>
use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/polygon_util.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../placeholders/motors/rc/brushed_motor.scad>
use <../../placeholders/motors/rc/gearbox.scad>
use <../../placeholders/motors/rc/gearmotor.scad>
use <driveshaft_magnet_sleeve.scad>
use <gearbox_boss.scad>
use <gearmotor_encoder_bracket.scad>
use <util.scad>

show_gearbox                  = true;
show_motor                    = true;
show_bearing                  = true;
show_drive_shaft              = true;
show_mount_bolts              = true;
show_nuts                     = true;
show_bracket                  = true;
show_shaft_seeve              = false;
show_extra_drive_shaft        = false;
show_encoder_bracket          = true;
show_encoder                  = true;
show_encoder_magnet           = true;
show_encoder_sleeve           = true;
show_gearbox_bosses           = true;

show_min_parent_surface_width = false;

debug_circle_color            = matte_black;

function lerp(a, b, t) = a*(1-t) + b*t;

function lerp_pts(pts1, pts2, t) =
  [for (i=[0:len(pts1)-1])
      [lerp(pts1[i][0], pts2[i][0], t),
       lerp(pts1[i][1], pts2[i][1], t)]];

module loft_slices(pts1, pts2, h, steps=20, r=0) {
  for (i=[0:steps-1]) {
    t1 = i/steps;
    t2 = (i + 1)/steps;
    z1 = h*t1;
    // Keep the final 0.01 mm slice inside the requested height.
    z2 = min(h - 0.01, h*t2);
    p1 = lerp_pts(pts1, pts2, t1);
    p2 = lerp_pts(pts1, pts2, t2);

    hull() {
      translate([0, 0, z1]) {
        linear_extrude(height=0.01) {
          offset_vertices_2d(r=r) {
            polygon(p1);
          }
        }
      }

      translate([0, 0, z2]) {
        linear_extrude(height=0.01) {
          offset_vertices_2d(r=r) {
            polygon(p2);
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  loft_polyhedron
  ─────────────────────────────────────────────────────────────────────────────

  Loft corresponding polygon vertices from Z=0 to Z=h.

  **Parameters:**
  - `pts1`: Bottom outline; each entry starts with numeric X/Y coordinates.
  - `pts2`: Top outline with the same vertex count, winding, and correspondence.
  - `h`: Positive height.
  - `steps`: Positive integer number of interpolated side bands. Increase for
    nonplanar sides; one band suffices for planar sides.

  **Behavior:**
  Either clockwise or counterclockwise outlines are accepted. Extra point
  metadata is ignored. Outlines and their interpolations must be simple,
  nondegenerate polygons without duplicate adjacent vertices or crossed sides.
  Concavities are preserved. Unlike `loft_slices()`, this does not convexify
  the outline or round its corners.
 */
module loft_polyhedron(pts1, pts2, h, steps=1) {
  assert(is_list(pts1) && is_list(pts2), "Loft outlines must be lists");
  n = len(pts1);
  assert(n >= 3 && len(pts2) == n,
         "Loft outlines need the same number of vertices (at least three)");
  assert(is_num(h) && h > 0, "Loft height must be positive");
  assert(is_num(steps) && steps >= 1 && steps == floor(steps),
         "Loft steps must be a positive integer");
  for (pts = [pts1, pts2]) {
    for (p = pts) {
      assert(is_list(p) && len(p) >= 2 && is_num(p[0]) && is_num(p[1]),
             "Loft vertices need numeric X/Y coordinates");
    }
    for (i = [0:n-1]) {
      assert(norm([pts[i][0] - pts[(i + 1)%n][0],
                   pts[i][1] - pts[(i + 1)%n][1]]) > 0,
             "Loft outlines must not repeat adjacent vertices");
    }
  }
  area1 = polygon_signed_area(pts1);
  area2 = polygon_signed_area(pts2);
  assert(area1 * area2 > 0, "Loft outlines must have matching nonzero winding");

  points = [for (k = [0:steps])
      for (p = lerp_pts(pts1, pts2, k/steps))
        [p[0], p[1], h*k/steps]];
  // For CCW outlines OpenSCAD wants the bottom in forward order, the top
  // reversed, and side edges opposite their neighboring cap edges.
  // Triangles avoid nonplanar quads when corresponding edges are not parallel.
  faces = concat([[for (i = [0:n-1]) i]],
                 [[for (i = [n-1:-1:0]) steps*n + i]],
                 [for (k = [0:steps-1], i = [0:n-1])
                     let (j = (i + 1)%n,
                          a = k*n + i, b = k*n + j,
                          c = (k + 1)*n + j, d = (k + 1)*n + i)
                       each [[a, d, c], [a, c, b]]]);
  polyhedron(points=points,
             faces=area1 > 0 ? faces : [for (face = faces) reverse(face)],
             convexity=10);
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  gearmotor_bracket
  ─────────────────────────────────────────────────────────────────────────────

  Render the shaft-centered motor bracket, hardware, or parent mounting cutters.

  **Parameters:**
  - `plist`: Motor hardware plist; unnecessary when `params` is supplied.
  - `color`: Bracket color.
  - `bolt_pad_x`: Bracket mounting-hole padding along X.
  - `bolt_pad_y`: Bracket mounting-hole padding along Y.
  - `ear_bolt_pad`: Padding around gearbox mounting ears.
  - `bolt_d`: Bracket-to-chassis through-hole diameter.
  - `bracket_thickness`: Base thickness.
  - `corner_r`: Outline rounding radius.
  - `fillet_x_w`: Base flare along X.
  - `fillet_y_w`: Base flare along Y.
  - `show_gearbox`: Display gearbox hardware.
  - `show_motor`: Display motor hardware.
  - `show_bearing`: Display drive-shaft bearings.
  - `show_drive_shaft`: Display the gearbox's drive shaft.
  - `show_mount_bolts`: Display motor mounting bolts.
  - `show_bracket`: Display the printed bracket.
  - `show_nuts`: Display motor mounting nuts.
  - `chassis_thickness`: Additional cutter depth for the parent plate.
  - `show_shaft_seeve`: Display the shaft sleeve.
  - `show_extra_drive_shaft`: Display the sleeve's output shaft.
  - `anchor`: Legacy XY datum selector; `[0, 0, 1]` retains native coordinates.
    X=0 always retains the drive-shaft center, not the asymmetric box center.
    On X/Y, -1 selects the minimum and 1 the maximum reference coordinate.
    The mounting plane remains Z=0.
  - `anchor_mode`: `"holes_center"` selects hole-center extents; `"size"` selects
    bracket footprint extents for nonzero X/Y anchor components.
  - `debug_circle_color`: Vertex-label marker color.
  - `show_min_parent_surface_width`: Display the symmetric parent reference.
  - `slot_mode`: Emit parent mounting cutters instead of solids.
  - `debug`: Display outline and hole labels.
  - `params`: Result of `gearmotor_bracket_compute_params()`; overrides `plist`
    and sizing arguments so layout and geometry use the same specification.
  - `encoder_plist`: Encoder PCB specification; `undef` removes the mounting feature.
  - `show_encoder_bracket`: Display the removable encoder mount.
  - `show_encoder`: Display its PCB; `show_mount_bolts` also controls its fasteners.
  - `show_encoder_magnet`: Display the magnet seated in its shaft sleeve.
  - `boss_wall_thickness`: Radial boss wall; zero disables both bosses.
  - `show_gearbox_bosses`: Display the two separate removable supports.
  - `motor_carrier_clearance`: Motor cutout diameter allowance and top relief.
  - `boss_pocket_clearance`: Diametral allowance in the boss sockets.
  - `boss_pocket_depth`: Boss engagement below the top of the base.
  - `boss_h_clearances`: Front/rear gaps below the gearbox ears.
  - `show_encoder_sleeve`: Display the printed shaft-end magnet holder.
 */
module gearmotor_bracket(plist,
                         color=white_off_1,
                         bolt_pad_x=gearbox_bracket_bolt_pad_x,
                         bolt_pad_y=gearbox_bracket_bolt_pad_y,
                         ear_bolt_pad=gearbox_bracket_ear_bolt_pad,
                         bolt_d=gearbox_bracket_bolt_d,
                         bracket_thickness=bracket_thickness,
                         corner_r=gearbox_bracket_corner_r,
                         fillet_x_w=gearbox_bracket_fillet_x_w,
                         fillet_y_w=gearbox_bracket_fillet_y_w,
                         show_gearbox=show_gearbox,
                         show_motor=show_motor,
                         show_bearing=show_bearing,
                         show_drive_shaft=show_drive_shaft,
                         show_mount_bolts=show_mount_bolts,
                         show_bracket=show_bracket,
                         show_nuts=show_nuts,
                         chassis_thickness=chassis_thickness,
                         show_shaft_seeve=show_shaft_seeve,
                         show_extra_drive_shaft=show_extra_drive_shaft,
                         anchor=[0, 1, 1],
                         anchor_mode="holes_center",  // holes_center | size
                         debug_circle_color=debug_circle_color,
                         show_min_parent_surface_width=show_min_parent_surface_width,
                         slot_mode=false,
                         debug=false,
                         params=undef,
                         encoder_plist=motor_encoder_plist,
                         show_encoder_bracket=show_encoder_bracket,
                         show_encoder=show_encoder,
                         show_encoder_magnet=show_encoder_magnet,
                         boss_wall_thickness=gearbox_bracket_boss_thickness,
                         show_gearbox_bosses=show_gearbox_bosses,
                         motor_carrier_clearance=gearbox_bracket_motor_carrier_clearance,
                         boss_pocket_clearance=gearbox_bracket_boss_pocket_clearance,
                         boss_pocket_depth=gearbox_bracket_boss_pocket_depth,
                         boss_h_clearances=gearbox_bracket_boss_pocket_h_clearances,
                         show_encoder_sleeve=show_encoder_sleeve,
                         bolt_dist_from_cap=gearbox_bracket_bolt_dist_from_cap,
                         nut_pocket_clearance=gearbox_bracket_nut_pocket_clearance,
                         nut_pocket_h_clearance=gearbox_bracket_nut_pocket_h_clearance,
                         use_polyhedron=false) {
  resolved = is_undef(params)
    ? gearmotor_bracket_compute_params(plist=plist,
                                       bolt_pad_x=bolt_pad_x,
                                       bolt_pad_y=bolt_pad_y,
                                       ear_bolt_pad=ear_bolt_pad,
                                       bolt_d=bolt_d,
                                       bracket_thickness=bracket_thickness,
                                       corner_r=corner_r,
                                       fillet_x_w=fillet_x_w,
                                       fillet_y_w=fillet_y_w,
                                       encoder_plist=encoder_plist,
                                       boss_wall_thickness=boss_wall_thickness,
                                       boss_pocket_clearance=boss_pocket_clearance,
                                       boss_pocket_depth=boss_pocket_depth,
                                       boss_h_clearances=boss_h_clearances,
                                       motor_carrier_clearance=motor_carrier_clearance,
                                       bolt_dist_from_cap=bolt_dist_from_cap,
                                       nut_pocket_clearance=nut_pocket_clearance)
    : params;
  motor = plist_get("motor", resolved);
  encoder_mount = plist_get("encoder_mount", resolved);
  resolved_bolt_d = plist_get("bolt_d", resolved);
  resolved_bracket_thickness = plist_get("bracket_thickness", resolved);
  resolved_corner_r = plist_get("corner_r", resolved);
  outer_shaft_y_center = plist_get("outer_shaft_y_center", resolved);
  mount_bolt_d = plist_get("mount_bolt_d", resolved);
  boss_od = plist_get("boss_od", resolved);
  carrier_clearance = plist_get("motor_carrier_clearance", resolved);
  mount_cbore_d = plist_get("mount_cbore_d", resolved);
  motor_outer_shaft_x_spacing = plist_get("motor_outer_shaft_x_spacing",
                                          resolved);
  motor_d = plist_get("motor_d", resolved);
  motor_shaft_y = plist_get("motor_shaft_y", resolved);
  body_h = plist_get("body_h", resolved);
  carrier_w = plist_get("carrier_w", resolved);

  bracket_mount_holes = plist_get("bracket_mount_holes", resolved);
  gearbox_mount_holes = plist_get("gearbox_mount_holes", resolved);
  pts = plist_get("pts", resolved);
  pts_2 = plist_get("pts_2", resolved);
  min_hole_x = plist_get("min_hole_x", resolved);
  max_hole_x = plist_get("max_hole_x", resolved);
  min_hole_y = plist_get("min_hole_y", resolved);
  max_hole_y = plist_get("max_hole_y", resolved);
  min_x = plist_get("min_x", resolved);
  max_x = plist_get("max_x", resolved);
  min_y = plist_get("min_y", resolved);
  max_y = plist_get("max_y", resolved);

  magnet_sleeve_mount = plist_get("sleeve", with_default(encoder_mount, []));

  anchor_x_modes = ["holes_center", [-1, -min_hole_x,
                                     1, -max_hole_x],
                    "size", [-1, -min_x,
                             1, -max_x]];
  anchor_y_modes = ["holes_center", [-1, -min_hole_y,
                                     1, -max_hole_y],
                    "size", [-1, -min_y,
                             1, -max_y]];

  total_l = abs(max_y) + abs(min_y);

  x_shift = plist_get(anchor[0], plist_get(anchor_mode, anchor_x_modes, []), 0);
  y_shift = plist_get(anchor[1], plist_get(anchor_mode, anchor_y_modes, []), 0);

  module _bosses(slot_mode=false) {
    gearbox_bosses(params=resolved, slot_mode=slot_mode);
  }

  module _slot_holes(holes,
                     h,
                     d=resolved_bolt_d,
                     bore_d,
                     bore_h,
                     sink=false,
                     pocket=false) {

    for (pair = holes) {
      let (x = pair[0],
           y = pair[1]) {
        translate([x, y, 0]) {
          if ($children) {
            children();
          } else {
            counterbore(h=h,
                        d=d,
                        sink=sink,
                        bore_d=bore_d,
                        bore_h=bore_h,
                        fn=$preview ? 16 : 300,
                        reverse=true);
          }
        }
      }
    }
  }

  module _slot(extra_thickness=0) {
    let (slot_h = resolved_bracket_thickness
         + outer_shaft_y_center
         + extra_thickness,
         motor_parent_thickness = resolved_bracket_thickness
         + extra_thickness) {
      union() {
        gearmotor(plist=motor,
                  slot_mode=true,
                  parent_thickness=motor_parent_thickness);
        _slot_holes(h=slot_h,
                    holes=gearbox_mount_holes,
                    sink=true,
                    bore_d=mount_cbore_d,
                    bore_h=resolved_bracket_thickness,
                    d=mount_bolt_d);

        _slot_holes(holes=bracket_mount_holes,
                    h=slot_h,
                    d=resolved_bolt_d);
      }
    }
  }

  module _bracket() {
    difference() {
      union() {
        maybe_color(color) {
          union() {
            if (use_polyhedron) {
              loft_polyhedron(pts_2,
                              pts,
                              h=resolved_bracket_thickness,
                              steps=24);
            } else {
              loft_slices(pts_2,
                          pts,
                          h=resolved_bracket_thickness,
                          steps=24,
                          r=resolved_corner_r);
            }

            if (!is_undef(encoder_mount)) {
              land = plist_get("base_extension_bounds", encoder_mount);
              translate(land[0]) {
                cuboid(size=land[1] - land[0],
                       anchor=[1, 1, 1],
                       side="right",
                       r_factor=0.5);
              }
            }
          }

          translate([-motor_outer_shaft_x_spacing, 0, 0]) {
            let (sleeve_origin = plist_get("sleeve_origin",
                                           with_default(encoder_mount, [])),
                 body_support_l = is_undef(sleeve_origin)
                 ? body_h
                 : sleeve_origin[1],
                 size_z = resolved_bracket_thickness + motor_shaft_y,
                 eps = 1) {
              difference() {
                cuboid(size=[carrier_w, body_support_l, size_z],
                       anchor=[0, 1, 1]);

                translate([0, -0.5, size_z]) {
                  rotate([-90, 0, 0]) {
                    cylinder(d=motor_d + carrier_clearance,
                             h=body_h + eps,
                             $fn=$preview ? 30 : 300);
                  }
                  translate([0, 0, -motor_d * 0.23 - carrier_clearance]) {
                    cuboid(size=[carrier_w + eps, body_h + eps, size_z],
                           anchor=[0, 1, 1]);
                  }
                }
              }
            }
          }
        }
      }

      if (boss_od > mount_bolt_d) {
        _bosses(slot_mode=true);
      }

      if (!is_undef(encoder_mount)) {
        gearmotor_encoder_bracket(encoder_mount, slot_mode=true);
      }

      gearmotor(plist=motor,
                slot_mode=true,
                parent_thickness=resolved_bracket_thickness);

      let (slot_h = resolved_bracket_thickness) {
        _slot_holes(holes=bracket_mount_holes,
                    h=slot_h,
                    d=resolved_bolt_d) {
          rotate([0, 0, 90]) {
            pocket_slot(h=slot_h,
                        h_clearance=nut_pocket_h_clearance,
                        d=resolved_bolt_d,
                        fn=$preview ? 16 : 200,
                        clearance=nut_pocket_clearance);
          }
        }
      }
    }
  }

  translate([x_shift, y_shift, 0]) {
    if (slot_mode) {
      _slot(extra_thickness=chassis_thickness);
    } else {

      if (show_bracket) {
        _bracket();
      }

      if (show_gearbox_bosses) {
        _bosses();
      }

      if (show_min_parent_surface_width) {
        translate([-max(plist_get("side_widths", resolved)),
                   plist_get("parent_surface_y_bounds", resolved)[0],
                   0]) {
          color(cobalt_blue_metallic, alpha=1) {
            cuboid(size=concat(plist_get("min_parent_surface_size",
                                         resolved),
                               [1]),
                   anchor=[1, 1, 1]);
          }
        }
      }

      if (!is_undef(encoder_mount)) {
        gearmotor_encoder_bracket(encoder_mount,
                                  show_bracket=show_encoder_bracket,
                                  show_encoder=show_encoder,
                                  show_mount_bolts=show_mount_bolts,
                                  color=color);
        translate(plist_get("sleeve_origin", encoder_mount)) {
          rotate(plist_get("sleeve_rotation", encoder_mount)) {
            driveshaft_magnet_sleeve(params=magnet_sleeve_mount,
                                     show_sleeve=show_encoder_sleeve,
                                     show_magnet=show_encoder_magnet);
          }
        }
      }

      gearmotor(plist=motor,
                show_gearbox=show_gearbox,
                show_motor=show_motor,
                show_nuts=show_nuts,
                show_bearing=show_bearing,
                show_drive_shaft=show_drive_shaft,
                show_mount_bolts=show_mount_bolts,
                parent_thickness=resolved_bracket_thickness,
                show_shaft_seeve=show_shaft_seeve,
                show_extra_drive_shaft=show_extra_drive_shaft);
    }

    if (debug) {
      let (debug_circle_r=total_l * 0.01,
           debug_font_size=total_l * 0.03) {

        translate([0,
                   0,
                   slot_mode
                   ? chassis_thickness + resolved_bracket_thickness
                   : resolved_bracket_thickness]) {
          debug_polygon_text(points=pts,
                             offset_x=5,
                             circle_r=debug_circle_r,
                             circle_color=debug_circle_color,
                             font_size=debug_font_size,
                             offset_line_w=0.1);
          debug_polygon_text(points=bracket_mount_holes,
                             color=matte_black_2,
                             circle_r=0.1,
                             circle_color=debug_circle_color,
                             font_size=resolved_bolt_d * 0.5,
                             default_txt_plist=["halign", "left"]);
          translate([0, 0, outer_shaft_y_center]) {
            debug_polygon_text(points=gearbox_mount_holes,
                               color=cobalt_blue_dark_1,
                               circle_r=0.1,
                               circle_color=debug_circle_color,
                               font_size=resolved_bolt_d * 0.5);
          }
        }
      }
    }
  }
}

gearmotor_bracket(plist=motor_plist,
                  anchor_mode="size",
                  anchor=[0, 0, 1],
                  debug=false,
                  show_gearbox=false,
                  show_motor=true,
                  show_encoder_bracket=false,
                  show_encoder=false,
                  use_polyhedron=false);
