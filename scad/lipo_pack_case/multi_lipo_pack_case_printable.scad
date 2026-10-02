include <../rc_params.scad>

use <multi_lipo_pack_case.scad>

module multi_lipo_pack_case_printable(pl=multi_lipo_packs_case) {
  multi_lipo_pack_case(pl,
                       target_h=0,
                       show_packs=false,
                       slot_mode=false,
                       show_standoffs=false,
                       show_rail_bolts=false);
}

multi_lipo_pack_case_printable();