/**
  * Module: Raised rear battery mounting and sliding lidar lid.
  * Coordinates match the native rear holder-row layout, below the chassis.
  */
include <rear_chassis_params.scad>

use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lipo_pack_case/lid_wiring.scad>
use <../../lipo_pack_case/multi_lipo_pack_case.scad>
use <../../lipo_pack_case/multi_lipo_pack_lid.scad>
use <../../placeholders/standoff.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_power_case_mount
  ─────────────────────────────────────────────────────────────────────────────
  Reserve four symmetric support columns outside the motor and panels.
  **Parameters:**
  - `pl`: Battery case specification, or undef to omit the raised payload.
  - `motor_bounds`: Motor bracket bounds in chassis coordinates.
  - `y_offset`: Case-center offset from the motor's footprint center.
  - `clearance`: Gap from support/hole envelopes to neighboring components.
  - `panels`: Resolved panels to enclose between the supporting columns.
  **Returns:** Mount plist with an adjusted case plist, XY centers, bounds and
  exclusion bounds. The generated bolt pattern belongs to the printed case;
  it does not alter any battery or lidar hardware dimensions.
 */
function rear_power_case_mount(pl,
                               motor_bounds,
                               y_offset=0,
                               clearance=rear_power_standoff_clearance,
                               panels=[]) =
  is_undef(pl) ? undef :
  let (d = plist_get("bolt_d", pl),
       spec = calc_standoff_params(d, 5)[0],
       radius = max(plist_get("body_d", spec) + 0.1,
                    plist_get("bore_d", pl, d)) / 2,
       bottom_t = max(plist_get("bottom_t", pl,
                                plist_get("t", plist_get("bottom", plist_get("walls", pl)))),
                      plist_get("thread_h", spec) + 0.2),
       thick_pl = plist_merge(pl, ["bottom_t", bottom_t,
                                   "mount_nut_pockets", true]),
       props = multi_lipo_pack_props(thick_pl),
       orientation = plist_get("orientation", props),
       body_size = plist_get("size", props),
       max_span = orientation_size(orientation,
                                   concat(plist_get("max_bolt_spacing", props), [0])),
       occupied_x = max(concat([abs(motor_bounds[0][0]), abs(motor_bounds[1][0])],
                               [for (p = panels, b = plist_get("bounds", p)) abs(b[0])])),
       span = [2 * (occupied_x + radius + clearance),
               max_span[1]],
       center = [0,
                 (motor_bounds[0][1] + motor_bounds[1][1]) / 2 + y_offset, 0],
       canonical_span = orientation == "lwh" ? [span[1], span[0]] : span,
       ear_d = 2 * (radius + clearance),
       adjusted = plist_merge(plist_remove("bolt_spacing_x", plist_remove("bolt_spacing_y", thick_pl)),
                              ["bolt_spacing", canonical_span,
                               "mount_ear_d", ear_d]),
       size = plist_get("size", multi_lipo_pack_props(adjusted)),
       holes = [for (x = [-1, 1], y = [-1, 1])
           [center[0] + x * span[0] / 2, center[1] + y * span[1] / 2]],
       bounds = [center - [size[0]/2, size[1]/2, 0],
                 center + [size[0]/2, size[1]/2, size[2]]])
                 assert(orientation == "wlh" || orientation == "lwh",
                        "Rear battery floor must be horizontal")
  assert(clearance >= 0 && span[1] > 2 * radius,
         "Battery case needs nonnegative support clearance and separated support rows")
                 ["plist", adjusted,
                  "size", size,
                  "body_size", body_size,
                  "pos", center,
                  "bounds", bounds,
                  "bolt_spacing", span,
                  "mount_holes", holes,
                  "radius", radius,
                  "keepout", [[center[0] - span[0]/2 - radius - clearance, bounds[0][1], 0],
                              [center[0] + span[0]/2 + radius + clearance, bounds[1][1], 0]]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_motor_clearance_height
  ─────────────────────────────────────────────────────────────────────────────
  Return the installed motor/gearbox/encoder height above the chassis top.
  `bracket` is the resolved gearmotor bracket specification.
 */
function rear_motor_clearance_height(bracket) =
  let (gearbox = plist_get("gearbox_params", bracket),
       base = plist_get("bracket_thickness", bracket))
  max(plist_get("size", bracket)[2],
      base + plist_get("motor_shaft_y", gearbox)
      + plist_get("motor_d", gearbox) / 2 + plist_get("motor_pad", gearbox),
      base + plist_get("outer_shaft_y_center", gearbox)
      + plist_get("upper_gear_d", gearbox) / 2 + plist_get("motor_pad", gearbox));

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_power_lid_plist
  ─────────────────────────────────────────────────────────────────────────────

  Apply an explicit lidar selection while preserving the shared lid settings.

  **Parameters:**

  `pl`: Resolved case plist, including its mounting ears and floor thickness.
  `lidar_pl`: Lidar hardware plist; undef keeps a plain sliding roof.
 */
function rear_power_lid_plist(pl, lidar_pl) =
  plist_merge(pl,
              ["lid", plist_merge(plist_get("lid", pl, []),
                                  ["lidar", lidar_pl])]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_power_payload
  ─────────────────────────────────────────────────────────────────────────────
  Render the raised case, standoffs, sliding lid, and optional lidar.
  **Parameters:**
  - `payload`: Resolved `power_case` entry from the rear layout.
  - `show_case`: Display the printed battery case.
  - `show_packs`: Display installed batteries.
  - `show_standoffs`: Display the four case support columns.
  - `show_lidar`: Display the lidar and its own mounting standoffs.
  - `show_lid`: Display the sliding lid with the shared rail and lidar mounting patterns.
  - `slot_mode`: Emit the four chassis mounting cutters only.
  - `show_wiring`: Undef follows lid/lidar visibility; true enables a wiring
    cutaway with the roof hidden. The case wiring.enabled setting still applies.
  - `report_wire_lengths`: Echo lengths for the resolved rear-payload harness.
  The lid follows the case rail datums, including case orientation and mounting
  ears. Its visibility does not alter either the case or lidar placement.
 */
module rear_power_payload(payload,
                          show_case=true,
                          show_packs=true,
                          show_standoffs=true,
                          show_lidar=true,
                          show_lid=true,
                          slot_mode=false,
                          show_wiring=undef,
                          report_wire_lengths=false) {
  if (!is_undef(payload)) {
    pl = plist_get("plist", payload);
    pos = plist_get("pos", payload);
    mount_z = plist_get("mount_z", payload);
    lidar_pl = plist_get("lidar", payload);
    lid_pl = rear_power_lid_plist(pl, lidar_pl);
    wired = (is_undef(show_wiring) ? show_lid || show_lidar : show_wiring)
      && plist_get("enabled", plist_get("wiring", lid_pl, []), false);
    translate(pos) {
      if (slot_mode || show_case) {
        multi_lipo_pack_case(pl,
                             anchor=[0, 0, 1],
                             target_h=plist_get("target_h", payload),
                             parent_thickness=chassis_thickness,
                             show_standoffs=show_standoffs,
                             show_packs=show_packs,
                             slot_mode=slot_mode);
      } else if (show_standoffs) {
        translate([0, 0, chassis_thickness]) {
          four_corner_standoffs(h=plist_get("standoff_h", payload),
                                parent_thickness=chassis_thickness,
                                bolt_d=plist_get("bolt_d", pl),
                                cbore_d=plist_get("bore_d", pl),
                                cbore_h=plist_get("bore_h", pl),
                                bolt_spacing=plist_get("bolt_spacing", payload));
        }
      }
      if (!slot_mode && (show_lid || show_lidar || wired)
          && plist_get("enabled", plist_get("rail_props", multi_lipo_pack_props(pl)))) {
        translate([0, 0, mount_z]) {
          if (wired) {
            lid_wiring(lid_pl, report=report_wire_lengths);
          }
          multi_lipo_pack_lid_on_case(lid_pl,
                                      show_lid=show_lid,
                                      show_lidar=show_lidar);
        }
      }
    }
  }
}
