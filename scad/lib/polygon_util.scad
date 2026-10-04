/**
  * Module: Polygon helpers
  *
  * This file provides small helpers for extracting extents from 2D point lists.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

/**
  ─────────────────────────────────────────────────────────────────────────────
  point_x
  ─────────────────────────────────────────────────────────────────────────────

  Return the X coordinate of a 2D point.

  **Parameters:**
  - `p`: Point vector where `p[0]` is the X component.

  **Returns:**
  The first element of `p`.
 */
use <functions.scad>

function point_x(p) = p[0];

/**
  ─────────────────────────────────────────────────────────────────────────────
  point_y
  ─────────────────────────────────────────────────────────────────────────────

  Return the Y coordinate of a 2D point.

  **Parameters:**
  - `p`: Point vector where `p[1]` is the Y component.

  **Returns:**
  The second element of `p`.
 */
function point_y(p) = p[1];

/**
  ─────────────────────────────────────────────────────────────────────────────
  polygon_min_y
  ─────────────────────────────────────────────────────────────────────────────

  Return the minimum Y value found in a polygon point list.

  **Parameters:**
  - `pts`: List of 2D points.

  **Returns:**
  The smallest Y coordinate in `pts`.
 */
function polygon_min_y(pts) = min([for (p = pts) point_y(p)]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  polygon_max_y
  ─────────────────────────────────────────────────────────────────────────────

  Return the maximum Y value found in a polygon point list.

  **Parameters:**
  - `pts`: List of 2D points.

  **Returns:**
  The largest Y coordinate in `pts`.
 */
function polygon_max_y(pts) = max([for (p = pts) point_y(p)]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  polygon_y_len
  ─────────────────────────────────────────────────────────────────────────────

  Return the height of a polygon's axis-aligned bounding box.

  **Parameters:**
  - `pts`: List of 2D points.

  **Returns:**
  `polygon_max_y(pts) - polygon_min_y(pts)`.
 */
function polygon_y_len(pts) = polygon_max_y(pts) - polygon_min_y(pts);

/**
  ─────────────────────────────────────────────────────────────────────────────
  polygon_min_x
  ─────────────────────────────────────────────────────────────────────────────

  Return the minimum X value found in a polygon point list.

  **Parameters:**
  - `pts`: List of 2D points.

  **Returns:**
  The smallest X coordinate in `pts`.
 */
function polygon_min_x(pts) = min([for (p = pts) point_x(p)]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  polygon_max_x
  ─────────────────────────────────────────────────────────────────────────────

  Return the maximum X value found in a polygon point list.

  **Parameters:**
  - `pts`: List of 2D points.

  **Returns:**
  The largest X coordinate in `pts`.
 */
function polygon_max_x(pts) = max([for (p = pts) point_x(p)]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  polygon_x_len
  ─────────────────────────────────────────────────────────────────────────────

  Return the width of a polygon's axis-aligned bounding box.

  **Parameters:**
  - `pts`: List of 2D points.

  **Returns:**
  `polygon_max_x(pts) - polygon_min_x(pts)`.
 */
function polygon_x_len(pts) = polygon_max_x(pts) - polygon_min_x(pts);

/**
  ─────────────────────────────────────────────────────────────────────────────
  polygon_size
  ─────────────────────────────────────────────────────────────────────────────

  Return the axis-aligned bounding-box size of a polygon point list.

  **Parameters:**
  - `pts`: List of 2D points. Empty or `undef` input returns `[0, 0]`.

  **Returns:**
  `[width, height]` derived from the polygon extents.
 */
function polygon_size(pts) = is_undef(pts) || len(pts) == 0
  ? [0, 0]
  : [polygon_x_len(pts), polygon_y_len(pts)];

// Compare two scalar values with direction.
// Returns:
//   -1 if a should come before b
//    1 if a should come after b
//    0 if equal

function centroid(pts) = [sum([for (p=pts) p[0]]) / len(pts),
                          sum([for (p=pts) p[1]]) / len(pts)];

// OpenSCAD atan2 form is atan2(y, x), result in degrees
function angle_from(c, p) = atan2(p[1] - c[1], p[0] - c[0]);

// normalize to 0..360
function norm_ang(a) = a < 0 ? a + 360 : a;

// clockwise from +X axis
function cw_angle(c, p) = 360 - norm_ang(angle_from(c, p));

// --- simple sort by numeric key ---
function _insert_by_key(x, xs, keyf) =
  len(xs) == 0 ? [x] :
  keyf(x) <= keyf(xs[0])
  ? concat([x], xs)
  : concat([xs[0]],
           _insert_by_key(x, [for (i=[1:len(xs)-1]) xs[i]], keyf));

function _sort_by_key(elems, keyf, i=0, acc=[]) =
  i >= len(elems) ? acc :
  _sort_by_key(elems, keyf, i + 1, _insert_by_key(elems[i], acc, keyf));

// main
function sort_clockwise(pts) =
  let (c = centroid(pts))
  _sort_by_key(pts, function(p) cw_angle(c, p));

function v_add(a, b) = [a[0] + b[0], a[1] + b[1]];
function v_sub(a, b) = [a[0] - b[0], a[1] - b[1]];
function v_mul(a, s) = [a[0] * s, a[1] * s];
function v_len(v) = sqrt(v[0] * v[0] + v[1] * v[1]);
function v_unit(v) =
  let (l = v_len(v))
  l == 0 ? [0, 0] : [v[0] / l, v[1] / l];

function v_perp_left(v) = [-v[1], v[0]];
function v_perp_right(v) = [v[1], -v[0]];

// Signed area: >0 => CCW, <0 => CW
function polygon_signed_area(pts) =
  len(pts) < 3 ? 0 :
  sum([for (i = [0 : len(pts) - 1])
    let (p0 = pts[i],
         p1 = pts[(i + 1) % len(pts)])
    p0[0] * p1[1] - p1[0] * p0[1]]) / 2;

function polygon_is_ccw(pts) = polygon_signed_area(pts) > 0;

// Outward unit normal for edge p0->p1
function edge_outward_normal(p0, p1, is_ccw=true) =
  let (e = v_sub(p1, p0))
  v_unit(is_ccw ? v_perp_right(e) : v_perp_left(e));

// Averaged outward direction at vertex i
function polygon_vertex_outward_dir(pts, i) =
  let (n = len(pts),
       prev = pts[(i - 1 + n) % n],
       curr = pts[i],
       next = pts[(i + 1) % n],
       is_ccw = polygon_is_ccw(pts),

       n0 = edge_outward_normal(prev, curr, is_ccw),
       n1 = edge_outward_normal(curr, next, is_ccw),

       avg = v_add(n0, n1),
       avg_len = v_len(avg))
  avg_len == 0
  ? n1
  : v_unit(avg);
/**
  ─────────────────────────────────────────────────────────────────────────────
  rounded_polygon_points
  ─────────────────────────────────────────────────────────────────────────────

  Replace selected polygon vertices with tangent circular arcs.

  **Parameters:**
  - `points`: Ordered vertices of a simple polygon, clockwise or anticlockwise.
    Each entry supplies at least X/Y; extra annotation fields are ignored.
    Do not repeat the first point at the end or use consecutive duplicates.
  - `radii`: One nonnegative radius in mm, or one radius per input vertex.
    Zero preserves that vertex exactly. Both convex and concave corners round.
  - `segments`: Number of straight segments per arc, positive integer.

  **Returns:**
  A list of XY polygon vertices. Radii shrink locally when adjacent fillets
  would overlap along an edge. Collinear forward vertices stay unchanged.
  This local limit does not detect collisions with nonadjacent edges; choose
  radii that fit narrow features in concave polygons.

  **Examples:**
  ```scad
  rounded_polygon_points([[0,0], [30,0], [25,20], [5,20]], [0,0,3,3]);
  ```
 */
function rounded_polygon_points(points, radii=0, segments=12) =
  assert(is_list(points) && len(points) >= 3,
         "rounded polygon needs at least three vertices")
  assert(is_num(segments) && segments >= 1 && floor(segments) == segments,
         "polygon arc segments must be a positive integer")
  let (pts = [for (p = points)
    assert(is_list(p) && len(p) >= 2 && is_num(p[0]) && is_num(p[1]),
           "polygon vertices must contain numeric X/Y coordinates")
    [p[0], p[1]]],
       n = len(pts),
       rs = is_list(radii) ? radii : repeat(radii, n))
  assert(len(rs) == n, "corner radii must match the polygon vertex count")
  let (corners = [for (i = [0 : n - 1])
    let (a = pts[(i + n - 1) % n] - pts[i],
         b = pts[(i + 1) % n] - pts[i],
         la = norm(a), lb = norm(b))
    assert(la > 0 && lb > 0, "polygon must not repeat adjacent vertices")
    assert(is_num(rs[i]) && rs[i] >= 0, "polygon radii must be nonnegative")
    let (u = a / la, v = b / lb,
         cosine = max(-1, min(1, u * v)),
         half = acos(cosine) / 2)
    assert(half > 0.000001, "polygon edges must not double back")
    let (distance = half > 89.999999 ? 0 : rs[i] / tan(half))
    [u, v, la, lb, half, distance]],
       distances = [for (i = [0 : n - 1])
         let (c = corners[i],
              before = corners[(i + n - 1) % n][5] + c[5],
              after = corners[(i + 1) % n][5] + c[5])
         c[5] * min(1, before > 0 ? c[2] / before : 1,
                    after > 0 ? c[3] / after : 1)])
  let (result = [for (i = [0 : n - 1])
    each let (c = corners[i], d = distances[i])
      d <= 0.000001 ? [pts[i]] :
      let (radius = d * tan(c[4]),
           center = pts[i] + v_unit(c[0] + c[1]) * radius / sin(c[4]),
           start = pts[i] + c[0] * d - center,
           end = pts[i] + c[1] * d - center,
           angle = atan2(start[1], start[0]),
           sweep = atan2(start[0] * end[1] - start[1] * end[0], start * end))
        [for (j = [0 : segments])
          center + radius * [cos(angle + sweep * j / segments),
                             sin(angle + sweep * j / segments)]]])
  [for (i = [0 : len(result) - 1])
    if (norm(result[i] - result[(i + len(result) - 1) % len(result)]) > 0.000000001)
        result[i]];
