/**
  * Module: A joint for rear chassis and rear suspension
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../rc_params.scad>
include <../rear_chassis/computed_params.scad>
include <../rear_chassis/rear_chassis_params.scad>

use <../../components/plate_joint/plate_joint.scad>
use <../../lib/plist.scad>

module rear_suspension_chassis_joint(mode,
                                     layout=rear_chassis_layout(),
                                     color,
                                     slot_mode=false,
                                     show_bolts=false,
                                     anchor,
                                     show_sizes) {

  suspension_w = plist_get("suspension_w", layout);
  transition_y_start = plist_get("transition_y_start", layout);
  transition_y_end = plist_get("transition_y_end", layout);
  joint_l = transition_y_start - transition_y_end;

  // The chassis joins at local Y=-joint_l; the suspension mount joins at Y=0.
  // Keep the male free-tip clearance away from its chassis attachment.
  root_side = mode == "female" ? 1 : -1;

  plate_joint(plate_h=chassis_thickness,
              bolt_d=chassis_bolt_d,
              bolt_n_center=2,
              pin_use_pad=false,
              pin_d=front_chassis_joint_pin_d,
              pin_l=rear_suspension_joint_pin_l
                + 2 * front_chassis_joint_pin_end_clearance,
              l=joint_l,
              pin_spacing="60%",
              show_bolts=show_bolts,
              show_sizes=show_sizes,
              sizes_offset=[30, 0, 0],
              mode=mode,
              root_side=root_side,
              slot_mode=slot_mode,
              include_pin_holes=true,
              anchor=anchor,
              w=suspension_w,
              color=color);
}
