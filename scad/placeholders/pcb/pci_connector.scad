/**
  * Module: PCI connector placeholder
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
  pci_connector_size_from_plist
  ─────────────────────────────────────────────────────────────────────────────
  Return the oriented nominal body size of a PCI/CSI connector.

  **Parameters:**
  - `plist`: Connector properties; omitted size defaults to `[16, 2, 2.5]`.
  - `orientation`: Optional override of the plist orientation, default `"lwh"`.
  **Returns:** Oriented `[width, length, height]` used for body anchoring.

  Latch overhang and latch thickness are excluded from this reference box.
 */
function pci_connector_size_from_plist(plist, orientation) =
  let (plist = with_default(plist, []),
       size = plist_get("size", plist, [16, 2, 2.5]),
       orientation = with_default(orientation,
                                  plist_get("orientation", plist, "lwh")))
  orientation_size(orientation, size);

/**
  ─────────────────────────────────────────────────────────────────────────────
  pci_connector_oriented_size
  ─────────────────────────────────────────────────────────────────────────────
  Return the nominal connector size in an explicit orientation.

  **Parameters:**
  - `plist`: Connector properties, including optional `size`.
  - `orientation`: Orientation to use; defaults to `"lwh"`.
  **Returns:** Oriented `[width, length, height]`, excluding the latch.
 */
function pci_connector_oriented_size(plist, orientation="lwh") =
  pci_connector_size_from_plist(plist, orientation);

/**
  ─────────────────────────────────────────────────────────────────────────────
  pci_connector
  ─────────────────────────────────────────────────────────────────────────────
  Create a flat cable connector with an overhanging latch.

  **Parameters:**
  - `size`: Nominal body `[width, length, height]` before orientation.
  - `latch_pad`: Width of each latch edge; `undef` uses 23% of body length.
  - `color`: Body color.
  - `latch_color`: Latch color.
  - `anchor`: Placement against the oriented body box; default `[0, 0, 1]`.
  - `latch_thickness`: Latch height and overhang allowance; `undef` uses 0.4.
  - `orientation`: Axis convention for the body, default `"lwh"`.

  The reference size excludes latch overhang and additional latch height.
 */
module pci_connector(size=[16.0, 2, 2.5],
                     latch_pad=3.66,
                     color=metallic_yellow_silver_2,
                     latch_color=jet_black,
                     anchor=[0, 0, 1],
                     latch_thickness = 0.4,
                     orientation="lwh") {
  latch_w = size[0] / 2;
  latch_pad = with_default(latch_pad, size[1] * 0.23);
  latch_thickness = with_default(latch_thickness, 0.4);
  h = size[2];

  with_orientation(from="wlh", to=orientation, anchor=anchor, size=size) {
    union() {
      color(color) {
        cuboid(size=size);
      }
      color(latch_color, alpha=1) {
        translate([0, 0, h]) {
          translate([-size[0] / 2 - latch_thickness, 0, 0]) {
            cuboid(size=[latch_w + latch_thickness, size [1] + 0.1, latch_thickness],
                   anchor=[1, 0, 1]);
          }

          mirror_copy([0, 1, 0]) {
            translate([0, size[1] / 2 - latch_pad / 2, 0]) {
              cuboid(size=[size[0] + latch_thickness, latch_pad, latch_thickness]);
            }
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  pci_connector_from_plist
  ─────────────────────────────────────────────────────────────────────────────
  Render a PCI/CSI connector from its property list.

  **Parameters:**
  - `plist`: `pci_connector` properties; missing keys use its module defaults.
  - `anchor`: Optional override of the plist anchor, default `[0, 0, 1]`.
  - `orientation`: Optional override of the plist orientation, default `"lwh"`.

  Anchoring uses the nominal body box. The latch extends beyond that box.
 */
module pci_connector_from_plist(plist, anchor, orientation) {
  plist = with_default(plist, []);
  size = plist_get("size", plist, [16, 2, 2.5]);
  latch_pad = plist_get("latch_pad", plist, 3.66);
  color = plist_get("color", plist, metallic_yellow_silver_2);
  latch_color = plist_get("latch_color", plist, jet_black);
  anchor = with_default(anchor, plist_get("anchor", plist, [0, 0, 1]));
  orientation = with_default(orientation,
                             plist_get("orientation", plist, "lwh"));
  latch_thickness = plist_get("latch_thickness", plist, 0.4);

  pci_connector(size=size,
                latch_pad=latch_pad,
                color=color,
                latch_color=latch_color,
                anchor=anchor,
                latch_thickness=latch_thickness,
                orientation=orientation);
}

pci_connector(size=[16.0, 2, 2.5],
              latch_pad=3.66,
              color=metallic_yellow_silver_2,
              latch_color=jet_black,
              anchor=[0, 0, 1],
              latch_thickness = 0.4,
              orientation="lwh");
