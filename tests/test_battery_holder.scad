/**
  * Module: Battery holder solder-tab bounds assertions
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

use <../scad/placeholders/battery_holder/util.scad>

for (count = [1, 3]) {
  for (battery_len = [50, 65]) {
    size = battery_holder_solder_tab_full_len(inner_thickness=1,
                                             side_thickness=2,
                                             count=count,
                                             front_rear_thickness=2,
                                             battery_dia=18,
                                             battery_len=battery_len,
                                             terminal_type="solder_tab",
                                             contact_hole_d=1,
                                             tab_contact_slot_pad_len=3);
    assert(is_num(size[0]) && is_num(size[1]),
           "Solder-tab holder bounds must be numeric");
    assert(abs(size[0] - (20 * count + 4)) < 0.000001,
           "Holder width must include every cell and both side walls");
    assert(abs(size[1] - (battery_len + 20.99208)) < 0.000001,
           "Holder length must include both walls and solder-tab extensions");
  }
}
