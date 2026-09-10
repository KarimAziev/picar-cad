/**
  * Module: RC single-speed offset gearbox and brushed motor placeholder.
  *
  * Photo-based packaging model, not a measured MN78 mounting drawing.
  * Local output axis is -Y. The body is XY-centered and rests on Z=0;
  * shafts and terminals extend beyond its nominal anchor envelope.
  */
include <../parameters.scad>
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/transforms.scad>

show_motor = true;
show_gearbox = true;
show_rear_shaft = true;
show_front_shaft = true;

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_gearmotor_size
  ─────────────────────────────────────────────────────────────────────────────
  Return the photo's nominal body envelope, excluding shafts and terminals.
  **Parameters:**
  - `spec`: Motor property list.
  **Returns:** Body `[w, l, h]` in mm.
 */
function rc_gearmotor_size(spec=rc_gearmotor_plist) =
  plist_props(["body_w", "body_l", "body_h"], spec);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_gearmotor_axis_x
  ─────────────────────────────────────────────────────────────────────────────
  Return the lateral center of either gear lobe in the nominal body envelope.
  **Parameters:**
  - `spec`: Motor property list.
  - `output`: Select the output axis; false selects the motor-can axis.
  **Returns:** X coordinate in mm. Axis separation is a photo approximation.
 */
function rc_gearmotor_axis_x(spec=rc_gearmotor_plist, output=true) =
  output ? (plist_get("output_lobe_d", spec) - plist_get("body_w", spec)) / 2
         : (plist_get("body_w", spec) - plist_get("body_h", spec)) / 2;

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_gearmotor_shaft_tip
  ─────────────────────────────────────────────────────────────────────────────
  Return a shaft endpoint in the default body-anchor coordinates.
  **Parameters:**
  - `spec`: Motor property list.
  - `rear`: Select the rear (-Y) output, or the unused forward output.
  **Returns:** `[x, y, z]` in mm, including shaft protrusion.
 */
function rc_gearmotor_shaft_tip(spec=rc_gearmotor_plist, rear=true) =
  let (size = rc_gearmotor_size(spec))
  [rc_gearmotor_axis_x(spec),
   -size[1] / 2 + (rear ? -plist_get("rear_shaft_l", spec)
     : plist_get("gearbox_l", spec) + plist_get("front_shaft_l", spec)),
   size[2] / 2];

module _rc_gearmotor_profile(spec) {
  h = plist_get("body_h", spec);
  hull() {
    for (output = [false, true]) {
      translate([rc_gearmotor_axis_x(spec, output), h / 2])
        circle(d=output ? plist_get("output_lobe_d", spec) : h);
    }
  }
}

// Cylinders run from the rear face toward +Y.
module _rc_gearmotor_axial(d, l) {
  rotate([-90, 0, 0]) cylinder(d=d, h=l);
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_gearmotor
  ─────────────────────────────────────────────────────────────────────────────
  Build the offset transmission, can, casing ears, bearings and two shafts.
  **Parameters:**
  - `spec`: Photo-based motor property list; all detail dimensions provisional.
  - `show_motor`: Show the can, end cap and terminals.
  - `show_gearbox`: Show the casing, cover, ears and bearing bosses.
  - `show_rear_shaft`: Show the driven rear output.
  - `show_front_shaft`: Show the unused forward output.
  - `slot_mode`: Emit a conservative body/shaft clearance envelope, not holes.
  - `clearance`: Radial/body allowance used only in slot mode.
  - `anchor`: Anchor on the body envelope, excluding shaft/terminal extensions.
 */
module rc_gearmotor(spec=rc_gearmotor_plist,
                    show_motor=show_motor,
                    show_gearbox=show_gearbox,
                    show_rear_shaft=show_rear_shaft,
                    show_front_shaft=show_front_shaft,
                    slot_mode=false,
                    clearance=0,
                    anchor=[0, 0, 1]) {
  size = rc_gearmotor_size(spec);
  gear_l = plist_get("gearbox_l", spec);
  can_d = plist_get("can_d", spec);
  cap_l = plist_get("end_cap_l", spec);
  cover_l = plist_get("cover_l", spec);
  ear_d = plist_get("ear_d", spec);
  output_x = rc_gearmotor_axis_x(spec);
  can_x = rc_gearmotor_axis_x(spec, false);
  z = size[2] / 2;
  assert(size[0] >= size[2] && size[2] >= can_d);
  assert(plist_get("output_lobe_d", spec) <= size[2]);
  assert(can_x - output_x > (can_d + plist_get("bearing_d", spec)) / 2,
         "Forward output bearing intersects the motor can");
  assert(gear_l > cover_l * 2 && size[1] > gear_l + cap_l);
  assert(clearance >= 0);
  $fn = $preview ? 40 : 80;

  with_anchor(anchor, size, centered=true) {
    if (slot_mode) {
      translate([0, 0, -clearance])
        cuboid(size + [clearance * 2, clearance * 2, clearance * 2]);
      for (rear = [true, false]) {
        if (rear ? show_rear_shaft : show_front_shaft) {
          tip = rc_gearmotor_shaft_tip(spec, rear);
          face_y = -size[1] / 2 + (rear ? 0 : gear_l);
          translate([output_x, min(tip[1], face_y) - clearance, z])
            _rc_gearmotor_axial(plist_get("bearing_d", spec) + clearance * 2,
                                abs(tip[1] - face_y) + clearance * 2);
        }
      }
    } else {
      if (show_gearbox) {
        color("#30343b") {
          difference() {
            union() {
              translate([0, -size[1] / 2 + gear_l, 0]) rotate([90, 0, 0])
                linear_extrude(height=gear_l - cover_l) _rc_gearmotor_profile(spec);
              // Casing ears are visualization only, not chassis mount datums.
              for (side = [-1, 1]) hull() {
                translate([side * (size[0] - ear_d) / 2,
                           -size[1] / 2 + cover_l,
                           side > 0 ? ear_d / 2 : size[2] - ear_d / 2])
                  _rc_gearmotor_axial(ear_d, gear_l - cover_l);
                translate([rc_gearmotor_axis_x(spec, side < 0), -size[1] / 2 + cover_l, z])
                  _rc_gearmotor_axial(ear_d, gear_l - cover_l);
              }
            }
            for (side = [-1, 1])
              translate([side * (size[0] - ear_d) / 2,
                         -size[1] / 2 - cover_l,
                         side > 0 ? ear_d / 2 : size[2] - ear_d / 2])
                _rc_gearmotor_axial(plist_get("case_bolt_d", spec),
                                    gear_l + cover_l * 2);
          }
        }
        color("silver")
          translate([0, -size[1] / 2 + cover_l, 0]) rotate([90, 0, 0])
            linear_extrude(height=cover_l) _rc_gearmotor_profile(spec);
        for (rear = [true, false]) {
          bearing_l = plist_get("bearing_l", spec);
          color("#555b65")
            translate([output_x, -size[1] / 2 + (rear ? -bearing_l : gear_l), z])
              _rc_gearmotor_axial(plist_get("bearing_d", spec), bearing_l);
        }
      }
      if (show_motor) {
        color("silver")
          translate([can_x, -size[1] / 2 + gear_l, z])
            _rc_gearmotor_axial(can_d, size[1] - gear_l - cap_l);
        color("#343a85")
          translate([can_x, size[1] / 2 - cap_l, z])
            _rc_gearmotor_axial(can_d, cap_l);
        for (side = [-1, 1])
          color("gold") translate([can_x + side * can_d / 3, size[1] / 2, z])
            cuboid(plist_props(["terminal_w", "terminal_l", "terminal_h"], spec),
                   anchor=[0, 1, 0]);
      }
      for (rear = [true, false]) {
        if (rear ? show_rear_shaft : show_front_shaft) {
          tip = rc_gearmotor_shaft_tip(spec, rear);
          face_y = -size[1] / 2 + (rear ? 0 : gear_l);
          color("silver") translate([output_x, min(tip[1], face_y), z])
            _rc_gearmotor_axial(plist_get("shaft_d", spec), abs(tip[1] - face_y));
        }
      }
    }
  }
}

rc_gearmotor();
