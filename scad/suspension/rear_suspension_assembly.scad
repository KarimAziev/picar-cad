/**
  * Module: Rear suspension presets and chassis attachment.
  *
  * Axle geometry uses vehicle axes, with its origin on the mounting plane
  * below the differential. Chassis attachment uses native rear-deck axes.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../rc_params.scad>
include <rear_axle/structure_params.scad>
include <rear_axle/hardware_params.scad>
include <rear_axle/arm_hub_params.scad>

use <../lib/plist.scad>
use <../placeholders/hsp_rear_drivetrain.scad>
use <../placeholders/rc_touring_wheel.scad>
use <rear_chassis/computed_params.scad>
use <rear_axle/rear_axle_assembly.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_wheel_origin
  ─────────────────────────────────────────────────────────────────────────────
  Locate the right wheel's inboard face in the axle frame; local +Z is outboard.
  **Parameters:** `housing`: `rear_housing_spec` in
  `rear_axle/structure_params.scad`. `arm`, `hub`: `rear_lower_arm_spec` and
  `rear_hub_spec` in `rear_axle/arm_hub_params.scad`. `axle`:
  `rear_wheel_axle_spec` in `rear_axle/hardware_params.scad`.
  `wheel`: `rc_wheel_plist` in `../rc_params.scad`, including its hex datum.
  `settings`: `rear_axle_settings` in `rear_axle/structure_params.scad`.
  **Returns:** [x, y, z] translation before a +90 degree rotation about Y.
 */
function rear_suspension_wheel_origin(housing, arm, hub, axle, wheel,
                                      settings=rear_axle_settings) =
  rear_axle_wheel_shaft_origin(housing, arm, hub, axle, settings)
  + [hsp_rear_wheel_axle_mount_z(axle) - plist_get("mount_z", wheel), 0, 0];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_chassis_datum
  ─────────────────────────────────────────────────────────────────────────────
  Locate the axle origin in the unanchored native rear-deck frame.
  **Parameters:** `layout`: Resolved rear chassis layout. `mount_h`: Plate height.
  `joint_spacing`: Rearward separation of the suspension plate, in millimeters.
  **Returns:** [x, y, z]; rotate axle geometry 180 degrees about Z at this point.
 */
function rear_suspension_chassis_datum(layout, mount_h, joint_spacing) =
  [0, plist_get("bulkhead_2_y", layout) + joint_spacing, mount_h];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_wheel_reference_center
  ─────────────────────────────────────────────────────────────────────────────
  Return the positive-X tire center in the unanchored native rear-deck frame.
  **Parameters:** `layout`: Rear layout. `mount_h`: Suspension mounting height.
  `housing`, `settings`: `rear_housing_spec`, `rear_axle_settings` in
  `rear_axle/structure_params.scad`. `arm`, `hub`: `rear_lower_arm_spec`,
  `rear_hub_spec` in `rear_axle/arm_hub_params.scad`. `axle`:
  `rear_wheel_axle_spec` in `rear_axle/hardware_params.scad`.
  `wheel`: `rc_wheel_plist` in `../rc_params.scad`.
  **Behavior:** Uses the assembled reference pose, with zero joint separation.
 */
function rear_suspension_wheel_reference_center(
    layout,
    mount_h,
    housing=rear_housing_spec,
    arm=rear_lower_arm_spec,
    hub=rear_hub_spec,
    axle=rear_wheel_axle_spec,
    wheel=rc_wheel_plist,
    settings=rear_axle_settings) =
  let (p = rear_suspension_wheel_origin(housing, arm, hub, axle, wheel, settings)
           + [plist_get("width", wheel) / 2, 0, 0],
       datum = rear_suspension_chassis_datum(layout, mount_h, 0))
  datum + [p[0], -p[1], p[2]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_assembly
  ─────────────────────────────────────────────────────────────────────────────
  Assemble the rear suspension in vehicle axle coordinates.
  **Parameters:** `layout`: Resolved `rear_chassis_layout()` mounting layout.
  `settings`, `housing`, `tower`, `fastener`: `rear_axle_settings`,
  `rear_housing_spec`, `rear_tower_spec`, `rear_fastener_spec` in
  `rear_axle/structure_params.scad`.
  `arm`, `hub`: `rear_lower_arm_spec`, `rear_hub_spec` in
  `rear_axle/arm_hub_params.scad`.
  `differential`, `pinion`, `dogbone`, `axle`, `sleeve`, `shock`: Corresponding
  `rear_*_spec` presets in `rear_axle/hardware_params.scad`.
  `wheel`: `rc_wheel_plist` in `../rc_params.scad`.
  `show_wheels`: Display both wheels.
  `show_tires`: Display their tires.
  **Behavior:** Wheels seat on the wheel shaft's hex faces and follow hub datums.
 */
module rear_suspension_assembly(layout=rear_chassis_layout(),
                                settings=rear_axle_settings,
                                housing=rear_housing_spec,
                                arm=rear_lower_arm_spec,
                                hub=rear_hub_spec,
                                tower=rear_tower_spec,
                                differential=rear_differential_spec,
                                pinion=rear_pinion_spec,
                                dogbone=rear_dogbone_spec,
                                axle=rear_wheel_axle_spec,
                                sleeve=rear_motor_sleeve_spec,
                                shock=rear_shock_spec,
                                fastener=rear_fastener_spec,
                                wheel=rc_wheel_plist,
                                show_wheels=false,
                                show_tires=true) {
  rear_axle_assembly(settings=settings, housing=housing, arm=arm, hub=hub,
                     tower=tower, differential=differential, pinion=pinion,
                     dogbone=dogbone, axle=axle, sleeve=sleeve, shock=shock,
                     fastener=fastener, layout=layout);
  if (show_wheels) {
    p = rear_suspension_wheel_origin(housing, arm, hub, axle, wheel, settings);
    for (side = [-1, 1]) {
      translate([side * p[0], p[1], p[2]]) {
        rotate([0, side * 90, 0]) {
          rc_touring_wheel(pl=wheel, anchor=[0, 0, 1], show_tire=show_tires,
                           slot_mode=false, clearance=0);
        }
      }
    }
  }
}

rear_suspension_assembly();
