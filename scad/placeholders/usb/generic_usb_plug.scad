/**
  * Module: Generic USB plug module
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>

use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>

function usb_plug_params(plist) =
  let (plug_shell=plist_get("plug_shell", plist, []),
       plug_shell_size=plist_get("size", plug_shell, [0, 0, 0]),
       plug_shell_color=plist_get("color", plug_shell, metallic_silver_3),
       plug_body=plist_get("plug_body", plist, []),
       plug_body_color=plist_get("color", plug_body, matte_black),
       plug_body_size=plist_get("size", plug_body),
       strain_relief=plist_get("strain_relief", plist, []),
       strain_relief_d=plist_get("d", strain_relief, 0),
       strain_relief_l=plist_get("l", strain_relief),
       strain_relief_r_factor=plist_get("corner_r_factor", strain_relief, 0.5),
       strain_relief_size = plist_get("size",
                                      strain_relief,
                                      [strain_relief_d,
                                       strain_relief_l,
                                       strain_relief_d]),
       strain_l = with_default(with_default(strain_relief_l, strain_relief_size[1]),
                               0),
       strain_relief_color=plist_get("color", strain_relief, plug_body_color),
       plug_body_l=is_undef(plug_body_size) ? 0 : plug_body_size[1],
       body_with_strain_l = strain_l + plug_body_l,
       shell_l = plug_shell_size[1],
       max_thickness=max([for (v = [plug_body_size[2],
                                    plug_shell_size[2],
                                    with_default(strain_relief_d,
                                                 strain_relief_size[2])])
                             if (!is_undef(v)) v]),
       max_w=max([for (v = [plug_body_size[0],
                            plug_shell_size[0],
                            with_default(strain_relief_d,
                                         strain_relief_size[0])])
                     if (!is_undef(v)) v]),
       full_l=sum([for (v = [plug_body_l,
                             plug_shell_size[1],
                             strain_l])
                      if (!is_undef(v)) v]))
                      ["plug_shell", plug_shell,
                       "plug_shell_size", plug_shell_size,
                       "plug_shell_color", plug_shell_color,
                       "plug_body", plug_body,
                       "plug_body_color", plug_body_color,
                       "plug_body_size", plug_body_size,
                       "strain_relief", strain_relief,
                       "strain_relief_d", strain_relief_d,
                       "strain_relief_l", strain_relief_l,
                       "strain_relief_r_factor", strain_relief_r_factor,
                       "strain_relief_size", strain_relief_size,
                       "strain_l", strain_l,
                       "body_with_strain_l", body_with_strain_l,
                       "shell_l", shell_l,
                       "strain_relief_color", strain_relief_color,
                       "plug_body_l", plug_body_l,
                       "full_size", [max_w, full_l, max_thickness],
                       "max_thickness", max_thickness,
                       "max_w", max_w,
                       "full_l", full_l];

function usb_oriented_size(plist,
                           orientation="wlh") =
  let (params = usb_plug_params(plist),
       full_size =  plist_get("full_size", params))
  orientation_size(orientation, full_size);

module generic_usb_plug(plist,
                        orientation="wlh",
                        anchor=[0, 0, 1],
                        rotate_z_180=false) {
  params = usb_plug_params(plist);

  plug_shell_size = plist_get("plug_shell_size", params);
  plug_shell_color = plist_get("plug_shell_color", params);

  plug_body_color = plist_get("plug_body_color", params);
  plug_body_size = plist_get("plug_body_size", params);

  strain_relief_d = plist_get("strain_relief_d", params);
  strain_relief_l = plist_get("strain_relief_l", params);
  strain_relief_r_factor = plist_get("strain_relief_r_factor", params);
  strain_relief_size = plist_get("strain_relief_size", params);
  strain_l = plist_get("strain_l", params);
  strain_relief_color = plist_get("strain_relief_color", params);
  plug_body_l = plist_get("plug_body_l", params);

  max_thickness = plist_get("max_thickness", params);
  max_w = plist_get("max_w", params);
  full_l = plist_get("full_l", params);

  _anchor=[0, 1, 0];

  with_orientation(anchor=anchor,
                   to=orientation,
                   rotate_z_180=rotate_z_180,
                   size=[max_w, full_l, max_thickness]) {
    translate([0, strain_l - full_l / 2, max_thickness / 2]) {
      union() {
        if (plug_body_size) {
          color(plug_body_color) {
            union() {
              let (size = [plug_body_size[0], plug_body_size[2], plug_body_l]) {
                with_orientation(from="wlh",
                                 to="whl",
                                 anchor=_anchor,
                                 size=size) {
                  cuboid(size=size,
                         anchor=[0, 0, 1],
                         r_factor=0.5);
                }
              }
            }
          }
        }

        if (plug_shell_size) {
          translate([0, plug_body_l, 0]) {
            color(plug_shell_color, alpha=1) {
              cuboid(size=plug_shell_size, anchor=_anchor);
            }
          }
        }
        if (strain_relief_d > 0 && strain_l > 0) {
          color(strain_relief_color) {
            cyl(h=strain_relief_l,
                d=strain_relief_d,
                anchor=[0, -1, 0],
                orientation="lhw");
          }
        } else if (strain_relief_size[0] > 0) {
          color(strain_relief_color) {
            let (size = [strain_relief_size[0],
                         strain_relief_size[2],
                         strain_relief_size[1]]) {
              with_orientation(from="wlh",
                               to="whl",
                               anchor=[0, -1, 0],
                               size=size) {
                cuboid(size=size,
                       anchor=[0, 0, 1],
                       r_factor=strain_relief_r_factor);
              }
            }
          }
        }
      }
    }
  }
}

generic_usb_plug(plist=usb_c_plist,

                 anchor=[1, 1, 0]);

generic_usb_plug(plist=usb_a_plist,
                 anchor=[-1, -1, 0]);