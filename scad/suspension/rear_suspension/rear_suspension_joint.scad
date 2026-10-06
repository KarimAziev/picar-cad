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
use <../chassis_joint_bolts.scad>
use <../front_chassis/front_chassis_joint.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_chassis_joint_params
  ─────────────────────────────────────────────────────────────────────────────
  Resolve the rear suspension joint's fixed mating dimensions and socket fit.
  **Parameters:**
  - `layout`: Shared rear chassis layout.
  **Returns:** A `plate_joint_parameters()` plist. Rail width, bolt centers,
  and pin centers use the nominal layout allowance independently of socket fit.
 */
function rear_suspension_chassis_joint_params(layout=rear_chassis_layout()) =
  let (ys = rear_suspension_joint_y_bounds(layout),
       w = rear_suspension_joint_width(layout),
       nominal = plate_joint_parameters(
         plate_h=chassis_thickness,
         bolt_d=chassis_bolt_d,
         bolt_bore_d=chassis_counterbore_bore_d,
         bolt_bore_h=chassis_counterbore_h,
         w=w,
         rail_w=front_chassis_body_joint_rail_w(w),
         l=ys[1] - ys[0],
         bolt_n_center=5,
         clearance=suspension_chassis_joint_layout_clearance,
         axial_clearance=front_chassis_joint_axial_clearance,
         pin_use_pad=false,
         pin_d=front_chassis_joint_pin_d,
         pin_l=rear_suspension_joint_pin_l
               + 2 * front_chassis_joint_pin_end_clearance,
         pin_spacing=rear_suspension_joint_pin_spacing,
         include_pin_holes=true))
  plist_merge(nominal, ["clearance", front_chassis_joint_clearance]);

module rear_suspension_chassis_joint(mode,
                                     layout=rear_chassis_layout(),
                                     color,
                                     slot_mode=false,
                                     show_bolts=false,
                                     anchor,
                                     show_sizes) {

  p = rear_suspension_chassis_joint_params(layout);

  // The chassis joins at local Y=-joint_l; the suspension mount joins at Y=0.
  // Keep the male free-tip clearance away from its chassis attachment.
  root_side = mode == "female" ? 1 : -1;

  module _joint() {
    plate_joint(plate_h=chassis_thickness,
                bolt_d=chassis_bolt_d,
                bolt_n_center=5,
                pin_use_pad=false,
                pin_d=front_chassis_joint_pin_d,
                rail_w=plist_get("rail_w", p),
                bolt_spacing_center=plist_get("bolt_spacing_center", p),
                clearance=front_chassis_joint_clearance,
                axial_clearance=front_chassis_joint_axial_clearance,
                pin_l=rear_suspension_joint_pin_l
                      + 2 * front_chassis_joint_pin_end_clearance,
                l=plist_get("l", p),
                pin_spacing=plist_get("pin_spacing", p),
                show_sizes=show_sizes,
                sizes_offset=[30, 0, 0],
                mode=mode,
                root_side=root_side,
                slot_mode=slot_mode,
                include_pin_holes=true,
                anchor=anchor,
                w=plist_get("w", p),
                color=color);
  }
  if (slot_mode) {
    _joint();
    chassis_joint_bolt_holes(p, mode=mode, anchor=anchor);
  } else {
    difference() {
      _joint();
      chassis_joint_bolt_holes(p, mode=mode, anchor=anchor);
    }
  }
  if (show_bolts && !slot_mode) {
    %chassis_joint_bolts(p, mode=mode, anchor=anchor);
  }
}
