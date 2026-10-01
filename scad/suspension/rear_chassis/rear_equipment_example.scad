/**
  * Module: Rear equipment inspection with the raised battery case hidden.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../rear_suspension/computed_params.scad>
use <rear_chassis_frame.scad>

// Use rear_equipment_specs here to inspect your configured production loadout.
layout = rear_suspension_layout(equipment=rear_equipment_mixed);
rear_chassis(layout=layout, show_power_case=false, show_lipo_packs=false,
             show_lidar=false, show_lidar_lid=false,
             show_equipment_zones=true);
