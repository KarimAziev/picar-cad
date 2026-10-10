/**
  * Module: Printable power-enclosure lid panels.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../parameters.scad>

use <../../lib/functions.scad>
use <step_down_voltage_enclosure.scad>

panel = "both"; // [both, main, text]
text_panel_t = 1;
gap = 6;

/**
  ─────────────────────────────────────────────────────────────────────────────
  step_down_enclosure_lid_printable
  ─────────────────────────────────────────────────────────────────────────────

  Lay out an engraved lid or two raised-text lid panels flat on the bed.

  **Parameters:**
  - `plist`: Enclosure overrides.
  - `color`: Preview color for the printable parts.
  - `panel`: `"both"`, or `"main"` / `"text"` for a single raised-text panel.
  - `text_panel_t`: Outer panel thickness below the lettering, in mm.
  - `gap`: Edge gap between the panels along Y, in mm.
 */
module step_down_enclosure_lid_printable(plist=step_down_enclosure_plist,
                                         color=white_smoke_1,
                                         panel="both",
                                         text_panel_t=1,
                                         gap=6) {
  assert(member(panel, ["both", "main", "text"]),
         "Panel must be both, main or text");
  color(color) {
    step_down_enclosure_printable(plist=plist,
                                  part=panel == "both" ? "lid" : str("lid_", panel),
                                  text_panel_t=text_panel_t,
                                  gap=gap);
  }
}

step_down_enclosure_lid_printable(panel=panel,
                                  text_panel_t=text_panel_t,
                                  gap=gap);
