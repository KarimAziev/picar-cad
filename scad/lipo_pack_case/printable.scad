/**
  * Module: Multi-pack case and matching lid, and adapter, all oriented for printing.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../steering_params.scad>

use <../lib/plist.scad>
use <../lib/functions.scad>
use <../components/button_bracket/button_bracket.scad>
use <../wago/wago_bracket.scad>
use <lid_equipment.scad>
use <lid_fuse.scad>
use <../wago/wago_mounts.scad>
use <multi_lipo_pack_adapter.scad>
use <multi_lipo_pack_case.scad>
use <multi_lipo_pack_lid.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_printable
  ─────────────────────────────────────────────────────────────────────────────

  Place the case, lid, and optional adapter on Z=0 with gaps between them.

  **Parameters:**

  `pl`: Case/lid plist, including any desired mounting-ear pattern.
  `spacing`: Edge-to-edge X gap between case and lid, in millimeters.
 */
module multi_lipo_pack_printable(pl=multi_lipo_packs_case, spacing=8) {
  assert(spacing >= 0);
  canonical = plist_merge(pl, ["orientation", "wlh"]);
  case_size = plist_get("canonical_size", multi_lipo_pack_props(canonical));
  lid_props = multi_lipo_pack_lid_props(canonical);
  lid_size = plist_get("canonical_size", lid_props);
  adapter = plist_get("adapter_props", lid_props);
  multi_lipo_pack_case(canonical,
                       anchor=[0, 0, 1],
                       show_standoffs=false,
                       show_packs=false,
                       show_rail_bolts=false);
  translate([(case_size[0] + lid_size[0]) / 2 + spacing, 0, 0]) {
    multi_lipo_pack_lid_printable(canonical);
  }
  if (plist_get("enabled", adapter, false)) {
    translate([case_size[0]/2 + lid_size[0] + plist_get("size", adapter)[0]/2 + 2*spacing,
               0,
               0]) {
      multi_lipo_pack_adapter_printable(adapter);
    }
  }
  if (plist_get("standoff_h", adapter, 0) > 0) {
    translate([case_size[0] / 2 + lid_size[0]
               + plist_get("size", adapter)[0] / 2 + 2 * spacing,
               plist_get("size", adapter)[1] + spacing, 0]) {
      multi_lipo_pack_adapter_spacers(adapter);
    }
  }
  lid_spec = plist_get("lid", pl, []);
  fuse = lid_fuse_props(plist_get("fuse", lid_spec), lid_props);
  wagos = multi_lipo_pack_lid_wago_mounts(pl, lid_props);
  equipment = lid_equipment_layout(plist_get("equipment", lid_spec, []), lid_props,
    concat(_lid_fuse_tie_bounds(fuse),
           [for (m = wagos) _wago_bounds(concat(plist_get("pos", m), [0]), wago_mount_size(m))]));
  printed = [for (m = equipment) if (plist_get("kind", m) != "voltmeter") m];
  widths = [for (m = printed) plist_get("size", plist_get("props", m))[0]];
  for (i = [0:1:len(printed) - 1]) {
    m = printed[i];
    size = plist_get("size", plist_get("props", m));
    preceding = i == 0 ? 0 : sum([for (j = [0:i - 1]) widths[j] + spacing]);
    translate([preceding + size[0] / 2 - case_size[0] / 2,
               -max(case_size[1], lid_size[1]) / 2 - spacing - size[1] / 2, 0]) {
      if (plist_get("kind", m) == "button") {
        button_bracket(plist_get("component", m), show_button=false);
      } else {
        wago_bracket(plist_get("component", m, []), anchor=[0, 0, 1]);
      }
    }
  }

}

multi_lipo_pack_printable();
