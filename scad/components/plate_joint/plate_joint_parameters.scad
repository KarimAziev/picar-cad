/**
  * Module: Plate joint parameter resolution.
  *
  * Standalone plate joint; dimensions are in millimeters.
  */

use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../placeholders/bolt.scad>

function _plate_joint_percent_valid(s) =
  let (n = len(s),
       end = n > 0 && s[n - 1] == "%" ? n - 1 : n,
       chars = end > 0 ? [for (i = [0:end - 1]) s[i]] : [],
       dots = [for (c = chars) if (c == ".") c],
       digits = [for (c = chars) if (c >= "0" && c <= "9") c])
  len(digits) > 0 && len(dots) <= 1 && len(digits) + len(dots) == end;

/**
  ─────────────────────────────────────────────────────────────────────────────
  plate_joint_dimension
  ─────────────────────────────────────────────────────────────────────────────

  Resolve an omitted, numeric, or percentage dimension.

  **Parameters:**
  - `value`: Number, non-negative decimal percentage string (optional % suffix), or undef.
  - `total`: Reference dimension used for strings.
  - `automatic`: Value used when omitted.
  - `name`: Parameter label for validation errors.

  **Returns:**
  A non-negative number in millimeters.
 */
function plate_joint_dimension(value, total, automatic, name="dimension") =
  assert(is_undef(value) || is_num(value) || is_string(value),
         str(name, " must be numeric, a percentage string, or undef"))
  assert(!is_string(value) || _plate_joint_percent_valid(value),
         str(name, " must be a non-negative decimal percentage"))
  let (num = is_undef(value) ? automatic
       : is_string(value) ? percent_to_mm(parse_percent(value), total) : value)
  assert(is_num(num) && num >= 0,
         str(name, " must resolve to a non-negative number"))
  num;

/**
  ─────────────────────────────────────────────────────────────────────────────
  plate_joint_parameters
  ─────────────────────────────────────────────────────────────────────────────

  Resolve and validate the shared dimensions for both joint halves.

  **Parameters:**
  - `plate_h`: Required positive plate thickness; numeric millimeters.
  - `bolt_d`: Required positive bolt through-hole diameter; numeric millimeters.
  - `w`: Envelope width along X; omitted/undef calculates space for rail, pins and side bolts.
  - `l`: Required positive envelope length along Y; numeric millimeters.
  - `rail_w`: Rail width; percent of `w`; auto targets 70% of w, reducing it when side bolts need room.
  - `bolt_spacing_center`: Outermost bolt-center span; percent of `w`; auto centers the outer bolts in the side strips: (w + rail_w)/2.
  - `bolt_n_center`: Integer bolt count; auto fits up to three. Zero disables bolts; one centers a bolt.
  - `base_h`: Upper base thickness; percent of `plate_h`; auto is half the height left by the rail.
  - `angle`: Numeric flank angle from vertical in degrees; default 20 degrees, as in the front joint.
  - `rail_h`: Rail height; percent of `plate_h`; auto is half the plate thickness.
  - `rail_corner_r`: Rail corner radius; percent of `rail_h`; default 0.4 mm, as in the front joint.
  - `dovetail_rib`: Use the double-taper rib; false selects a single dovetail.
  - `edge_land`: Relief land; percent of `rail_h`; default 0.45 mm.
  - `relief_depth`: Relief depth; percent of `rail_h`; auto is zero (disabled).
  - `clearance`: Female profile offset; percent of `bolt_d`; default 0.4 mm, as in the front joint.
  - `axial_clearance`: Male free-tip setback; percent of `l`; auto equals `clearance`.
  - `boolean_overlap`: Parent attachment overlap; percent of `plate_h`; default 0.02 mm, as in the front joint.
  - `wall`: Material reserved beside a side-bolt cutter during automatic sizing; percent of bolt_d; default 2 mm.
  - `bolt_bore_d`: Counterbore diameter; percent of `bolt_d`; auto uses the selected bolt head diameter.
  - `bolt_bore_h`: Counterbore depth; percent of `plate_h`; auto uses the selected bolt head height.
  - `bolt_no_bore`: Disable counterbores while retaining through holes; default true.
  - `include_pin_holes`: Cut two longitudinal reinforcing-pin passages in either half.
  - `pin_d`: Pin diameter; percent of `rail_h`; default 3.1 mm.
  - `pin_l`: Pin cutter length; percent of `l`; default 41 mm.
  - `pin_spacing`: Pin-center span; percent of `rail_w`; auto is 67.5% of rail width, as in the front joint.
  - `pin_z`: Pin-center height; percent of `plate_h`; auto centers it in the combined base-plus-rail height, before flipping.
  - `pin_use_pad`: Use a pin-shaped passage with an end flat instead of a sag-compensated hole.
  - `pin_pad_l`: Pin flat length; percent of `pin_l`; default 5.5 mm.
  - `pin_pad_w`: Pin flat thickness; percent of `pin_d`; default 2.5 mm.
  - `pin_direction`: Pin cutter direction along Y: -1 or 1.
  - `pin_center`: Center the cutter at Y=-l/2; false starts at Y=0.
  - `pin_pad_side`: End flat side: "bottom" or "top", following the source pin convention.
  - `pin_compensation`: Sag compensation width; percent of `pin_d`; default 0.4 mm, from sag_compensated_hole().
  - `bolt_head_type`: Bolt head style for optional recess sizing and display; default "socket".
  - `bolt_cut_overlap`: Bolt cutter extension; percent of plate_h; default 0.1 mm from counterbore().

  **Returns:**
  A flat property list read with `plist_get(key, params)`. It contains the
  resolved input dimensions plus `bolt_xs`, `rail_neck_w`, and `bottom_h`.
  Counts, angles, booleans, and direction selectors do not accept percentages.
  Explicit dimensions are preserved. Optional undef values use defaults.
 */
function plate_joint_parameters(plate_h,
                                bolt_d,
                                w,
                                l,
                                rail_w,
                                bolt_spacing_center,
                                bolt_n_center,
                                base_h,
                                angle,
                                rail_h,
                                rail_corner_r,
                                dovetail_rib=true,
                                edge_land,
                                relief_depth,
                                clearance,
                                axial_clearance,
                                boolean_overlap,
                                wall,
                                bolt_bore_d,
                                bolt_bore_h,
                                bolt_no_bore=true,
                                include_pin_holes=false,
                                pin_d,
                                pin_l,
                                pin_spacing,
                                pin_z,
                                pin_use_pad=false,
                                pin_pad_l,
                                pin_pad_w,
                                pin_direction=-1,
                                pin_center=true,
                                pin_pad_side="bottom",
                                pin_compensation,
                                bolt_head_type="socket",
                                bolt_cut_overlap) =
  assert(is_num(plate_h) && plate_h > 0,
         "plate_h is required and must be positive")
  assert(is_num(bolt_d) && bolt_d > 0,
         "bolt_d is required and must be positive")
  assert(is_undef(w) || (is_num(w) && w > 0),
         "w must be positive when specified")
  assert(is_num(l) && l > 0, "l is required and must be positive")
  let (dovetail_rib = with_default(dovetail_rib, true),
       bolt_no_bore = with_default(bolt_no_bore, true),
       include_pin_holes = with_default(include_pin_holes, false),
       pin_use_pad = with_default(pin_use_pad, false),
       pin_center = with_default(pin_center, true),
       pin_direction = with_default(pin_direction, -1),
       pin_pad_side = with_default(pin_pad_side, "bottom"),
       bolt_head_type = with_default(bolt_head_type, "socket"))
  assert(is_undef(angle) || (is_num(angle) && angle >= 0 && angle < 90),
         "angle must be numeric in [0, 90)")
  let (rh = plate_joint_dimension(rail_h, plate_h, plate_h / 2, "rail_h"),
       bh = plate_joint_dimension(base_h, plate_h, (plate_h - rh) / 2, "base_h"),
       bottom = plate_h - bh - rh,
       margin = plate_joint_dimension(wall, bolt_d, 2, "wall"),
       gap = plate_joint_dimension(clearance, bolt_d, 0.4, "clearance"),
       axial = plate_joint_dimension(axial_clearance, l, gap, "axial_clearance"),
       eps = plate_joint_dimension(boolean_overlap, plate_h, 0.02, "boolean_overlap"),
       head_d = find_bolt_head_d(bolt_d, bolt_head_type),
       head_h = find_bolt_head_h(bolt_d, bolt_head_type),
       bd = plate_joint_dimension(bolt_bore_d, bolt_d, head_d, "bolt_bore_d"),
       bdepth = plate_joint_dimension(bolt_bore_h, plate_h, head_h, "bolt_bore_h"),
       footprint = bolt_no_bore || bdepth == 0 ? bolt_d : bd,
       // A centered side bolt needs material on both sides, including socket clearance.
       side_min = footprint + 2 * margin + 2 * gap,
       taper = (dovetail_rib ? rh : 2 * rh) * tan(with_default(angle, 20)),
       pd = plate_joint_dimension(pin_d, rh, 3.1, "pin_d"),
       comp = plate_joint_dimension(pin_compensation, pd, 0.4, "pin_compensation"),
       pin_x = pin_use_pad ? pd : max(pd, comp),
       radius = plate_joint_dimension(rail_corner_r, rh, 0.4, "rail_corner_r"),
       rail_fraction = is_string(rail_w) ? plate_joint_dimension(rail_w, 1, 0.7, "rail_w") : 0.7,
       pin_fraction = is_string(pin_spacing) ? plate_joint_dimension(pin_spacing, 1, 0.675, "pin_spacing") : 0.675,
       want_side_bolts = is_undef(bolt_n_center) || (is_num(bolt_n_center) && bolt_n_center >= 2))
  assert(!is_undef(w) || (rail_fraction > 0 && rail_fraction < 1),
         "Automatic w needs a rail percentage between 0 and 100")
  assert(!is_undef(w) || !include_pin_holes || is_num(pin_spacing) || pin_fraction < 1,
         "Automatic w needs pin spacing below 100% of the rail")
  let (pin_rail_min = !include_pin_holes ? 0 : is_num(pin_spacing)
         ? pin_spacing + pin_x + 2 * margin + taper
         : (pin_x + 2 * margin + taper) / max(0.001, 1 - pin_fraction),
       rail_min = max(taper + 2 * radius, pin_rail_min),
       side_space = want_side_bolts ? side_min : margin + gap,
       auto_w = !is_undef(w) ? w : is_num(rail_w) ? max(rail_w / 0.7, rail_w + 2 * side_space)
         : max(rail_min / rail_fraction, 2 * side_space / (1 - rail_fraction)),
       w = with_default(w, auto_w),
       rail_limit = w - 2 * side_min,
       side_bolts_fit = rail_limit >= rail_min - 0.000001,
       auto_rail = want_side_bolts && side_bolts_fit ? min(w * 0.7, rail_limit) : w * 0.7,
       rw = plate_joint_dimension(rail_w, w, auto_rail, "rail_w"),
       // Each side strip is (w-rw)/2 wide. Its center is at +/- (w+rw)/4.
       span = plate_joint_dimension(bolt_spacing_center, w, (w + rw) / 2, "bolt_spacing_center"),
       ang = with_default(angle, 20))
  assert(rh > 0 && bh > gap && bottom > gap,
         "Rail and plate skins must remain positive after clearance")
  assert(rw > 0, "rail_w must be positive")
  assert(is_num(ang) && ang >= 0 && ang < 90,
         "angle must be numeric in [0, 90)")
  assert(axial < l && eps < l,
         "Axial clearance and overlap must be smaller than l")
  let (neck = rw - (dovetail_rib ? rh : 2 * rh) * tan(ang),
       land = plate_joint_dimension(edge_land, rh, 0.45, "edge_land"),
       relief = plate_joint_dimension(relief_depth, rh, 0, "relief_depth"),
       bolt_eps = plate_joint_dimension(bolt_cut_overlap, plate_h, 0.1, "bolt_cut_overlap"),
       auto_n = !side_bolts_fit && is_undef(bolt_spacing_center) ? 1
         : min(3, max(1, floor(span / (footprint + margin)) + 1)),
       n = with_default(bolt_n_center, auto_n))
  assert(neck > 0, "angle collapses the rail neck")
  assert(is_num(n) && n >= 0 && floor(n) == n,
         "bolt_n_center must be a non-negative integer")
  let (pl = plate_joint_dimension(pin_l, l, 41, "pin_l"),
       ps = plate_joint_dimension(pin_spacing, rw, rw / 2 + rw * 0.35 / 2, "pin_spacing"),
       pz = plate_joint_dimension(pin_z, plate_h, bottom + (bh + rh) / 2, "pin_z"),
       padl = plate_joint_dimension(pin_pad_l, pl, 5.5, "pin_pad_l"),
       padw = plate_joint_dimension(pin_pad_w, pd, 2.5, "pin_pad_w"),
       xs = n == 0 ? [] : n == 1 ? [0] : [for (i = [0:n - 1]) -span / 2 + i * span / (n - 1)])
  assert(pin_direction == -1 || pin_direction == 1,
         "pin_direction must be -1 or 1")
  assert(pin_pad_side == "bottom" || pin_pad_side == "top",
         "Invalid pin_pad_side")
  // result plist
  ["plate_h", plate_h, // plate height
   "bolt_d", bolt_d,
   "w", w,
   "l", l,
   "rail_w", rw,
   "rail_h", rh,
   "base_h", bh,
   "bottom_h", bottom,
   "angle", ang,
   "rail_neck_w", neck,
   "rail_corner_r", radius,
   "dovetail_rib", dovetail_rib,
   "edge_land", land,
   "relief_depth", relief,
   "clearance", gap,
   "axial_clearance", axial,
   "boolean_overlap", eps,
   "wall", margin,
   "bolt_bore_d", bd,
   "bolt_bore_h", bdepth,
   "bolt_no_bore", bolt_no_bore,
   "bolt_head_type", bolt_head_type,
   "bolt_head_d", head_d,
   "bolt_head_h", head_h,
   "bolt_cut_overlap", bolt_eps,
   "bolt_spacing_center", n < 2 ? 0 : span,
   "bolt_n_center", n,
   "bolt_xs", xs,
   "include_pin_holes", include_pin_holes,
   "pin_d", pd,
   "pin_l", pl,
   "pin_spacing", ps,
   "pin_z", pz,
   "pin_use_pad", pin_use_pad,
   "pin_pad_l", padl,
   "pin_pad_w", padw,
   "pin_direction", pin_direction,
   "pin_center", pin_center,
   "pin_pad_side", pin_pad_side, // result plist
   "pin_compensation", comp];

/**
  ─────────────────────────────────────────────────────────────────────────────
  plate_joint_size_report
  ─────────────────────────────────────────────────────────────────────────────

  Report resolved dimensions and remaining material in the mating joint.

  **Parameters:**
  - `params`: Resolved property list from plate_joint_parameters().
  - `flip`: Report the reflected pin axis inside the nominal envelope.

  **Returns:**
  Rows `[label, millimeters, check_min_wall]`. Wall values account for socket
  clearance, enabled counterbores and the pin compensation envelope. The pin
  side value is a conservative bound using the narrowest rail section; it is
  not a measurement of the rounded surface or a strength calculation.
 */
function plate_joint_size_report(params, flip=false) =
  let (p = params,
       w = plist_get("w", p),
       l = plist_get("l", p),
       h = plist_get("plate_h", p),
       rw = plist_get("rail_w", p),
       rh = plist_get("rail_h", p),
       base = plist_get("base_h", p),
       bottom = plist_get("bottom_h", p),
       gap = plist_get("clearance", p),
       xs = plist_get("bolt_xs", p),
       bore = plist_get("bolt_no_bore", p) ? 0 : plist_get("bolt_bore_h", p),
       hole_d = bore > 0 ? max(plist_get("bolt_d", p), plist_get("bolt_bore_d", p)) : plist_get("bolt_d", p),
       pd = plist_get("pin_d", p),
       pz = plist_get("pin_z", p),
       ps = plist_get("pin_spacing", p),
       comp = plist_get("pin_compensation", p),
       pad = plist_get("pin_use_pad", p),
       pin_z_extent = pad ? pd : pd + comp,
       pin_x_extent = pad ? pd : max(pd, comp),
       outer_x = len(xs) > 0 ? max([for (x = xs) abs(x)]) : 0,
       // The shared slider's rib half-profile join shortens its nominal tip by 0.05.
       rib_tip = plist_get("dovetail_rib", p) ? 0.05 : 0)
  concat([["Joint X width", w, false],
          ["Joint Y length", l, false],
          ["Plate height", h, false],
          ["Rail width", rw, false],
          ["Rail height", rh, false],
          ["Base skin", base, true],
          ["Female floor after fit", bottom - gap, true],
          ["Side strip before fit", (w - rw) / 2, false]],
         len(xs) == 0 ? [] : [["Bolt outer edge wall", w / 2 - outer_x - hole_d / 2, true],
                              ["Bolt span", plist_get("bolt_spacing_center", p), false]],
         len(xs) < 2 ? [] : [["Side bolt to socket wall", outer_x - rw / 2 - gap - hole_d / 2, true]],
         bore <= 0 ? [] : [["Male skin below head", base - bore, true],
                           ["Female floor above head", bottom - gap - bore, true]],
         !plist_get("include_pin_holes", p) ? [] : [["Pin axis Z in envelope", flip ? h - pz : pz, false],
                                                    ["Pin top cover", h - pz - pin_z_extent / 2, true],
                                                    ["Pin bottom cover", pz - pin_z_extent / 2 - bottom - rib_tip, true],
                                                    ["Pin side (neck bound)", (plist_get("rail_neck_w", p) - ps - pin_x_extent) / 2, true],
                                                    ["Pin engagement each end", (plist_get("pin_l", p) - l) / 2, true]]);
