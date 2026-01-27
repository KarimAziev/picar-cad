include <../parameters.scad>

use <../lib/shapes3d.scad>

washer_shoulder_d       = wheel_bearing_bore_d + 0.6;
washer_shoulder_outer_d = wheel_bearing_shoulder_d;
washer_thickness        = 1.8;

module washer_shoulder() {
  ring(d=washer_shoulder_d,
       outer_d=washer_shoulder_outer_d,
       h=washer_thickness,
       fn=360);
}

washer_shoulder();