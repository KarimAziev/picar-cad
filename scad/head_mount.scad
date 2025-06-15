// This module defines the robot head component designed to support two Raspberry Pi Camera Module 2 units.
// It features a main mounting plate, connector plates, a back plate, and side panels with accurately placed holes for screws.
// The head mount design assumes it will be attached via the side panel’s mounting hole on the servo assembly.
// Detailed parameters control the dimensions and placement of each constituent element to ensure proper alignment and aesthetics.

plate_width                   = 38;
plate_height                  = 50;
plate_thickness               = 2;

lens_width                    = 14;
lens_height                   = 23;

screw_offset_x                = 10.3;
screw_offset_y                = -4.2;
screw_offset_y_top            = 8.54;
M2_dia                        = 2.4;

cam_center_offset             = 13;
cam_centers                   = [[0, -cam_center_offset], [0, cam_center_offset]];

back_plate_width              = plate_width * 0.9;
back_plate_height             = plate_height/2;

connector_width               = back_plate_width * 0.7;
connector_height              = 4;

connector_plate_offset_bottom = plate_height/2 + 2;
connector_plate_offset_top    = -(plate_height/2 + 2);

side_panel_height             = plate_height;
side_panel_width              = plate_width * 1.2;
servo_dia                     = 8;

side_panel_slot_width         = side_panel_width * 0.8;
side_panel_slot_height        = 2;
side_panel_slot_ypos          = [-9, +0.2];
side_panel_hole_d             = 3;

// Don't try to find a lot of sense in the calculations of the side panel polygon, this is an aesthetic choice.
side_panel_top                = -side_panel_height * (4/15);
side_panel_curve_start        = side_panel_width * (1/2.1);
side_panel_notch_y            = -side_panel_height * (7/14.2);
side_panel_bottom             = side_panel_height * (1/4.9);
side_panel_curve_end          = side_panel_height * (3/4.0);

hole_offset                   = 4;

hole_row_offsets              = [hole_offset * 2];

x_positions                   = [side_panel_width * 0.25, side_panel_width * 0.5, side_panel_width * 0.75];

tilt_angle                    = atan2((-side_panel_curve_end) - (-side_panel_bottom),
                                      side_panel_curve_start - side_panel_width);
servo_screw_d                 = 1.5;

servo_hole_distances          = [-19, -17, -15, -13, -11, -9, -6, 6, 9, 11, 13, 15];

module main_plate() {
  difference() {
    cube([plate_width, plate_height, plate_thickness], center=true);

    for (i = [0: len(cam_centers)-1]) {
      c = cam_centers[i];
      translate([c[0], c[1], 0]) {

        cube([lens_width, lens_height, plate_thickness+0.1], center=true);

        for (dx = [1, -1])
          for (dy = [1, -1])
            translate([dx * screw_offset_x, (dy == 1 ? screw_offset_y_top : screw_offset_y), 0])
              cylinder(h = plate_thickness+0.1, r = M2_dia/2, center=true, $fn=50);
      }
    }
  }
}

module connector_plate(y_offset) {
  translate([0, y_offset, 0])
    cube([connector_width, connector_height, plate_thickness], center=true);
}

module back_plate_geometry() {
  difference() {
    translate([-back_plate_width/2, -back_plate_height, -1])
      cube([back_plate_width, back_plate_height, plate_thickness], center = false);

    slot_width = (back_plate_width) * 0.8;
    slot_height = 2;

    slot_centers = [-back_plate_height * 0.2,
                    -back_plate_height * 0.5,
                    -back_plate_height * 0.8];

    for (center_y = slot_centers) {
      translate([0, center_y, 0])
        translate([-slot_width/2, 0, -1.1])
        cube([slot_width, slot_height, plate_thickness+0.2], center=false);
    }

    circle_dia = 3;
    circle_rad = circle_dia/2;

    for (cc = [-8, 0, 8])
      translate([cc, -back_plate_height/3, 0])
        cylinder(h = plate_thickness+0.2, r = circle_rad, center=true, $fn=50);
  }
}

module back_plate() {
  translate([0, plate_height/2 + 4, 0])
    rotate([90, 0, 0])
    back_plate_geometry();
}

function side_panel_servo_center() =
  [side_panel_width/2.0, -side_panel_height/2.0];

module dotted_line(y_pos, x_pos) {
  for (x = x_pos)
    translate([x, y_pos])
      circle(d = side_panel_hole_d, $fn = 50);
}

module side_panel_2d() {
  difference() {
    polygon(points = [[0, -side_panel_top],
                      [side_panel_curve_start, -side_panel_notch_y],
                      [side_panel_width, -side_panel_notch_y],
                      [side_panel_width, -side_panel_bottom],
                      [side_panel_curve_start, -side_panel_curve_end],
                      [0, -side_panel_curve_end]]);

    translate(side_panel_servo_center())
      circle(d = servo_dia, $fn = 50);

    for (dist = servo_hole_distances) {
      translate([side_panel_servo_center()[0] + dist * cos(tilt_angle),
                 side_panel_servo_center()[1] + dist * sin(tilt_angle)])
        circle(d = servo_screw_d, $fn = 50);
    }

    for (slot_y = side_panel_slot_ypos) {
      translate([(side_panel_width - side_panel_slot_width) / 2, slot_y])
        square([side_panel_slot_width, side_panel_slot_height]);
    }

    y_upper_base = side_panel_slot_ypos[1];
    y_lower_base = side_panel_slot_ypos[0];

    for (off = hole_row_offsets) {
      if (off >= 0)
        dotted_line(y_upper_base + off, x_positions);
      else
        dotted_line(y_lower_base + off, x_positions);
    }

    dotted_line(hole_offset * 5, [side_panel_width * 0.50,
                                  side_panel_width * 0.66,
                                  side_panel_width * +0.85]);
  }
}

module side_panel_3d() {
  linear_extrude(height = plate_thickness)
    side_panel_2d();
}

module side_panel(is_left=true) {
  side_panel_offset_y = plate_height/4;

  if (is_left)
    translate([-(plate_width/2), side_panel_offset_y, 0])
      mirror([1,0,0])
      rotate([0, 90, 0])
      side_panel_3d();
  else
    translate([plate_width/2, side_panel_offset_y, 0])
      rotate([0, 90, 0])
      side_panel_3d();
}

module head_mount() {
  rotate([0, 180, 0]) {
    union() {
      main_plate();
      connector_plate(connector_plate_offset_bottom);
      connector_plate(connector_plate_offset_top);
      back_plate();
      side_panel(true);
      side_panel(false);
    }
  }
}

color("white") {
  head_mount();
}
