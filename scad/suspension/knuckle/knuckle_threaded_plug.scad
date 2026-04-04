/**
  * Module: Threaded plug for knuckle's ball stud housing
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../steering_params.scad>

use <../../lib/threading/threaded_plug_hex_socket.scad>
use <../../lib/threading/threads.scad>

module knuckle_threaded_plug() {
  threaded_plug_hex_socket(d=knuckle_threaded_plug_d,
                           l=knuckle_threaded_plug_l,
                           hex_size=knuckle_threaded_plug_hex_key_size,
                           tolerance=knuckle_threaded_plug_tolerance);
}

knuckle_threaded_plug();