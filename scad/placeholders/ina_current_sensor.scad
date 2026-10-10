/**
  * Module: INA current sensor.
  *
  * PCB placeholder with optional components, silkscreen and mounting cutters.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/placement.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/slots.scad>
use <../lib/text.scad>
use <../lib/transforms.scad>
use <pad_hole.scad>
use <pin_header.scad>
use <screw_terminal.scad>
use <smd/smd_chip.scad>
use <standoff.scad>

function _ina_get(key, pl, fallback) =
  with_default(plist_get(key, pl), fallback);

function _ina_defined(pl) =
  [for (key = plist_keys(pl))
    if (!is_undef(plist_get(key, pl))) each [key, plist_get(key, pl)]];

function _ina_pin_positions(size, pin) =
  let (cols = _ina_get("cols", pin, 0),
       pitch = _ina_get("pitch", pin, 2.54),
       y = -size[1] / 2 + _ina_get("y_offset", pin, 0))
  cols > 0
  ? [for (i = [0 : cols - 1]) [(i - (cols - 1) / 2) * pitch, y, 0]]
  : [];

function _ina_power_positions(size, pad) =
  let (d = _ina_get("d", pad, 0),
       l = _ina_get("len", pad, 0),
       x = _ina_get("x_offset", pad, 0),
       y = size[1] / 2 - (l + d) / 2 - _ina_get("y_offset", pad, 0))
  d > 0 ? [[-x, y, 0], [x, y, 0]] : [];

function _ina_terminal(pl) =
  plist_merge(["thickness", 7.6,
               "base_h", 6.8,
               "top_l", 5.5,
               "top_h", 3.2,
               "contacts_n", 2,
               "contact_w", 3.5,
               "contact_h", 4.47,
               "pitch", 4.5,
               "colr", medium_blue_2,
               "pin_h", 0], _ina_defined(pl));

module _ina_texts(texts, style) {
  for (spec = with_default(texts, [])) {
    text_from_plist(plist=plist_merge(_ina_defined(style),
                                     _ina_defined(with_default(spec, []))),
                    default_font="Liberation Sans:style=Bold",
                    default_color="white",
                    default_size=1,
                    default_height=0.01,
                    default_halign="right",
                    default_valign="top");
  }
}

module _ina_chip(chip, size) {
  chip_size = _ina_get("size", chip, [0, 0, 0]);
  lead_l = _ina_get("jlead_x_len", chip, 0);
  if (len(chip_size) == 3 && min(chip_size) > 0) {
    translate([0,
               -size[1] / 2 + chip_size[1] / 2
               + _ina_get("y_offset", chip, 0),
               size[2]]) {
      rotate([0, 0, 90]) {
        smd_chip(length=chip_size[1],
                 w=chip_size[0],
                 h=chip_size[2],
                 total_w=chip_size[0] + 2 * lead_l,
                 j_lead_n=lead_l > 0 ? _ina_get("jlead_count", chip, 0) : 0,
                 lower_lead_fraction=_ina_get("jlead_lower_lead_fraction",
                                              chip, 0.8),
                 j_lead_thickness=_ina_get("jlead_thickness", chip, 0.2));
      }
    }
  }
}

module _ina_pins(pin, size, style, slot_mode=false) {
  positions = _ina_pin_positions(size, pin);
  hole_d = _ina_get("hole_d", pin, 0);
  pads = _ina_get("pad_spec", pin, []);
  texts = _ina_get("texts", pin, []);
  text_style = plist_merge(style, _ina_get("text_style", pin, []));

  for (i = [0 : 1 : len(positions) - 1]) {
    translate(positions[i]) {
      if (slot_mode) {
        if (hole_d > 0) {
          translate([0, 0, -0.1]) {
            cylinder(d=hole_d, h=size[2] + 0.2, $fn=30);
          }
        }
      } else {
        if (len(pads) > 0) {
          pad_hole(bolt_d=hole_d, thickness=size[2], specs=pads);
        }
        if (i < len(texts)) {
          translate([0, 0, size[2]]) {
            _ina_texts([texts[i]], text_style);
          }
        }
      }
    }
  }
}

module _ina_power_pads(pad, size, style, slot_mode=false) {
  positions = _ina_power_positions(size, pad);
  hole_d = _ina_get("hole_d", pad, 0);
  d = _ina_get("d", pad, 0);
  l = _ina_get("len", pad, 0);
  texts = _ina_get("texts", pad, []);
  text_style = plist_merge(style, _ina_get("text_style", pad, []));
  border = _ina_get("border", pad, []);
  border_w = _ina_get("w", border, 0);
  padding = _ina_get("padding", border, [0, 0]);

  for (i = [0 : 1 : len(positions) - 1]) {
    translate(positions[i]) {
      if (slot_mode) {
        if (hole_d > 0) {
          translate([0, 0, -0.15]) {
            cylinder(d=hole_d, h=size[2] + 0.3, $fn=30);
          }
        }
      } else {
        color(_ina_get("color", pad, "#FDCC0D")) {
          translate([0, 0, -0.1]) {
            linear_extrude(height=size[2] + 0.2, convexity=2) {
              capsule(y=l, d=d);
            }
          }
        }
        if (i < len(texts)) {
          translate([0, 0, size[2]]) {
            _ina_texts([texts[i]], text_style);
          }
        }
      }
    }
  }

  if (!slot_mode && len(positions) > 0 && border_w > 0) {
    w = _ina_get("x_offset", pad, 0) * 2 + d + padding[0];
    h = _ina_get("y_offset", pad, 0) + l + d + border_w + padding[1];
    color(_ina_get("color", border, "white")) {
      translate([0, size[1] / 2 - h / 2, size[2]]) {
        linear_extrude(height=0.05) {
          difference() {
            square([w, h], center=true);
            translate([0, border_w / 2]) {
              square([w - border_w, h], center=true);
            }
          }
        }
      }
    }
  }
}

module _ina_i2c(i2c, size, style) {
  specs = _ina_get("addr_specs", i2c, []);
  texts = _ina_get("texts", i2c, []);
  text_style = plist_merge(style, _ina_get("text_style", i2c, []));
  if (len(specs) > 0) {
    translate([-size[0] / 2 + _ina_get("x_offset", i2c, 0),
               -size[1] / 2 + _ina_get("y_offset", i2c, 0),
               size[2]]) {
      color(_ina_get("color", i2c, metallic_yellow_1)) {
        rounded_rect_slots(specs=specs, thickness=0.1);
      }
      rounded_rect_slots(specs=specs, thickness=0.1) {
        if ($i < len(texts)) {
          _ina_texts([texts[$i]], text_style);
        }
      }
    }
  }
}

/**
   ─────────────────────────────────────────────────────────────────────────────
   ina_current_sensor_props
   ─────────────────────────────────────────────────────────────────────────────

   Resolve the board, mounting row, pin clearance and populated height.

   **Parameters:**
   - `plist`: Sensor specification accepted by `ina_current_sensor`.

   **Returns:**
   `size`, `bolt_spacing`, `bolt_d`, `mounting_y`, `bottom_h`, `standoff_h`,
   `standoff_thread_h` and `populated_h`. `header_pos` and `terminal_pos` are
   connector centers in the native board frame; `header_size` and `terminal_size`
   are their XY footprints (zero when omitted). Heights are measured from the PCB underside;
   standoff height is measured from its mounting surface.
 */
function ina_current_sensor_props(plist=ina_plist) =
  let (size = plist_get("size", plist),
       bolt_spacing = plist_get("bolt_spacing", plist),
       bolt_d = plist_get("bolt_d", plist))
  assert(is_list(size) && len(size) == 3
         && len([for (n = size) if (is_num(n) && n > 0) n]) == 3,
         "ina_current_sensor: size must contain three positive dimensions")
  assert(is_list(bolt_spacing) && len(bolt_spacing) == 2
         && len([for (n = bolt_spacing) if (is_num(n) && n >= 0) n]) == 2
         && max(bolt_spacing) > 0,
         "ina_current_sensor: bolt_spacing must contain two nonnegative spacings")
  assert(is_num(bolt_d) && bolt_d > 0,
         "ina_current_sensor: bolt_d must be positive")
  let (pin = _ina_get("pin", plist, []),
       header = _ina_get("header", pin, []),
       terminal = _ina_get("screw_terminal", plist, []),
       terminal_pl = _ina_terminal(terminal),
       header_enabled = len(header) > 0 && _ina_get("cols", pin, 0) > 0,
       header_size = header_enabled
           ? pin_header_size(header_width=_ina_get("header_width", header, 2.45),
                              header_y_width=_ina_get("pitch", pin, 2.54),
                              cols=_ina_get("cols", pin, 0), rows=1)
           : [0, 0],
       chip = _ina_get("size", _ina_get("chip", plist, []), []),
       chip_h = len(chip) == 3 ? chip[2] : 0,
       pin_h = _ina_get("cols", pin, 0) > 0 && len(header) > 0
           ? _ina_get("pin_height", header, 11.45)
             - _ina_get("z_offset", header, 0)
           : 0,
       terminal_h = len(terminal) > 0
           ? _ina_get("base_h", terminal, 6.8) + _ina_get("top_h", terminal, 3.2)
           : 0,
       bottom_h = max(0,
                       _ina_get("cols", pin, 0) > 0
                       ? _ina_get("z_offset", header, 0) : 0,
                       _ina_get("pin_h", terminal, 0) - size[2]),
       standoff = standoff_h_spec(min_h=bottom_h, d=bolt_d))
  ["size", size,
   "bolt_spacing", bolt_spacing,
   "bolt_d", bolt_d,
   "mounting_y", bolt_spacing[1] == 0
     ? size[1] / 2 - bolt_d / 2 - _ina_get("mount_hole_dist", plist, 0)
     : 0,
   "bottom_h", bottom_h,
   "standoff_h", standoff[0],
   "standoff_thread_h", with_default(standoff[1], 0),
   "header_pos", [0, -size[1] / 2 + _ina_get("y_offset", pin, 0), 0],
   "header_size", [header_size[1], header_size[0]],
   "terminal_size", len(terminal) > 0
     ? [screw_terminal_width_from_plist(terminal_pl),
        plist_get("thickness", terminal_pl)]
     : [0, 0],
   "terminal_pos", [0, size[1] / 2 - plist_get("thickness", terminal_pl) / 2
                       - _ina_get("y_offset", terminal, 0), size[2]],
   "populated_h", max(pin_h, size[2] + max(chip_h, terminal_h))];

/**
   ─────────────────────────────────────────────────────────────────────────────
   ina_current_sensor
   ─────────────────────────────────────────────────────────────────────────────

   Render a current-sensor PCB or its mounting cutters.

   **Parameters:**
   - `plist`: Board specification; `size`, `bolt_spacing` and `bolt_d` are
     required. `size` is a positive XYZ vector; `bolt_spacing` is a nonnegative
     XY center spacing, with at least one nonzero axis; `bolt_d` is positive.
     Optional keys are described below. The default is `ina_plist`.
   - `show_terminal`: Render the configured screw terminal.
   - `show_pins`: Render the configured pin header.
   - `show_standoffs`: Render mounting standoffs, or cut their parent plate.
   - `thread_at_top`: Point the standoff's male thread toward the PCB.
   - `anchor_z_mode`: Reference Z to the PCB (`"thickness"`), the lowest
     configured pin (`"pin"`), or the standoff base (`"standoff"`).
   - `anchor`: Reference-box anchor; `[0, 0, 1]` centers the PCB on X/Y.
   - `orientation`: Axis order accepted by `with_orientation`.
   - `sink`: Use countersunk mounting recesses.
   - `cbore_d`: Mounting recess diameter; defaults to zero.
   - `cbore_h`: Mounting recess depth; defaults to zero.
   - `parent_thickness`: Parent plate thickness for standoff mounting cutters
     and bolts; omitted in solid mode to hide the parent bolts.
   - `slot_mode`: Emit mounting cutters. With standoffs, cutters occupy the
     parent plate below the standoff base. Without standoffs, cutters start
     at the PCB underside and use `parent_thickness`, defaulting to PCB thickness.

   **Behavior:**

   The reference footprint is the PCB, centered on X/Y before anchoring. Its
   underside is Z=0 in `"thickness"` mode. Hardware does not change the XY
   reference box. Pin clearance includes configured hardware even when hidden.

   Missing, `undef`, or empty feature groups omit their geometry. Missing or
   `undef` scalar properties use local defaults. `color` defaults to blue;
   `corner_rad` and `mount_hole_dist` default to zero. For a two-hole X row,
   `mount_hole_dist` is the gap from the +Y board edge to the hole edge.
   `pad_hole_spec` contains the diameter/color bands accepted by `pad_hole`.

   Feature groups:
   - `chip`: `size`, `y_offset` (gap from the -Y edge to the chip body), and
     `jlead_x_len`, `jlead_count`, `jlead_thickness`,
     `jlead_lower_lead_fraction`. Missing size omits the chip; missing lead
     count or lead length omits leads.
   - `pin`: `cols` (default zero), `pitch` (default 2.54), `y_offset` (center
     distance from the -Y edge), `hole_d`, `pad_spec`, `texts`, `text_style`,
     and `header`. Header keys match `pin_header`: `header_width`,
     `header_height`, `pin_height`, `p`, and `z_offset`; count and pitch come
     from `pin`. An empty header omits hardware without affecting PCB holes.
   - `power_pad`: `d`, `len`, `hole_d`, `x_offset` (half center spacing),
     `y_offset` (gap from the +Y edge), `color`, `texts`, `text_style`, and
     `border` (`w`, `padding` XY, `color`). Missing diameter omits the pads.
   - `i2c`: `addr_specs` accepted by `rounded_rect_slots`, `x_offset` and
     `y_offset` measured from the -X/-Y board corner, `color`, `texts`, and
     `text_style`. Missing address specs omit the pads.
   - `screw_terminal`: Keys accepted by `screw_terminal_from_plist`, plus
     `y_offset` (gap between the terminal body and the +Y board edge).

   `text_style` supplies shared text properties. `top_texts`, `bottom_texts`,
   and each feature's `texts` are lists of `text_from_plist` plists. Feature
   styles override the board style; individual texts override both. Pin and
   power-pad texts correspond to holes from left to right; I2C texts follow
   `addr_specs`. Translations are relative to their feature on the PCB face.
   Bottom text uses a frame rotated 180 degrees about Y at the PCB underside.

   **Examples:**
   ```scad
   ina_current_sensor(plist=["size", [23, 23, 1.6],
                             "bolt_spacing", [18, 0],
                             "bolt_d", 2.6]);
   ```
 */
module ina_current_sensor(plist=ina_plist,
                          show_terminal=false,
                          show_pins=false,
                          show_standoffs=false,
                          thread_at_top=true,
                          anchor_z_mode="thickness",
                          anchor=[0, 0, 1],
                          orientation="wlh",
                          sink=false,
                          cbore_d,
                          cbore_h,
                          parent_thickness,
                          slot_mode=false) {
  props = ina_current_sensor_props(plist);
  size = plist_get("size", props);
  bolt_spacing = plist_get("bolt_spacing", props);
  bolt_d = plist_get("bolt_d", props);
  assert(member(anchor_z_mode, ["thickness", "pin", "standoff"]),
         "ina_current_sensor: anchor_z_mode must be thickness, pin or standoff");

  pin = _ina_get("pin", plist, []);
  header = _ina_get("header", pin, []);
  power_pad = _ina_get("power_pad", plist, []);
  terminal = _ina_get("screw_terminal", plist, []);
  terminal_pl = _ina_terminal(terminal);
  style = _ina_get("text_style", plist, []);
  mounting_pads = _ina_get("pad_hole_spec", plist, []);
  mounting_y = plist_get("mounting_y", props);
  bottom_h = plist_get("bottom_h", props);
  standoff_h = plist_get("standoff_h", props);
  standoff_thread_h = plist_get("standoff_thread_h", props);
  initial_z = anchor_z_mode == "pin"
    ? bottom_h
    : anchor_z_mode == "standoff" ? standoff_h : 0;
  anchor_h = anchor_z_mode == "pin"
    ? size[2] + bottom_h
    : anchor_z_mode == "standoff" ? standoff_h : size[2];
  standoff_z = thread_at_top ? -standoff_h : size[2] - standoff_thread_h;

  with_orientation(to=orientation,
                   anchor=anchor,
                   size=[size[0], size[1], anchor_h]) {
    translate([0, 0, initial_z]) {
      if (!slot_mode) {
        difference() {
          union() {
            color(_ina_get("color", plist, medium_blue_2)) {
              linear_extrude(height=size[2], convexity=3) {
                rounded_rect(size=[size[0], size[1]],
                             r=_ina_get("corner_rad", plist, 0),
                             center=true,
                             fn=20);
              }
            }
            translate([0, mounting_y, 0]) {
              if (len(mounting_pads) > 0) {
                four_corner_children(size=bolt_spacing, center=true) {
                  pad_hole(bolt_d=bolt_d,
                           thickness=size[2],
                           specs=mounting_pads);
                }
              }
            }
            _ina_chip(_ina_get("chip", plist, []), size);
            _ina_pins(pin, size, style);
            _ina_power_pads(power_pad, size, style);
            _ina_i2c(_ina_get("i2c", plist, []), size, style);
            translate([0, 0, size[2]]) {
              _ina_texts(_ina_get("top_texts", plist, []), style);
            }
            rotate([0, 180, 0]) {
              _ina_texts(_ina_get("bottom_texts", plist, []), style);
            }
          }
          translate([0, mounting_y, -0.15]) {
            four_corner_children(size=bolt_spacing, center=true) {
              cylinder(d=bolt_d, h=size[2] + 0.3, $fn=60);
            }
          }
          _ina_pins(pin, size, style, slot_mode=true);
          _ina_power_pads(power_pad, size, style, slot_mode=true);
        }

        if (show_terminal && len(terminal) > 0) {
          translate(plist_get("terminal_pos", props)) {
            screw_terminal_from_plist(terminal_pl, center=true);
          }
        }
        if (show_pins && len(header) > 0 && _ina_get("cols", pin, 0) > 0) {
          translate(plist_get("header_pos", props)) {
            rotate([0, 0, 90]) {
              pin_header(cols=plist_get("cols", pin),
                         rows=1,
                         header_width=_ina_get("header_width", header, 2.54),
                         header_height=_ina_get("header_height", header, 2.54),
                         header_y_width=_ina_get("pitch", pin, 2.54),
                         pin_height=_ina_get("pin_height", header, 11.45),
                         z_offset=_ina_get("z_offset", header, 0),
                         p=_ina_get("p", header, 0.4),
                         center=true);
            }
          }
        }
      }

      if (show_standoffs) {
        translate([0, mounting_y,
                   standoff_z - (slot_mode
                                 ? with_default(parent_thickness, 0) : 0)]) {
          four_corner_standoffs(bolt_d=bolt_d,
                                bolt_spacing=bolt_spacing,
                                h=bottom_h,
                                parent_thickness=slot_mode
                                  ? with_default(parent_thickness, 0)
                                  : parent_thickness,
                                cbore_d=with_default(cbore_d, 0),
                                cbore_h=with_default(cbore_h, 0),
                                thread_at_top=thread_at_top,
                                slot_mode=slot_mode,
                                sink=sink);
        }
      } else if (slot_mode) {
        translate([0, mounting_y, 0]) {
          four_corner_children(size=bolt_spacing, center=true) {
            counterbore(d=bolt_d,
                        h=with_default(parent_thickness, size[2]),
                        bore_d=with_default(cbore_d, 0),
                        bore_h=with_default(cbore_h, 0),
                        sink=sink);
          }
        }
      }
    }
  }
}

ina_current_sensor(show_standoffs=true,
                   anchor_z_mode="standoff",
                   parent_thickness=4,
                   cbore_h=2,
                   cbore_d=5);
