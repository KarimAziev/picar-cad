/**
 * Module: head_neck - Dual Servo Neck Bracket for Robot Head
 *
 * Defines a modular neck bracket assembly that enables Pan and Tilt movement
 * for a robot’s head using two servo motors (a pan servo and a tilt servo).
 *
 * The bracket is compatible with the robot head designed for dual Raspberry Pi Camera
 * Module 3 units and allows integration of the robot head via the tilt servo mount.
 *
 * Conceptually, this bracket combines:
 * - A pan servo on the horizontal base that rotates the entire structure horizontally.
 * - A tilt servo on the vertical plate that allows the attached head to tilt vertically.
 * - Optional mounts for visualizing servo and head placement in the 3D model.
 *
 * Structure:
 * ----------
 * This assembly is implemented using an L-shaped bracket (from `l_bracket.scad`)
 * as the foundational geometry, with servo slot cutouts and optionally mounted servo models.
 * The robot head (from `head_mount.scad`) can also be visualized to confirm fitment.
 *
 * Features:
 * ---------
 * - Automatically sizes the bracket to fit both pan and tilt servo components.
 * - Allows toggling visualization of tilt servo, pan servo, and head.
 * - Designed with wiring clearance and geometric offsets for hat components and bolts.
 *
 * Parameters:
 * -----------
 * @param show_tilt_servo   Boolean - Whether to render the tilt servo model in 3D.
 * @param show_head         Boolean - Whether to render the robot head on the neck mount.
 * @param show_pan_servo    Boolean - Whether to render the pan servo model in 3D.
 * @param bracket_color     Color value - Color used for rendering the neck bracket.
 * @param head_color        Color value - Color used for rendering the robot head.
 * @param show_ir_case      Boolean - Whether to render the case for IR LED
 * @param show_ir_led       Boolean - Whether to render the IR LED if show_ir_case is also enabled.
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/l_bracket.scad>
use <../lib/plist.scad>
use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <../placeholders/pan_servo.scad>
use <../placeholders/servo.scad>
use <../placeholders/tilt_servo.scad>
use <head_mount.scad>
use <ir_case.scad>

pan_servo_rotation          = 0; // [-179:179]
tilt_servo_rotation         = 0; // [-90:90]

show_camera                 = true;
show_camera_bolts           = true;
show_camera_nuts            = true;
show_ir_case                = true;
show_ir_case_bolts          = true;
show_ir_case_nuts           = true;
show_ir_led                 = true;
show_ir_case_rail           = true;
show_ir_case_rail_bolts     = true;
show_ir_case_rail_nuts      = true;

show_pan_servo_horn         = true;

show_tilt_servo_horn_screws = true;
show_tilt_servo_horn_bolt   = true;
head_servo_horn_screw_side  = "horizontal";

show_tilt_servo_horn        = true;
show_tilt_servo_bolts       = true;
show_tilt_servo_nuts        = true;

show_pan_servo_bolts        = true;
show_pan_servo_nuts         = true;

echo_bolts_length           = true;

function head_neck_full_w(base_width=max(head_neck_pan_servo_slot_width,
                                         head_neck_tilt_servo_slot_width),
                          bolts_dia=max(head_neck_pan_servo_bolt_dia,
                                        head_neck_tilt_servo_bolt_dia),
                          bolts_offset=max(head_neck_pan_servo_bolts_offset,
                                           head_neck_tilt_servo_bolts_offset),
                          extra_w=max(head_neck_pan_servo_extra_w,
                                      head_neck_tilt_servo_extra_w)) =
  base_width + (bolts_offset * 2 + bolts_dia * 2) + extra_w;

function head_neck_full_pan_panel_h() =
  let (nominal_h = head_neck_pan_servo_slot_height
                   + head_neck_tilt_servo_slot_thickness / 2,
       diff = (head_plate_width / 2 + head_plate_thickness) - nominal_h)
  nominal_h + diff + head_plate_thickness * 2;

function head_neck_full_tilt_panel_h() =
  head_neck_tilt_servo_slot_height
  + head_neck_pan_servo_slot_thickness
  + pan_servo_height_after_flange()
  + head_neck_tilt_servo_extra_lower_h
  + head_neck_tilt_servo_extra_top_h;

// Bounds are built from component envelopes, before either servo rotation.
function _head_neck_box(lo, hi, padding=0) =
  [for (x=[lo[0] - padding, hi[0] + padding],
        y=[lo[1] - padding, hi[1] + padding],
        z=[lo[2] - padding, hi[2] + padding]) [x, y, z]];

function _head_neck_bounds(points) =
  [for (side=[0, 1])
    [for (axis=[0:2])
      let (values=[for (p=points) p[axis]])
      side == 0 ? min(values) : max(values)]];

// Include heads, nuts, and the rounding-up of selected bolt lengths.
function _head_neck_fastener_padding(d, lock=false) =
  let (diameter=snap_bolt_d(d),
       spec=find_bolt_nut_spec(diameter),
       head=plist_get("pan", plist_get("head", spec, []), []),
       nut=plist_get(lock ? "lock_nut" : "nut", spec, []))
  max(plist_get("dia", head, diameter * 1.5) / 2,
      plist_get("height", head, diameter * 0.7),
      plist_get("outer_dia", nut, 0) / 2,
      plist_get("height", nut, 0) + 1);

function _head_neck_pan_offset() =
  let (w=head_neck_full_w(),
       slot_w=(w - pan_servo_size[0]) / 2)
  [-head_neck_full_pan_panel_h() / 2 - head_neck_tilt_servo_slot_thickness / 2,
   w - slot_w - (head_neck_pan_servo_assembly_reversed
                 ? pan_servo_gearbox_d1 + pan_servo_gearbox_d2
                 : pan_servo_gearbox_d1 / 2),
   pan_servo_gearbox_h + pan_servo_height_before_flange()
   - head_neck_pan_servo_slot_thickness + pan_servo_gear_height()
   + servo_horn_ring_height - servo_horn_arm_z_offset];

function _head_neck_tilt_pivot() =
  [head_neck_full_w() / 2 - tilt_servo_size[0] / 2 + tilt_servo_gearbox_d1 / 2,
   head_neck_tilt_servo_slot_thickness + tilt_servo_height_after_flange()
   + tilt_servo_flange_thickness - tilt_servo_size[2] - tilt_servo_gearbox_h,
   head_neck_full_tilt_panel_h() - head_neck_tilt_servo_slot_height / 2
   - head_neck_tilt_servo_extra_top_h];

// Points in head_mount coordinates. The frame's nonrectangular outline and
// accessory hardware are enclosed rather than tessellated here.
function _head_neck_head_points() =
  let (t=head_plate_thickness,
       side_y=[for (y=[-head_side_panel_top, -head_side_panel_notch_y,
                       -head_side_panel_bottom, -head_side_panel_curve_end])
         y + head_side_panel_curve_end - head_plate_height / 2],
       frame=_head_neck_box([-max(head_plate_width / 2 + t, head_upper_plate_width / 2,
                                  head_upper_connector_width / 2, head_lower_connector_width / 2),
                             min(-head_plate_height / 2 - head_lower_connector_height / 2,
                                 min(side_y)), 0],
                            [max(head_plate_width / 2 + t, head_upper_plate_width / 2,
                                 head_upper_connector_width / 2, head_lower_connector_width / 2),
                             max(head_plate_height / 2 + head_upper_connector_height + t,
                                 max(side_y)),
                             max(t, head_side_panel_width, head_upper_plate_height,
                                 head_upper_connector_len)]),
       // Horn coordinates before head_mount's outer Y rotation.
       horn_r=max(servo_horn_center_ring_outer_dia / 2,
                  servo_horn_ending_arm_w / 2
                  + servo_horn_center_ring_outer_dia / 2 + servo_horn_len / 4),
       horn_pad=_head_neck_fastener_padding(servo_horn_screw_d),
       horn_center=side_panel_servo_center(),
       horn=[for (p=_head_neck_box([-horn_r, -horn_r, -servo_horn_ring_height],
                                   [horn_r, horn_r, servo_horn_arm_z_offset
                                                    + servo_horn_arm_thickness], horn_pad))
         rotY([head_plate_width / 2,
               -head_plate_height / 2 + head_side_panel_curve_end, 0]
              + rotY([horn_center[0], horn_center[1], t] +
                     rotZ(p, atan2(head_side_panel_bottom
                                   - head_side_panel_curve_end,
                                   head_side_panel_curve_start
                                   - head_side_panel_width)), 90), 180)],
       camera_pad=_head_neck_fastener_padding(head_camera_bolt_dia),
       cameras=[for (i=[0:len(head_cameras)-1])
         let (spec=head_cameras[i],
              single_shift=len(head_cameras) > 1 ? 0 : head_cameras_y_distance / 2,
              y=camera_final_y(i) + single_shift + spec[2][1] / 2
                + head_camera_bolt_dia / 2 + spec[1] + camera_h / 2
                - camera_holes_size[1] / 2 - camera_bolt_hole_dia / 2
                - camera_holes_distance_from_top,
              lens_h=sum([for (s=camera_lens_items) s[2]]),
              lens_w=max([for (s=camera_lens_items) s[0]]),
              connector_h=max([for (s=camera_lens_connectors) s[2]]))
           each _head_neck_box([-max(camera_w, lens_w, spec[2][0]) / 2,
                                head_plate_height / 2 - y - camera_h / 2
                                - camera_module_ffc_zif_h,
                                t - max(lens_h, connector_h)],
                               [max(camera_w, lens_w, spec[2][0]) / 2,
                                head_plate_height / 2 - y + camera_h / 2
                                + camera_module_ffc_zif_h,
                                t + camera_thickness + camera_module_socket_thickness], camera_pad)],
       ir_t=ir_case_full_thickness(),
       ir_pad=max(_head_neck_fastener_padding(ir_case_bolt_dia),
                  _head_neck_fastener_padding(ir_case_rail_bolt_dia, true)),
       ir_pos=[head_plate_width / 2 + t + ir_case_l_bracket_len,
               head_side_panel_curve_end / 2 - ir_case_slider_y_pos()
               + ir_case_head_bolts_side_panel_positions[0][1] + ir_case_bolt_dia / 2,
               -ir_case_l_bracket_h / 2 - ir_t / 2 + ir_case_bolt_dia / 2
               + t + ir_case_head_bolts_side_panel_positions[0][0]],
       ir_points=[for (p=_head_neck_box([-ir_case_l_bracket_len - ir_t, 0,
                                         min(0, ir_t - max(ir_led_height,
                                                           ir_led_light_detector_h) - 0.1)],
                                        [ir_case_width + ir_case_l_bracket_len + ir_t,
                                         max(ir_case_height, ir_led_board_len),
                                         max(ir_case_l_bracket_h + ir_t / 2,
                                             ir_t + ir_case_carriage_h + ir_case_rail_h
                                             + ir_case_rail_protrusion_h)], ir_pad)) p + ir_pos],
       ir=is_ir_case_bracket_enabled("both")
       ? concat(ir_points, [for (p=ir_points) [-p[0], p[1], p[2]]])
       : is_ir_case_bracket_enabled("left") ? ir_points
       : is_ir_case_bracket_enabled("right")
       ? [for (p=ir_points)
         p + [-head_plate_width - ir_case_width - 2*t
              - 2*ir_case_l_bracket_len, 0, 0]] : [])
  concat(frame, horn, cameras, ir);

// Bounding points relative to the tilt axis, before its Z rotation in the
// vertical plate's local frame (which becomes X rotation in assembly space).
function _head_neck_tilting_points() =
  let (c=side_panel_servo_center())
  [for (p=_head_neck_head_points())
    rotY(p, 90) + [-c[0], -c[1] / 2, -head_plate_width / 2]];

function _head_neck_fixed_points() =
  let (w=head_neck_full_w(),
       l=head_neck_full_pan_panel_h(),
       h=head_neck_full_tilt_panel_h(),
       t=head_neck_pan_servo_slot_thickness,
       vt=head_neck_tilt_servo_slot_thickness,
       pad=max(_head_neck_fastener_padding(head_neck_pan_servo_bolt_dia),
               _head_neck_fastener_padding(head_neck_tilt_servo_bolt_dia)),
       bracket=_head_neck_box([0, 0, 0], [w, l + vt / 2, h], pad),
       // Horn rotation is enclosed for all pan angles; its planar envelope
       // is deliberately conservative, including the arm screws.
       horn_r=servo_horn_len / 2 + servo_horn_center_ring_outer_dia / 2,
       pan_axis_x=pan_servo_size[0] / 2 - pan_servo_gearbox_d1 / 2,
       pan_z=pan_servo_size[2] + t - pan_servo_flange_z_offset
             + pan_servo_flange_thickness / 2,
       pan=[for (p=_head_neck_box([-max(pan_servo_size[0] / 2, pan_servo_flange_w / 2,
                                        horn_r - pan_axis_x),
                                   -max(pan_servo_size[1] / 2, pan_servo_flange_h / 2, horn_r),
                                   pan_z - pan_servo_full_height() - servo_horn_ring_height],
                                  [max(pan_servo_size[0] / 2, pan_servo_flange_w / 2,
                                       pan_axis_x + horn_r),
                                   max(pan_servo_size[1] / 2, pan_servo_flange_h / 2, horn_r),
                                   pan_z], pad))
         [w/2, l/2 + vt/2, 0]
         + rotZ(p, head_neck_pan_servo_assembly_reversed ? 180 : 0)],
       tilt_y=h / 2 - head_neck_tilt_servo_slot_height / 2
              - head_neck_tilt_servo_extra_top_h,
       tilt=[for (p=_head_neck_box([-max(tilt_servo_size[0], tilt_servo_flange_w) / 2,
                                    -max(tilt_servo_size[1], tilt_servo_flange_h) / 2, 0],
                                   [max(tilt_servo_size[0], tilt_servo_flange_w) / 2,
                                    max(tilt_servo_size[1], tilt_servo_flange_h) / 2,
                                    tilt_servo_full_height()], pad))
         [w/2, vt/2, h/2]
         + rotX(p + [0, tilt_y, -tilt_servo_height_after_flange()
                                - vt/2 - tilt_servo_flange_thickness], 90)])
  concat(bracket, pan, tilt);

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_neck_bounds
  ─────────────────────────────────────────────────────────────────────────────
  Return conservative assembly bounds in the same coordinates as `head_neck`.

  **Parameters:**
  - `pan_servo_rotation`: Pan angle in degrees; defaults to the model's angle.
  - `tilt_servo_rotation`: Tilt angle in degrees; defaults to the model's angle.
  - `center_pan_servo_slot`: Use the pan mounting origin (default `true`, as in
    this file's assembled preview). Pass `false` for `head_neck`'s bracket origin.

  **Returns:**
  `[minimum, maximum]`, each an `[x, y, z]` vector in millimeters.

  **Behavior:**
  Encloses the fully populated assembly, including both cameras, configured IR
  case side(s), servos, horns, and fasteners. Visibility toggles do not shrink
  this clearance envelope. Component boxes and hardware allowances make it
  conservative, especially in X/Y; this is not a tight mesh measurement.
  Pan affects assembly orientation only with `center_pan_servo_slot=true`.
  The servo placeholder's additional `$t` animation is included in tilt.
 */
function head_neck_bounds(pan_servo_rotation=pan_servo_rotation,
                          tilt_servo_rotation=tilt_servo_rotation,
                          center_pan_servo_slot=true) =
  assert(is_num(pan_servo_rotation), "pan_servo_rotation must be numeric")
  assert(is_num(tilt_servo_rotation), "tilt_servo_rotation must be numeric")
  assert(is_bool(center_pan_servo_slot),
         "center_pan_servo_slot must be boolean")
  let (angle=tilt_servo_rotation + $t * ($t > 0.5 ? -90 : 90),
       pivot=_head_neck_tilt_pivot(),
       offset=_head_neck_pan_offset(),
       points=concat(_head_neck_fixed_points(),
                     [for (p=_head_neck_tilting_points())
                       pivot + rotX(rotZ(p, angle), 90)]))
  _head_neck_bounds(center_pan_servo_slot
                    ? [for (p=points)
                      rotZ(rotZ(p, -90) + offset,
                           pan_servo_rotation)]
                    : points);

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_neck_bbox
  ─────────────────────────────────────────────────────────────────────────────
  Return the assembled head's conservative bounding-box size `[x, y, z]`.

  **Parameters:**
  - `pan_servo_rotation`: Pan angle in degrees; defaults to the model's angle.
  - `tilt_servo_rotation`: Tilt angle in degrees; defaults to the model's angle.
  - `center_pan_servo_slot`: Pan mounting origin when `true` (default); bracket
    origin when `false`. Matches the corresponding `head_neck` option.

  **Returns:**
  Width, length, and height in millimeters, using `head_neck_bounds`' envelope.
  Height is `max_z - min_z`, not elevation above the mounting origin.

  **Examples:**
  ```scad
  bbox = head_neck_bbox(pan_servo_rotation=30, tilt_servo_rotation=45);
  lidar_obstacle_z = head_neck_max_z();

  // Draw the box at its minimum corner, rather than at the assembly origin.
  bounds = head_neck_bounds(pan_servo_rotation=30, tilt_servo_rotation=45);
  translate(bounds[0]) {
    cube(bounds[1] - bounds[0]);
  }
  ```
 */
function head_neck_bbox(pan_servo_rotation=pan_servo_rotation,
                        tilt_servo_rotation=tilt_servo_rotation,
                        center_pan_servo_slot=true) =
  let (b=head_neck_bounds(pan_servo_rotation, tilt_servo_rotation,
                          center_pan_servo_slot)) b[1] - b[0];

// Maximum of each possible upper/lower support pair over a full tilt turn.
// Taking the diameter handles moving extrema at the SAME angle, instead of
// subtracting extrema reached at two unrelated angles in the swept volume.
function _head_neck_height_limits() =
  let (fixed=_head_neck_bounds(_head_neck_fixed_points()),
       p=_head_neck_tilting_points(),
       radius=max([for (v=p) norm([v[0], v[1]])]),
       diameter=max([for (a=p, b=p) norm([a[0]-b[0], a[1]-b[1]])]),
       z=_head_neck_tilt_pivot()[2])
  [max(fixed[1][2], z + radius),
   max(fixed[1][2] - fixed[0][2],
       diameter,
       z + radius - fixed[0][2],
       fixed[1][2] - z + radius)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_neck_max_height
  ─────────────────────────────────────────────────────────────────────────────
  Return the largest conservative bbox height over all pan and tilt angles.

  **Returns:**
  Maximum `head_neck_bbox(...)[2]` in millimeters. Analytic over a full 360-degree
  tilt turn, independent of pan and origin translation. Mechanical servo limits
  and collisions are deliberately not applied, so limited travel may need less
  clearance. Uses the fully populated envelope described by `head_neck_bounds`.
 */
function head_neck_max_height() = _head_neck_height_limits()[1];

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_neck_max_z
  ─────────────────────────────────────────────────────────────────────────────
  Return the highest possible Z coordinate for lidar clearance.

  **Parameters:**
  - `center_pan_servo_slot`: Use the pan mounting origin (default `true`), or
    the bracket origin (`false`), matching the assembly being positioned.

  **Returns:**
  Highest envelope Z in millimeters over every pan/tilt angle, using the same
  full-turn assumption as `head_neck_max_height`. Add the assembly's mounting Z
  and desired clearance before using this as a lidar obstacle elevation.
 */
function head_neck_max_z(center_pan_servo_slot=true) =
  assert(is_bool(center_pan_servo_slot),
         "center_pan_servo_slot must be boolean")
  _head_neck_height_limits()[0]
  + (center_pan_servo_slot ? _head_neck_pan_offset()[2] : 0);

module servo_mount_bolts(d=head_neck_pan_servo_bolt_dia,
                         flang_thickness=pan_servo_flange_thickness,
                         slot_thickness=head_neck_pan_servo_slot_thickness,
                         slot_size=[head_neck_pan_servo_slot_width,
                                    head_neck_pan_servo_slot_height],
                         bolts_offset=head_neck_pan_servo_bolts_offset,
                         bolt_name,
                         reverse=true,
                         show_nut=false) {
  let (nut_spec = find_nut_spec(inner_d=d,
                                lock=false),
       nut_h = plist_get("height", nut_spec, 2),
       bolt_h = ceil(nut_h + flang_thickness + slot_thickness),
       nut_head_distance=flang_thickness + slot_thickness,
       init_z = reverse
       ? -slot_thickness / 2 + bolt_h
       : slot_thickness / 2 - bolt_h) {

    translate([0,
               0,
               init_z]) {
      if (echo_bolts_length) {
        echo(str("The bolt ",
                 is_undef(bolt_name) ? "" : bolt_name,
                 ": M" ,
                 snap_bolt_d(d),
                 "x",
                 bolt_h,
                 "mm"));
      }
      with_servo_slot_slots(size=slot_size,
                            bolts_dia=d,
                            bolts_offset=bolts_offset) {
        maybe_rotate([reverse ? 180 : 0, 0, 0]) {
          bolt(h=bolt_h,
               d=d,
               nut_head_distance=nut_head_distance,
               show_nut=show_nut);
        }
      }
    }
  }
}

module head_neck_base(show_tilt_servo=false,
                      show_head=false,
                      show_camera=true,
                      show_pan_servo=false,
                      show_ir_case=false,
                      show_camera_bolts=show_camera_bolts,
                      show_camera_nuts=show_camera_nuts,
                      show_ir_case_bolts=show_ir_case_bolts,
                      show_ir_case_nuts=show_ir_case_nuts,
                      show_ir_led=show_ir_led,
                      show_ir_case_rail=show_ir_case_rail,
                      show_ir_case_rail_bolts=show_ir_case_rail_bolts,
                      show_ir_case_rail_nuts=show_ir_case_rail_nuts,
                      show_tilt_servo_bolts=show_tilt_servo_bolts,
                      show_tilt_servo_nuts=show_tilt_servo_nuts,
                      show_pan_servo_bolts=show_pan_servo_bolts,
                      show_pan_servo_nuts=show_pan_servo_nuts,
                      tilt_servo_rotation=tilt_servo_rotation,
                      pan_servo_rotation=pan_servo_rotation,
                      show_tilt_servo_horn_screws=show_tilt_servo_horn_screws,
                      show_tilt_servo_horn_bolt=show_tilt_servo_horn_bolt,
                      show_tilt_servo_horn=show_tilt_servo_horn,
                      show_pan_servo_horn=show_pan_servo_horn,
                      head_servo_horn_screw_side=head_servo_horn_screw_side,
                      bracket_color=matte_black,
                      head_color="white") {
  pan_servo_h = pan_servo_size[2];
  full_pan_h = head_neck_full_pan_panel_h();
  full_tilt_h = head_neck_full_tilt_panel_h();
  full_w = head_neck_full_w();
  pan_rad = min(min(full_w, full_pan_h) * 0.2, 3);
  tilt_rad = min(min(full_w, full_tilt_h) * 0.2, 3);

  half_of_tilt_h = full_tilt_h / 2;

  tilt_servo_y = half_of_tilt_h
                 - head_neck_tilt_servo_slot_height / 2
                 - head_neck_tilt_servo_extra_top_h;

  reverse_rotation = head_neck_pan_servo_assembly_reversed ? 180 : 0;

  l_bracket(size=[full_w,
                  full_pan_h,
                  full_tilt_h],
            bracket_color=bracket_color,
            vertical_thickness=head_neck_tilt_servo_slot_thickness,
            thickness=head_neck_pan_servo_slot_thickness,
            children_modes=[["difference", "horizontal"],
                            ["union", "horizontal"],
                            ["difference", "vertical"],
                            ["union", "vertical"]],
            center=false,
            y_r=pan_rad,
            z_r=tilt_rad) {
    // difference
    servo_slot_2d(size=[head_neck_pan_servo_slot_width,
                        head_neck_pan_servo_slot_height],
                  bolts_dia=head_neck_pan_servo_bolt_dia,
                  bolts_offset=head_neck_pan_servo_bolts_offset);

    // union
    union() {
      if (show_pan_servo_bolts) {
        servo_mount_bolts(d=head_neck_pan_servo_bolt_dia,
                          flang_thickness=pan_servo_flange_thickness,
                          slot_thickness=head_neck_pan_servo_slot_thickness,
                          slot_size=[head_neck_pan_servo_slot_width,
                                     head_neck_pan_servo_slot_height],
                          bolts_offset=head_neck_pan_servo_bolts_offset,
                          show_nut=show_pan_servo_nuts,
                          bolt_name="for pan servo");
      }
      rotate([reverse_rotation, reverse_rotation, 0]) {
        translate([pan_servo_size[0] / 2,
                   -pan_servo_size[1] / 2 ,
                   pan_servo_h
                   + head_neck_pan_servo_slot_thickness / 2
                   - pan_servo_flange_z_offset
                   + pan_servo_flange_thickness / 2]) {
          if (show_pan_servo) {
            rotate([0, 0, 0]) {
              rotate([0, 180, 0]) {
                pan_servo(show_servo_horn=show_pan_servo_horn,
                          show_servo_horn_bolt=true,
                          servo_horn_rotation=pan_servo_rotation);
              }
            }
          }
        }
      }
    }

    // difference
    translate([0, tilt_servo_y, 0]) {
      servo_slot_2d(size=[head_neck_tilt_servo_slot_width,
                          head_neck_tilt_servo_slot_height],
                    bolts_dia=head_neck_tilt_servo_bolt_dia,
                    bolts_offset=head_neck_tilt_servo_bolts_offset,
                    center=true);
    }
    // union
    union() {
      if (show_tilt_servo_bolts) {
        translate([0, tilt_servo_y, 0]) {
          servo_mount_bolts(d=head_neck_tilt_servo_bolt_dia,
                            flang_thickness=tilt_servo_flange_thickness,
                            slot_thickness=head_neck_tilt_servo_slot_thickness,
                            slot_size=[head_neck_tilt_servo_slot_width,
                                       head_neck_tilt_servo_slot_height],
                            bolts_offset=head_neck_tilt_servo_bolts_offset,
                            bolt_name="for tilt servo",
                            reverse=false,
                            show_nut=show_tilt_servo_nuts);
        }
      }

      translate([0,
                 tilt_servo_y,
                 -tilt_servo_height_after_flange()
                 - head_neck_tilt_servo_slot_thickness / 2
                 - tilt_servo_flange_thickness]) {

        if (show_tilt_servo || show_head) {

          tilt_servo(center=true,
                     show_servo_horn=false,
                     alpha=show_tilt_servo ? 1 : 0) {
            if (show_head) {
              head_centers = side_panel_servo_center();

              rotate([0, 0, tilt_servo_rotation]) {
                translate([-head_centers[0],
                           -head_centers[1] / 2,
                           -head_plate_width / 2]) {
                  rotate([0, 90, 0]) {
                    head_mount(head_color=head_color,
                               show_ir_case=show_ir_case,
                               show_servo_horn=show_tilt_servo_horn,
                               show_camera=show_camera,
                               show_camera_bolts=show_camera_bolts,
                               show_camera_nuts=show_camera_nuts,
                               show_ir_case_bolts=show_ir_case_bolts,
                               show_ir_case_nuts=show_ir_case_nuts,
                               show_ir_led=show_ir_led,
                               show_ir_case_rail=show_ir_case_rail,
                               show_ir_case_rail_bolts=show_ir_case_rail_bolts,
                               show_ir_case_rail_nuts=show_ir_case_rail_nuts,
                               show_servo_horn_screws=show_tilt_servo_horn_screws,
                               show_servo_horn_bolt=show_tilt_servo_horn_bolt,
                               servo_horn_screw_side=head_servo_horn_screw_side);
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

module head_neck(center_pan_servo_slot=false,
                 show_tilt_servo=true,
                 show_head=true,
                 show_pan_servo=true,
                 show_camera=show_camera,
                 show_ir_case=show_ir_case,
                 show_camera_bolts=show_camera_bolts,
                 show_camera_nuts=show_camera_nuts,
                 show_ir_case_bolts=show_ir_case_bolts,
                 show_ir_case_nuts=show_ir_case_nuts,
                 show_ir_led=show_ir_led,
                 show_ir_case_rail=show_ir_case_rail,
                 show_ir_case_rail_bolts=show_ir_case_rail_bolts,
                 show_ir_case_rail_nuts=show_ir_case_rail_nuts,
                 show_tilt_servo_horn=show_tilt_servo_horn,
                 show_pan_servo_horn=show_pan_servo_horn,
                 show_tilt_servo_bolts=show_tilt_servo_bolts,
                 show_tilt_servo_nuts=show_tilt_servo_nuts,
                 show_pan_servo_bolts=show_pan_servo_bolts,
                 show_pan_servo_nuts=show_pan_servo_nuts,
                 bracket_color="white",
                 show_tilt_servo_horn_screws=show_tilt_servo_horn_screws,
                 show_tilt_servo_horn_bolt=show_tilt_servo_horn_bolt,
                 head_servo_horn_screw_side=head_servo_horn_screw_side,
                 tilt_servo_rotation=tilt_servo_rotation,
                 pan_servo_rotation=pan_servo_rotation,
                 head_color="white") {

  module head_neck_mod() {
    head_neck_base(show_tilt_servo=show_tilt_servo,
                   show_head=show_head,
                   show_camera=show_camera,
                   show_pan_servo=show_pan_servo,
                   show_ir_case=show_ir_case,
                   show_ir_led=show_ir_led,
                   bracket_color=bracket_color,
                   head_color=head_color,
                   pan_servo_rotation=pan_servo_rotation,
                   tilt_servo_rotation=tilt_servo_rotation,
                   show_camera_bolts=show_camera_bolts,
                   show_camera_nuts=show_camera_nuts,
                   show_ir_case_bolts=show_ir_case_bolts,
                   show_ir_case_nuts=show_ir_case_nuts,
                   show_ir_case_rail=show_ir_case_rail,
                   show_ir_case_rail_bolts=show_ir_case_rail_bolts,
                   show_ir_case_rail_nuts=show_ir_case_rail_nuts,
                   show_tilt_servo_horn=show_tilt_servo_horn,
                   show_pan_servo_horn=show_pan_servo_horn,
                   show_tilt_servo_bolts=show_tilt_servo_bolts,
                   show_tilt_servo_nuts=show_tilt_servo_nuts,
                   show_pan_servo_bolts=show_pan_servo_bolts,
                   show_pan_servo_nuts=show_pan_servo_nuts,
                   show_tilt_servo_horn_screws=show_tilt_servo_horn_screws,
                   show_tilt_servo_horn_bolt=show_tilt_servo_horn_bolt,
                   head_servo_horn_screw_side=head_servo_horn_screw_side);
  }

  if (!center_pan_servo_slot) {
    head_neck_mod();
  } else {
    rotate([0, 0, pan_servo_rotation]) {
      translate(_head_neck_pan_offset()) {
        rotate([0, 0, -90]) {
          head_neck_mod();
        }
      }
    }
  }
}

module head_neck_printable() {
  head_neck(center_pan_servo_slot=false,
            show_tilt_servo=false,
            show_head=false,
            show_pan_servo=false,
            show_camera=false,
            show_camera_bolts=false,
            show_camera_nuts=false,
            show_ir_case=false,
            show_ir_case_bolts=false,
            show_ir_case_nuts=false,
            show_ir_led=false,
            show_ir_case_rail=false,
            show_ir_case_rail_bolts=false,
            show_ir_case_rail_nuts=false,
            show_pan_servo_horn=false,
            show_tilt_servo_horn=false,
            show_tilt_servo_bolts=false,
            show_tilt_servo_nuts=false,
            show_pan_servo_bolts=false,
            show_pan_servo_nuts=false,
            show_tilt_servo_horn_screws=false,
            show_tilt_servo_horn_bolt=false);
}

head_neck(center_pan_servo_slot=true);

bounds = head_neck_bounds(pan_servo_rotation=pan_servo_rotation,
                          tilt_servo_rotation=tilt_servo_rotation,
                          center_pan_servo_slot=true);
bbox = bounds[1] - bounds[0];

// The size alone does not describe the assembly's asymmetric placement.
#translate(bounds[0]) {
  cube(size=bbox);
}
