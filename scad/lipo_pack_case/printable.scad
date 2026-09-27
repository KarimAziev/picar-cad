/**
  * Module: Multi-pack case and matching lid, both oriented for printing.
  */
include <../steering_params.scad>
use <../lib/plist.scad>
use <multi_lipo_pack_case.scad>
use <multi_lipo_pack_lid.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_printable
  ─────────────────────────────────────────────────────────────────────────────

  Place the case floor and lid roof on Z=0, with a gap between the parts.

  **Parameters:**

  `pl`: Case/lid plist, including any desired mounting-ear pattern.
  `spacing`: Edge-to-edge X gap between case and lid, in millimeters.
 */
module multi_lipo_pack_printable(pl=multi_lipo_packs_case, spacing=8) {
  assert(spacing >= 0);
  canonical = plist_merge(pl, ["orientation", "wlh"]);
  case_size = plist_get("canonical_size", multi_lipo_pack_props(canonical));
  lid_size = plist_get("canonical_size", multi_lipo_pack_lid_props(canonical));
  multi_lipo_pack_case(canonical, anchor=[0, 0, 1], show_standoffs=false);
  translate([(case_size[0] + lid_size[0]) / 2 + spacing, 0, 0]) {
    multi_lipo_pack_lid_printable(canonical);
  }
}

multi_lipo_pack_printable();
