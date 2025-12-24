/**
 * Module: Reusable several utility functions
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

/**
   ─────────────────────────────────────────────────────────────────────────────
   number_sequence
   ─────────────────────────────────────────────────────────────────────────────

   Returns an array of numbers starting at `from` and incremented by `step`.

   The `from` value is always included, and `to` is included if the sequence
   lands on it exactly; otherwise, the last number is the largest value that
   does not exceed `to`.

   **Parameters:**

   `from`: start value (number)
   `to`: end value (number)
   `step`: increment (number)

   **Returns:**
   A list of numbers.

   **Example:**

   ```scad
   number_sequence(from=2, to=7, step=2) // -> [2, 4, 6]
   ```
*/

function number_sequence(from, to, step) = [for (i = [from : step : to]) i];

/**
   ─────────────────────────────────────────────────────────────────────────────
   truncate
   ─────────────────────────────────────────────────────────────────────────────

   Truncate a number to a specified number of decimal places.

   **Parameters:**

   `val`: The input number to truncate.
   `dec`: The number of decimal places to retain (default is 1).

   **Returns:**
   The truncated number.

   **Examples:**

   ```scad
   truncate(3.14159, 2)  // returns 3.14
   truncate(-2.718, 1)   // returns -2.7
   ```
*/
function truncate(val, dec=1) =
  (val >= 0) ? floor(val * pow(10, dec)) / pow(10, dec)
  : ceil(val * pow(10, dec)) / pow(10, dec);

/**
   ─────────────────────────────────────────────────────────────────────────────
   calc_notch_width
   ─────────────────────────────────────────────────────────────────────────────

   Computes the depth (or reduction in width) at the notch on a circle.

   This function calculates the notch width by determining the chord’s offset
   from the circle’s edge. It subtracts two times the distance from the circle's
   center to the chord (computed using the Pythagorean theorem) from the full
   diameter.

   **Parameters:**

   `dia`: The diameter of the circle.
   `w`: The chord length corresponding to the notch width at the circle’s center.

   **Returns:**
   The calculated notch width (reduction in diameter due to the notch).

   **Example:**

   ```scad
   calc_notch_width(3.2, 10) // -> 1.33975
   ```
*/
function calc_notch_width(dia, w) =
  dia - 2 * sqrt(((dia / 2) * (dia / 2)) - ((w / 2) * (w / 2)));

/**
   ─────────────────────────────────────────────────────────────────────────────
   sum
   ─────────────────────────────────────────────────────────────────────────────

   Recursively sum elements of a numeric list.

   **Parameters:**

   `list`: the list of numeric values.
   `count`: optional number of first elements to sum. If omitted, the whole list
   is summed.

   **Returns:**
   The sum of the requested elements.

   **Examples:**

   ```scad
   sum([1, 5, 10]); // 16
   sum([1, 5, 10], 2); // 6
   ```
*/
function sum(list, count=undef) =
  let (length = is_undef(count) ? len(list) : count)
  length < 2
  ? list[0]
  : (list[length - 1] + sum(list, length - 1));

/**
   ─────────────────────────────────────────────────────────────────────────────
   drop
   ─────────────────────────────────────────────────────────────────────────────

   Drop the first n elements from a list and return the remainder.

   **Parameters:**

   `a`: The input list.
   `n`: The number of elements to drop from the start (0-based count).

   **Returns:**
   A list containing the elements of `a` after the first `n` elements.

   **Behavior:**
   If `n` is greater than or equal to `len(a)`, an empty list is returned.

   **Examples:**

   ```scad
   drop([1, 2, 3, 4], 2)    // returns [3, 4]
   drop([1, 2], 0)         // returns [1, 2]
   drop([1, 2], 5)         // returns []
   drop([], 0)             // returns []
   ```
*/
function drop(a, n) = n >= len(a) ? [] : [for (i = [n : len(a)-1]) a[i]];
/**
   ─────────────────────────────────────────────────────────────────────────────
   slice
   ─────────────────────────────────────────────────────────────────────────────

   Return a sublist of elements between start and end indices (inclusive).

   Supports negative indices (from end). Indices are clamped to [0..len(a)].

   **Parameters:**

   `a`: The input list.
   `start`: The starting index (inclusive).
   `end`: The ending index (inclusive).

   **Examples:**

   ```scad
   a = [0, 1, 2, 3, 4, 5];

   slice(a, 0, 0) // -> []
   slice(a, 0, 1) // -> [0]
   slice(a, 2, 5) // -> [2, 3, 4]
   slice(a, 2) // -> [2, 3, 4, 5]
   slice(a) // -> [0, 1, 2, 3, 4, 5]
   slice(a, -1) // -> [5]
   slice(a, -3) // -> [3, 4, 5]
   slice(a, 1, -1) // -> [1, 2, 3, 4]
   slice(a, -4, -1) // -> [2, 3, 4]
   slice(a, 99, 100) -> [] // -> []
   slice(a, -99, 2) clamps start // -> [0, 1]
   slice(a, 2, -99) end before start // -> []
   slice(a, 0, 99) clamps end // -> [0, 1, 2, 3, 4, 5]
   ```
*/

function slice(a, start=0, end=undef) =
  let (n  = len(a),
       s0 = (start==undef) ? 0 : start,
       e0 = (end  ==undef) ? n : end,
       s1 = (s0 < 0) ? n + s0 : s0,
       e1 = (e0 < 0) ? n + e0 : e0,
       s  = (s1 < 0) ? 0 : (s1 > n) ? n : s1,
       e  = (e1 < 0) ? 0 : (e1 > n) ? n : e1)
  (e <= s) ? [] : [for (i = [s : e-1]) a[i]];

// function slice(a, start, end) = start > end
//   ? []
//   : [for (i = [start : end]) a[i]];

/**
   ─────────────────────────────────────────────────────────────────────────────
   reverse
   ─────────────────────────────────────────────────────────────────────────────

   Return a new list with the elements in reverse order.

   **Parameters:**

   `list`: The input list to reverse.

   **Returns:**
   A list with elements of `list` in reverse order.

   **Examples:**

   ```scad
   reverse([1, 2, 3])   // returns [3, 2, 1]
   reverse([42])        // returns [42]
   reverse([])          // returns []
   ```
*/
function reverse(list) = [for (i = [len(list)-1:-1:0]) list[i]];

/**
   ─────────────────────────────────────────────────────────────────────────────
   non_empty
   ─────────────────────────────────────────────────────────────────────────────

   Test whether a list exists and contains at least one element.

   **Parameters:**

   `items`: The list (or value) to test.

   **Returns:**
   `true` only if `items` is a truthy value and its length is greater than 0.

   **Examples:**

   ```scad
   non_empty([1, 2])   // returns true
   non_empty([])       // returns false
   non_empty([0])      // returns true   // list has one element (even if element is falsy)
   ```
*/
function non_empty(items) = items && len(items) > 0;

/**
   ─────────────────────────────────────────────────────────────────────────────
   map_idx
   ─────────────────────────────────────────────────────────────────────────────

   Extracts a column (index) from a list of records, providing a default value
   for missing entries.

   **Parameters:**

   `items`: list of lists (records)
   `idx`: integer index to extract from each item
   `def_val`: value to use when `items[i][idx]` is undefined

   **Returns:**
   A list where each element is `items[i][idx]` when defined, otherwise `def_val`.

   **Example:**

   ```scad
   map_idx([[10, 30, 50]], [[15, 35, 25]], 1) // ->  [30, 35]
   ```
*/
function map_idx(items, idx, def_val) = [for (i = [0 : len(items) - 1])
    is_undef(items[i][idx])
      ? def_val
      : items[i][idx]];

/**
   ─────────────────────────────────────────────────────────────────────────────
   poly_width_at_y
   ─────────────────────────────────────────────────────────────────────────────

   Compute the horizontal width of a polygon at a given y (distance between
   the leftmost and rightmost intersections of the polygon with the horizontal
   line y = y_target).

   **Parameters:**

   `pts`: A list of 2D points defining the polygon, each point as `[x, y]`. The polygon is treated as closed (the last point connects to the first).
   `y_target`: The y coordinate of the horizontal scan line.

   **Returns:**
   The horizontal width at `y_target` (max(intersections) - min(intersections)).

   **Behavior and notes:**
   - The function computes x coordinates where each polygon edge (non-horizontal)
   intersects the horizontal line `y = y_target` and returns `max(intersections) - min(intersections)`.
   - Horizontal edges (edges with identical y values) are skipped to avoid
   division by zero; vertices that lie exactly on `y_target` can produce
   intersections through adjacent non-horizontal edges.
   - For a simple polygon the horizontal line typically produces an even number
   of intersections; if only one intersection occurs the function returns 0
   (`max == min`). If there are no intersections the result is undefined
   (an error occurs since `max/min` are called on an empty list). The caller
   should ensure the line intersects the polygon (or guard against empty intersections).

   **Examples:**

   ```scad
   poly_width_at_y([[0, 0], [10, 0], [10, 5], [0, 5]], 2)
   // returns 10    (rectangle width at y=2)

   poly_width_at_y([[0, 0],[5, 10],[10, 0]], 5);
   // returns 5     (isosceles triangle intersects at x=2.5 and x=7.5)

   poly_width_at_y([[0, 0],[10, 0],[10, 5],[0, 5]], 0);
   // returns 10    (horizontal line along bottom edge: horizontal edges are ignored,
   // intersections come from vertical edges)

   poly_width_at_y([[0, 0],[5, 10],[10, 0]], 20);
   // undefined      (no intersections; caller should check / avoid this case)
   ```
*/
function poly_width_at_y(pts, y_target) =
  let (intersections = [for (i = [0 : len(pts)-1])
           if (((pts[i][1] - y_target)
                * (pts[(i + 1) % len(pts)][1] - y_target) <= 0)
               && (pts[(i + 1) % len(pts)][1] - pts[i][1] != 0))
             pts[i][0] + ((y_target - pts[i][1])
                          / (pts[(i + 1) % len(pts)][1] - pts[i][1]))
               * (pts[(i + 1) % len(pts)][0] - pts[i][0])])
  (max(intersections) - min(intersections));

/**
   ─────────────────────────────────────────────────────────────────────────────
   notched_circle_square_center_x
   ─────────────────────────────────────────────────────────────────────────────

   Compute the x-coordinate of the center of a square "notch" measured from
   the circle center when the square of width `cutout_w` is aligned so that
   its inner corner lies on the circle's circumference.

   **Parameters:**

   `r`: Radius of the circle (must be >= 0).
   `cutout_w`: Width of the square cutout (must satisfy `cutout_w <= 2 * r`).

   **Returns:**
   The x-coordinate (in same units as `r` and `cutout_w`).

   **Behavior:**
   Uses `L = sqrt(r^2 - (cutout_w/2)^2)` and returns `L + cutout_w/2`.
   The expression requires `cutout_w <= 2*r` (otherwise `sqrt` of a negative
   value occurs).

   **Examples:**

   ```scad
   notched_circle_square_center_x(10, 6)   // returns ~12.539387
   notched_circle_square_center_x(5, 10)   // returns 5
   notched_circle_square_center_x(5, 11)   // invalid: cutout_w > 2*r -> sqrt of negative
   ```
*/
function notched_circle_square_center_x(r, cutout_w) =
  let (L = sqrt(r * r - (cutout_w / 2) * (cutout_w / 2)))
  L + cutout_w / 2;

/**
   ─────────────────────────────────────────────────────────────────────────────
   cutout_depth
   ─────────────────────────────────────────────────────────────────────────────

   Compute the depth (radial intrusion) of a square cutout into a circle.

   **Parameters:**

   `r`: Radius of the circle (must be >= 0).
   `cutout_w`: Width of the square cutout (must satisfy `cutout_w <= 2 * r`).

   **Returns:**
   The radial depth of the cutout.

   **Behavior:**
   Returns `r - sqrt(r^2 - (cutout_w/2)^2)`. For `cutout_w = 0` the depth is 0;
   for `cutout_w = 2*r` the depth equals `r`. If `cutout_w > 2*r` a negative
   value under the square root occurs (invalid).

   **Examples:**

   ```scad
   cutout_depth(10, 6)   // returns 0.460608
   cutout_depth(5, 10)   // returns 5
   cutout_depth(5, 11)   // nan: cutout_w > 2*r -> sqrt of negative
   ```
*/
function cutout_depth(r, cutout_w) =
  r - sqrt(r * r - (cutout_w / 2) * (cutout_w / 2));

/**
   ─────────────────────────────────────────────────────────────────────────────
   calc_isosceles_trapezoid_top_width
   ─────────────────────────────────────────────────────────────────────────────

   Calculate the top (narrower) base width of an isosceles trapezoid.

   **Parameters:**

   `bottom_width`: Width of the bottom base.
   `side_length`: Length of each equal side (leg). A negative value is accepted but treated as its absolute value.
   `angle_deg`: Angle in degrees measured from vertical for each leg. (0° = leg vertical, 90° = leg horizontal).

   **Returns:**
   The top base width (clamped to a minimum of 0).

   **Behavior:**
   Horizontal inset on each side = `side_length * sin(angle_deg)`.
   `top = bottom_width - 2 * side_length * sin(angle_deg)`.
   The function clamps the result to a minimum of 0. OpenSCAD’s trigonometric
   functions operate on degrees, so `angle_deg` is passed directly to `sin()`.

   **Examples:**

   ```scad
   calc_isosceles_trapezoid_top_width(20, 5, 30)   // returns 15
   calc_isosceles_trapezoid_top_width(10, 10, 90)  // returns 0
   calc_isosceles_trapezoid_top_width(12, -3, 45)  // returns 7.75736
   ```
*/
function calc_isosceles_trapezoid_top_width(bottom_width,
                                            side_length,
                                            angle_deg) =
  let (s = abs(side_length),
       top = bottom_width - 2 * s * sin(angle_deg))
  max(0, top);

/**
   ─────────────────────────────────────────────────────────────────────────────
   bolt_x_offst
   ─────────────────────────────────────────────────────────────────────────────

   Calculates the translation positions for bolts.

   **Parameters:**

   `slot_w`: The width of the centered parent slot.
   `bolt_dia`: The diameter of the bolt.
   `distance`: The desired distance between the centered parent slot and the bolt.

   **Returns:**
   The x offset for placing the bolt relative to slot center.

   **Example:**

   ```scad
   bolt_x_offst(10, 3.5, 2) // -> 8.75
   ```
*/
function bolt_x_offst(slot_w, bolt_dia, distance) =
  (slot_w * 0.5 + bolt_dia * 0.5) + distance;

/**
   ─────────────────────────────────────────────────────────────────────────────
   sort_by_idx
   ─────────────────────────────────────────────────────────────────────────────

   Sorts a list of scalars or a list of lists by the element at a given index.
   Uses a simple recursive selection-sort style algorithm that preserves list
   elements (if elements are lists they are returned as whole items).

   **Parameters:**

   `elems`: A list of scalars or a list of lists to be sorted.
   `asc`:   Boolean, true for ascending order (default true), false for descending.
   `idx`:   When elements are lists, the index inside each element to use as the
   sort key. If elements are scalars or idx is out of range, the element
   itself is used as the key (default 0).

   **Returns:**
   A new list containing the elements of `elems` sorted according to the key.

   **Examples:**

   ```scad
   sort_by_idx([1,3,2], true);                     // -> [1, 2, 3]
   sort_by_idx([[1,5],[3,10],[2,4]], true, idx=0); // -> [[1,5], [2,4], [3,10]]
   sort_by_idx([[1,5],[3,10],[2,4]], false, idx=1);// -> [[3,10], [1,5], [2,4]]
   ```
*/
function sort_by_idx(elems, asc=true, idx=0) =
  len(elems) <= 1 ? elems :
  let (best_i = find_best_index(elems, idx, asc),
       best   = elems[best_i],
       rest   = [for (i=[0:len(elems)-1]) if (i != best_i) elems[i]])
  concat([best], sort_by_idx(rest, asc, idx));

/**
   ─────────────────────────────────────────────────────────────────────────────
   find_best_index
   ─────────────────────────────────────────────────────────────────────────────

   Finds the index of the "best" element in a list according to a key and sort
   direction. Used internally by sort_by_idx. Performs a linear scan to locate
   either the minimum (asc=true) or maximum (asc=false) element by key.

   **Parameters:**

   `elems`:  A list of scalars or a list of lists to search.
   `idx`:    When elements are lists, the index inside each element to use as the
   comparison key. If elements are scalars or idx is out of range,
   the element itself is used as the key.
   `asc`:    Boolean, true to select the minimum key (ascending), false to
   select the maximum key (descending).
   `i`:      Internal recursion parameter: current index being examined
   (do not set unless you know what you're doing; default 0).
   `best_i`: Internal recursion parameter: index of current best candidate
   (do not set unless you know what you're doing; default 0).

   **Returns:**
   The index (integer) of the best element in `elems` according to the key and
   direction. If `elems` is empty behavior is not defined (caller should ensure
   non-empty list).

   **Examples:**

   ```scad
   find_best_index([1,3,2], 0, true);                     // -> 0  (index of min 1)
   find_best_index([1,3,2], 0, false);                    // -> 1  (index of max 3)
   find_best_index([[1,5],[3,10],[2,4]], 0, true);        // -> 0  (index of [1,5])
   find_best_index([[1,5],[3,10],[2,4]], 0, false);       // -> 1  (index of [3,10])
   ```
*/
function find_best_index(elems, idx, asc, i=0, best_i=0) =
  i >= len(elems) ? best_i :
  let (k  = key(elems[i], idx),
       bk = key(elems[best_i], idx),
       better = asc ? (k < bk) : (k > bk))
  better ? find_best_index(elems, idx, asc, i + 1, i)
  : find_best_index(elems, idx, asc, i + 1, best_i);

/**
   ─────────────────────────────────────────────────────────────────────────────
   key
   ─────────────────────────────────────────────────────────────────────────────

   Extracts the comparison key from an item. If the item is a list and the
   requested index is within range, returns item[idx]. Otherwise returns the
   item itself (useful for mixing scalars and lists as sortable elements).

   **Parameters:**

   `item`: The element to extract the key from (scalar or list).
   `idx`:  Index to use when `item` is a list.

   **Returns:**
   The selected key value (either item[idx] or item).

   **Examples:**

   ```scad
   key([3,10], 1); // -> 10
   key([3,10], 2); // -> [3,10] (idx out of range, returns the whole item)
   key(5, 0);      // -> 5
   ```
*/
function key(item, idx) =
  is_list(item) && (idx >= 0) && (idx < len(item)) ? item[idx] : item;

/**
   ─────────────────────────────────────────────────────────────────────────────
   rot_x_bbox_align
   ─────────────────────────────────────────────────────────────────────────────

   Calculate the bounding box size of a rectangle rotated around the X axis.

   **Parameters:**

   `size`: A 3-element vector [dx, dy, dz] representing the size of the box.
   `angle`: The rotation angle in radians.
   `pos`: Optional 2-element vector [y0, z0] representing the position offset
   in the YZ plane (default is [0, 0]).

   **Returns:**
   A 6-element vector:
   [rotated_size_y, rotated_size_z, min_y, min_z, max_y, max_z]

   where rotated_size_y and rotated_size_z are the dimensions of the bounding
   box after rotation, and min_y, min_z, max_y, max_z are the extents in YZ
   plane.

   **Example:**

   ```scad
   bbox = rot_x_bbox_align([w, h, thickness], angle=angle);
   bbox_w = bbox[0];
   bbox_h = bbox[1];
   ```
*/
function rot_x_bbox_align(size, angle, pos=[0, 0]) =
  let (y0 = pos[0],
       y1 = pos[0] + size[1],
       z0 = pos[1],
       z1 = pos[1] + size[2],

       ya = y0*cos(angle) - z0*sin(angle),
       yb = y1*cos(angle) - z0*sin(angle),
       yc = y0*cos(angle) - z1*sin(angle),
       yd = y1*cos(angle) - z1*sin(angle),

       za = y0*sin(angle) + z0*cos(angle),
       zb = y1*sin(angle) + z0*cos(angle),
       zc = y0*sin(angle) + z1*cos(angle),
       zd = y1*sin(angle) + z1*cos(angle),

       min_y = min([ya, yb, yc, yd]),
       max_y = max([ya, yb, yc, yd]),
       min_z = min([za, zb, zc, zd]),
       max_z = max([za, zb, zc, zd]),

       rot_y_size = max_y - min_y,
       rot_z_size = max_z - min_z,
       z_shift = -min_z)
  [rot_y_size, rot_z_size, min_y, min_z, max_y, max_z];

/**
   ─────────────────────────────────────────────────────────────────────────────
   in_list
   ─────────────────────────────────────────────────────────────────────────────

   Check if an item is present in a list.

   **Parameters:**

   `item`: The item to search for.
   `list`: The list to search within.
   `i`: Internal recursion index (do not set unless you know what you're doing).

   **Returns:**
   `true` if `item` is found in `list`, otherwise `false`.

   **Examples:**

   ```scad
   in_list(3, [1, 2, 3]); // returns true
   in_list(4, [1, 2, 3]); // returns false
   ```
*/
function in_list(item, list, i = 0) =
  i >= len(list) ? false
  : (list[i] == item) ? true
  : in_list(item, list, i + 1);
/**
   ─────────────────────────────────────────────────────────────────────────────
   with_default
   ─────────────────────────────────────────────────────────────────────────────
   Returns `val` if it is defined and matches the specified type, otherwise,
   returns `default`.
   **Parameters:**
   `val`: The value to check.
   `default`: The default value to return if `val` is undefined or of the wrong type.
   `type`: A string specifying the expected type of `val`. Can be:
   - "any" (default) or undef
   - "number" or "n"
   - "string", "str" or "s"
   - "list", "l", "arr"
   **Returns:**
   `val` if it is defined and of the correct type, otherwise `default`.

*/
function with_default(val, default, type = "any") =
  (is_undef(type) || type == "any")
  ? (is_undef(val) ? default : val)
  : in_list(type, ["str", "string", "s"])
  ? (is_string(val) ? val : default)
  : in_list(type, ["l", "arr", "list"])
  ? (is_list(val) ? val : default)
  : in_list(type, ["n", "number"])
  ? (is_num(val) ? val : default)
  : default;

/*
  ─────────────────────────────────────────────────────────────────────────────
  calc_cols_params
  ─────────────────────────────────────────────────────────────────────────────

  **Example**:
  ```scad
  calc_cols_params(cols=4, w=10, gap=2); // -> [12, 46]

  ```
*/
function calc_cols_params(cols, w, gap) =
  let (step = gap + w,
       total_x = cols * w + (cols - 1)
       * gap)
  [step, total_x];

/**
   ─────────────────────────────────────────────────────────────────────────────
   constraint
   ─────────────────────────────────────────────────────────────────────────────

   **Example**:
   ```scad
   constraint(10, 12, 12) // ->  12
   constraint(10, 11, 12) // ->  11
   constraint(10, 10, 12) // ->  10
   constraint(13, 10, 12) // ->  12
   ```
*/
function constraint(val, min_val, max_val) =
  max(min_val, min(max_val, val));

/**
   ─────────────────────────────────────────────────────────────────────────────
   clamp
   ─────────────────────────────────────────────────────────────────────────────

   **Example**:
   ```scad
   clamp(1, 0, len([1, 2, 3])) // -> 1

   ```
*/
function clamp(x, lo, hi) = (x < lo) ? lo : (x > hi) ? hi : x;

/**
   ─────────────────────────────────────────────────────────────────────────────
   take
   ─────────────────────────────────────────────────────────────────────────────
   Take first n (clamped). If n <= 0 => []

   **Example**:
   ```scad
   take(["foo", "bar", "baz"], 1); // => ["foo"]
   take(["foo", "bar", "baz"], 2); // => ["foo", "bar"]
   take(["foo", "bar", "baz"], 3); // => ["foo", "bar", "baz"]
   take(["foo", "bar", "baz"], 4); // => ["foo", "bar", "baz"]
   take(["foo", "bar", "baz"], 0); // => []
   ```

*/
function take(l, n=1) =
  let (nn = with_default(n, 1))
  (nn <= 0) ? [] : slice(l, 0, nn);

/**
   ─────────────────────────────────────────────────────────────────────────────
   drop
   ─────────────────────────────────────────────────────────────────────────────
   Drop first n. If n <= 0 => original list

   **Example**:
   ```scad
   drop(["foo", "bar", "baz"], 1); //=> ["bar", "baz"]
   drop(["foo", "bar", "baz"], 2); //=> ["baz"]
   drop(["foo", "bar", "baz"], 3); //=> []
   drop(["foo", "bar", "baz"], 4); //=> []
   ```

*/
function drop(l, n=1) =
  let (nn = with_default(n, 1))
  (nn <= 0) ? l : slice(l, nn);

/**
   ─────────────────────────────────────────────────────────────────────────────
   drop_last
   ─────────────────────────────────────────────────────────────────────────────
   Drop last n. If n <= 0 => original list

   **Example**:

   ```scad
   drop_last(["foo", "bar", "baz"]); //=> ["foo", "bar"]
   drop_last(["foo", "bar", "baz"], 1); //=> ["foo", "bar"]
   drop_last(["foo", "bar", "baz"], 2); //=> ["foo"]
   drop_last(["foo", "bar", "baz"], 3); //=> []
   drop_last(["foo", "bar", "baz"], 4); //=> []
   drop_last(["foo", "bar", "baz"], 4 ); //=> []
   ```

*/
function drop_last(l, n=1) =
  let (nn  = clamp(with_default(n, 1), 0, len(l)))
  (nn <= 0) ? l : slice(l, 0, len(l) - nn);

/**
   ─────────────────────────────────────────────────────────────────────────────
   take_last
   ─────────────────────────────────────────────────────────────────────────────
   Take last n. If n <= 0 => []

   **Example**:
   ```scad
   take_last(["foo", "bar", "baz"], 1); // => ["baz"]
   take_last(["foo", "bar", "baz"], 2); // => ["bar", "baz"]
   take_last(["foo", "bar", "baz"], 3); // => ["foo", "bar", "baz"]
   take_last(["foo", "bar", "baz"], 4); // => ["foo", "bar", "baz"]
   ```

*/
function take_last(l, n=1) =
  let (nn  = clamp(with_default(n, 1), 0, len(l)))
  (nn <= 0) ? [] : slice(l, len(l) - nn, len(l));

/**
   ─────────────────────────────────────────────────────────────────────────────
   search_idxs
   ─────────────────────────────────────────────────────────────────────────────

   **Example**:
   ```scad
   search_idxs([2, 1, 2, 3], 2); // => [0, 2]
   ```
*/
function search_idxs(l, val) = [for (i = [0:len(l) - 1]) if (l[i] == val) i];

/**
   ─────────────────────────────────────────────────────────────────────────────
   search_idx
   ─────────────────────────────────────────────────────────────────────────────

   **Example**:
   ```scad
   search_idx([2, 1, 2, 3], 2); // => 0
   ```
*/
function search_idx(l, val) = search_idxs(l, val)[0];

/**
   ─────────────────────────────────────────────────────────────────────────────
   search_idx
   ─────────────────────────────────────────────────────────────────────────────

   **Example**:
   ```scad
   member([2, 1, 2, 3], 2); // => true
   member([2, 1, 2, 3], 10); // => false
   ```
*/
function member(x, xs) =
  true == [for (v = xs) if (v == x) true][0];

/**
   ─────────────────────────────────────────────────────────────────────────────
   flatten_pairs
   ─────────────────────────────────────────────────────────────────────────────
   Turns [[a,b], [c,d]] into [a, b, c, d]

   **Example**:
   ```scad
   flatten_pairs([[2, 1], [2, 3]]); // => [2, 1, 2, 3]
   ```
*/
function flatten_pairs(pairs) = [for (p = pairs) each p];

/**
   ─────────────────────────────────────────────────────────────────────────────
   list_sum
   ─────────────────────────────────────────────────────────────────────────────

   **Example**:
   ```scad
   list_sum([]); 0
   list_sum([1]); ->  1
   list_sum([1, 2]); // ->  3
   list_sum([1, 2, 3]); // ->  6
   list_sum([], 1); // -> 0
   list_sum([1], 1); // -> 0
   list_sum([1, 2], 1); // -> 2
   list_sum([1, 2], 2); // ->  0
   list_sum([1, 2], 0); // ->  3

   ```
*/
function list_sum(v, i=0) =
  i >= len(v) ? 0 : v[i] + list_sum(v, i + 1);

/**
   ─────────────────────────────────────────────────────────────────────────────
   best_by_lower_sum
   ─────────────────────────────────────────────────────────────────────────────
   Choose the “better” of two lists.

   Rules (in order):
   - If one list is empty (`[]`), return the other.
   - Prefer the list with the smaller `list_sum(...)`.
   - If sums are equal, prefer the lexicographically larger list (`a > b`).

   **Example**:
   ```scad
   best_by_lower_sum([], [1,2]);        //=> [1,2]
   best_by_lower_sum([1,2], []);        //=> [1,2]

   best_by_lower_sum([1,1,1], [3]);     //=> [1,1,1]   (sum 3 == sum 3, tie-break by lex order)
   best_by_lower_sum([1,2],   [4]);     //=> [1,2]     (3 < 4)
   best_by_lower_sum([2,2],   [1,3]);   //=> [2,2]     (sum tie: 4 == 4, and [2,2] > [1,3])
   ```
*/
function best_by_lower_sum(a, b) =
  a == [] ? b :
  b == [] ? a :
  list_sum(a) < list_sum(b) ? a :
  list_sum(a) > list_sum(b) ? b :
  a > b ? a : b;

/**
   ─────────────────────────────────────────────────────────────────────────────
   best_list_by_lower_sum
   ─────────────────────────────────────────────────────────────────────────────
   Return the “best” list from a list-of-lists `v`, using `best_by_lower_sum()`.


   **Example**:
   ```scad
   best_list_by_lower_sum([]);                              //=> []
   best_list_by_lower_sum([[], [1,2], [3]]);                //=> [3]      (sum tie 3==3, [3] > [1,2])
   best_list_by_lower_sum([[], []]);                        //=> []
   ```
*/
function best_list_by_lower_sum(v, i=0) =
  i == len(v) ? [] :
  best_by_lower_sum(v[i], best_list_by_lower_sum(v, i + 1));

/**
   ─────────────────────────────────────────────────────────────────────────────
   best_height_combo
   ─────────────────────────────────────────────────────────────────────────────
   Find the “best” combination of heights whose sum is >= `min_h`, using at most
   `limit` items, chosen from `heights` (repetition allowed).

   Notes:
   - Order matters for tie-breaking (because lexicographic comparison is used),
   even if multiple permutations represent the same multiset.
   - A result may overshoot `min_h`; overshoot is allowed and minimized.

   **Example**:
   ```scad
   best_height_combo(6, [1,3,4], 2);   //=> [3,3]   (sum 6)
   best_height_combo(6, [4,5],   2);   //=> [4,4]   (sum 8; [5,5] is 10)
   best_height_combo(6, [4,5],   1);   //=> []      (can't reach 6 with one item)
   best_height_combo(1, [2,3],   3);   //=> [2]     (sum 2 is minimal >= 1)
   ```
*/
function best_height_combo(min_h, heights, limit) =
  min_h <= 0 ? [] :
  limit == 0 ? [] :
  let (candidates = [for (h = heights)
           let (r = best_height_combo(min_h - h, heights, limit - 1))
             r == [] && min_h - h > 0 ? [] : concat([h], r)])
  best_list_by_lower_sum(candidates);
