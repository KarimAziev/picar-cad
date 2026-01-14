include <../../parameters.scad>


function front_panel_rear_panel_z() = ultrasonic_pin_len_b
  - ultrasonic_thickness
  - ultrasonic_pin_protrusion_h
  + ultrasonic_pin_thickness;

function front_rear_panel_boss_height() = front_panel_rear_panel_z()
  + front_panel_thickness / 2
  - front_panel_ultrasonic_cutout_depth;

function front_rear_panel_full_thickness() = front_rear_panel_boss_height()
  + front_panel_rear_panel_thickness;

function front_panel_bolt_y_offset(x, y) =
  - max(front_panel_connector_bolt_bore_dia,
        front_panel_connector_bolt_dia) / 2
  - front_panel_connector_bolts_padding_y;