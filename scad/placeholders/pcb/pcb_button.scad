
/**
  * Module: PCB button placeholder
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../parameters.scad>

use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  pcb_button_size_from_plist
  ─────────────────────────────────────────────────────────────────────────────
  Return the oriented nominal body size of a PCB button.

  **Parameters:**
  - `plist`: Button properties; omitted size defaults to `[4.5, 3.3, 3]`.
  - `orientation`: Optional override of the plist orientation, default `"wlh"`.
  **Returns:** Oriented `[width, length, height]` used for body anchoring.

  The projecting button is excluded from the reference box.
 */
function pcb_button_size_from_plist(plist, orientation) =
  let (plist = with_default(plist, []),
       size = plist_get("size", plist, [4.5, 3.3, 3]),
       orientation = with_default(orientation,
                                  plist_get("orientation", plist, "wlh")))
  orientation_size(orientation, size);

/**
  ─────────────────────────────────────────────────────────────────────────────
  pcb_button
  ─────────────────────────────────────────────────────────────────────────────
  Create a rectangular switch body with a projecting round button.

  **Parameters:**
  - `size`: Nominal body `[width, length, height]` before orientation.
  - `button_h`: Projection of the button above the canonical body top.
  - `button_d`: Button diameter.
  - `color`: Body color; `undef` uses matte black.
  - `button_color`: Button color; `undef` uses metallic yellow silver.
  - `orientation`: Axis convention for the body, default `"wlh"`.
  - `anchor`: Placement against the oriented body box; default `[0, 0, 1]`.

  The projecting button is excluded from the anchoring reference size.
 */
module pcb_button(size=[4.5, 3.3, 3],
                  button_h=1.36,
                  button_d=1.8,
                  color=matte_black,
                  button_color=metallic_yellow_silver,
                  orientation="wlh",
                  anchor=[0, 0, 1]) {

  with_orientation(from="wlh", to=orientation, anchor=anchor, size=size) {
    color(with_default(color, matte_black), alpha=1) {
      cuboid(size=size);
    }
    translate([0, 0, size[2]]) {
      color(with_default(button_color, metallic_yellow_silver), alpha=1) {
        cyl(d=button_d, h=button_h, $fn=10);
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  pcb_button_from_plist
  ─────────────────────────────────────────────────────────────────────────────
  Render a PCB button from its property list.

  **Parameters:**
  - `plist`: `pcb_button` properties; missing keys use its module defaults.
  - `orientation`: Optional override of the plist orientation, default `"wlh"`.
  - `anchor`: Optional override of the plist anchor, default `[0, 0, 1]`.

  Anchoring uses the nominal body box, excluding the projecting button.
 */
module pcb_button_from_plist(plist, orientation, anchor) {
  plist = with_default(plist, []);
  size = plist_get("size", plist, [4.5, 3.3, 3]);
  button_h = plist_get("button_h", plist, 1.36);
  button_d = plist_get("button_d", plist, 1.8);
  color = plist_get("color", plist, matte_black);
  button_color = plist_get("button_color", plist, metallic_yellow_silver);
  orientation = with_default(orientation,
                             plist_get("orientation", plist, "wlh"));
  anchor = with_default(anchor, plist_get("anchor", plist, [0, 0, 1]));
  pcb_button(size=size,
             button_h=button_h,
             button_d=button_d,
             color=color,
             button_color=button_color,
             orientation=orientation,
             anchor=anchor);
}

pcb_button();
