/**
 * Module: Printable detachable back panel that secures the ultrasonic sensor from behind
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

use <../components/front_panel/front_panel_back_mount.scad>

module front_panel_back_mount_printable(color="white") {
  color(color, alpha=1) {
    front_panel_back_mount();
  }
}

front_panel_back_mount_printable();
