/**
 * Module: Shared cylindrical fixtures and labels for visual shape tests.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <../../scad/lib/shapes3d.scad>

// Keep the uncut reference box at [16, 16, 24] for every specimen.
module cylindric_fixture(kind,
                         orientation="wlh",
                         anchor=[0, 0, 1],
                         color="SteelBlue") {
  if (kind == "cylinder") {
    cyl(d=16,
        h=24,
        $fn=48,
        orientation=orientation,
        anchor=anchor,
        color=color);
  } else if (kind == "frustum") {
    cyl(d1=16,
        d2=8,
        h=24,
        $fn=48,
        orientation=orientation,
        anchor=anchor,
        color=color);
  } else if (kind == "cone") {
    cyl(d1=16,
        d2=0,
        h=24,
        $fn=48,
        orientation=orientation,
        anchor=anchor,
        color=color);
  } else if (kind == "flats") {
    cylinder_cut(r=8,
                 h=24,
                 cut_w=6,
                 fn=48,
                 orientation=orientation,
                 anchor=anchor,
                 color=color);
  } else if (kind == "notches") {
    // One X notch and two Y notches make rotation of the profile visible.
    notched_circle(d=16,
                   h=24,
                   cutout_w=11,
                   x_cutouts_n=1,
                   y_cutouts_n=2,
                   fn=48,
                   convexity=4,
                   orientation=orientation,
                   anchor=anchor,
                   color=color);
  } else if (kind == "ring") {
    ring(od=16,
         d=9,
         h=24,
         fn=48,
         orientation=orientation,
         anchor=anchor,
         color=color);
  } else if (kind == "tapered ring") {
    ring(od1=16,
         od2=10,
         d1=10,
         d2=5,
         h=24,
         fn=48,
         orientation=orientation,
         anchor=anchor,
         color=color);
  } else {
    assert(false, str("Unknown cylindrical fixture: ", kind));
  }
}

module shape_test_label(label, size=3, halign="center") {
  color("#303746") {
    linear_extrude(height=0.2) {
      text(label, size=size, halign=halign, valign="center");
    }
  }
}

// Positive final X/Y/Z axes, with a dark sphere at the selected anchor.
module shape_test_axes(length=19) {
  color("Crimson") {
    cube([length, 0.35, 0.35]);
  }
  color("ForestGreen") {
    cube([0.35, length, 0.35]);
  }
  color("RoyalBlue") {
    cube([0.35, 0.35, length]);
  }
  color("#303746") {
    sphere(r=0.8, $fn=16);
  }
}
