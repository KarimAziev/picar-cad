use <../../scad/components/plate_joint/plate_joint.scad>
use <../../scad/lib/plist.scad>

part = "male";
rib = true;
pins = false;
pad = false;
relief = 0;
side = 1;
joint_anchor = [0, -1, 1];
bolts = 3;
show_bolts = false;
show_sizes = false;
flip = false;
pin_d = undef;
mirror_part = "male";

module joint(mode, slot=false, flipped=flip) {
  plate_joint(plate_h=6, bolt_d=3, w=54, l=24, mode=mode == "female_slots" ? "female" : mode,
              dovetail_rib=rib, include_pin_holes=pins, pin_use_pad=pad, pin_d=pin_d,
              relief_depth=relief, root_side=side, anchor=joint_anchor,
              bolt_n_center=bolts, slot_mode=slot, show_bolts=show_bolts, flip=flipped, show_sizes=show_sizes);
}

if (part == "male" || part == "female") {
  joint(part);
} else if (part == "collision") {
  intersection() {
    joint("male");
    joint("female");
  }
} else if (part == "socket_difference") {
  // Compare the female body to cutting the same socket out of a parent plate.
  difference() {
    difference() {
      translate([-27, -24 - (side == -1 ? 0.02 : 0), 0]) {
        cube([54, 24.02, 6]);
      }
      joint("female", slot=true);
    }
    joint("female");
  }
} else if (part == "base") {
  plate_joint_base(w=54, l=24, plate_h=6, base_h=1.5,
                   rail_w=37.8, rail_h=3, angle=20, rail_corner_r=0.5,
                   dovetail_rib=rib, anchor=joint_anchor, flip=flip);
}


module check_flip_difference() {
  // Reference reflection about the midpoint of the already-anchored envelope.
  module expected() {
    translate([0, 0, 6 * joint_anchor[2]]) {
      mirror([0, 0, 1]) {
        joint(mirror_part, slot=mirror_part == "female_slots", flipped=false);
      }
    }
  }
  module actual() {
    joint(mirror_part, slot=mirror_part == "female_slots", flipped=true);
  }
  difference() {
    actual();
    expected();
  }
  difference() {
    expected();
    actual();
  }
}

module check_pin_cover() {
  // A 3.1 mm pin bridges a 24 mm joint with 12 mm embedded in each parent.
  // Verify a thin sleeve of material around each passage, including below it.
  p = plate_joint_parameters(plate_h=6, bolt_d=3.2, w=54, l=24,
                             pin_d=3.1, include_pin_holes=true);
  module holes() {
    plate_joint_pin_holes(d=plist_get("pin_d", p), pin_l=plist_get("pin_l", p),
                          l=24, spacing=plist_get("pin_spacing", p),
                          z=plist_get("pin_z", p),
                          compensation=plist_get("pin_compensation", p));
  }
  module parents_and_joint() {
    difference() {
      union() {
        plate_joint_male(p);
        plate_joint_female(p);
        translate([-27, 0, 0]) {
          cube([54, 12, 6]);
        }
        translate([-27, -36, 0]) {
          cube([54, 12, 6]);
        }
      }
      // Cut at assembly scope so both parent plates receive the full passages.
      holes();
    }
  }
  difference() {
    difference() {
      plate_joint_pin_holes(d=3.6, pin_l=44, l=24,
                            spacing=plist_get("pin_spacing", p),
                            z=plist_get("pin_z", p), compensation=0.4);
      plate_joint_pin_holes(d=3.5, pin_l=48, l=24,
                            spacing=plist_get("pin_spacing", p),
                            z=plist_get("pin_z", p), compensation=0.4);
      // The male free tip intentionally stops short of its mating plate.
      // Exclude only that axial fit gap from the material-cover probe.
      translate([-27, -24.001, 0]) {
        cube([54, plist_get("axial_clearance", p) + 0.002, 6]);
      }
    }
    parents_and_joint();
  }
}

if (part == "flip_difference") {
  check_flip_difference();
}
if (part == "pin_cover_missing") {
  check_pin_cover();
}
