include <../colors.scad>
include <../parameters.scad>

use <../lib/debug.scad>
use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/text.scad>
use <../lib/transforms.scad>
use <../placeholders/pin_header.scad>
use <../placeholders/screw_terminal.scad>
use <../placeholders/smd/can_capacitor.scad>
use <../placeholders/smd/ceramic_capacitor.scad>
use <../placeholders/smd/power_inductor.scad>
use <../placeholders/smd/schottky_diode.scad>
use <../placeholders/smd/smd_chip.scad>
use <../placeholders/smd/smd_resistor.scad>

module smd_placeholder_renderer(plist,
                                cell_size,
                                align_x = -1,
                                align_y = -1,
                                thickness,
                                spin,
                                show_screw_terminal=true,
                                show_smd_resistor=true,
                                show_smd_chip=true,
                                show_shielded_power_inductor=true,
                                show_unshielded_power_inductor=true,
                                show_can_capacitor=true,
                                show_pin_header=true,
                                show_schottky_diode=true,
                                show_ceramic_capactior=true) {
  placeholder = plist_get("type", plist);
  cell_size = with_default(cell_size, []);
  placeholder_size = plist_get("placeholder_size", plist);
  spin = with_default(spin, 0);

  translate([0, 0, with_default(thickness, 0)]) {
    if (show_screw_terminal && placeholder == "screw_terminal") {
      let (base_x = screw_terminal_width_from_plist(plist),
           base_y = plist_get("thickness", plist, 7.6),
           placeholder_size=[base_x, base_y]) {
        align_children_with_spin(parent_size=cell_size,
                                 size=placeholder_size,
                                 align_x=align_x,
                                 align_y=align_y,
                                 spin=spin) {
          screw_terminal_from_plist(plist, center=false);
        }
      }
    } else if (show_can_capacitor && placeholder == "can_capacitor") {
      let (d = plist_get("d", plist)) {
        align_children(parent_size=cell_size,
                       size=[d, d],
                       align_x=align_x,
                       align_y=align_y) {
          can_capacitor_from_plist(plist, center=false);
        }
      }
    } else if (is_list(placeholder_size) && is_num(placeholder_size[0])) {
      align_children_with_spin(parent_size=cell_size,
                               size=placeholder_size,
                               align_x=align_x,
                               align_y=align_y,
                               spin=spin) {
        if (show_smd_resistor && placeholder == "smd_resistor") {
          smd_resistor_from_plist(plist, center=false);
        } else if (show_schottky_diode && placeholder == "schottky_diode") {
          schottky_diode(plist, center=false); {
          }
        } else if (show_ceramic_capactior
                   && placeholder == "ceramic_capactior") {
          ceramic_capactior(plist, center=false); {
          }
        } else if (show_smd_chip && placeholder == "smd_chip") {
          smd_chip_from_plist(plist, center=false);
        } else if (show_unshielded_power_inductor
                   && placeholder == "unshielded_power_inductor") {
          unshielded_power_inductor_from_plist(plist, center=false);
        } else if (show_shielded_power_inductor
                   && placeholder == "shielded_power_inductor") {
          shielded_power_inductor_from_plist(plist, center=false);
        }
      }
    } else if (placeholder == "text") {
      let (txt = plist_get("text", plist),
           tm = textmetrics(text=is_string(txt) ? txt : str(txt),
                            size=plist_get("size", plist),
                            font=plist_get("font", plist),
                            spacing=plist_get("spacing", plist),
                            halign=plist_get("halign", plist, "left"),
                            valign=plist_get("valign", plist, "baseline")),
           size = tm.size) {
        align_children_with_spin(parent_size=cell_size,
                                 size=size,
                                 align_x=align_x,
                                 align_y=align_y,
                                 spin=spin) {

          text_from_plist(txt=txt,
                          plist=plist,
                          default_valign="baseline",
                          default_halign="baselleft");
        }
      }
    } else if (show_pin_header && placeholder == "pin_header") {
      let (size = pin_header_size_from_plist(plist)) {
        align_children_with_spin(parent_size=cell_size,
                                 size=size,
                                 align_x=align_x,
                                 align_y=align_y,
                                 spin=spin) {
          pin_header_from_plist(plist, center=false);
        }
      }
    }
  }
}

module smd_placeholder_slot_renderer(plist,
                                     cell_size,
                                     align_x = -1,
                                     align_y = -1,
                                     thickness,
                                     spin,
                                     show_screw_terminal=true) {
  placeholder = plist_get("type", plist);
  cell_size = with_default(cell_size, []);
  placeholder_size = plist_get("placeholder_size", plist);
  spin = with_default(spin, 0);

  translate([0, 0, 0]) {
    if (show_screw_terminal && placeholder == "screw_terminal") {
      let (base_x = screw_terminal_width_from_plist(plist),
           base_y = plist_get("thickness", plist, 7.6),
           placeholder_size=[base_x, base_y]) {
        align_children_with_spin(parent_size=cell_size,
                                 size=placeholder_size,
                                 align_x=align_x,
                                 align_y=align_y,
                                 spin=spin) {
          screw_terminal_from_plist(plist,
                                    center=false,
                                    slot_mode=true,
                                    slot_thickness=thickness);
        }
      }
    }
  }
}

smd_placeholder_renderer(["type","smd_chip",
                          "placeholder_size", [10, 17],
                          "corner_rad", 0.0,
                          "spin", 0,
                          "chip_size", [8, 17, 1.65],
                          "j_lead",
                          [["count", 11,
                            "thickness", 0.4,
                            "sides", ["left", "right"]]]],
                         cell_size=[20, 30],
                         align_x=0,
                         align_y=0);
