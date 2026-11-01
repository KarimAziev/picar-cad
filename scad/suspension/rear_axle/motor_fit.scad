/**
  * Module: Rear axle motor coupling fit diagnostics.
  *
  * Endpoints use the native rear chassis frame before its assembly rotation.
  * Diagnostics preserve the configured chassis, motor and axle placements.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../../lib/plist.scad>
use <../../placeholders/hsp_rear_drivetrain.scad>
use <rear_bulkhead.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_axle_motor_fit
  ─────────────────────────────────────────────────────────────────────────────

  Compare the geared motor output with the reducing sleeve in millimeters.

  **Parameters:**
  - `layout`: Resolved rear chassis layout, including its motor bracket.
  - `housing`: `rear_housing_spec` in
    `scad/suspension/rear_axle/structure_params.scad`.
  - `differential`: `rear_differential_spec` in
    `scad/suspension/rear_axle/hardware_params.scad`.
  - `pinion`: `rear_pinion_spec` in the same hardware parameter file.
  - `sleeve`: `rear_motor_sleeve_spec` in the same hardware parameter file;
    includes reducing bores and shaft engagement lengths.
  - `mount_h`: Axle mounting plane height above the chassis bottom.
  - `joint_spacing`: Rear suspension displacement along native chassis +Y.

  **Returns:**
  Plist containing `motor_tip`, `required_motor_tip`, `sleeve_motor_mouth`,
  and `tip_delta` (required minus actual), all native-frame XYZ vectors.
  `radial_offset` measures separation of the parallel shaft axes.
  `engagement_available` is signed axial penetration past the sleeve mouth;
  it assumes coincident axes and is not a fit claim. `engagement_required`
  is the configured motor engagement, and `engagement_deficit` is the
  nonnegative shortage relative to that length. `motor_shaft_d` and
  `sleeve_motor_bore_d` identify the mating nominal diameters.

  **Behavior:**
  Requires the rear layout's motor rotation `[0, 0, 180]` and native motor
  anchor `[0, 0, 1]`. The axle is rotated `[0, 0, 180]` about its mounting
  datum so its pinion points toward native chassis -Y. Axial overlap cannot
  establish fit when the shaft axes have a radial offset.
 */
function rear_axle_motor_fit(layout,
                             housing,
                             differential,
                             pinion,
                             sleeve,
                             mount_h,
                             joint_spacing) =
  assert(is_list(layout) && is_list(housing) && is_list(differential)
         && is_list(pinion) && is_list(sleeve),
         "Motor fit requires resolved layout and hardware plists")
  assert(is_num(mount_h) && is_num(joint_spacing),
         "Motor fit requires explicit mounting height and joint spacing")
  assert(plist_get("motor_rotation", layout) == [0, 0, 180]
         && plist_get("motor_anchor", layout) == [0, 0, 1],
         "Motor fit requires the native rear chassis motor orientation")
  let (bracket = plist_get("bracket", layout),
       gearbox = plist_get("gearbox_params", bracket),
       motor_pos = plist_get("motor_pos", layout),
       motor_tip = motor_pos
                   + [0, plist_get("thickness", gearbox)
                         + plist_get("outer_shaft_rear_len", gearbox),
                      plist_get("size", layout)[2]
                      + plist_get("bracket_thickness", bracket)
                      + plist_get("outer_shaft_y_center", bracket)],
       pinion_pos = rear_bulkhead_pinion_origin(housing, differential, pinion),
       sleeve_l = hsp_motor_sleeve_size(sleeve)[2],
       sleeve_end_y = pinion_pos[1] + hsp_rear_pinion_shaft_end(pinion)[2]
                      - plist_get("pinion_engagement", sleeve) + sleeve_l,
       sleeve_mouth = [-pinion_pos[0],
                       plist_get("bulkhead_2_y", layout) + joint_spacing
                       - sleeve_end_y,
                       mount_h + pinion_pos[2]],
       engagement_required = plist_get("motor_engagement", sleeve),
       required_tip = sleeve_mouth + [0, engagement_required, 0],
       delta = required_tip - motor_tip,
       engagement_available = motor_tip[1] - sleeve_mouth[1])
  ["motor_tip", motor_tip,
   "required_motor_tip", required_tip,
   "sleeve_motor_mouth", sleeve_mouth,
   "tip_delta", delta,
   "radial_offset", norm([delta[0], delta[2]]),
   "engagement_available", engagement_available,
   "engagement_required", engagement_required,
   "engagement_deficit", max(0, engagement_required - engagement_available),
   "motor_shaft_d", plist_get("outer_shaft_d", gearbox),
   "sleeve_motor_bore_d", plist_get("motor_bore_d", sleeve)];
