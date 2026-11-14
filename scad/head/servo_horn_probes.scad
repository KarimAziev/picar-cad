/**
  * Module: Printable single-arm servo-horn mounting probes.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../parameters.scad>

use <../lib/placement.scad>
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/text.scad>
use <../lib/transforms.scad>
use <../placeholders/servo_horn.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  servo_horn_probes
  ─────────────────────────────────────────────────────────────────────────────
  Arrange labeled mounting coupons with single-arm recesses facing upward.

  **Parameters:**
  - `initial_screws_gaps`: Edge-to-edge hub-to-first-hole gaps in millimeters.
  - `pl`: Horn dimensions; missing properties use servo_horn_default_plist.
    Each coupon uses shape="single" and its labeled initial_screws_gap.
  - `seat_h`: Material thickness beneath the horn-arm recess.
  - `clearance`: XY recess allowance per side, including the hub opening.
  - `screw_clearance`: Radial screw-hole allowance; hole centers stay fixed.
  - `gap`: Edge-to-edge separation of the printable coupons along X.
  - `anchor`: Anchor of the complete arrangement's reference box.

  Recess depth follows the horn's arm thickness. The hub opening and all arm
  screw holes pass through the coupon. Labels are engraved 0.4 mm deep.
  With the default anchor, the arrangement starts at zero on X, Y, and Z.

  **Examples:**
  ```scad
  servo_horn_probes();
  servo_horn_probes(initial_screws_gaps=[1.9]);
  ```
 */
module servo_horn_probes(initial_screws_gaps=[1.8, 1.9, 2.0],
                         pl=pan_servo_horn_slot_plist,
                         seat_h=2,
                         clearance=pan_servo_horn_recess_clearance,
                         screw_clearance=pan_servo_horn_screw_clearance,
                         gap=3,
                         anchor=[1, 1, 1]) {
  assert(is_list(initial_screws_gaps) && len(initial_screws_gaps) > 0);
  assert(plist_is(pl));
  assert(seat_h > 0 && clearance >= 0 && screw_clearance >= 0 && gap > 0);

  props = plist_merge(servo_horn_default_plist, pl);
  arm_l = plist_get("arm_len", props);
  recess_h = plist_get("thickness", props);
  hub_r = plist_get("center_ring_dia", props) / 2 + clearance;
  pad = 2;
  label_h = 4;
  label_depth = 0.4;
  eps = 0.01;
  w = max(2 * hub_r,
          plist_get("arm_bottom_width", props) + 2 * clearance,
          plist_get("arm_top_width", props) + 2 * clearance) + 2 * pad;
  hub_y = 2 * pad + label_h + hub_r;
  l = hub_y + max(arm_l + clearance, hub_r) + pad;
  h = seat_h + recess_h;
  count = len(initial_screws_gaps);
  size = [count * w + (count - 1) * gap, l, h];

  assert(arm_l > 0 && recess_h > 0 && h > label_depth);
  with_anchor(size=size, anchor=anchor) {
    columns_children(cols=count, w=w, gap=gap) {
      initial_gap = initial_screws_gaps[$i];
      assert(is_num(initial_gap) && initial_gap >= 0);
      horn = plist_merge(props,
                         ["shape", "single",
                          "initial_screws_gap", initial_gap]);
      label = str(initial_gap, initial_gap == floor(initial_gap) ? ".0" : "");

      translate([-w / 2, 0, 0]) {
        difference() {
          cuboid([w, l, h], anchor=[1, 1, 1], r_factor=0.2);
          translate([w / 2, hub_y, seat_h]) {
            linear_extrude(height=recess_h + eps) {
              servo_horn_profile_from_plist(pl=horn,
                                            mode="shape",
                                            clearance=clearance);
            }
          }
          translate([w / 2, hub_y, -eps]) {
            cylinder(r=hub_r, h=h + 2 * eps, $fn=80);
            linear_extrude(height=h + 2 * eps) {
              servo_horn_profile_from_plist(pl=horn,
                                            mode="holes",
                                            screw_clearance=screw_clearance);
            }
          }
          translate([w / 2, pad + label_h / 2, h - label_depth]) {
            text_fit(txt=label,
                     x=w - 2 * pad,
                     y=label_h,
                     h=label_depth + eps,
                     font="Liberation Sans:style=Bold");
          }
        }
      }
    }
  }
}

servo_horn_probes();
