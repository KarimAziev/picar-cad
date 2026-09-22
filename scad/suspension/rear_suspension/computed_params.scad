/**
  * Module: Rear-suspension, motor bracket and controls layout.
  * Native coordinates put the last holder row at Y=0; the joining edge is -Y.
  */
include <../../steering_params.scad>
include <../computed.scad>
include <rear_suspension_params.scad>

use <../../lib/plist.scad>
use <../../motor_brackets/rc/gearbox_bracket.scad>
use <../../panel_stack/panel_stack.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_layout
  ─────────────────────────────────────────────────────────────────────────────

  Compute the symmetric plate and the components mounted beside its shaft axis.

  **Parameters:**
  - `bracket`: Result of `gearmotor_bracket_compute_params()`.
  - `side`: `"left"` (-X), `"right"` (+X), or `"auto"` in chassis coordinates.
  - `orientation`: Panel mounting orientation: `"wlh"` or `"lwh"`.
  - `panel_gap`: Edge-to-edge gap from the bracket to the panel footprint.
  - `panel_y_offset`: Shift the panel along chassis Y from the bracket's center.
  - `motor_dist`: Gap along Y from the drive connection to the maintenance-hole
    center; zero aligns the sleeve's outer end with that center.

  **Returns:**
  A plist in holder-row coordinates, with Z=0 below the plate. `size` and
  `bounds` describe the plate only; `min_y` is its flat joining edge and `join_w`
  its width there. `motor_pos`, `motor_rotation`, and `motor_anchor` are shared
  by the solid bracket and its cutters. The bracket is rotated 180 degrees so
  the drive connection faces the suspension; its shaft stays on X=0.
  `panel_pos`, `panel_anchor`, and `panel_orientation` similarly locate the
  controls and their holes. Auto chooses the shorter bracket side after this
  rotation (left on a tie). `candidate_half_widths` reports `[left, right]`
  symmetric plate half-widths including the panel gap and perimeter margin.
 */
function rear_suspension_layout(bracket=gearmotor_bracket_compute_params(motor_plist),
                                side=panel_stack_side,
                                orientation=panel_stack_orientation,
                                panel_gap=panel_stack_side_x_dist_from_motor,
                                panel_y_offset=panel_stack_y_offset,
                                motor_dist=rc_motor_maintenance_hole_dist) =
  assert(side == "auto" || side == "left" || side == "right",
         "panel_stack_side must be auto, left or right")
  assert(orientation == "wlh" || orientation == "lwh",
         "A chassis-mounted panel stack must use wlh or lwh")
  assert(panel_gap >= 0 && motor_dist >= 0,
         "Panel gap and drive-connection distance must be nonnegative")
  let (d = rear_suspension_chassis_bolt_bore_d,
       r = d / 2,
       pad = rear_suspension_chassis_bolt_pad,
       spacing_1 = rear_bulkhead_bolt_spacing_1,
       spacing_2 = rear_bulkhead_bolt_spacing_2,
       bh_1 = -d - rear_bulkhead_bolt_spacing_1_holder_dist,
       bh_2 = bh_1 - spacing_1[1] / 2 - d
       - rear_bulkhead_bolt_spacing_1_2_edge_dist - spacing_2[1] / 2,
       rect_y = bh_2 - spacing_2[1] / 2 - r
       - rear_suspension_arm_pad_bulkhead_slot_dist
       - rear_suspension_arm_pad_rect_slot_size[1] / 2,
       maintenance_y = rect_y - rear_suspension_arm_pad_rect_slot_size[1] / 2
       - rear_chassis_maintenance_hole_arm_pad_dist
       - rear_chassis_maintenance_hole_d / 2,
       bracket_bounds = plist_get("bounds", bracket),
       motor_y = maintenance_y - motor_dist + plist_get("drive_end_y", bracket),
       motor_bounds = [[-bracket_bounds[1][0], motor_y - bracket_bounds[1][1], 0],
                       [-bracket_bounds[0][0], motor_y - bracket_bounds[0][1],
                        bracket_bounds[1][2]]],
       side_widths = [-motor_bounds[0][0], motor_bounds[1][0]],
       resolved_side = side == "auto"
       ? (side_widths[0] <= side_widths[1] ? "left" : "right")
       : side,
       panel_size = panel_stack_oriented_size(orientation),
       panel_x = resolved_side == "left"
       ? motor_bounds[0][0] - panel_gap - panel_size[0] / 2
       : motor_bounds[1][0] + panel_gap + panel_size[0] / 2,
       panel_y = (motor_bounds[0][1] + motor_bounds[1][1]) / 2 + panel_y_offset,
       panel_min_y = panel_y - panel_size[1] / 2,
       panel_max_y = panel_y + panel_size[1] / 2,
       suspension_half_w = max(spacing_1[0], spacing_2[0]) / 2 + r + pad,
       ear_x = suspension_half_w + r,
       ear_start_y = -r - pad,
       ear_end_y = bh_1 + spacing_1[1] / 2 + r + pad,
       candidate_half_widths = [for (reach = side_widths)
           max(suspension_half_w,
               max(side_widths) + pad,
               reach + panel_gap + panel_size[0] + pad)],
       max_half_w = max(candidate_half_widths[resolved_side == "left" ? 0 : 1],
                        front_middle_chassis_max_w / 2),
       min_y = min(motor_bounds[0][1], panel_min_y,
                   maintenance_y - rear_chassis_maintenance_hole_d / 2) - pad,
       max_y = r + pad,
       holder_max_x = rear_suspension_holder_bolt_spacing_x / 2 + d + pad,
       half_w = max(ear_x, max_half_w, holder_max_x),
       transition_y_start = bh_2 - spacing_2[1] / 2 - r - pad,
       transition_y_end = max(transition_y_start - rear_suspension_chassis_transition_len,
                              max(motor_bounds[1][1], panel_max_y) + pad),
       size = [half_w * 2, max_y - min_y, front_chassis_thickness])
       assert(ear_start_y > ear_end_y,
              "Holder-to-bulkhead gap cannot contain the ear")
       assert(rear_suspension_chassis_transition_len > 0
              && transition_y_start > transition_y_end,
              "Motor/panel placement overlaps the suspension transition; move it toward -Y")
       ["bulkhead_1_y", bh_1,
        "bulkhead_2_y", bh_2,
        "rect_y", rect_y,
        "maintenance_y", maintenance_y,
        "min_y", min_y,
        "max_y", max_y,
        "join_w", max_half_w * 2,
        "suspension_w", suspension_half_w * 2,
        "ear_x", ear_x,
        "ear_start_y", ear_start_y,
        "ear_end_y", ear_end_y,
        "transition_y_start", transition_y_start,
        "transition_y_end", transition_y_end,
        "size", size,
        "bounds", [[-half_w, min_y, 0], [half_w, max_y, size[2]]],
        "bracket", bracket,
        "motor_pos", [0, motor_y, 0],
        "motor_rotation", [0, 0, 180],
        "motor_anchor", [0, 0, 1],
        "motor_bounds", motor_bounds,
        "motor_side_widths", side_widths,
        "drive_connection_y", maintenance_y - motor_dist,
        "panel_side", resolved_side,
        "panel_pos", [panel_x, panel_y, 0],
        "panel_anchor", [0, 0, 1],
        "panel_orientation", orientation,
        "panel_size", panel_size,
        "panel_bounds", [[panel_x - panel_size[0] / 2, panel_min_y, 0],
                         [panel_x + panel_size[0] / 2, panel_max_y, panel_size[2]]],
        "candidate_half_widths", candidate_half_widths,
        "max_half_w", max_half_w];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_chassis_size
  ─────────────────────────────────────────────────────────────────────────────

  Return the plate envelope `[width, length, thickness]`, excluding hardware.

  **Parameters:**
  - `layout`: Resolved rear layout; pass the same value used for rendering.
 */
function rear_suspension_chassis_size(layout=rear_suspension_layout()) =
  plist_get("size", layout);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_outline_points
  ─────────────────────────────────────────────────────────────────────────────

  Derive the right half-outline from the suspension lands and component bounds.

  **Parameters:**
  - `layout`: Resolved rear layout.

  **Returns:** Nonduplicated polygon points; mirror across X for the full plate.
 */
function rear_suspension_outline_points(layout=rear_suspension_layout()) =
  let (r = rear_suspension_chassis_bolt_bore_d / 2,
       pad = rear_suspension_chassis_bolt_pad,
       corner_r = rear_suspension_chassis_corner_r,
       holder_x = rear_suspension_holder_bolt_spacing_x / 2 + r,
       half_w = plist_get("suspension_w", layout) / 2,
       max_y = plist_get("max_y", layout),
       min_y = plist_get("min_y", layout),
       max_half_w = plist_get("max_half_w", layout))
  [[-corner_r, max_y],
   [holder_x, max_y],
   [holder_x + r + pad, 0],
   [half_w - pad, -r],
   [plist_get("ear_x", layout), plist_get("ear_start_y", layout)],
   [plist_get("ear_x", layout), plist_get("ear_end_y", layout)],
   [half_w, plist_get("bulkhead_1_y", layout) + rear_bulkhead_bolt_spacing_1[1] / 2 + r],
   [half_w, plist_get("transition_y_start", layout)],
   [max_half_w, plist_get("transition_y_end", layout)],
   [max_half_w, min_y],
   [-corner_r, min_y]];
