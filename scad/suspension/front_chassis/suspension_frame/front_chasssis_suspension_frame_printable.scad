/**
  * Module: Bulkhead and bellcrank frame in printable orientation.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <front_chassis_suspension_frame.scad>

module front_chassis_suspension_frame_printable(debug=false) {
  front_chassis_suspension_frame(debug=$preview ? debug : false);
}

front_chassis_suspension_frame_printable(debug=false);
