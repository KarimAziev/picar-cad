use <../../scad/components/plate_joint/example.scad>
use <../../scad/components/plate_joint/plate_joint.scad>
part = "plate_a";

// Match a typical common wrapper: these options arrive explicitly as undef.
module wrapper(mode, slot_mode, show_bolts, anchor, flip) {
  plate_joint(plate_h=6, bolt_d=3.2, w=140, l=26, pin_l=30,
              include_pin_holes=true, mode=mode, slot_mode=slot_mode,
              show_bolts=show_bolts, anchor=anchor, flip=flip);
}
module direct() {
  plate_joint(plate_h=6, bolt_d=3.2, w=140, l=26, pin_l=30, include_pin_holes=true);
}
if (part == "plate_a") {
  plate_a();
} else if (part == "plate_b") {
  plate_b();
} else if (part == "collision") {
  intersection() {
    plate_a();
    plate_b();
  }
} else if (part == "undef_difference") {
  difference() {
    wrapper();
    direct();
  }
  difference() {
    direct();
    wrapper();
  }
} else if (part == "male_slots_difference") {
  // At Y=1, the pin cutters must continue into plate A beyond the tongue.
  difference() {
    translate([33.075, 1, 3.75]) {
      rotate([90, 0, 0]) {
        cylinder(d=1, h=1, $fn=20);
      }
    }
    wrapper(mode="male", slot_mode=true);
  }
} else if (part == "thin_bolt_slots_difference") {
  // A thin plate's default male cutters must be plain shafts, without head recesses.
  difference() {
    plate_joint(plate_h=2, bolt_d=3, w=54, l=24, mode="male", slot_mode=true);
    for (x = [-22.95, 0, 22.95]) {
      translate([x, -12, -0.1]) {
        cylinder(d=3, h=2.2, $fn=60);
      }
    }
  }
}

if (part == "parent_pin_empty") {
  // Check the actual drilled parent material, beyond each end of the tongue.
  intersection() {
    plate_a();
    translate([33.075, 1, 3.75]) {
      sphere(r=0.3, $fn=20);
    }
  }
  intersection() {
    plate_b();
    translate([-33.075, -27, 3.75]) {
      sphere(r=0.3, $fn=20);
    }
  }
}

if (part == "auto_width_male" || part == "auto_width_female") {
  plate_joint(plate_h=6, bolt_d=3.2, l=26, pin_l=30,
              include_pin_holes=true, mode=part == "auto_width_male" ? "male" : "female");
}
if (part == "auto_width_collision") {
  intersection() {
    plate_joint(plate_h=6, bolt_d=3.2, l=26, pin_l=30, include_pin_holes=true);
    plate_joint(plate_h=6, bolt_d=3.2, l=26, pin_l=30, include_pin_holes=true, mode="female");
  }
}
