/**
  * Module: Standalone power lid with geometrically placed equipment.
  *
  * Configure components and placement in ../steering_params.scad.
  * The exterior roof face is Z=0; the fuse holder is concealed below it.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <standalone_parameters.scad>

use <../lib/plist.scad>
use <multi_lipo_pack_lid.scad>

props = multi_lipo_pack_lid_props(standalone_lipo_case);
translate([0, 0, -plist_get("canonical_size", props)[2]]) {
  multi_lipo_pack_lid(standalone_lipo_case,
                      show_adapter=true,
                      show_equipment=true);
}
