/**
  * Module: Plate joint example.
  *
  * Two mating plates share one joint configuration and full-length pin cutters.
  */
include <../../colors.scad>

use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>
use <../../lib/trapezoids.scad>
use <plate_joint.scad>

plate_thickness         = 6;

bolt_d                  = 3.2;
pin_d                   = 3.1;
pin_l                   = 30;

joint_l                 = 26;

plate_a_top             = 80;
plate_a_bottom          = 140;
plate_a_l               = 90;

plate_b_top             = plate_a_bottom;
plate_b_bottom          = 200;
plate_b_l               = 120;

plates_assembly_spacing = 50; // [0:1:50]
show_joint_bolts        = true;
show_joint_sizes        = false;

// Shared edge: Y=0. Plate A occupies +Y; plate B occupies -Y.
// The male tongue and female socket occupy Y=-joint_l..0.
// Positive assembly spacing slides plate B along -Y for inspection.

module common_plate_joint(mode, slot_mode=false, show_bolts=false, anchor, show_sizes) {
  plate_joint(plate_h=plate_thickness,
              bolt_d=bolt_d,
              pin_d=pin_d,
              pin_l=pin_l,
              l=joint_l,
              show_bolts=show_bolts,
              show_sizes=show_sizes,
              sizes_offset=[30, 0, 0],
              rail_w="70%",
              mode=mode,
              slot_mode=slot_mode,
              include_pin_holes=true,
              anchor=anchor,
              w=min(plate_a_bottom, plate_b_top),
              color=mode == "female" ? cobalt_blue_light_1 : cobalt_blue_dark_1);
}

module plate_a() {
  color(cobalt_blue_dark_1) {
    difference() {
      union() {
        color(cobalt_blue_dark_1) {
          with_anchor(anchor=[0, 1, 1],
                      size=[max(plate_a_bottom, plate_a_top), plate_a_l, plate_thickness],
                      centered=true) {
            linear_extrude(height=plate_thickness) {
              trapezoid(b=plate_a_bottom,
                        t=plate_a_top,
                        h=plate_a_l,
                        center=true);
            }
          }
        }
        common_plate_joint(mode="male", show_bolts=show_joint_bolts, show_sizes=show_joint_sizes);
      }
      // Subtract at parent scope: pins continue beyond the tongue into plate A.
      common_plate_joint(mode="male", slot_mode=true);
    }
  }
}

module plate_b() {
  color(cobalt_blue_light_1) {
    difference() {
      color(cobalt_blue_light_1) {
        with_anchor(anchor=[0, -1, 1],
                    size=[max(plate_b_bottom, plate_b_top), plate_b_l, plate_thickness],
                    centered=true) {
          linear_extrude(height=plate_thickness) {
            trapezoid(b=plate_b_bottom,
                      t=plate_b_top,
                      h=plate_b_l,
                      center=true);
          }
        }
      }
      // The same configuration cuts the socket, bolt holes and pin passages.
      common_plate_joint(mode="female", slot_mode=true);
    }
  }
}

module assembly_example() {
  plate_a();
  translate([0, -plates_assembly_spacing, 0]) {
    plate_b();
  }
}

assembly_example();