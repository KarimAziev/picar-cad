/**
  * Module: USB A Placeholder placeholder
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../parameters.scad>

use <generic_usb_plug.scad>

function usb_a_oriented_size(plist=usb_a_plist, orientation="wlh") =
  usb_oriented_size(plist,
                    orientation=orientation);

function usb_a_params(plist=usb_a_plist, orientation="wlh") =
  usb_plug_params(plist);

module usb_a_plug(plist=usb_a_plist,
                  orientation="wlh",
                  anchor=[0, 1, 1]) {
  generic_usb_plug(plist=plist,
                   orientation=orientation,
                   anchor=anchor);
}

usb_a_plug();