use <../scad/head/head_neck.scad>

function close(a, b, tolerance=0.00001) = norm(a - b) < tolerance;

$t=0;
bbox       = head_neck_bbox(0, 0);
bounds     = head_neck_bounds(0, 0);
assert(len(bbox) == 3 && min(bbox) > 0);
assert(close(bbox, bounds[1] - bounds[0]));

// A quarter-turn swaps X/Y; translation and pan cannot change Z span.
quarter    = head_neck_bbox(90, 0);
assert(close(quarter, [bbox[1], bbox[0], bbox[2]]));
assert(close(head_neck_bbox(0, 0, false), [bbox[1], bbox[0], bbox[2]]));
assert(close(head_neck_bbox(10, 23, false), head_neck_bbox(70, 23, false)));
assert(close(head_neck_bbox(-31, -47), head_neck_bbox(329, 313)));

max_h      = head_neck_max_height();
max_z      = head_neck_max_z();
max_z_base = head_neck_max_z(false);
mount_z    = bounds[1][2] - head_neck_bounds(0, 0, false)[1][2];
assert(abs(max_z - max_z_base - mount_z) < 0.00001);

// A dense full-turn sweep approaches both analytic maxima, including
// non-cardinal angles; it must never exceed them.
samples    = [for (tilt=[-180:2:180]) head_neck_bounds(37, tilt)];
heights    = [for (b=samples) b[1][2] - b[0][2]];
tops       = [for (b=samples) b[1][2]];
assert(max(heights) <= max_h + 0.00001);
assert(max(tops) <= max_z + 0.00001);
assert(max_h - max(heights) < 0.02);
assert(max_z - max(tops) < 0.02);
assert(max_z > max([for (a=[-180,-90, 0, 90, 180])
  head_neck_bounds(0, a)[1][2]]) + 0.1);

// Highest Z is independent of pan, also at fractional angles.
for (pan=[-179, -32.5, 0, 90, 179]) {
  assert(abs(head_neck_bounds(pan, 28.5)[1][2]
             - head_neck_bounds(0, 28.5)[1][2]) < 0.00001);
}

// Match the existing servo placeholder's animation transform.
let ($t=0.25) {
  assert(close(head_neck_bbox(0, 0),
               let ($t=0) head_neck_bbox(0, 22.5)));
}
let ($t=0.75) {
  assert(close(head_neck_bbox(0, 0),
               let ($t=0) head_neck_bbox(0, -67.5)));
}
echo("PASS: assembled head bounds, rotation invariants, analytic height and mounting clearance");
