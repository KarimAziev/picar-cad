use <../lib/shapes3d.scad>

module stairs_solid(total_size=[100, 50, 40], step_count=5, center=true) {
  length = total_size[0];
  width  = total_size[1];
  height = total_size[2];

  step_count = max(1, round(step_count));
  run  = length / step_count;
  rise = height / step_count;

  translate([center ? -length / 2 : 0, center ? -width / 2 : 0, 0]) {
    for (i = [0 : step_count-1]) {
      translate([i * run, 0, i * rise]) {
        cube([length - i * run, width, rise]);
      }
    }
  }
}
