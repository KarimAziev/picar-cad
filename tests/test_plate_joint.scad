include <../scad/parameters.scad>
include <../scad/rc_params.scad>
include <../scad/suspension/front_chassis/computed_params.scad>

use <../scad/components/plate_joint/plate_joint.scad>
use <../scad/lib/plist.scad>
use <../scad/placeholders/bolt.scad>
use <util.scad>

p = plate_joint_parameters(plate_h=6,
                           bolt_d=3.2,
                           w=140,
                           l=26,
                           pin_d=3.1,
                           pin_l=30);
assert_eq(plist_get("bolt_no_bore", p), true, "through holes by default");
assert_eq(plist_get("clearance", p),
          front_chassis_joint_clearance,
          "proven rail clearance");
assert_eq(plist_get("axial_clearance", p),
          front_chassis_joint_clearance,
          "proven axial fit");
assert_eq(plist_get("boolean_overlap", p),
          front_chassis_joint_boolean_overlap,
          "proven root overlap");
assert_eq(plist_get("pin_compensation", p),
          0.4,
          "sag_compensated_hole default");
assert_eq(plist_get("bolt_cut_overlap", p), 0.1, "counterbore cutter overlap");
assert_eq(plist_get("angle", p),
          front_chassis_joint_rail_angle,
          "proven angle");
assert_eq(plist_get("rail_corner_r", p),
          front_chassis_joint_rail_corner_r,
          "proven radius");
assert_eq(plist_get("pin_z", p), 3.75, "pin center includes base and rail");
assert_eq(plist_get("pin_spacing", p),
          plist_get("rail_w", p) * 0.675,
          "front joint pin spacing");
assert_eq((plist_get("pin_l", p) - plist_get("l", p)) / 2,
          2,
          "example pin engagement in each plate");

// Forwarding unset wrapper parameters must mean the same thing as omitting them.
u = plate_joint_parameters(plate_h=6,
                           bolt_d=3.2,
                           w=140,
                           l=26,
                           pin_d=3.1,
                           pin_l=30,
                           dovetail_rib=undef,
                           bolt_no_bore=undef,
                           include_pin_holes=undef,
                           pin_use_pad=undef,
                           pin_center=undef,
                           pin_direction=undef,
                           pin_pad_side=undef,
                           bolt_head_type=undef);
assert_eq(u, p, "forwarded undef options preserve defaults");
assert_eq(plist_get("bolt_bore_h", p),
          find_bolt_head_h(3.2, "socket"),
          "optional bore depth follows real head height");
assert_eq(plist_get("bolt_bore_d", p),
          find_bolt_head_d(3.2, "socket"),
          "optional bore diameter follows real head");

q = plate_joint_parameters(plate_h=6,
                           bolt_d=3,
                           w=54,
                           l=24,
                           rail_w="70%",
                           rail_h="50",
                           base_h="25%",
                           pin_d="50%",
                           pin_l="150%",
                           pin_spacing="50%",
                           pin_z="50%",
                           pin_pad_l="10%",
                           pin_pad_w="80%",
                           pin_compensation="10%",
                           clearance="5%",
                           axial_clearance="1%");
assert_eq(plist_get("rail_w", q), 37.8, "explicit percentage rail width");
assert_eq(plist_get("pin_z", q), 3, "explicit percentage pin height");
assert_eq(plist_get("pin_l", q), 36, "explicit percentage pin length");
assert_eq(plist_get("pin_compensation", q),
          0.15,
          "explicit compensation overrides reference default");
assert_eq(plist_get("clearance", q),
          0.15,
          "explicit clearance overrides reference default");
assert_eq(plist_get("axial_clearance", q), 0.24, "explicit axial clearance");

for (n = [0, 1, 2, 3]) {
  s = plate_joint_parameters(plate_h=6,
                             bolt_d=3,
                             w=54,
                             l=24,
                             rail_w=37.8,
                             bolt_n_center=n,
                             bolt_spacing_center=30);
  expected = n == 0 ? [] : n == 1 ? [0] : n == 2 ? [-15, 15] : [-15, 0, 15];
  assert_eq(plist_get("bolt_xs", s), expected, "explicit bolt count and span");
}
asymmetric = plate_joint_parameters(plate_h=8,
                                    bolt_d=3,
                                    w=54,
                                    l=24,
                                    base_h=1,
                                    rail_h=4);
assert_eq(plist_get("pin_z", asymmetric),
          5.5,
          "asymmetric skins preserve pin center");
assert_eq(plate_joint_dimension(0, 40, 8), 0, "zero is an explicit dimension");
assert_eq(plate_joint_dimension("12.5%", 40, 0), 5, "fractional percentage");
echo("PASS: plate joint reference defaults and wrapper contract");

module assert_joint_close(actual, expected, label) {
  error = is_list(actual) ? norm(actual - expected) : abs(actual - expected);
  assert_true(error < 0.000001, label);
}
assert_joint_close(plist_get("rail_w", p), 98, "automatic 70 percent rail");
assert_joint_close(plist_get("bolt_xs", p),
                   [-59.5, 0, 59.5],
                   "side bolts centered on the 15 percent strips");
assert_joint_close((plist_get("w", p) - plist_get("rail_w", p)) / 2,
                   21,
                   "each side strip is 21 mm");
narrow = plate_joint_parameters(plate_h=6, bolt_d=3, w=40, l=24);
assert_joint_close(plist_get("rail_w", narrow),
                   24.4,
                   "rail reduces when side bolts need room");
assert_joint_close(plist_get("bolt_xs", narrow),
                   [-16.1, 0, 16.1],
                   "centers follow reduced rail");
assert_joint_close(16.1 - 24.4 / 2 - 0.4 - 3 / 2,
                   2,
                   "socket-side bolt wall retains the layout pad");
explicit = plate_joint_parameters(plate_h=6,
                                  bolt_d=3,
                                  w=40,
                                  l=24,
                                  rail_w="70%");
assert_joint_close(plist_get("rail_w", explicit),
                   28,
                   "explicit width is not resized");
report_p = plate_joint_parameters(plate_h=6,
                                  bolt_d=3.2,
                                  w=140,
                                  l=26,
                                  pin_d=3.1,
                                  pin_l=30,
                                  include_pin_holes=true);
report = plate_joint_size_report(report_p);
function report_value(label) = [for (row = report) if (row[0] == label) row[1]][0];
assert_joint_close(report_value("Female floor after fit"),
                   1.1,
                   "report subtracts socket clearance");
assert_joint_close(report_value("Pin top cover"),
                   0.5,
                   "report includes vertical sag compensation");
assert_joint_close(report_value("Pin bottom cover"),
                   0.45,
                   "report includes shared rib tip geometry");
assert_joint_close(report_value("Side bolt to socket wall"),
                   8.5,
                   "report subtracts hole radius and socket clearance");

auto_width = plate_joint_parameters(plate_h=6,
                                    bolt_d=3.2,
                                    l=26,
                                    pin_l=30,
                                    include_pin_holes=true);
assert_joint_close(plist_get("w", auto_width),
                   160 / 3,
                   "automatic width reserves side-bolt material");
assert_joint_close(plist_get("rail_w", auto_width),
                   112 / 3,
                   "automatic width retains 70 percent rail");
assert_joint_close(plist_get("pin_l", auto_width),
                   30,
                   "pin length is preserved along Y");
assert_joint_close(plist_get("l", auto_width),
                   26,
                   "auto X does not alter the longitudinal dimension");
larger_pin = plate_joint_parameters(plate_h=12,
                                    bolt_d=3.2,
                                    l=26,
                                    pin_d=8,
                                    pin_l=30,
                                    include_pin_holes=true);
assert(plist_get("w", larger_pin) > plist_get("w", auto_width),
       "larger pin cross section can require a wider joint");

flipped_report = plate_joint_size_report(report_p, flip=true);
assert_joint_close([for (row = flipped_report) if (row[0] == "Pin axis Z in envelope") row[1]][0],
                   2.25,
                   "size table reports the flipped pin axis");
