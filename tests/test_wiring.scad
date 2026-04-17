use <../scad/lib/wire.scad>

d         = 1.5;
x_spacing = 5;
y_spacing = 5;
step      = 4;

quality   = "medium";

pts       = [[0, 0, 0],
             [0, -5, -2],
             [-22, -15, -1],
             [-22, 10, -60],
             [-70, 10, -60]];

// [...["centripetal" | "uniform" | "chordal", step, color]]
examples  = [["uniform", quality, "blue"],
             ["centripetal", quality, "green"],
             ["chordal", quality, "red"],
             ["none", quality, "yellow"]];

union() {
  for (i = [0 : len(examples) - 1]) {
    let (mode=examples[i][0],
         quality = examples[i][1],
         colr = examples[i][2],
         x = i * x_spacing,
         y = i * y_spacing) {
      translate([x, y, 0]) {
        wire_path(points=pts,
                  d=1.5,
                  colr=colr,
                  mode=mode,
                  quality=quality,
                  put_joints=false);
      }
    }
  }
}

union() {
  for (i = [0 : len(examples) - 1]) {
    let (mode=examples[i][0],
         quality = examples[i][1],
         colr = examples[i][2],
         x = i * x_spacing,
         y = i * y_spacing) {
      translate([-x, -y, 0]) {
        wire_bundle(points=pts,
                    d=1.5,
                    colors=["gold", "grey", "white"],
                    mode=mode,
                    quality=quality,
                    put_joints=false);
      }
    }
  }
}
