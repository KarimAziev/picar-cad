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
use <../lib/slots.scad>
use <../lib/text.scad>
use <../lib/transforms.scad>
use <bolt.scad>
use <pins.scad>
use <smd/ceramic_capacitor.scad>
use <smd/smd_chip.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  encoder_connector_spec
  ─────────────────────────────────────────────────────────────────────────────

  Resolve a connector on the PCB face opposite the sensor, extending into -Z.

  **Parameters:**
  - `plist`: Encoder specification. `show_jst_shr` and `show_pins` independently
    enable the connectors. `jst_shr` and `pins` hold optional dimensions.
  - `type`: `"jst_shr"` for the interface pads or `"pins"` for the wire pads.

  **Returns:**
  A plist containing `enabled`, `size`, `position`, `rotation`, `contacts`,
  `pitch`, and `tail_l` (header pin reach from the row center, zero for JST).
  `position` is the center of the body's inner edge at PCB Z=0;
  the body spans centered X, positive Y and negative Z before `rotation`.
  Coordinates use the PCB-centered XY reference of `encoder()`.

  The JST-SHR-06V-S envelope is [9.7, 4.83, 3.4] mm with six contacts at 1 mm.
  Its inner edge follows the interface pads' inner edge. Header contact count
  and pitch follow the wire pads; its body is centered on their row. `size`
  overrides JST dimensions; `contacts` and `pitch` derive its width otherwise.
 */
function encoder_connector_spec(plist, type) =
  assert(in_list(type, ["jst_shr", "pins"]), "Unknown encoder connector")
  let (jst = type == "jst_shr",
       enabled = plist_get(str("show_", type), plist, false),
       props = plist_get(type, plist, []),
       pcb = plist_get("size", plist),
       pads = plist_get(jst ? "interface_pads" : "wire_pads", plist, []),
       side = plist_get("side", pads, jst ? "top" : "bottom"),
       angle = side == "top" ? 0
       : side == "bottom" ? 180
       : side == "left" ? 90 : -90,
       contacts = plist_get("contacts", props,
                             jst ? 6 : plist_get("cols", pads, 3)),
       pitch = plist_get("pitch", props,
                          jst ? 1 : plist_get("w", pads, 1.74)
                          + plist_get("gap", pads, 0.8)),
       size = jst
       ? plist_get("size", props, [(contacts - 1) * pitch + 4.7, 4.83, 3.4])
       : [contacts * pitch, pitch, plist_get("h", props, 4.56)],
       edge = pcb[in_list(side, ["top", "bottom"]) ? 1 : 0] / 2,
       pad_l = plist_get("l", pads, size[1]),
       inner = edge - plist_get("padding", pads, 0)
       - (jst ? pad_l : (pad_l + size[1]) / 2),
       position = [-sin(angle) * inner, cos(angle) * inner, 0])
  assert(!enabled || (len(pads) > 0 && in_list(side, ["top", "bottom", "left", "right"])),
         "Enabled encoder connectors require a valid contact-pad row")
  assert(contacts >= 1 && floor(contacts) == contacts && pitch > 0
         && min(size) > 0, "Invalid encoder connector dimensions")
  ["enabled", enabled, "size", size, "position", position,
   "rotation", [0, 0, angle], "contacts", contacts, "pitch", pitch,
   "tail_l", jst ? 0 : plist_get("tail_l", props, 6)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  encoder_has_connectors
  ─────────────────────────────────────────────────────────────────────────────

  Return whether either rear-face connector is enabled in encoder `plist`.
 */
function encoder_has_connectors(plist) =
  plist_get("show_jst_shr", plist, false) || plist_get("show_pins", plist, false);

/**
  ─────────────────────────────────────────────────────────────────────────────
  encoder_connector_clearance
  ─────────────────────────────────────────────────────────────────────────────

  Emit rear-face connector cutouts through a PCB support wall.

  **Parameters:**
  - `plist`: Encoder specification, including `connector_clearance` (0.2 mm).
  - `depth`: Wall depth behind PCB Z=0; must be positive.
  - `edge_span`: Optional width and outward reach for full edge trims. Omit for
    local connector notches that preserve material beside the connectors.

  Uses PCB-centered XY coordinates and -Z depth. Apply the same placement and
  rotation as `encoder(..., anchor=[0, 0, 1])`. Only enabled connectors cut.
 */
module encoder_connector_clearance(plist, depth, edge_span=undef) {
  clearance = plist_get("connector_clearance", plist, 0.2);
  assert(depth > 0 && clearance >= 0, "Invalid encoder connector clearance");
  for (type = ["jst_shr", "pins"]) {
    spec = encoder_connector_spec(plist, type);
    size = plist_get("size", spec);
    w = is_undef(edge_span) ? size[0] + 2 * clearance : edge_span;
    l = is_undef(edge_span) ? size[1] + 2 * clearance : edge_span;
    if (plist_get("enabled", spec)) {
      translate(plist_get("position", spec)) {
        rotate(plist_get("rotation", spec)) {
          translate([-w / 2, -clearance, -depth - 0.01]) {
            cube([w, l, depth + 0.02]);
          }
        }
      }
    }
  }
}

module _encoder_connectors(plist) {
  for (type = ["jst_shr", "pins"]) {
    spec = encoder_connector_spec(plist, type);
    size = plist_get("size", spec);
    props = plist_get(type, plist, []);
    contacts = plist_get("contacts", spec);
    pitch = plist_get("pitch", spec);
    if (plist_get("enabled", spec)) {
      translate(plist_get("position", spec)) {
        rotate(plist_get("rotation", spec)) {
          if (type == "jst_shr") {
            color("Ivory") {
              difference() {
                translate([-size[0] / 2, 0, -size[2]]) {
                  cube(size);
                }
                translate([-size[0] / 2 + 0.6, 0.6, -size[2] + 0.5]) {
                  cube([size[0] - 1.2, size[1], size[2] - 1]);
                }
              }
            }
            color(metallic_silver_1) {
              for (i = [0 : contacts - 1]) {
                translate([(i - (contacts - 1) / 2) * pitch - 0.15,
                           0.5, -size[2] / 2 - 0.15]) {
                  cube([0.3, size[1] - 1, 0.3]);
                }
              }
            }
          } else {
            body_h = plist_get("body_h", props, 2.5);
            pin_w = plist_get("pin_w", props, 0.64);
            tail_l = plist_get("tail_l", spec);
            assert(body_h > 0 && body_h < size[2] && pin_w > 0
                   && pin_w < pitch && tail_l > size[1] / 2,
                   "Invalid encoder pin-header dimensions");
            color("black") {
              translate([-size[0] / 2, 0, -body_h]) {
                cube([size[0], size[1], body_h]);
              }
            }
            translate([0, size[1] / 2, 0]) {
              rotate([0, 0, 180]) {
                pins_centered(pitch=pitch,
                              count=contacts,
                              pin_w=pin_w,
                              pin_b=size[2] - pin_w / 2,
                              pin_a=tail_l + pin_w / 2);
              }
            }
          }
        }
      }
    }
  }
}

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
                         defaults=["size", 1,
                                   "valign", "center"]) =
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
          _encoder_connectors(plist);
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

  assert(in_list(side, ["top", "left",
                        "right", "bottom"]),
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

module _text_item(spec, pad_w, pad_l, defaults=["size", 1,
                                                "valign", "center"]) {
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
               defaults=plist_get("text_props", plist, ["size", 1,
                                                        "valign", "top"]));
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
                          ["w", pad_w,
                           "l", pad_l]);
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
