/**
  * Module: Printable D24V90F5 and INA260 enclosure base.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../components/step_down_enclosure/step_down_voltage_enclosure.scad>

module step_down_enclosure_base_printable() {
  step_down_enclosure_printable(part="base");
}

step_down_enclosure_base_printable();
