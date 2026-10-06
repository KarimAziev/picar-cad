/**
  * Module: Rear suspension mounting plate with its flat underside on the print bed.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <rear_suspension_mount.scad>

module rear_suspension_mount_printable() {
  rear_suspension_mount(debug=false, slot_mode=false);
}

rear_suspension_mount_printable();