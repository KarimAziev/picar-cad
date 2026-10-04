use <../../scad/lib/shapes2d.scad>
use <../../scad/lib/shapes3d.scad>

// Top row: thin extrusions of rounded_rect. Bottom row: cuboid.
// Columns: side list, independent radii, a square-corner override.
selections = [["top_left", "bottom_right"],
              [["top", 7], ["bottom", "10%"]],
              [["all", 6], ["top_left", 0]]];
labels     = ["opposite corners", "7 mm / 10%", "all 6, top-left 0"];

for (i = [0:2]) {
  translate([i * 50, 40, 0]) {
    color("SteelBlue") {
      linear_extrude(height=1) {
        rounded_rect([40, 24], r=6, side=selections[i], fn=48);
      }
    }
  }
  translate([i * 50, 0, 0]) {
    cuboid([40, 24, 8],
           r=6,
           side=selections[i],
           fn=48,
           center=false,
           color="DarkOrange");
  }
  translate([i * 50 + 20, -7, 0]) {
    color("DimGray") {
      linear_extrude(height=0.5) {
        text(labels[i], size=3, halign="center");
      }
    }
  }
}
