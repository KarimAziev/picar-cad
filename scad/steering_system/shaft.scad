include <../parameters.scad>
use <../util.scad>
use <../placeholders/servo.scad>

module shaft(d=knuckle_shaft_dia, h=knuckle_shaft_len) {
  rotate([0, 90, 0]) {
    linear_extrude(height=h, center=true) {
      circle(r=d / 2, $fn=120);
    }
  }
}

// module bent_cylinder(d=knuckle_shaft_dia,
//                      upper_horiz_len=knuckle_shaft_upper_horiz_len,
//                      vertical_len=knuckle_shaft_vertical_len,
//                      lower_horiz_len=knuckle_shaft_lower_horiz_len,
//                      $fn=64) {
//   r = d / 2;
//   union() {

//     translate([upper_horiz_len + d, 0, 0]) {
//       rotate([90, 0, 180]) {
//         rotate_extrude(angle = -90, $fn = $fn)
//           translate([r, 0]) {
//           circle(r = r, $fn = $fn);
//         }
//       }
//       translate([0, r, -r]) {
//         rotate_extrude(angle = -90, $fn = $fn)
//           translate([r, 0]) {
//           circle(r = r, $fn = $fn);
//         }
//         translate([r, 0, 0]) {
//           rotate([-90, 0, 0]) {
//             cylinder(h = lower_horiz_len, r = r, center = false, $fn=$fn);
//           }
//         }
//       }
//     }

//     translate([upper_horiz_len + r, 0, 0]) {
//       cylinder(h = vertical_len, r = r, center = false, $fn=$fn);
//       translate([-upper_horiz_len - r, 0, vertical_len + r]) {
//         rotate([0, 90, 0]) {
//           cylinder(h = upper_horiz_len, r = r, center = false, $fn=$fn);
//         }
//       }
//       translate([- r, 0, vertical_len]) {
//         rotate([90, 0, 0]) {
//           rotate_extrude(angle = 90, $fn = $fn)
//             translate([r, 0]) {
//             circle(r = r, $fn = $fn);
//           }
//         }
//       }
//     }
//   }
// }

module bent_cylinder(d=knuckle_shaft_dia,
                     upper_horiz_len=knuckle_shaft_upper_horiz_len,
                     vertical_len=knuckle_shaft_vertical_len,
                     lower_horiz_len=knuckle_shaft_lower_horiz_len,
                     $fn=64) {
  r = d / 2;
  union() {

    translate([0, 0, 0]) {
      translate([0, -upper_horiz_len, vertical_len + r]) {
        rotate([90, 0, 0]) {
          cylinder(h = upper_horiz_len, r = r, center = false, $fn=$fn);
        }
        // translate([0, 0, -vertical_len]) {
        //   cylinder(h = vertical_len, r = r, center = false, $fn=$fn);
        // }
      }
      translate([0, -upper_horiz_len - d, vertical_len]) {
        rotate([90, 0, -90]) {
          rotate_extrude(angle = 90, $fn = $fn)
            translate([r, 0]) {
            circle(r = r, $fn = $fn);
          }
        }
      }
    }

    // translate([upper_horiz_len + d, 0, 0]) {
    //   rotate([90, 0, 180]) {
    //     rotate_extrude(angle = -90, $fn = $fn)
    //       translate([r, 0]) {
    //       circle(r = r, $fn = $fn);
    //     }
    //   }
    //   translate([0, r, -r]) {
    //     rotate_extrude(angle = -90, $fn = $fn)
    //       translate([r, 0]) {
    //       circle(r = r, $fn = $fn);
    //     }
    //     translate([r, 0, 0]) {
    //       rotate([-90, 0, 0]) {
    //         cylinder(h = lower_horiz_len, r = r, center = false, $fn=$fn);
    //       }
    //     }
    //   }
    // }
  }
}

bent_cylinder();