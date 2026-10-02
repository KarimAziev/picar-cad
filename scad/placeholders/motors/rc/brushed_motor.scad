/**
  * Module: Measured RC motor stack and gear-envelope gearbox placeholder.
  *
  * Native origin is the motor axis on the gearbox's outer cover plane.
  * The motor extends along +Z; the driven output extends along -Z.
  * Gear positions use a provisional pitch model, not a manufacturing drawing.
  */
include <../../../parameters.scad>
include <../../../rc_params.scad>

use <../../../lib/functions.scad>
use <../../../lib/plist.scad>
use <../../../lib/shapes3d.scad>
use <../../../lib/transforms.scad>

show_motor       = true;
show_gearbox     = true;
show_gear_layout = false;

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
  rc_motor_body_full_h
  ─────────────────────────────────────────────────────────────────────────────
  Return the measured motor stack length, excluding pinion, gearbox
  and shaft protrusions.
  **Parameters:**
  - `plist`: Nested motor hardware specification.
  **Returns:** Front plate, can, contact cup and tallest rear contact-stack length.
 */
function rc_motor_body_full_h(plist) =
  let (body = plist_get("body", plist),
       contact_cup = plist_get("contact_cup", plist),
       contact_stack = plist_get("contact_stack", plist),
       contact_cup_h = plist_get("h", contact_cup),
       body_h = plist_get("h", body),
       contact_stack_heights = contact_stack_get_heights(contact_stack),
       contact_stack_h = non_empty(contact_stack_heights) ? sum(contact_stack_heights) : 0,
       body_full_h = body_h + contact_cup_h
       + max(contact_stack_h, plist_get("size", plist_get("contact", plist))[2]))
  body_full_h;

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_motor_total_h
  ─────────────────────────────────────────────────────────────────────────────
  Return the measured motor stack length, excluding gearbox and shaft protrusions.
  **Parameters:**
  - `plist`: Nested motor hardware specification.
  **Returns:** Front plate, can, contact cup and tallest rear contact-stack length.
 */
function rc_motor_total_h(plist) =
  let (full_body_h = rc_motor_body_full_h(plist),
       pinion_gear_h = plist_get("pinion_gear_h", plist, 0),
       motor_full_h = pinion_gear_h + full_body_h)
  motor_full_h;

module brushed_motor(plist) {
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

brushed_motor(plist=motor_plist);
