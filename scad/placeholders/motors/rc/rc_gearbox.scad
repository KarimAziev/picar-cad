/**
  * Module: Measured RC motor stack and gear-envelope gearbox placeholder.
  *
  * Native origin is the motor axis on the gearbox's outer cover plane.
  * The motor extends along +Z; the driven output extends along -Z.
  * Gear positions use a provisional pitch model, not a manufacturing drawing.
  */
include <../../../parameters.scad>

use <../../../lib/functions.scad>
use <../../../lib/plist.scad>
use <../../../lib/shapes3d.scad>
use <../../../lib/transforms.scad>

motor_plist = rc_motor_plist;
show_motor = true;
show_gearbox = true;
show_gear_layout = false;
show_rear_shaft = true;
show_front_shaft = true;

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_gearbox_size
  ─────────────────────────────────────────────────────────────────────────────
  Return the measured housing envelope, excluding bearing bosses and shafts.
  **Parameters:**
  - `plist`: Nested motor hardware specification.
  **Returns:** Native `[w, l, h]`; h is axial gearbox thickness.
 */
function rc_gearbox_size(plist=rc_motor_plist) =
  plist_get("size", plist_get("gearbox", plist));

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_gearbox_mesh_distance
  ─────────────────────────────────────────────────────────────────────────────
  Estimate standard external-gear center distance from tooth-tip diameters.
  **Parameters:**
  - `d1`: First gear outside diameter.
  - `d2`: Second gear outside diameter.
  - `m`: Assumed common module; not inferred from inconsistent photo labels.
  **Returns:** Half the sum of pitch diameters, with pitch diameter = OD - 2m.
  **Notes:** Valid only for the assumed unshifted standard tooth proportions.
 */
function rc_gearbox_mesh_distance(d1, d2, m) =
  assert(m > 0 && min(d1, d2) > 2 * m)
  (d1 + d2) / 2 - 2 * m;

function _rc_gearbox_circle_lower(a, b, r1, r2) =
  let (delta = b - a, d = norm(delta))
  assert(d > 0 && d <= r1 + r2 && d >= abs(r1 - r2),
         "The intermediate gear circles cannot intersect")
  let (u = delta / d,
       along = (r1 * r1 - r2 * r2 + d * d) / (2 * d),
       rise = sqrt(max(0, r1 * r1 - along * along)),
       base = a + u * along,
       v = [-u[1], u[0]] * rise,
       p = base + v, q = base - v)
  p[1] < q[1] ? p : q;

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_gearbox_layout
  ─────────────────────────────────────────────────────────────────────────────
  Solve a folded four-axis train inside the measured housing envelope.
  **Parameters:**
  - `plist`: Nested hardware specification; requires two compound idlers.
  **Returns:** Property list with native XY `centers` ordered motor, first
  idler, second idler, output; housing `center`, `lobe_ds`, and the three
  `mesh_distances`. The motor center remains [0, 0].
  **Notes:** Tangency to the measured bounds selects one possible arrangement.
  Actual shaft locations, wall thickness and module still need verification.
 */
function rc_gearbox_layout(plist=rc_motor_plist) =
  let (box = plist_get("gearbox", plist),
       size = rc_gearbox_size(plist),
       pad = plist_get("pad", box),
       m = plist_get("mesh_module", box),
       body_d = plist_get("d", plist_get("body", plist)),
       pinion_d = plist_get("gear_d", plist_get("motor_shaft", plist)),
       output_d = plist_get("gear_d", plist_get("drive_shaft", plist)),
       idlers = plist_get("motor_shaft_gears", plist))
  assert(len(idlers) == 2, "This gearbox has two compound intermediate shafts")
  let (d1 = plist_get("d", idlers[0]), d2 = plist_get("d", idlers[1]),
       small1 = plist_get("inner_d", idlers[0]),
       small2 = plist_get("inner_d", idlers[1]),
       radii = [body_d / 2 + pad, d1 / 2 + pad, d2 / 2 + pad, output_d / 2 + pad],
       motor = [size[0] / 2 - radii[0], 0],
       output = [-size[0] / 2 + radii[3], size[1] / 2 - radii[3]],
       first_y = -size[1] / 2 + radii[1],
       a = rc_gearbox_mesh_distance(pinion_d, d1, m),
       b = rc_gearbox_mesh_distance(small1, d2, m),
       c = rc_gearbox_mesh_distance(small2, output_d, m))
  assert(abs(first_y) < a, "Housing length leaves no room for the input gear pair")
  let (first = [motor[0] - sqrt(a * a - first_y * first_y), first_y],
       second = _rc_gearbox_circle_lower(first, output, b, c),
       centers = [motor, first, second, output])
  assert(min([for (i = [0:3]) centers[i][0] - radii[i]]) >= -size[0] / 2 - 0.000001
         && max([for (i = [0:3]) centers[i][0] + radii[i]]) <= size[0] / 2 + 0.000001
         && min([for (i = [0:3]) centers[i][1] - radii[i]]) >= -size[1] / 2 - 0.000001
         && max([for (i = [0:3]) centers[i][1] + radii[i]]) <= size[1] / 2 + 0.000001,
         "Gear envelopes do not fit the measured housing")
  ["centers", [for (p = centers) p - motor],
   "center", -motor, "lobe_ds", radii * 2,
   "mesh_distances", [a, b, c]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_gearbox_profile
  ─────────────────────────────────────────────────────────────────────────────
  Emit the tangent housing outline around the motor and compound gear envelopes.
  **Parameters:**
  - `plist`: Nested motor hardware specification.
  **Notes:** Native XY coordinates; no scaling or clipping of measured circles.
 */
module rc_gearbox_profile(plist=rc_motor_plist) {
  layout = rc_gearbox_layout(plist);
  centers = plist_get("centers", layout);
  ds = plist_get("lobe_ds", layout);
  hull() {
    for (i = [0:3]) {
      translate(centers[i]) {
        circle(d=ds[i]);
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  gearbox
  ─────────────────────────────────────────────────────────────────────────────
  Build the measured-envelope housing without inventing casing screw positions.
  **Parameters:**
  - `plist`: Nested motor hardware specification.
  - `slot_mode`: Emit an expanded housing envelope.
  - `clearance`: Radial and axial allowance in slot mode.
  - `anchor`: Housing envelope anchor, or undef to retain the native motor origin.
 */
module gearbox(plist=rc_motor_plist, slot_mode=false, clearance=0, anchor=undef) {
  size = rc_gearbox_size(plist);
  center = plist_get("center", rc_gearbox_layout(plist));
  allowance = slot_mode ? clearance : 0;
  assert(clearance >= 0);
  $fn = $preview ? 64 : 128;
  with_anchor(is_undef(anchor) ? [0, 0, 1] : anchor, size, centered=true) {
    translate(is_undef(anchor) ? [0, 0, 0] : [-center[0], -center[1], 0]) {
      maybe_color(slot_mode ? undef : plist_get("color", plist_get("gearbox", plist))) {
        translate([0, 0, -allowance]) {
          linear_extrude(height=size[2] + 2 * allowance) {
            offset(r=allowance) {
              rc_gearbox_profile(plist);
            }
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_gearbox_gear_layout
  ─────────────────────────────────────────────────────────────────────────────
  Show a planar schematic of outside, compound and pitch circles over the cover.
  **Parameters:**
  - `plist`: Nested motor hardware specification.
  **Notes:** This is not a set of solid gears or an axial meshing model.
  Blue = outside diameters; green = small compound gears; red = pitch circles.
 */
module rc_gearbox_gear_layout(plist=rc_motor_plist) {
  layout = rc_gearbox_layout(plist);
  centers = plist_get("centers", layout);
  box = plist_get("gearbox", plist);
  m = plist_get("mesh_module", box);
  line_w = plist_get("boolean_overlap", box);
  idlers = plist_get("motor_shaft_gears", plist);
  ds = [plist_get("gear_d", plist_get("motor_shaft", plist)),
        plist_get("d", idlers[0]), plist_get("d", idlers[1]),
        plist_get("gear_d", plist_get("drive_shaft", plist))];
  $fn = 96;
  module _ring(d, w, colr) {
    color(colr) {
      linear_extrude(height=line_w) {
        difference() {
          circle(d=d);
          circle(d=d - w);
        }
      }
    }
  }
  translate([0, 0, rc_gearbox_size(plist)[2] + line_w]) {
    for (i = [0:3]) {
      translate(centers[i]) {
        _ring(ds[i], m / 2, "royalblue");
        _ring(ds[i] - 2 * m, m / 3, "crimson");
        if (i == 1 || i == 2) {
          small_d = plist_get("inner_d", idlers[i - 1]);
          _ring(small_d, m / 2, "seagreen");
          _ring(small_d - 2 * m, m / 3, "crimson");
        }
        color("black") {
          cylinder(d=m, h=line_w);
        }
      }
    }
  }
}

function _contact_stack_item_get_h(plist) =
  let (size = plist_get("size", plist),
       h = is_undef(size) ? plist_get("h", plist) : size[2])
  h;

/**
  ─────────────────────────────────────────────────────────────────────────────
  contact_stack_get_heights
  ─────────────────────────────────────────────────────────────────────────────
  Return axial heights of rectangular or cylindrical contact-stack items.
  **Parameters:**
  - `plists`: Ordered contact-stack property lists.
  **Returns:** One height per item, in the same order.
 */
function contact_stack_get_heights(plists) =
  [for (v = plists) _contact_stack_item_get_h(v)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  contact_stack_total_h
  ─────────────────────────────────────────────────────────────────────────────
  Return the total axial height of a contact stack.
  **Parameters:**
  - `plists`: Ordered contact-stack property lists.
  **Returns:** Height in mm, or zero for an empty stack.
 */
function contact_stack_total_h(plists) =
  let (heights = contact_stack_get_heights(plists))
  len(heights) > 0 ? sum(heights) : 0;

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_motor_total_h
  ─────────────────────────────────────────────────────────────────────────────
  Return the measured motor stack length, excluding gearbox and shaft protrusions.
  **Parameters:**
  - `plist`: Nested motor hardware specification.
  **Returns:** Front plate, can, contact cup and tallest rear contact-stack length.
 */
function rc_motor_total_h(plist=rc_motor_plist) =
  let (body = plist_get("body", plist),
       contact_cup = plist_get("contact_cup", plist),
       contact_stack = plist_get("contact_stack", plist),
       pinion_gear_h = plist_get("pinion_gear_h", plist),
       contact_cup_h = plist_get("h", contact_cup),
       body_h = plist_get("h", body),
       contact_stack_heights = contact_stack_get_heights(contact_stack),
       contact_stack_h = non_empty(contact_stack_heights) ? sum(contact_stack_heights) : 0,
       motor_full_h = pinion_gear_h + body_h + contact_cup_h
                      + max(contact_stack_h, plist_get("size", plist_get("contact", plist))[2]))
  motor_full_h;

module _rc_motor_body(plist) {
  body = plist_get("body", plist);
  contact_cup = plist_get("contact_cup", plist);
  contact = plist_get("contact", plist);

  contact_stack = plist_get("contact_stack", plist);
  contact_size = plist_get("size", contact);
  contact_color = plist_get("color", contact);
  contact_pad = plist_get("pad", contact);

  pinion_gear_h = plist_get("pinion_gear_h", plist);
  pinion_hole_d = plist_get("pinion_hole_d", plist);
  pinion_gear_color = plist_get("pinion_gear_color", plist);

  contact_cup_h = plist_get("h", contact_cup);
  contact_cup_color = plist_get("color", contact_cup);

  body_d = plist_get("d", body);
  body_h = plist_get("h", body);
  body_color = plist_get("color", body);

  contact_stack_heights = contact_stack_get_heights(contact_stack);

  motor_shaft = plist_get("motor_shaft", plist);
  motor_shaft_h = plist_get("h", motor_shaft);
  motor_shaft_d = plist_get("d", motor_shaft);
  motor_shaft_gear_d = plist_get("gear_d", motor_shaft);
  motor_shaft_gear_h = plist_get("gear_h", motor_shaft);

  translate([0, 0, 0]) {
    difference() {
      maybe_color(pinion_gear_color) {
        cylinder(d=body_d, h=pinion_gear_h);
      }
      translate([0, 0, -0.05]) {
        cylinder(d=pinion_hole_d, h=pinion_gear_h + 0.1, $fn=16);
      }
    }

    color(metallic_silver_3, alpha=1) {
      translate([0, 0, pinion_gear_h - motor_shaft_h]) {
        cylinder(d=motor_shaft_d, h=motor_shaft_h);
        translate([0, 0, 0]) {
          cylinder(d=motor_shaft_gear_d, h=motor_shaft_gear_h);
        }
      }
    }

    translate([0, 0, pinion_gear_h]) {
      maybe_color(body_color) {
        cylinder(d=body_d, h=body_h);
      }
      translate([0, 0, body_h]) {
        maybe_color(contact_cup_color) {
          cylinder(d=body_d, h=contact_cup_h);
        }
        translate([0, 0, contact_cup_h]) {
          mirror_copy([1, 0, 0]) {
            translate([body_d / 2 - contact_pad, 0, 0]) {
              maybe_color(contact_color) {
                cuboid(size=contact_size);
              }
            }
          }
          if (len(contact_stack) > 0) {
            for (i = [0:len(contact_stack) - 1]) {
              let (item = contact_stack[i],
                   prev_heights = take(contact_stack_heights, i),
                   prev_h = non_empty(prev_heights) ? sum(prev_heights) : 0,
                   item_h = contact_stack_heights[i],
                   item_color = plist_get("color", item),
                   item_d = plist_get("d", item),
                   item_size = plist_get("size", item)) {
                translate([0, 0, prev_h]) {
                  if (item_d) {
                    maybe_color(item_color) {
                      cylinder(d=item_d, h=item_h, $fn=16);
                    }
                  } else if (item_size) {

                    maybe_color(item_color) {
                      cuboid(size=item_size, r=plist_get("corner_r", item));
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
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_motor
  ─────────────────────────────────────────────────────────────────────────────
  Compose the measured motor stack, housing and optional output shafts.
  **Parameters:**
  - `plist`: Nested motor hardware specification.
  - `show_motor`: Show the original measured motor and contact stack.
  - `show_gearbox`: Show the housing.
  - `show_gear_layout`: Show the planar gear-circle schematic above the housing.
  - `show_rear_shaft`: Show the -Z output and its bearing boss.
  - `show_front_shaft`: Show the provisional long +Z output.
  - `slot_mode`: Emit a conservative assembly envelope.
  - `clearance`: Radial and axial slot allowance.
  - `anchor`: Envelope anchor, or undef for the original motor-axis datum.
  **Notes:** Anchor envelope excludes output shafts but includes the contact stack.
 */
module rc_motor(plist=motor_plist,
                 show_motor=show_motor,
                 show_gearbox=show_gearbox,
                 show_gear_layout=show_gear_layout,
                 show_rear_shaft=show_rear_shaft,
                 show_front_shaft=show_front_shaft,
                 slot_mode=false,
                 clearance=0,
                 anchor=undef) {
  box = plist_get("gearbox", plist);
  box_size = rc_gearbox_size(plist);
  layout = rc_gearbox_layout(plist);
  center = plist_get("center", layout);
  output = plist_get("centers", layout)[3];
  shaft_d = plist_get("d", plist_get("drive_shaft", plist));
  bearing_d = plist_get("bearing_d", box);
  bearing_h = plist_get("bearing_h", box);
  size = [box_size[0], box_size[1], box_size[2] + rc_motor_total_h(plist)];
  eps = plist_get("boolean_overlap", box);
  assert(clearance >= 0);
  $fn = $preview ? 64 : 128;
  with_anchor(is_undef(anchor) ? [0, 0, 1] : anchor, size, centered=true) {
    translate(is_undef(anchor) ? [0, 0, 0] : [-center[0], -center[1], 0]) {
      if (slot_mode) {
        translate([center[0], center[1], -clearance]) {
          cuboid(size + [2 * clearance, 2 * clearance, 2 * clearance]);
        }
      } else {
        if (show_gearbox) {
          gearbox(plist);
        }
        if (show_motor) {
          translate([0, 0, box_size[2]]) {
            _rc_motor_body(plist);
          }
        }
        if (show_gear_layout) {
          rc_gearbox_gear_layout(plist);
        }
      }
      for (rear = [true, false]) {
        if (rear ? show_rear_shaft : show_front_shaft) {
          l = plist_get(rear ? "rear_shaft_h" : "front_shaft_h", box);
          face_z = rear ? 0 : box_size[2];
          assert(l >= bearing_h);
          translate([output[0], output[1], face_z]) {
            if (slot_mode) {
              translate([0, 0, rear ? -l - clearance : -clearance]) {
                cylinder(d=bearing_d + clearance * 2, h=l + clearance * 2);
              }
            } else {
              color("silver") {
                translate([0, 0, rear ? -l : -eps]) {
                  cylinder(d=shaft_d, h=l + eps);
                }
              }
              color("dimgray") {
                translate([0, 0, rear ? -bearing_h : -eps]) {
                  cylinder(d=bearing_d, h=bearing_h + eps);
                }
              }
            }
          }
        }
      }
    }
  }
}

rc_motor();
