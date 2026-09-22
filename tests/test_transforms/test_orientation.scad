use <../../scad/lib/functions.scad>
use <../../scad/lib/shapes3d.scad>
use <../../scad/lib/transforms.scad>

logical_size = [20, 50, 3];
orientations = ["wlh", "whl", "lwh", "lhw", "hlw", "hwl"];
expected_sizes = [[20, 50, 3],
                  [20, 3, 50],
                  [50, 20, 3],
                  [50, 3, 20],
                  [3, 50, 20],
                  [3, 20, 50]];
identity = [[1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]];
test_anchors = [for (x = [-1 : 1], y = [-1 : 1], z = [-1 : 1]) [x, y, z]];
tol = 0.000001;

function box_corners(size) =
  [for (x = [-size[0] / 2, size[0] / 2],
        y = [-size[1] / 2, size[1] / 2],
        z = [0, size[2]]) [x, y, z]];

function reoriented_point(point, from, to) =
  let (from_size = orientation_size(from, logical_size),
       to_size = orientation_size(to, logical_size),
       centered = point - [0, 0, from_size[2] / 2],
       rotated = orientation_transform(from, to) * concat(centered, [1]))
  [rotated[0], rotated[1], rotated[2] + to_size[2] / 2];

function axis_values(points, axis) = [for (point = points) point[axis]];

function anchor_min(anchor_value, extent) =
  anchor_value == 1 ? 0 : anchor_value == 0 ? -extent / 2 : -extent;

function vectors_close(a, b, epsilon=tol) =
  len(a) == len(b)
  && len([for (i = [0 : len(a) - 1]) if (abs(a[i] - b[i]) <= epsilon) i])
     == len(a);

assert(normalize_anchor([undef, 0, undef]) == [1, 0, 1]);
assert(!is_orientation("xyz"));
assert(!is_orientation(undef));

for (i = [0 : len(orientations) - 1]) {
  orientation = orientations[i];
  matrix = orientation_matrix(orientation);

  assert(is_orientation(orientation));
  assert(orientation_size(orientation, logical_size) == expected_sizes[i]);
  assert(matrix * transpose_matrix(matrix) == identity);
}

for (from = orientations, to = orientations) {
  from_size = orientation_size(from, logical_size);
  to_size = orientation_size(to, logical_size);
  transform = orientation_transform(from, to);

  assert(transform * orientation_transform(to, from) == identity);

  for (anchor = test_anchors) {
    anchor_translation = to_anchor(anchor, to_size, centered=true);
    transformed = [for (point = box_corners(from_size))
                     reoriented_point(point, from, to) + anchor_translation];
    actual_min = [for (axis = [0 : 2]) min(axis_values(transformed, axis))];
    actual_max = [for (axis = [0 : 2]) max(axis_values(transformed, axis))];
    expected_min = [for (axis = [0 : 2]) anchor_min(anchor[axis], to_size[axis])];
    expected_max = expected_min + to_size;

    assert(vectors_close(actual_min, expected_min),
           str(from, " -> ", to, " has wrong minimum bounds at ", anchor,
               ": ", actual_min, " != ", expected_min));
    assert(vectors_close(actual_max, expected_max),
           str(from, " -> ", to, " has wrong maximum bounds at ", anchor,
               ": ", actual_max, " != ", expected_max));
  }
}

module orientation_fixture(orientation) {
  current_size = orientation_size(orientation, logical_size);
  marker_r = 1.2;

  color([0.7, 0.7, 0.7, 0.45]) {
    cuboid(size=current_size, anchor=[0, 0, 1]);
  }

  translate([0, 0, current_size[2] / 2]) {
    multmatrix(orientation_matrix(orientation)) {
      color("red") {
        translate([logical_size[0] / 2,
                   -logical_size[1] / 2 + marker_r * 2,
                   0]) {
          sphere(r=marker_r, $fn=12);
        }
      }
      color("green") {
        translate([-logical_size[0] / 2 + marker_r * 2,
                   logical_size[1] / 2,
                   0]) {
          sphere(r=marker_r, $fn=12);
        }
      }
      color("blue") {
        translate([-logical_size[0] / 2 + marker_r * 2,
                   -logical_size[1] / 2 + marker_r * 2,
                   logical_size[2] / 2]) {
          sphere(r=marker_r, $fn=12);
        }
      }
    }
  }
}

grid_spacing = 60;
for (from_index = [0 : len(orientations) - 1],
     to_index = [0 : len(orientations) - 1]) {
  from = orientations[from_index];
  to = orientations[to_index];

  translate([from_index * grid_spacing, to_index * grid_spacing, 0]) {
    with_orientation(from=from,
                     to=to,
                     size=logical_size,
                     anchor=[0, 0, 1]) {
      orientation_fixture(from);
    }
  }
}

echo("PASS: all orientation pairs preserve target bounds and anchors");
