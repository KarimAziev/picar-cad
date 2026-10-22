use <../scad/head/head_neck.scad>
use <../scad/head/head_mount.scad>
include <../scad/parameters.scad>
use <../scad/lib/functions.scad>

function close(a, b, tolerance=0.00001) =
  (is_num(a) ? abs(a - b) : norm(a - b)) < tolerance;

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

stop = head_neck_lower_tilt_stop();
assert(stop > 32.8 && stop < 33);
axis = head_tilt_axis_position();
plate_corner = [head_front_thickness - axis[0], -axis[1], 0];
assert(abs(_head_neck_tilt_pivot()[0] + rotZ(plate_corner, stop)[0]) < 1e-8);
assert(_head_neck_tilt_pivot()[0] + rotZ(plate_corner, stop - 0.1)[0] < 0);
assert(_head_neck_tilt_pivot()[0] + rotZ(plate_corner, stop + 0.1)[0] > 0);
echo("PASS: camera plate reaches the neck upright at the geometric tilt stop");

// Clipping must retain edge/plane intersections even without a corner in the slab.
box = _head_neck_box([-2, -3, -10], [2, 3, 10]);
clipped = _head_neck_clip_box(box, [-1, 1]);
assert(len(clipped) == 8);
assert(_head_neck_bounds(clipped) == [[-2, -3, -1], [2, 3, 1]]);
assert(_head_neck_clip_box(box, [11, 12]) == []);
assert(close(_head_neck_pan_front([[3, 4, 0]], [-180, 180]), 5));
assert(close(_head_neck_pan_front([[3, 4, 0]], [0, 0]), 4));
assert(close(_head_neck_pan_front([[3, 4, 0]], [360, 720]), 5));

// Exact cylinder-section radius of a fully revolved rectangular envelope.
orbit_box = _head_neck_box([10, -5, -2], [20, 5, 2]);
orbit_reach = _head_neck_tilt_box_front(orbit_box, [8, 9], [-180, 180],
                                       [-180, 180], [0, 0, 0], [0, 0, 0]);
assert(close(orbit_reach, sqrt(20 * 20 + 5 * 5 + 2 * 2 - 8 * 8)));

// Endpoint poses, fractional travel limits and slab crossings must all fit.
// Dense tilt samples independently check the analytic event selection.
for (pan_range=[[-179, 179], [-27, 43], [145, 235], [0, 0]],
     tilt_range=[[-90, 90], [-33.7, 19.2], [70, 110]]) {
  z_range = [1.5, 27.9];
  reach = head_neck_swept_front_reach(z_range, pan_range, tilt_range);
  moving = _head_neck_tilting_points();
  fixed = _head_neck_fixed_points();
  offset = _head_neck_pan_offset();
  pivot = _head_neck_tilt_pivot();
  sampled = max([for (i=[0:120])
    let (tilt=tilt_range[0] + (tilt_range[1] - tilt_range[0]) * i / 120,
         points=concat([for (p=fixed) rotZ(p, -90) + offset],
                       [for (p=moving)
                         rotZ(pivot + rotX(rotZ(p, tilt), 90), -90) + offset]))
    max([for (j=[0:8:len(points) - 1])
      _head_neck_pan_front(_head_neck_clip_box(
        [for (k=[0:7]) points[j + k]], z_range), pan_range)])]);
  assert(sampled <= reach + 1e-7, [pan_range, tilt_range, sampled, reach]);
  assert(reach - sampled < 0.4, [pan_range, tilt_range, sampled, reach]);
}

assert(head_neck_swept_front_reach([1000, 1001]) == 0);
let ($t=0.75) {
  assert(close(head_neck_swept_front_reach([1.5, 27.9]),
               let ($t=0) head_neck_swept_front_reach([1.5, 27.9])));
}
echo("PASS: continuous pan/tilt reach, clipped component envelopes and animation independence");
