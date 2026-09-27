/**
  * Module: Multi-pack case, removable sliding lid, and lidar preview.
  */
include <../steering_params.scad>
use <multi_lipo_pack_case.scad>
use <multi_lipo_pack_lid.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_case_assembly
  ─────────────────────────────────────────────────────────────────────────────

  Preview the complete power case using the case envelope as its reference.

  **Parameters:**

  `pl`: Case/lid plist with enabled rails.
  `anchor`: Shared anchor on the case envelope, including rails and mounting ears.
  `show_packs`: Display the batteries and their wiring.
  `show_lid`: Display the printed sliding lid.
  `show_lidar`: Display the lidar and its standoffs.
  `show_bolts`: Display removable rail-locking bolts and nuts.
  `slide`: Lid translation along the canonical rail axis; zero seats it.
  `lift`: Lid Z offset for an exploded preview.
  `l_clearance`: Pack-cell Y clearance, shared by case and lid.
  `w_clearance`: Pack-cell X clearance, shared by case and lid.
 */
module multi_lipo_pack_case_assembly(pl=multi_lipo_packs_case, anchor=[0, 0, 1],
                                      show_packs=true, show_lid=true,
                                      show_lidar=true, show_bolts=false,
                                      slide=0, lift=0, l_clearance=0.4, w_clearance=0.4) {
  multi_lipo_pack_case(pl, anchor=anchor, show_packs=show_packs,
                       l_clearance=l_clearance, w_clearance=w_clearance);
  multi_lipo_pack_lid_on_case(pl, anchor=anchor, slide=slide, lift=lift,
                              show_lid=show_lid, show_lidar=show_lidar, show_bolts=show_bolts,
                              l_clearance=l_clearance, w_clearance=w_clearance);
}

multi_lipo_pack_case_assembly();
