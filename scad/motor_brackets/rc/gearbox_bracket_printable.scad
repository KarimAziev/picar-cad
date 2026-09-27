/**
  * Module: Printable gearbox bracket
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../steering_params.scad>

use <gearbox_bracket.scad>

module gearbox_printable() {
  gearmotor_bracket(plist=motor_plist,
                    show_bracket=true,
                    show_gearbox=false,
                    show_motor=false,
                    show_bearing=false,
                    show_drive_shaft=false,
                    show_mount_bolts=false,
                    show_nuts=false,
                    show_shaft_seeve=false,
                    show_extra_drive_shaft=false,
                    show_encoder_bracket=false,
                    show_encoder=false,
                    show_encoder_magnet=false,
                    show_encoder_sleeve=false,
                    show_gearbox_bosses=false,
                    debug=false,
                    anchor_mode="size");
}

gearbox_printable();