/**
  * Module: PCB component placement and rendering.
  *
  * Align reusable board components by their oriented reference footprints.
  * Existing SMD component plists retain their original renderer behavior.
  */
include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/transforms.scad>
use <../placeholders/bcm.scad>
use <../placeholders/pcb/board_connectors.scad>
use <../placeholders/pcb/pci_connector.scad>
use <../placeholders/pcb/pcb_button.scad>
use <../placeholders/usb/generic_usb_socket.scad>
use <smd_placeholder_renderer.scad>

function _pcb_text_metrics(plist) =
  textmetrics(text=str(plist_get("text", plist, "")),
              size=plist_get("size", plist, 2),
              font=plist_get("font", plist, "Liberation Sans"),
              spacing=plist_get("spacing", plist, 1),
              halign=plist_get("halign", plist, "left"),
              valign=plist_get("valign", plist, "baseline"));

/**
  ─────────────────────────────────────────────────────────────────────────────
  pcb_placeholder_size
  ─────────────────────────────────────────────────────────────────────────────

  Return the nominal reference size for a reusable PCB component plist.

  **Parameters:**
  - `plist`: Component properties including `type`. Box, processor and connector
    types use `size=[w,l,h]`; PCI/button types also honor their `orientation`.
    `pcb_text` uses text metrics with numeric font `size`, `text`, optional
    `font`, `spacing`, `halign`, `valign` and extrusion `height` (default 0.1).

  **Returns:** `[w,l,h]` before cell spin, or `undef` for legacy SMD/unknown types.
  Text uses its ink bounds. Other sizes describe the nominal body, excluding
  latches, processor steps, button caps and attached USB plugs.
 */
function pcb_placeholder_size(plist) =
  let (type = plist_get("type", plist),
       size = plist_get("size", plist))
  type == "pci_connector" ? pci_connector_size_from_plist(plist)
  : type == "pcb_button" ? pcb_button_size_from_plist(plist)
  : type == "pcb_text"
  ? let (tm = _pcb_text_metrics(plist))
    [tm.size[0], tm.size[1], plist_get("height", plist, 0.1)]
  : member(type, ["cuboid", "bcm_processor", "ethernet_socket",
                  "board_edge_socket", "shrouded_connector", "multi_usb_socket"])
  ? assert(is_list(size) && len(size) == 3
           && len([for (v = size) if (is_num(v) && v > 0) v]) == 3,
           str("PCB component ", type, " requires positive size=[w,l,h]"))
    size
  : undef;

/**
  ─────────────────────────────────────────────────────────────────────────────
  pcb_placeholder_renderer
  ─────────────────────────────────────────────────────────────────────────────

  Render a PCB component aligned inside a cell at the board's top surface.

  **Parameters:**
  - `plist`: Component properties. Supported types are `cuboid`, `bcm_processor`,
    `ethernet_socket`, `board_edge_socket`, `shrouded_connector`,
    `multi_usb_socket`, `pci_connector`, `pcb_button` and `pcb_text`.
    Other types use `smd_placeholder_renderer` unchanged.
  - `cell_size`: Available `[w,l]` footprint; omitted dimensions skip alignment.
  - `align_x`: -1 aligns the minimum X side, 0 centers, 1 aligns the maximum side.
  - `align_y`: -1 aligns the minimum Y side, 0 centers, 1 aligns the maximum side.
  - `thickness`: Z coordinate of the PCB top surface; default zero.
  - `spin`: Cell rotation about Z in degrees, applied before footprint alignment.

  Components are placed with positive canonical bounds and their nominal body
  bottom on the PCB surface. Plist anchors are overridden for consistent cell
  placement. Connector orientation precedes cell spin. `cuboid` uses `corner_rad`
  (default zero), `fn` (default 40) and `color` (default matte black).
  `pcb_text` defaults to white, size 2, height 0.1 and Liberation Sans; its ink
  bounds are normalized before alignment. Legacy `text` plists are unchanged.
 */
module pcb_placeholder_renderer(plist,
                                 cell_size,
                                 align_x=0,
                                 align_y=0,
                                 thickness=0,
                                 spin=0) {
  type = plist_get("type", plist);
  reference_size = pcb_placeholder_size(plist);

  if (is_undef(reference_size)) {
    smd_placeholder_renderer(plist=plist,
                             cell_size=cell_size,
                             align_x=align_x,
                             align_y=align_y,
                             thickness=thickness,
                             spin=spin);
  } else {
    translate([0, 0, with_default(thickness, 0)]) {
      align_children_with_spin(parent_size=cell_size,
                               size=reference_size,
                               align_x=align_x,
                               align_y=align_y,
                               spin=spin) {
        if (type == "cuboid") {
          color(plist_get("color", plist, matte_black)) {
            cuboid(size=reference_size,
                   r=plist_get("corner_rad", plist, 0),
                   fn=plist_get("fn", plist, 40),
                   anchor=[1, 1, 1]);
          }
        } else if (type == "bcm_processor") {
          bcm_processor(size=reference_size,
                         detailed=plist_get("detailed", plist, rpi_model_detailed),
                         scale_both_sides=plist_get("scale_both_sides", plist, false),
                         r=plist_get("r", plist, 0.8),
                         step=plist_get("step", plist, 5),
                         extra_h=plist_get("extra_h", plist, 1),
                         txt=plist_get("txt", plist),
                         txt_color=plist_get("txt_color", plist),
                         txt_size=plist_get("txt_size", plist),
                         txt_spacing=plist_get("txt_spacing", plist, 1),
                         txt_font=plist_get("txt_font", plist),
                         colr=plist_get("color", plist, metallic_yellow_silver_2),
                         r_factor=plist_get("r_factor", plist, 0.06),
                         center=false);
        } else if (type == "ethernet_socket") {
          ethernet_socket(size=reference_size, anchor=[1, 1, 1]);
        } else if (type == "board_edge_socket") {
          board_edge_socket(size=reference_size, anchor=[1, 1, 1]);
        } else if (type == "shrouded_connector") {
          color(plist_get("color", plist, metallic_yellow_silver_2)) {
            shrouded_connector(size=reference_size,
                                detailed=plist_get("detailed", plist, false),
                                anchor=[1, 1, 1]);
          }
        } else if (type == "multi_usb_socket") {
          multi_usb_socket(size=reference_size,
                            usb_rows=plist_get("usb_rows", plist, 2),
                            color=plist_get("color", plist, metallic_yellow_silver),
                            offsets=plist_get("offsets", plist, [0, 0, 1]),
                            plugged_usb_idxes=plist_get("plugged_usb_idxes", plist, []),
                            usb_plist=plist_get("usb_plist", plist, usb_a_plist),
                            rotate_z_180=plist_get("rotate_z_180", plist, true),
                            anchor=[1, 1, 1]);
        } else if (type == "pci_connector") {
          pci_connector_from_plist(plist, anchor=[1, 1, 1]);
        } else if (type == "pcb_button") {
          pcb_button_from_plist(plist, anchor=[1, 1, 1]);
        } else if (type == "pcb_text") {
          tm = _pcb_text_metrics(plist);
          color(plist_get("color", plist, "white")) {
            translate([-tm.position[0], -tm.position[1], 0]) {
              linear_extrude(height=reference_size[2]) {
                text(text=str(plist_get("text", plist, "")),
                     size=plist_get("size", plist, 2),
                     font=plist_get("font", plist, "Liberation Sans"),
                     spacing=plist_get("spacing", plist, 1),
                     halign=plist_get("halign", plist, "left"),
                     valign=plist_get("valign", plist, "baseline"));
              }
            }
          }
        }
      }
    }
  }
}
