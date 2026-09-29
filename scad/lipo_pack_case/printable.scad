/**
  * Module: Multi-pack case and matching lid, and adapter, all oriented for printing.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../steering_params.scad>

use <../lib/plist.scad>
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
  multi_lipo_pack_case(canonical, anchor=[0, 0, 1], show_standoffs=false);
  // translate([(case_size[0] + lid_size[0]) / 2 + spacing, 0, 0]) {
  //   multi_lipo_pack_lid_printable(canonical);
  // }
  // if (plist_get("enabled", adapter, false)) {
  //   translate([case_size[0]/2 + lid_size[0] + plist_get("size", adapter)[0]/2 + 2*spacing,
  //              0,
  //              0]) {
  //     multi_lipo_pack_adapter_printable(adapter);
  //   }
  // }
}

multi_lipo_pack_printable();
