/**
  * Module: Motor drive shaft placeholder
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

use <../../suspension_arm_pin.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  motor_drive_shaft
  ─────────────────────────────────────────────────────────────────────────────

  **Example**:
  ```scad
  motor_drive_shaft(d=3.95, l=61.42, pad_l=6.8);

  ```
  */
module motor_drive_shaft(d, l, pad_l, pad_side="all", pad_l, pad_w) {
  suspension_arm_pin(d=d,
                     l=l,
                     pad_l=pad_l,
                     pad_w=is_undef(pad_w) ? d / 2 : pad_w,
                     pad_side=pad_side,
                     show_e_clip=false);
}
