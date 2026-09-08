/**
  * Module: Generic placeholder for rotary encoders, such as AS5048A
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/placement.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/text.scad>
use <../lib/transforms.scad>
use <bolt.scad>
use <smd/ceramic_capacitor.scad>
use <smd/smd_chip.scad>

function encoder_total_thickness(plist) =
  let (size = plist_get("size", plist),
       thickness = size[2],
       ceramic_capacitors = plist_get("placeholder_size",
                                      plist_get("props",
                                                plist_get("ceramic_capacitors",
                                                          plist, []),
                                                [])),
       capacitor_h = ceramic_capacitors[2],
       sensor_ic = plist_get("chip_size",
                             plist_get("sensor_ic", plist, []),
                             []),
       sensor_ic_h = sensor_ic[2],
       vals = [for (v = [capacitor_h, sensor_ic_h]) if (!is_undef(v)) v],
       max_h = len(vals) > 0 ? max(vals) : 0)
  thickness + max_h;

function text_to_plist(txt_or_plist) = is_string(txt_or_plist)
  ? ["text", txt_or_plist]
  : txt_or_plist;

function _get_text_plist(spec,
                         type,
                         defaults=["size", 1, "valign", "center"]) =
  let (value = spec && plist_get(type, spec)
       ? plist_merge(defaults,
                     text_to_plist(is_string(plist_get(type, spec)) ?
                                   ["text",
                                    plist_get(type, spec)]
                                   : plist_get(type, spec)))
       : undef)
  value;

module encoder(plist,
               show_encoder=true,
               show_bolt=true,
               show_nut=true,
               bolt_h,
               parent_thickness=1,
               bolt_reverse=false,
               slot_mode=false,
               counterbore_props=[],
               anchor=[0, 0, 1]) {
  parent_thickness = with_default(parent_thickness, 1);
  colr = plist_get("color", plist);
  size = plist_get("size", plist);
  corner_r = plist_get("corner_r", plist);
  chamfer_size = plist_get("chamfer_size", plist, 0);
  bolt_spacing = plist_get("bolt_spacing", plist);
  bolt_d = plist_get("bolt_d", plist=plist);
  pcb_w = size[0];
  pcb_l = size[1];
  pcb_thickness = size[2];

  sensor_ic = plist_get("sensor_ic", plist);

  interface_pads = plist_get("interface_pads", plist);

  wire_pads = plist_get("wire_pads", plist);

  ceramic_capacitors = plist_get("ceramic_capacitors", plist);

  assert(is_list(size), "Size is required for the encoder!");
  assert(is_num(size[0]) && is_num(size[1]) && is_num(size[2]),
         str("Encoder size must be a 3-dimensional array; received ", size));
  assert(is_list(sensor_ic),
         "A sensor IC plist is required for the encoder!");

  with_anchor(anchor=anchor, size=size, centered=true) {
    if (slot_mode) {
      four_corner_children(size=bolt_spacing, center=true) {
        counterbore_from_plist(plist_merge(["d", bolt_d,
                                            "h", parent_thickness],
                                           with_default(counterbore_props, [])));
      }
    } else {
      if (show_encoder) {
        union() {
          maybe_color(color=colr) {
            linear_extrude(height=pcb_thickness, center=false) {
              difference() {
                if (corner_r) {
                  offset_vertices_2d(r=corner_r)
                    chamfered_rect(size=size, chamfer=chamfer_size);
                } else {
                  chamfered_rect(size=size, chamfer=chamfer_size);
                }

                four_corner_children(size=bolt_spacing, center=true) {
                  circle(d=bolt_d, $fn=24);
                }
              }
            }
          }
          translate([0, 0, pcb_thickness]) {
            maybe_rotate(plist_get("rotation", sensor_ic)) {
              smd_chip_from_plist(sensor_ic, center=true);
            }

            if (interface_pads) {
              _interface_pads(plist=interface_pads,
                              pcb_w=pcb_w,
                              pcb_l=pcb_l,
                              h=0.1);
            }
            if (wire_pads) {
              _interface_pads(plist=wire_pads, pcb_w=pcb_w, pcb_l=pcb_l, h=0.1);
            }
            if (ceramic_capacitors) {
              _capacitors(ceramic_capacitors, pcb_w=pcb_w, pcb_l=pcb_l);
            }
          }
        }
      }
      if (show_bolt) {
        four_corner_children(size=bolt_spacing, center=true) {
          let (lock_nut = plist_get("lock_nut", plist),
               bolt_spec = find_bolt_nut_spec(bolt_d,
                                              specs=bolt_specs,
                                              default=[]),
               nut_type = lock_nut ? "lock_nut" : "nut",
               nut_spec=plist_get(nut_type, bolt_spec, []),
               nut_h = plist_get("height", nut_spec, 0),
               bolt_h = is_undef(bolt_h)
               ? (parent_thickness + nut_h + pcb_thickness)
               : bolt_h,
               nut_head_distance=parent_thickness + pcb_thickness,
               head_type = plist_get("bolt_head_type", plist, "pan"),
               head_spec = plist_get(head_type,
                                     plist_get("head", bolt_spec, []),
                                     []),
               head_h = head_type == "none" ? 0 : plist_get("height",
                                                            head_spec,)) {
            if (bolt_h > 0) {
              rotate([0, 0, 0]) {
                translate([0,
                           0,
                           bolt_reverse ? -head_h : (-bolt_h + pcb_thickness)]) {
                  bolt(d=bolt_d,
                       h=bolt_h,
                       nut_head_distance=nut_head_distance,
                       show_nut=show_nut,
                       reverse=bolt_reverse);
                }
              }
            }
          }
        }
      }
    }
  }
}

module _pad_rect_2d(plist) {
  w = plist_get("w", plist);
  l = plist_get("l", plist);
  corner_r = plist_get("corner_r", plist);
  side = plist_get("corner_r_side", plist);
  r_factor = plist_get("r_factor", plist);
  fn = plist_get("fn", plist);
  if (!corner_r && !r_factor) {
    square(size=[w, l], center=true);
  } else {
    rounded_rect(size=[w, l],
                 r_factor=r_factor,
                 r=corner_r,
                 side=side,
                 fn=fn,
                 center=true);
  }
}

module _pads(plist, pcb_w, pcb_l, h=0.1) {
  pads_cols = plist_get("cols", plist);

  pad_w = plist_get("w", plist);
  pad_l = plist_get("l", plist);
  pads_gap = plist_get("gap", plist);
  side = plist_get("side", plist, "top");
  padding = plist_get("padding", plist, 0);
  is_cols = in_list(side, ["top", "bottom"]);
  sgn = in_list(side, ["bottom", "left"]) ? -1 : 1;

  assert(in_list(side, ["top", "left", "right", "bottom"]),
         "Pads side must be one of: 'top', 'left', 'right', 'bottom'")

    translate([is_cols ? 0 : ((sgn * ((pcb_w - pad_l) / 2)) - sgn * padding),
               is_cols ? ((sgn * ((pcb_l - pad_l) / 2)) - sgn * padding) : 0,
               0]) {
    maybe_rotate([0, 0, is_cols ? 0 : 90]) {
      columns_children(cols=pads_cols,
                       w=pad_w,
                       gap=pads_gap,
                       center=true) {

        if ($children) {
          children();
        } else {
          linear_extrude(height=h, center=false) {
            _pad_rect_2d(plist);
          }
        }
      }
    }
  }
}

module _text_item(spec, pad_w, pad_l, defaults=["size", 1, "valign", "center"]) {
  for (type = ["before", "after", "bottom", "top", "on"]) {
    let (pl = _get_text_plist(spec=spec, type=type, defaults=defaults)) {
      if (pl) {
        let (txt_size = get_text_size(txt=plist_get("text", pl), plist=pl),
             gap = plist_get("gap", pl, 0),
             w = txt_size[0],
             text_l = txt_size[1],
             on = type == "on",
             vertical = in_list(type, ["bottom", "top"]),
             sgn = in_list(type, ["before", "bottom"]) ? -1 : 1,
             x = (vertical || on) ? 0 : sgn * (w / 2 + pad_w / 2 + gap),
             y = (!vertical || on) ? 0 : sgn * (text_l / 2 + pad_l / 2 + gap)) {
          translate([x, y, 0]) {
            text_from_plist(plist=pl, default_height=0.01);
          }
        }
      }
    }
  }
}
module _interface_pads(plist, pcb_w, pcb_l, h=0.1) {
  texts = plist_get("texts", plist, []);
  pads_color = plist_get("color", plist);

  _pads(plist=plist, pcb_w=pcb_w, pcb_l=pcb_l, h=h) {
    _text_item(spec=texts[$i],
               pad_w=plist_get("w", plist),
               pad_l=plist_get("l", plist),
               defaults=plist_get("text_props", plist, ["size", 1, "valign", "top"]));
    maybe_color(pads_color) {
      linear_extrude(height=h, center=false) {
        _pad_rect_2d(plist);
      }
    }
  }
}

module _capacitors(plist, pcb_w, pcb_l) {
  props = plist_get("props", plist);
  texts = plist_get("texts", plist, []);
  size = plist_get("placeholder_size", props);

  pad_w = size[0];
  pad_l = size[1];

  merged_pl = plist_merge(plist_remove_by_keys(["props", "texts"], plist),
                          ["w", pad_w, "l", pad_l]);
  _pads(merged_pl, pcb_w=pcb_w, pcb_l=pcb_l) {
    let (txt = texts[$i]) {
      _text_item(spec=txt, pad_w=pad_w, pad_l=pad_l);
      ceramic_capactior(props, center=true);
    }
  }
}

encoder(plist=as5048A_encoder_plist,
        bolt_reverse=false,
        slot_mode=false,
        parent_thickness=3,
        counterbore_props=["teardrop_angle", 45,
                           "teardrop_both_sides", true,
                           "bore_d", 4,
                           "bore_h", 2]);
