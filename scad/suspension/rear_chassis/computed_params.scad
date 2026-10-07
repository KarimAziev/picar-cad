/**
  * Module: Rear-suspension, motor bracket and controls layout.
  * Native coordinates put the last holder row at Y=0; the joining edge is -Y.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../rc_params.scad>
include <rear_chassis_params.scad>

use <../../lib/plist.scad>
use <../../lib/functions.scad>
use <../../lipo_pack_case/multi_lipo_pack_case.scad>
use <../../lipo_pack_case/multi_lipo_pack_lid.scad>
use <../../motor_brackets/rc/util.scad>
use <../../panel_stack/control_panel.scad>
use <../../panel_stack/panel_stack.scad>
use <../../wago/wago_mounts.scad>
use <../../wago/wago_bracket.scad>
use <../front_chassis/layout_params.scad>
use <rear_equipment.scad>
use <rear_payload.scad>

function _rear_bounds_overlap(a, b) =
  a[0][0] < b[1][0] - 0.000001 && a[1][0] > b[0][0] + 0.000001
  && a[0][1] < b[1][1] - 0.000001 && a[1][1] > b[0][1] + 0.000001;

// Place independent panels close to the motor before reserving battery columns.
function _rear_panel_layout(specs,
                            motor,
                            keepout,
                            gap,
                            y_offset,
                            orientation,
                            i=0,
                            placed=[]) =
  i >= len(specs) ? placed :
  let (spec = specs[i],
       type = plist_get("type", spec, "stack"),
       to = plist_get("orientation", spec, orientation),
       size = panel_component_size(type, to),
       left = min(concat([keepout[0][0]], [for (p = placed) plist_get("bounds", p)[0][0]])),
       right = max(concat([keepout[1][0]], [for (p = placed) plist_get("bounds", p)[1][0]])),
       requested = plist_get("side", spec, "auto"),
       side = requested == "auto" ? (-left <= right ? "left" : "right") : requested,
       dist = plist_get("gap", spec, gap),
       x = side == "left" ? left - dist - size[0]/2 : right + dist + size[0]/2,
       y = (motor[0][1] + motor[1][1])/2 + plist_get("y_offset", spec, y_offset),
       bounds = [[x-size[0]/2, y-size[1]/2, 0], [x + size[0]/2, y + size[1]/2, size[2]]],
       panel = ["type", type,
                "side", side,
                "orientation", to,
                "pos", [x, y, 0],
                "size", size,
                "bounds", bounds,
                "height", panel_component_height(type),
                "bolt_spacing", panel_component_bolt_spacing(type, to)])
    assert(to == "wlh" || to == "lwh", "Rear panels must mount horizontally")
    assert((side == "left" || side == "right") && dist >= 0,
           "Invalid panel side/gap")
    _rear_panel_layout(specs,
                       motor,
                       keepout,
                       gap,
                       y_offset,
                       orientation,
                       i + 1,
                       concat(placed, [panel]));

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
  - `panels`: Independent panel plists (`type`, `side`, `orientation`, optional
    `gap` and `y_offset`); [] omits panels. `undef` selects the legacy single
    stack controlled by the scalar panel arguments above.
  - `power_case`: Raised battery case plist, or `undef` to omit it.
  - `lidar_plist`: `"case"` (default) uses the selected power case's `lid.lidar`.
    An explicit plist overrides the sensor; explicit `undef` omits it.
  - `min_width`: Width required by adjoining chassis sections; zero measures
    the rear section alone. The default includes the front hardware.
  - `control_outside`: Move standalone controls toward the suspension within
    the existing full-width deck. Prefer clearing the whole panel; if it does
    not fit, clear only the levers and allow the low panel beneath the case.
    Per-panel `outside_case` overrides this setting. If even the levers cannot
    clear, the overlapping hardware still contributes to the case height.

  - `wago_mounts`: Optional Wago mounting specs for wago_chassis_mounts.
    Brackets may extend the joining edge; battery mounting holes stay fixed.
  - `equipment`: Independent deck component plists; [] leaves both zones empty.
  - `equipment_edge_margin`: Inset from the existing deck edges and taper.
  - `equipment_gap`: Separation from hardware and clearance beneath the case.
    Equipment never changes chassis dimensions or the battery mounting height.
  - `edge_pad`: Deck material outside mounted hardware and battery supports.
    The raised case and lid may overhang the deck.

  **Returns:**
  A plist in holder-row coordinates, with Z=0 below the plate. `size` and
  `bounds` describe the plate only; `min_y` is its flat joining edge and `join_w`
  its width there. `motor_pos`, `motor_rotation`, and `motor_anchor` are shared
  by the solid bracket and its cutters. The bracket is rotated 180 degrees so
  the drive connection faces the suspension; its shaft stays on X=0.
  `panels` contains each resolved panel's type, position, orientation and bounds.
  `power_case` contains the generated battery mount and height, or undef.
  Legacy `panel_*` entries alias the first panel when present. Auto chooses the
  smaller occupied side (left on a tie). `candidate_half_widths` retains the
  legacy single-panel width estimates, without the raised payload or later panels.
 */
function rear_chassis_layout(bracket=gearmotor_bracket_compute_params(motor_plist),
                             side=panel_stack_side,
                             orientation=panel_stack_orientation,
                             panel_gap=panel_stack_side_x_dist_from_motor,
                             panel_y_offset=panel_stack_y_offset,
                             motor_dist=rc_motor_maintenance_hole_dist,
                             panels=rear_panel_specs,
                             power_case=rear_power_case_plist,
                             lidar_plist="case",
                             min_width=front_chassis_required_width(),
                             control_outside=rear_control_outside_case,
                             wago_mounts=rear_wago_mounts,
                             equipment=rear_equipment_specs,
                             equipment_edge_margin=rear_equipment_edge_margin,
                             equipment_gap=rear_equipment_gap,
                             edge_pad=rear_chassis_edge_pad) =
  assert(side == "auto" || side == "left" || side == "right",
         "panel_stack_side must be auto, left or right")
  assert(orientation == "wlh" || orientation == "lwh",
         "A chassis-mounted panel stack must use wlh or lwh")
  assert(is_undef(panels) || is_list(panels),
         "panels must be a list of panel plists")
  assert(is_num(min_width) && min_width >= 0,
         "Minimum chassis width must be nonnegative")
  assert(is_num(edge_pad) && edge_pad >= 0,
         "Rear chassis edge padding must be nonnegative")
  assert(rear_control_case_gap >= 0, "Control-to-case gap must be nonnegative")
  assert(rear_power_case_clearance >= 0,
         "Battery mounting clearance must be nonnegative")
  let (case_lid = is_undef(power_case) ? [] : plist_get("lid", power_case, []),
       lidar = lidar_plist == "case" ? plist_get("lidar", case_lid) : lidar_plist,
       d = rear_suspension_chassis_bolt_bore_d,
       r = d / 2,
       suspension_pad = rear_suspension_chassis_bolt_pad,
       pad = edge_pad,
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
       panel_specs = is_undef(panels)
                     ? [["type", "stack",
                         "side", side,
                         "orientation", orientation]] : panels,
       close_panels = _rear_panel_layout(panel_specs, motor_bounds, motor_bounds,
                                         panel_gap, panel_y_offset, orientation),
       mount = rear_power_case_mount(power_case,
                                     motor_bounds=motor_bounds,
                                     y_offset=rear_power_case_y_offset,
                                     panels=close_panels),
       case_size = is_undef(mount) ? [0, 0, 0] : plist_get("size", mount),
       rail_enabled = !is_undef(mount)
                      && plist_get("enabled", plist_get("rail_props", multi_lipo_pack_props(plist_get("plist", mount)))),
       lid_props = !rail_enabled ? undef
                   : multi_lipo_pack_lid_props(rear_power_lid_plist(plist_get("plist", mount), lidar)),
       lid_size = is_undef(lid_props) ? [0, 0, 0] : plist_get("size", lid_props),
       overhead = is_undef(mount) ? undef
                  : [plist_get("pos", mount) - [max(case_size[0], lid_size[0])/2,
                                                max(case_size[1], lid_size[1])/2, 0],
                     plist_get("pos", mount) + [max(case_size[0], lid_size[0])/2,
                                                max(case_size[1], lid_size[1])/2, 0]],
       clearance_bounds = is_undef(overhead) ? undef
                          : [overhead[0] - [rear_control_case_gap, rear_control_case_gap, 0],
                             overhead[1] + [rear_control_case_gap, rear_control_case_gap, 0]],
       transition_start = bh_2 - spacing_2[1] / 2 - r - suspension_pad,
       // Reserve the existing taper; relocating controls must not shorten it.
       fixed_bounds = concat([motor_bounds], is_undef(overhead) ? [] : [overhead],
                             [for (p = close_panels) plist_get("bounds", p)]),
       deck_end = max(transition_start - rear_suspension_chassis_transition_len,
                      max([for (b = fixed_bounds) b[1][1]]) + pad),
       panel_layout = [for (i = [0:1:len(close_panels)-1])
         let (p = close_panels[i], b = plist_get("bounds", p),
              control = plist_get("type", p) == "control",
              regions = control ? control_panel_clearance_regions(plist_get("orientation", p))
                        : [],
              outside = !is_undef(mount) && control
                        && plist_get("outside_case", panel_specs[i], control_outside),
              pos = plist_get("pos", p),
              half_y = plist_get("size", p)[1]/2,
              max_y = deck_end - pad - half_y,
              full_y = outside ? max(pos[1], overhead[1][1] + rear_control_case_gap + half_y) : pos[1],
              lever_y = outside ? max(pos[1], overhead[1][1] + rear_control_case_gap
                                              - min([for (j = [1:len(regions)-1]) regions[j][0][1]])) : pos[1],
              y = !outside ? pos[1] : full_y <= max_y ? full_y : min(max_y, lever_y),
              shift = [0, y - pos[1], 0],
              new_pos = pos + shift,
              new_bounds = [b[0] + shift, b[1] + shift],
              clearances = control
                           ? [for (region = regions) [region[0] + new_pos, region[1] + new_pos]]
                           : [[new_bounds[0], [new_bounds[1][0], new_bounds[1][1], plist_get("height", p)]]])
         plist_merge(p, ["pos", new_pos,
                         "bounds", new_bounds,
                         "clearance_regions", clearances,
                         "outside_case", outside])],
       first = len(panel_layout) > 0 ? panel_layout[0] : [],
       resolved_side = plist_get("side", first),
       panel_size = plist_get("size", first, [0, 0, 0]),
       occupied_h = max(concat([rear_motor_clearance_height(bracket)],
                               [for (p = panel_layout, region = plist_get("clearance_regions", p))
                                 if (is_undef(clearance_bounds) || _rear_bounds_overlap(region, clearance_bounds))
                                     region[1][2]])),
       target_h = chassis_thickness + occupied_h + rear_power_case_clearance,
       mount_z = is_undef(mount) ? 0
                 : multi_lipo_pack_mount_height(plist_get("plist", mount), target_h, chassis_thickness),
       payload = is_undef(mount) ? undef
                 : plist_merge(mount, ["target_h", target_h,
                                       "mount_z", mount_z,
                                       "standoff_h", mount_z - chassis_thickness,
                                       "clearance_height", occupied_h,
                                       "lidar", lidar,
                                       "lid_size", lid_size]),
       wagos = wago_chassis_mounts(wago_mounts, payload,
                                   concat([motor_bounds,
                                           [[-rear_chassis_maintenance_hole_d/2,
                                             maintenance_y-rear_chassis_maintenance_hole_d/2, 0],
                                            [rear_chassis_maintenance_hole_d/2,
                                             maintenance_y + rear_chassis_maintenance_hole_d/2, 0]]],
                                          [for (p = panel_layout) plist_get("bounds", p)]), chassis_thickness),
       deck_bounds = concat([for (w = wagos) plist_get("bounds", w)],
                            [motor_bounds], [for (p = panel_layout) plist_get("bounds", p)]),
       component_bounds = concat(deck_bounds,
                                 is_undef(mount) ? [] : [overhead]),
       component_min_y = min([for (b = component_bounds) b[0][1]]),
       component_max_y = max([for (b = component_bounds) b[1][1]]),
       suspension_half_w = max(spacing_1[0], spacing_2[0]) / 2 + r + suspension_pad,
       ear_x = suspension_half_w + r,
       ear_start_y = -r - suspension_pad,
       ear_end_y = bh_1 + spacing_1[1] / 2 + r + suspension_pad,
       candidate_half_widths = [for (reach = side_widths)
         max(suspension_half_w,
             max(side_widths) + pad,
             reach + panel_gap + panel_size[0] + pad)],
       support_half_w = is_undef(mount) ? 0
                        : max([for (p = plist_get("mount_holes", mount)) abs(p[0])])
                          + plist_get("radius", mount) + pad,
       max_half_w = max(concat([suspension_half_w, min_width / 2,
                                support_half_w],
                               [for (b = deck_bounds)
                                 max(abs(b[0][0]), abs(b[1][0])) + pad])),
       min_y = min(component_min_y,
                   maintenance_y - rear_chassis_maintenance_hole_d / 2) - pad,
       max_y = r + suspension_pad,
       holder_max_x = rear_suspension_holder_bolt_spacing_x / 2 + d + suspension_pad,
       half_w = max(ear_x, max_half_w, holder_max_x),
       transition_y_start = transition_start,
       transition_y_end = max(transition_y_start - rear_suspension_chassis_transition_len,
                              component_max_y + pad),
       size = [half_w * 2, max_y - min_y, chassis_thickness])
  echo("case_size", case_size, "mount", mount)
  assert(ear_start_y > ear_end_y,
         "Holder-to-bulkhead gap cannot contain the ear")
  assert(rear_suspension_chassis_transition_len > 0
         && transition_y_start > transition_y_end,
         "Motor/panel placement overlaps the suspension transition; move it toward -Y")
  let (base_layout = ["bulkhead_1_y", bh_1,
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
                      "panels", panel_layout,
                      "wago_mounts", wagos,
                      "power_case", payload,
                      "clearance_height", occupied_h,
                      "panel_pos", plist_get("pos", first),
                      "panel_anchor", [0, 0, 1],
                      "panel_orientation", plist_get("orientation", first),
                      "panel_size", panel_size,
                      "panel_bounds", plist_get("bounds", first),
                      "candidate_half_widths", candidate_half_widths,
                      "max_half_w", max_half_w])
  assert(equipment_edge_margin >= rear_chassis_corner_r,
         "Equipment edge margin must cover the rounded deck corners")
  plist_merge(base_layout,
              ["equipment_zones", rear_equipment_zones(base_layout,
                                                       equipment_edge_margin, equipment_gap),
               "equipment_gap", equipment_gap,
               "equipment", rear_equipment_layout(equipment, base_layout,
                                                  equipment_edge_margin, equipment_gap)]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_chassis_size
  ─────────────────────────────────────────────────────────────────────────────

  Return the plate envelope `[width, length, thickness]`, excluding hardware.

  **Parameters:**
  - `layout`: Resolved rear layout; pass the same value used for rendering.
 */
function rear_suspension_chassis_size(layout=rear_chassis_layout()) =
  plist_get("size", layout);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_joint_y_bounds
  ─────────────────────────────────────────────────────────────────────────────
  Locate the joint independently of the deck's outer taper.

  **Parameters:**
  - `layout`: Resolved rear layout shared by both mating plates.

  **Returns:**
  `[min_y, max_y]` of the joint, from chassis root to suspension-mount root.
 */
function rear_suspension_joint_y_bounds(layout=rear_chassis_layout()) =
  let (lower_end = rear_suspension_mount_recess_end_y(layout),
       center = lower_end - rear_suspension_joint_pin_l / 2
                - front_chassis_joint_pin_end_clearance
                - suspension_chassis_joint_bore_pin_land,
       start = center + rear_suspension_chassis_transition_len / 2,
       end = center - rear_suspension_chassis_transition_len / 2)
  assert(end > plist_get("min_y", layout), "Joint must fit within the deck")
  assert(end - plist_get("motor_bounds", layout)[1][1] >= 2,
         "Rear suspension joint needs 2 mm clearance from the motor bracket")
  [end, start];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_mount_recess_end_y
  ─────────────────────────────────────────────────────────────────────────────
  Return the motor-side end of the lowered suspension footprint.
  **Parameters:** `layout`: Resolved rear layout.
 */
function rear_suspension_mount_recess_end_y(layout=rear_chassis_layout()) =
  plist_get("rect_y", layout) - rear_suspension_arm_pad_rect_slot_size[1] / 2
  - suspension_chassis_mount_clearance;

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_joint_width
  ─────────────────────────────────────────────────────────────────────────────
  Return the joint width between the wheel-relief edges, in mm.
  **Parameters:** `layout`: Resolved rear layout.
 */
function rear_suspension_joint_width(layout=rear_chassis_layout()) =
  plist_get("join_w", layout) - 2 * rear_chassis_wheel_relief[0];

// Transform an XY hole center and preserve its outer cutter diameter.
function _rear_hole_position(p, d, pos, rotation=0) =
  [pos[0] + p[0] * cos(rotation) - p[1] * sin(rotation),
   pos[1] + p[0] * sin(rotation) + p[1] * cos(rotation), d];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_chassis_mount_holes
  ─────────────────────────────────────────────────────────────────────────────
  Collect deck mounting circles including their counterbores and countersinks.
  **Parameters:**
  - `layout`: Resolved rear layout in native holder-row coordinates.
  **Returns:** `[x, y, d]` centers and outer cutter diameters, in millimeters.
  Includes motor/gearbox, panels, battery supports, Wagos and deck equipment.
  Joint fasteners, suspension-mount holes and service openings are separate
  interfaces and are not part of this mounting pattern.
 */
function rear_chassis_mount_holes(layout=rear_chassis_layout()) =
  let (bracket = plist_get("bracket", layout),
       motor_pos = plist_get("motor_pos", layout),
       motor_rotation = plist_get("motor_rotation", layout)[2],
       payload = plist_get("power_case", layout))
  concat([for (p = plist_get("mount_hole_positions", bracket))
           _rear_hole_position(p,
                               max(plist_get("bolt_d", bracket),
                                   gearbox_bracket_chassis_cbore_d),
                               motor_pos, motor_rotation)],
         [for (p = plist_get("gearbox_hole_positions", bracket))
           _rear_hole_position(p,
                               max(plist_get("mount_bolt_d", bracket),
                                   plist_get("mount_cbore_d", bracket)),
                               motor_pos, motor_rotation)],
         [for (panel = plist_get("panels", layout), x = [-1, 1], y = [-1, 1])
           let (span = plist_get("bolt_spacing", panel))
           _rear_hole_position([x * span[0] / 2, y * span[1] / 2],
                               max(panel_stack_bolt_dia,
                                   panel_stack_bolt_cbore_dia),
                               plist_get("pos", panel))],
         is_undef(payload) ? [] :
         [for (p = plist_get("mount_holes", payload))
           let (pl = plist_get("plist", payload))
           [p[0], p[1], max(plist_get("bolt_d", pl), plist_get("bore_d", pl))]],
         [for (mount = plist_get("wago_mounts", layout, []))
           let (props = wago_bracket_props(plist_get("bracket", mount, [])),
                size = plist_get("size", props))
           for (p = plist_get("mount_holes", props))
             _rear_hole_position(p - [size[0], size[1]] / 2,
                                 plist_get("hole_d", props),
                                 plist_get("pos", mount),
                                 plist_get("rotation", mount, 0))],
         [for (item = plist_get("equipment", layout, []))
           let (props = plist_get("props", item),
                kind = plist_get("kind", item),
                perf = kind == "perf_board",
                span = plist_get("bolt_spacing", props),
                offset = plist_get("mount_pos", props, [0, 0, 0]),
                points = perf
                    ? plist_get("bolt_positions", props)
                    : [for (x = [-1, 1], y = span[1] == 0 ? [0] : [-1, 1])
                        [offset[0] + x * span[0] / 2,
                         offset[1] + y * span[1] / 2]],
                d = plist_get("bolt_d", props),
                bore_d = perf
                    ? plist_get("slot_bore_d", plist_get("component", props))
                    : plist_get("bore_d", props, 2 * d))
           for (p = points)
             _rear_hole_position(p, max(d + (perf ? 0 : 0.2), bore_d),
                                 plist_get("pos", item),
                                 plist_get("rotation", item))]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_chassis_holes_bounds
  ─────────────────────────────────────────────────────────────────────────────
  Return sorted bounding-box corners of the deck mounting circles.
  **Parameters:**
  - `layout`: Resolved rear layout in native holder-row coordinates.
  - `pad`: Nonnegative material margin outside each cutter, in millimeters.
  **Returns:** Four `[x, y, d]` corners per mounting hole, sorted by ascending Y,
  then ascending X. XY includes the outer cutter radius and `pad`; `d` remains
  the counterbore/countersink or through-hole diameter without padding.
  These are bounds for outline construction, not ordered polygon vertices.
 */
function rear_chassis_holes_bounds(layout=rear_chassis_layout(), pad=0) =
  assert(is_num(pad) && pad >= 0, "Hole boundary padding must be nonnegative")
  let (corners = [for (p = rear_chassis_mount_holes(layout),
                      x = [-1, 1], y = [-1, 1])
         [p[0] + x * (p[2] / 2 + pad),
          p[1] + y * (p[2] / 2 + pad), p[2]]])
  sort_by_idx(sort_by_idx(corners, idx=0), idx=1);

function rear_chassis_outline_points(layout=rear_chassis_layout()) =

  let (corner_r = rear_chassis_corner_r,
       join_y = rear_suspension_joint_y_bounds(layout),
       join_w = rear_suspension_joint_width(layout),
       join_y0 = join_y[0],
       join_y1 = join_y[1],
       min_y = plist_get("min_y", layout),
       max_half_w = plist_get("max_half_w", layout),
       holes_bounds = rear_chassis_holes_bounds(layout))
  [[-corner_r, join_y1],
   [join_w / 2, join_y1],
   [max_half_w, join_y0],
   [max_half_w, min_y],
   [-corner_r, min_y]];
