/**
  * Module: MicroSD card and socket placeholders.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../colors.scad>

use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/transforms.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  micro_sd_card
  ─────────────────────────────────────────────────────────────────────────────
  Render a microSD card with its contact end facing +Y.

  **Parameters:**
  - `size`: Card `[width, length, thickness]`, default `[11, 15, 1]` mm.
  - `anchor`: Placement against the complete card reference box.
  - `show_contacts`: Show eight contacts inset into the +Z face.

  The reference envelope follows the SD Association's microSD form factor:
  https://www.sdcard.org/developers/sd-standard-overview/capacity-sd-sdhc-sdxc-sduc/
  Corner and contact details are simplified within that envelope.
 */
module micro_sd_card(size=[11, 15, 1],
                     anchor=[1, 1, 1],
                     show_contacts=true) {
  assert(len(size) == 3 && min(size) > 0, "Card size must be positive XYZ");
  with_anchor(size=size, anchor=anchor) {
    color(matte_black) {
      cuboid(size=size, r=min(size[0], size[1]) * 0.025,
             anchor=[1, 1, 1]);
    }
    if (show_contacts) {
      for (i = [0:7]) {
        translate([size[0] * (0.08 + i * 0.105),
                   size[1] * 0.73, size[2] - 0.01]) {
          color(metallic_yellow_1) {
            cube([size[0] * 0.075, size[1] * 0.23, 0.01]);
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  micro_sd_card_from_plist
  ─────────────────────────────────────────────────────────────────────────────
  Render a card from its reusable properties.

  **Parameters:**
  - `plist`: Optional `size`, `anchor` and `show_contacts` card properties.
  - `anchor`: Placement override; `undef` uses the plist or `[1, 1, 1]`.
 */
module micro_sd_card_from_plist(plist=[], anchor) {
  micro_sd_card(size=plist_get("size", plist, [11, 15, 1]),
                anchor=is_undef(anchor)
                ? plist_get("anchor", plist, [1, 1, 1])
                : anchor,
                show_contacts=plist_get("show_contacts", plist, true));
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  micro_sd_card_position
  ─────────────────────────────────────────────────────────────────────────────
  Return the inserted card's minimum XYZ relative to its socket.

  **Parameters:**
  - `size`: Socket `[width, depth, height]`, with its opening at Y=0.
  - `card_size`: Card `[width, length, thickness]`.
  - `insertion`: Distance from the socket mouth to the card's +Y tip.

  **Returns:** `[x, y, z]`, centered across the socket opening on X and Z.
 */
function micro_sd_card_position(size, card_size, insertion) =
  assert(min(card_size) > 0 && size[0] > card_size[0]
         && size[2] > card_size[2], "Card must fit inside its socket")
  assert(insertion > 0 && insertion <= min(size[1], card_size[1]),
         "Card insertion must fit inside the socket and card length")
  [(size[0] - card_size[0]) / 2,
   insertion - card_size[1],
   (size[2] - card_size[2]) / 2];

/**
  ─────────────────────────────────────────────────────────────────────────────
  micro_sd_socket
  ─────────────────────────────────────────────────────────────────────────────
  Render a socket opening toward -Y, with an optional inserted card.

  **Parameters:**
  - `size`: Socket body `[width, depth, height]`.
  - `card`: Card plist accepted by `micro_sd_card_from_plist`.
  - `insertion`: Distance from the socket mouth to the card's contact tip.
  - `show_card`: Display the inserted card when true.
  - `anchor`: Placement against the socket body, excluding card overhang.
 */
module micro_sd_socket(size=[11.95, 11.4, 1.42],
                       card=[],
                       insertion=10.75,
                       show_card=true,
                       anchor=[1, 1, 1]) {
  card_size = plist_get("size", card, [11, 15, 1]);
  card_pos = micro_sd_card_position(size, card_size, insertion);
  wall = min((size[0] - card_size[0]) / 3,
             (size[2] - card_size[2]) / 3);
  with_anchor(size=size, anchor=anchor) {
    color(metallic_silver_1) {
      difference() {
        cube(size);
        translate([wall, -0.01, wall]) {
          cube([size[0] - 2 * wall, size[1] - wall + 0.01,
                size[2] - 2 * wall]);
        }
      }
    }
    if (show_card) {
      translate(card_pos) {
        micro_sd_card_from_plist(card, anchor=[1, 1, 1]);
      }
    }
  }
}

micro_sd_socket();
