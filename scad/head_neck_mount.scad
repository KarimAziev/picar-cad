include <parameters.scad>
use <util.scad>
use <placeholders/servo.scad>

module head_neck_servo_mount(size=[cam_pan_servo_slot_width, cam_pan_servo_slot_height],
                             screws_dia=cam_pan_servo_screw_dia,
                             screws_offset=cam_pan_servo_screws_offset,
                             thickness=cam_pan_servo_slot_thickness,
                             extra_w=2,
                             extra_h=2) {
  w = size[0] + (screws_offset * 2 + screws_dia * 2) + extra_w;
  h = size[1] + extra_h;
  linear_extrude(height = thickness, center=true) {
    difference() {
      rounded_rect_two(size = [w, h], r = h * 0.1, center = true);
      servo_slot_2d(size=size, screws_dia=screws_dia, screws_offset=screws_offset);
    }
  }
}

module head_neck_tilt_servo_mount(size=[cam_tilt_servo_slot_width, cam_tilt_servo_slot_height],
                                  screws_dia=cam_tilt_servo_screw_dia,
                                  screws_offset=cam_tilt_servo_screws_offset,
                                  servo_height=cam_pan_servo_height,
                                  thickness=cam_tilt_servo_slot_thickness,
                                  extra_w=2,
                                  extra_h=2) {
  w = size[0] + (screws_offset * 2 + screws_dia * 2) + extra_w;

  h = size[1] + extra_h;
  linear_extrude(height = thickness, center=true) {
    union() {
      square(size = [w, servo_height], center=true);
      translate([0, servo_height * 0.5 + h * 0.5, 0]) {
        difference() {
          rounded_rect_two(size = [w, h], r = h * 0.1, center = true);
          servo_slot_2d(size=size, screws_dia=screws_dia, screws_offset=screws_offset);
        }
      }
    }
  }
}

module head_neck_mount(pan_servo_size=[cam_pan_servo_slot_width, cam_pan_servo_slot_height],
                       pan_screws_dia=cam_pan_servo_screw_dia,
                       pan_screws_offset=cam_pan_servo_screws_offset,
                       pan_thickness=cam_pan_servo_slot_thickness,
                       pan_servo_height=cam_pan_servo_height,
                       pan_servo_extra_w=pan_servo_extra_w,
                       pan_servo_extra_h=pan_servo_extra_h,
                       tilt_servo_size=[cam_tilt_servo_slot_width, cam_tilt_servo_slot_height],
                       tilt_screws_dia=cam_tilt_servo_screw_dia,
                       tilt_screws_offset=cam_tilt_servo_screws_offset,
                       tilt_thickness=cam_tilt_servo_slot_thickness,
                       tilt_servo_extra_w=2,
                       tilt_servo_extra_h=2) {
  color("white") {
    union() {
      rotate([180, 0, 0]) {
        head_neck_servo_mount(size=pan_servo_size,
                              screws_dia=pan_screws_dia,
                              screws_offset=pan_screws_offset,
                              thickness=pan_thickness,
                              extra_w=pan_servo_extra_w,
                              extra_h=pan_servo_extra_h);
      }
      rotate([90, 0, 0]) {
        translate([0, tilt_servo_size[1] * 0.5 + pan_servo_size[1] * 0.5 - pan_thickness - tilt_servo_extra_w * 0.5,
                   -pan_servo_size[1] * 0.5 - pan_servo_extra_h * 0.5 - tilt_thickness * 0.5]) {
          head_neck_tilt_servo_mount(size=tilt_servo_size,
                                     screws_dia=tilt_screws_dia,
                                     screws_offset=tilt_screws_offset,
                                     thickness=tilt_thickness,
                                     servo_height=pan_servo_height,
                                     extra_w=tilt_servo_extra_w,
                                     extra_h=tilt_servo_extra_h);
        }
      }
    }
  }
}

module head_neck_assembly() {
  union() {
    union() {
      head_neck_mount();
      translate([0, 0, cam_pan_servo_height * 0.5 - 2]) {
        servo(size=[cam_pan_servo_slot_width, cam_pan_servo_slot_height - 1, cam_pan_servo_height],
              servo_offset=cam_pan_servo_screws_offset);
      }
    }

    translate([0, -cam_tilt_servo_slot_height * 0.5 + pan_servo_extra_h - 1,
               cam_pan_servo_height + cam_tilt_servo_slot_height * 0.5]) {
      rotate([90, 0, 0]) {
        servo(size=[cam_tilt_servo_slot_width, cam_tilt_servo_slot_height - 1, cam_tilt_servo_height],
              servo_offset=cam_tilt_servo_screws_offset);
      }
    }
  }
}

head_neck_assembly();