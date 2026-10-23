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

show_bbox                   = false;

show_frame_bolts            = false;
show_frame_nuts             = false;
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
head_servo_horn_screw_side  = "horizontal"; // [vertical, horizontal]

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
       diff = (head_front_width / 2 + head_front_thickness) - nominal_h)
  nominal_h + diff + head_front_thickness * 2;

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

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_neck_lower_tilt_stop
  ─────────────────────────────────────────────────────────────────────────────
  Return the positive tilt angle where the camera plate meets the neck upright.
  **Returns:** Degrees from neutral to contact, derived from the tilt axis,
  camera plate thickness and upright's near edge. The plate's lower rear edge
  contacts the upright; installed fasteners can require an earlier servo limit.
 */
function head_neck_lower_tilt_stop() =
  let (c=head_tilt_axis_position(),
       x=c[0] - head_front_thickness,
       y=c[1],
       pivot=_head_neck_tilt_pivot(),
       r=norm([x, y]),
       a=acos(pivot[0] / r) - atan2(y, x),
       contact_z=pivot[2] - x * sin(a) - y * cos(a))
  assert(x > 0 && y > 0 && pivot[0] > 0 && pivot[0] < r,
         "The camera plate must start outside the upright's near edge")
  assert(contact_z > head_neck_pan_servo_slot_thickness
         && contact_z < head_neck_full_tilt_panel_h(),
         "The camera plate's contact must lie on the upright")
  a;

// Triangular prisms retain the eight-point box connectivity with one doubled
// vertex. Their extrusion is across the head, parallel to the tilt axis.
function _head_neck_frame_points() =
  let (profile=head_side_panel_outline(),
       half_w=head_front_width / 2,
       outer=half_w + head_side_panel_thickness,
       h=head_front_height,
       pad=_head_neck_fastener_padding(head_frame_bolt_d),
       head_h=find_bolt_head_h(head_frame_bolt_d, "pan"),
       joint_points=concat(head_front_joint_points(), head_bridge_joint_points()))
  concat(
    _head_neck_box([-half_w, -h / 2, 0],
                   [half_w, h / 2, head_front_flange_depth]),
    _head_neck_box([-outer, head_bridge_underside_y() - head_bridge_flange_height, 0],
                   [outer, head_bridge_underside_y() + head_bridge_thickness,
                    head_bridge_depth]),
    [for (i=[1:len(profile) - 2],
          p=[profile[0], profile[i], profile[i + 1], profile[i + 1]],
          x=[-outer, outer])
      [x, p[1] - h / 2, p[0]]],
    [for (p=joint_points)
      each _head_neck_box([-outer - head_h, p[1] - h / 2 - pad, p[0] - pad],
                          [outer + head_h, p[1] - h / 2 + pad, p[0] + pad])]);

function _head_neck_camera_points(i) =
  let (spec=head_cameras[i],
       shift=len(head_cameras) > 1 ? 0 : head_camera_gap / 2,
       hole_y=head_camera_y(i) + shift + spec[2][1] / 2
              + head_camera_bolt_d / 2 + spec[1],
       center_y=head_front_height / 2 - hole_y - camera_h / 2
                + camera_holes_size[1] / 2 + camera_bolt_hole_dia / 2
                + camera_holes_distance_from_top,
       lens_y=max([for (s=camera_lens_items) s[4] == "circle" ? s[0] : s[1]]),
       lens_center=camera_h / 2 - lens_y / 2 - camera_lens_distance_from_top,
       camera_points=concat(
         _head_neck_box([-camera_w / 2, -camera_h / 2, -0.05],
                        [camera_w / 2, camera_h / 2, camera_thickness + 0.1]),
         [for (j=[0:len(camera_lens_items) - 1])
           let (s=camera_lens_items[j],
                y=s[4] == "circle" ? s[0] : s[1],
                z=camera_thickness + (j == 0 ? 0
                   : sum([for (k=[0:j - 1]) camera_lens_items[k][2]])))
           each _head_neck_box([-s[0] / 2, lens_center - y / 2, z],
                               [s[0] / 2, lens_center + y / 2, z + s[2]])],
         [for (j=[0:len(camera_lens_connectors) - 1])
           let (s=camera_lens_connectors[j],
                x=len(s) > 5 && is_num(s[5]) ? s[5] : 0,
                y=camera_h / 2 - camera_lens_distance_from_top
                  + (j == 0 ? 0
                     : sum([for (k=[0:j - 1]) camera_lens_connectors[k][1]])))
           each _head_neck_box([x - s[0] / 2, y, camera_thickness],
                               [x + s[0] / 2, y + s[1], camera_thickness + s[2]])],
         _head_neck_box([-camera_module_ffc_zif_len / 2,
                         -camera_h / 2 + camera_module_socket_y_offset
                         - camera_module_ffc_zif_h, -camera_module_socket_thickness],
                        [camera_module_ffc_zif_len / 2,
                         -camera_h / 2 + camera_module_socket_y_offset
                         + camera_module_socket_base_h + camera_module_socket_upper_h, 0])),
       d=snap_bolt_d(head_camera_bolt_d),
       nut_h=find_nut_prop("height", d),
       bolt_l=ceil(head_front_thickness + camera_thickness + nut_h),
       r=max(find_bolt_head_prop("dia", d, "pan"),
             find_nut_prop("outer_dia", d) / cos(30)) / 2)
  concat([for (p=camera_points)
    [-p[0], center_y + p[1], head_front_thickness + camera_thickness - p[2]]],
    [for (x=[-spec[2][0] / 2, spec[2][0] / 2],
          y=[-spec[2][1] / 2, spec[2][1] / 2])
      each _head_neck_box([x - r, head_front_height / 2 - hole_y + y - r,
                           -find_bolt_head_h(d, "pan")],
                          [x + r, head_front_height / 2 - hole_y + y + r, bolt_l])]);

// Component envelopes in head_mount coordinates, including installed hardware.
function _head_neck_head_points() =
  let (frame=_head_neck_frame_points(),
       // Horn coordinates before head_mount's outer Y rotation.
       horn_r=max(servo_horn_center_ring_outer_dia / 2,
                  servo_horn_ending_arm_w / 2
                  + servo_horn_center_ring_outer_dia / 2 + servo_horn_len / 4),
       horn_pad=_head_neck_fastener_padding(servo_horn_screw_d),
       horn_center=head_tilt_axis_position(),
       horn=[for (p=_head_neck_box([-horn_r, -horn_r, -servo_horn_ring_height],
                                   [horn_r, horn_r, servo_horn_arm_z_offset
                                                    + servo_horn_arm_thickness], horn_pad))
         rotY([head_front_width / 2,
               -head_front_height / 2, 0]
              + rotY([horn_center[0], horn_center[1], head_horn_seat_thickness] +
                     rotZ(p, head_tilt_horn_angle()), 90), 180)],
       cameras=[for (i=[0:len(head_cameras) - 1])
         each _head_neck_camera_points(i)],
       ir_t=ir_case_face_thickness(),
       ir_pad=max(_head_neck_fastener_padding(ir_case_mount_bolt_d),
                  _head_neck_fastener_padding(ir_case_rail_bolt_dia, true)),
       ir_pos=head_ir_position(),
       ir=[for (p=_head_neck_box([0, -max(ir_case_mount_foot_thickness, ir_case_mount_bolt_length(head_bridge_thickness)),
                                  min(0, ir_t - max(ir_led_height, ir_led_light_detector_h) - 0.1)],
                                 [ir_case_width, max(ir_case_height, ir_led_board_len),
                                  max(ir_case_mount_foot_size()[1],
                                      ir_t + ir_case_carriage_h + ir_case_rail_h
                                      + ir_case_rail_protrusion_h)], ir_pad)) p + ir_pos])
  concat(frame, horn, cameras, ir);

// Bounding points relative to the tilt axis, before its Z rotation in the
// vertical plate's local frame (which becomes X rotation in assembly space).
function _head_neck_tilting_points() =
  let (c=head_tilt_axis_position())
  [for (p=_head_neck_head_points())
    rotY(p, 90) + [-c[0], head_front_height / 2 - c[1], -head_front_width / 2]];

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
  Encloses the fully populated assembly, including both cameras, the top-mounted IR
  case, servos, horns, and fasteners. Visibility toggles do not shrink
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

// Each component envelope retains _head_neck_box's eight-vertex ordering.
function _head_neck_box_edges() =
  [for (i=[0:7], step=[1, 2, 4])
    if (floor(i / step) % 2 == 0) [i, i + step]];

function _head_neck_clip_box(box, z_range) =
  concat([for (p=box)
    if (p[2] >= z_range[0] && p[2] <= z_range[1]) p],
    [for (edge=_head_neck_box_edges(), z=z_range)
      let (a=box[edge[0]], b=box[edge[1]], dz=b[2] - a[2])
      if (abs(dz) > 1e-10)
        let (t=(z - a[2]) / dz)
        if (t >= 0 && t <= 1) a + t * (b - a)]);

function _head_neck_periodic_angles(angle, range) =
  let (first=ceil((range[0] - angle) / 360),
       last=floor((range[1] - angle) / 360))
  first > last ? [] : [for (k=[first:last]) angle + 360 * k];

function _head_neck_pan_front(points, pan_range) =
  max(concat([0], [for (p=points)
    let (peak=atan2(p[0], p[1]),
         angles=concat(pan_range,
                       _head_neck_periodic_angles(peak, pan_range)))
    max([for (a=angles) p[0] * sin(a) + p[1] * cos(a)])]));

// On a clipped rotating convex profile, an extremum lies at an endpoint pose,
// a corner's orbit, or the perpendicular foot on an edge's supporting line.
// The latter covers stationary edge/height-plane intersections.
// Tilting component envelopes are convex XY profiles extruded along local Z;
// height clipping is independent of position along that extrusion.
function _head_neck_tilt_events(box, z_range, tilt_range) =
  let (feet=[for (edge=_head_neck_box_edges())
         let (a=box[edge[0]], b=box[edge[1]],
              v=[b[0] - a[0], b[1] - a[1]], vv=v * v)
         if (vv > 1e-10)
           let (t=-([a[0], a[1]] * v) / vv)
           if (t > 0 && t < 1) a + t * (b - a)])
  concat(tilt_range,
         [for (p=concat(box, feet), z=concat([0], z_range))
           let (r=norm([p[0], p[1]]))
           if (r > 1e-10 && abs(z) <= r)
             let (phase=atan2(p[1], p[0]), a=asin(z / r))
             for (angle=[a - phase, 180 - a - phase])
               each _head_neck_periodic_angles(angle, tilt_range)]);

function _head_neck_tilt_box_front(box, z_range, pan_range, tilt_range,
                                   pivot, offset) =
  let (local_z=z_range - [pivot[2] + offset[2], pivot[2] + offset[2]],
       angles=_head_neck_tilt_events(box, local_z, tilt_range))
  max([for (angle=angles)
    let (posed=[for (p=box)
      rotZ(pivot + rotX(rotZ(p, angle), 90), -90) + offset])
    _head_neck_pan_front(_head_neck_clip_box(posed, z_range), pan_range)]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_neck_swept_front_reach
  ─────────────────────────────────────────────────────────────────────────────
  Return the head envelope's forward reach within an obstacle's height range.

  **Parameters:**
  - `z_range`: Ordered `[bottom, top]` in millimeters relative to the pan
    mounting origin, matching `head_neck(..., center_pan_servo_slot=true)`.
  - `pan_range`: Ordered angular limits in degrees; defaults to `[-179, 179]`.
  - `tilt_range`: Ordered angular limits in degrees; defaults to the upward
    quarter-turn and the camera plate's contact with the neck upright.

  **Returns:** Maximum nonnegative Y across the continuous motion ranges,
  or zero when no envelope reaches the height interval or positive Y.

  **Behavior:** Uses the populated component envelopes of `head_neck_bounds`,
  clipped to the height interval before measuring their forward reach. This
  is a conservative packaging limit, not the minimum distance to a mesh.
  Ranges are absolute joint angles; preview pose and `$t` do not affect them.
  Explicit limits describe a geometric sweep; callers must keep them within
  mechanically reachable travel when using the result for packaging.
 */
function head_neck_swept_front_reach(z_range,
                                     pan_range=[-179, 179],
                                     tilt_range=[-90, head_neck_lower_tilt_stop()]) =
  assert(is_list(z_range) && len(z_range) == 2
         && is_num(z_range[0]) && is_num(z_range[1])
         && z_range[0] <= z_range[1], "z_range must be ordered numeric limits")
  assert(is_list(pan_range) && len(pan_range) == 2
         && is_num(pan_range[0]) && is_num(pan_range[1])
         && pan_range[0] <= pan_range[1]
         && pan_range[1] - pan_range[0] <= 360,
         "pan_range must be ordered numeric limits spanning at most 360 degrees")
  assert(is_list(tilt_range) && len(tilt_range) == 2
         && is_num(tilt_range[0]) && is_num(tilt_range[1])
         && tilt_range[0] <= tilt_range[1]
         && tilt_range[1] - tilt_range[0] <= 360,
         "tilt_range must be ordered numeric limits spanning at most 360 degrees")
  let (offset=_head_neck_pan_offset(),
       pivot=_head_neck_tilt_pivot(),
       fixed=[for (p=_head_neck_fixed_points()) rotZ(p, -90) + offset],
       moving=_head_neck_tilting_points())
  max(concat(
    [for (i=[0:8:len(fixed) - 1])
      _head_neck_pan_front(_head_neck_clip_box(
        [for (j=[0:7]) fixed[i + j]], z_range), pan_range)],
    [for (i=[0:8:len(moving) - 1])
      _head_neck_tilt_box_front([for (j=[0:7]) moving[i + j]],
                               z_range, pan_range, tilt_range, pivot, offset)]));

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
                      show_frame_bolts=show_frame_bolts,
                      show_frame_nuts=show_frame_nuts,
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
              head_centers = head_tilt_axis_position();

              rotate([0, 0, tilt_servo_rotation]) {
                translate([-head_centers[0],
                           head_front_height / 2 - head_centers[1],
                           -head_front_width / 2]) {
                  rotate([0, 90, 0]) {
                    head_mount(head_color=head_color,
                               show_frame_bolts=show_frame_bolts,
                               show_frame_nuts=show_frame_nuts,
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
                 show_frame_bolts=show_frame_bolts,
                 show_frame_nuts=show_frame_nuts,
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
                   show_frame_bolts=show_frame_bolts,
                   show_frame_nuts=show_frame_nuts,
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

if (show_bbox) {
  bounds = head_neck_bounds(pan_servo_rotation=pan_servo_rotation,
                            tilt_servo_rotation=tilt_servo_rotation,
                            center_pan_servo_slot=true);
  bbox = bounds[1] - bounds[0];

  // The size alone does not describe the assembly's asymmetric placement.
  #translate(bounds[0]) {
    cube(size=bbox);
  }
}
