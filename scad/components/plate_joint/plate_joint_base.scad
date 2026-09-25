/**
  * Module: Numeric plate joint profile.
  *
  * Standalone plate joint; dimensions are in millimeters.
  */

use <../../lib/shapes3d.scad>
use <../../lib/slider.scad>
use <../../lib/transforms.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  plate_joint_base
  ─────────────────────────────────────────────────────────────────────────────

  Extrude the numeric joint profile inside the nominal plate envelope.

  **Parameters:**
  - `color`: Optional display color.
  - `w`: Nominal X width.
  - `l`: Nominal Y length.
  - `base_h`: Base thickness below the top face.
  - `rail_w`: Rail width.
  - `plate_h`: Nominal plate thickness.
  - `angle`: Rail flank angle in degrees.
  - `rail_h`: Rail height.
  - `rail_corner_r`: Rail corner radius.
  - `dovetail_rib`: Select the double-taper rib.
  - `extra_h`: Increase base thickness and top Z by this amount.
  - `extra_w`: Additional full base width.
  - `extra_l`: Additional full length, split between both ends.
  - `clearance`: Outward profile offset for a socket cutter.
  - `edge_land`: Optional relief land.
  - `relief_depth`: Optional relief depth.
  - `anchor`: Nominal envelope anchor; default spans X=-w/2..w/2, Y=-l..0, Z=0..plate_h.
  - `flip`: Mirror in Z about plate_h/2 before anchoring, including any extra geometry.
 */
module plate_joint_base(color=undef,
                        w,
                        l,
                        base_h,
                        rail_w,
                        plate_h,
                        angle,
                        rail_h,
                        rail_corner_r,
                        dovetail_rib,
                        extra_h=0.0,
                        extra_w=0.0,
                        extra_l=0.0,
                        clearance=0,
                        edge_land,
                        relief_depth,
                        anchor=[0, -1, 1],
                        flip=false) {
  _base_h = base_h + extra_h;
  base_w = w + extra_w;

  with_anchor(anchor=anchor, size=[w, l, plate_h], centered=true) {
    _plate_joint_flip(plate_h, flip=flip) {
      translate([0, -l / 2 - extra_l / 2, plate_h + extra_h]) {
        rotate([-90, 0, 0]) {
          maybe_color(color) {
            linear_extrude(height=l + extra_l, center=false) {
              offset(delta=clearance) {
                slider_dovetail_rail_2d(base_w=base_w,
                                        base_h=_base_h,
                                        w=rail_w,
                                        h=rail_h,
                                        angle=angle,
                                        r=rail_corner_r,
                                        center_y=false,
                                        center_x=true,
                                        reverse=true,
                                        use_dovetail_rib=dovetail_rib,
                                        edge_land=dovetail_rib ? edge_land : undef,
                                        relief_depth=relief_depth);
              }
            }
          }
        }
      }
    }
  }
}

// Reflect within the nominal Z envelope. Keep this inside the anchor transform:
// reflecting already-anchored geometry about Z=0 would move bottom/top anchors.
module _plate_joint_flip(plate_h, flip=false) {
  assert(is_bool(flip), "flip must be a boolean");
  if (flip) {
    translate([0, 0, plate_h]) {
      mirror([0, 0, 1]) {
        children();
      }
    }
  } else {
    children();
  }
}
