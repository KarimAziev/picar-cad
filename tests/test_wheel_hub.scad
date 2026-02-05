include <../scad/parameters.scad>

use <../scad/wheels/wheel_hub.scad>

translate([-wheel_hub_outer_d / 2 - 2, 0, 0]) {
  wheel_hub_assembly(lower_spacer_h=wheel_hub_wheel_spacer_h,
                     bolt_cbore_d=wheel_hub_wheel_bolt_bore_d,
                     bolt_cbore_h=wheel_hub_wheel_bolt_bore_h,
                     show_lower_hub=true,
                     show_bearing=true,
                     show_upper_hub=true,
                     show_bolts=true,
                     show_nuts=true,
                     lock_nut=true);
}

translate([wheel_hub_outer_d / 2 + 2, 0, 0]) {
  wheel_hub_assembly(show_lower_hub=true,
                     show_bearing=true,
                     show_upper_hub=true,
                     show_bolts=true,
                     show_nuts=true,
                     lock_nut=false);
}
