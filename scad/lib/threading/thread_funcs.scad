/**
  * Module: Threading functions
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  *
  * Adapted in part from Ryan Colyer's threads-scad:
  *   https://github.com/rcolyer/threads-scad
  *   Original work released under CC0 1.0 Universal.
  *
  * Credit and thanks to Ryan Colyer for the original work and inspiration.
  * License: GPL-3.0-or-later
  *
  */

/**
  ─────────────────────────────────────────────────────────────────────────────
  thread_pitch
  ─────────────────────────────────────────────────────────────────────────────

  Provides standard metric thread pitches for the given d.

  **Example**:
  ```scad
  thread_pitch(1); // -> 0.4
  thread_pitch(2); // -> 0.4
  thread_pitch(3); // -> 0.5
  thread_pitch(4); // -> 0.7
  thread_pitch(5); // -> 0.8
  thread_pitch(6); // -> 1
  thread_pitch(7); // -> 1
  thread_pitch(8); // -> 1.25
  thread_pitch(9); // -> 1.375
  thread_pitch(10); // -> 1.5
  thread_pitch(11); // -> 1.625
  thread_pitch(12); // -> 1.75
  ```
  */
function thread_pitch(d) =
  (d <= 64) ?
  lookup(d,
         [[2, 0.4],
          [2.5, 0.45],
          [3, 0.5],
          [4, 0.7],
          [5, 0.8],
          [6, 1.0],
          [7, 1.0],
          [8, 1.25],
          [10, 1.5],
          [12, 1.75],
          [14, 2.0],
          [16, 2.0],
          [18, 2.5],
          [20, 2.5],
          [22, 2.5],
          [24, 3.0],
          [27, 3.0],
          [30, 3.5],
          [33, 3.5],
          [36, 4.0],
          [39, 4.0],
          [42, 4.5],
          [48, 5.0],
          [52, 5.0],
          [56, 5.5],
          [60, 5.5],
          [64, 6.0]]) :
  d * 6.0 / 64;

/**
  ─────────────────────────────────────────────────────────────────────────────
  hex_across_flats
  ─────────────────────────────────────────────────────────────────────────────

  Provides standard metric hex head widths across the flats.

  **Example**:
  ```scad
  hex_across_flats(0) // -> 4
  hex_across_flats(1) // -> 4
  hex_across_flats(2) // -> 4
  hex_across_flats(3) // -> 5.5
  hex_across_flats(4) // -> 7
  hex_across_flats(5) // -> 8
  hex_across_flats(6) // -> 10
  hex_across_flats(7) // -> 11
  hex_across_flats(8) // -> 13
  hex_across_flats(9) // -> 14.5
  hex_across_flats(10) // -> 16
  hex_across_flats(11) // -> 17
  hex_across_flats(12) // -> 18
  ```
  */
function hex_across_flats(d) =
  (d <= 64) ?
  lookup(d,
         [[2, 4],
          [2.5, 5],
          [3, 5.5],
          [3.5, 6],
          [4, 7],
          [5, 8],
          [6, 10],
          [7, 11],
          [8, 13],
          [10, 16],
          [12, 18],
          [14, 21],
          [16, 24],
          [18, 27],
          [20, 30],
          [22, 34],
          [24, 36],
          [27, 41],
          [30, 46],
          [33, 50],
          [36, 55],
          [39, 60],
          [42, 65],
          [48, 75],
          [52, 80],
          [56, 85],
          [60, 90],
          [64, 95]]) :
  d * 95 / 64;

/**
  ─────────────────────────────────────────────────────────────────────────────
  hex_across_corners
  ─────────────────────────────────────────────────────────────────────────────

  Provides standard metric hex head widths across the corners.

  **Example**:
  ```scad
  hex_across_corners(1); // -> 4.6188
  hex_across_corners(2); // -> 4.6188
  hex_across_corners(3); // -> 6.35085
  hex_across_corners(4); // -> 8.0829
  hex_across_corners(5); // -> 9.2376
  hex_across_corners(6); // -> 11.547
  hex_across_corners(7); // -> 12.7017
  hex_across_corners(8); // -> 15.0111
  hex_across_corners(9); // -> 16.7432
  hex_across_corners(10); // -> 18.4752
  hex_across_corners(11); // -> 19.6299
  hex_across_corners(12); // -> 20.7846

  ```
  */
function hex_across_corners(d) =
  hex_across_flats(d) / cos(30);

/**
  ─────────────────────────────────────────────────────────────────────────────
  hex_drive_across_flats
  ─────────────────────────────────────────────────────────────────────────────
  Provides standard metric hex (Allen) drive widths across the flats.

  **Example**:
  ```scad
  hex_drive_across_flats(1); // -> 1.5
  hex_drive_across_flats(2); // -> 1.5
  hex_drive_across_flats(3); // -> 2.5
  hex_drive_across_flats(4); // -> 3
  hex_drive_across_flats(5); // -> 4
  hex_drive_across_flats(6); // -> 5
  hex_drive_across_flats(7); // -> 5
  hex_drive_across_flats(8); // -> 6
  hex_drive_across_flats(9); // -> 7
  hex_drive_across_flats(10); // -> 8
  hex_drive_across_flats(11); // -> 9
  hex_drive_across_flats(12); // -> 10
  ```
  */
function hex_drive_across_flats(d) =
  (d <= 64) ?
  lookup(d,
         [[2, 1.5],
          [2.5, 2],
          [3, 2.5],
          [3.5, 3],
          [4, 3],
          [5, 4],
          [6, 5],
          [7, 5],
          [8, 6],
          [10, 8],
          [12, 10],
          [14, 12],
          [16, 14],
          [18, 15],
          [20, 17],
          [22, 18],
          [24, 19],
          [27, 20],
          [30, 22],
          [33, 24],
          [36, 27],
          [39, 30],
          [42, 32],
          [48, 36],
          [52, 36],
          [56, 41],
          [60, 42],
          [64, 46]]) :
  d * 46 / 64;

/**
  ─────────────────────────────────────────────────────────────────────────────
  hex_drive_across_corners
  ─────────────────────────────────────────────────────────────────────────────

  Return standard metric hex drive widths across the corners.

  **Example**:
  ```scad
  hex_drive_across_corners(1); // -> 1.73205
  hex_drive_across_corners(2); // -> 1.73205
  hex_drive_across_corners(3); // -> 2.88675
  hex_drive_across_corners(4); // -> 3.4641
  hex_drive_across_corners(5); // -> 4.6188
  hex_drive_across_corners(6); // -> 5.7735
  hex_drive_across_corners(7); // -> 5.7735
  hex_drive_across_corners(8); // -> 6.9282
  hex_drive_across_corners(9); // -> 8.0829
  hex_drive_across_corners(10); // -> 9.2376
  hex_drive_across_corners(11); // -> 10.3923
  hex_drive_across_corners(12); // -> 11.547

  ```
  */
function hex_drive_across_corners(d) =
  hex_drive_across_flats(d) / cos(30);

/**
  ─────────────────────────────────────────────────────────────────────────────
  countersunk_drive_across_flats
  ─────────────────────────────────────────────────────────────────────────────

  Returns metric countersunk hex (Allen) drive widths across the flats.

  **Example**:
  ```scad
  countersunk_drive_across_flats(1); // -> 1.5
  countersunk_drive_across_flats(2); // -> 1.5
  countersunk_drive_across_flats(3); // -> 2
  countersunk_drive_across_flats(4); // -> 2.5
  countersunk_drive_across_flats(5); // -> 3
  countersunk_drive_across_flats(6); // -> 4
  countersunk_drive_across_flats(7); // -> 4
  countersunk_drive_across_flats(8); // -> 5
  countersunk_drive_across_flats(9); // -> 5
  countersunk_drive_across_flats(10); // -> 6
  countersunk_drive_across_flats(11); // -> 7
  countersunk_drive_across_flats(12); // -> 8

  ```
  */
function countersunk_drive_across_flats(d) =
  (d <= 14) ? hex_drive_across_flats(hex_drive_across_flats(d)) : round(0.6*d);

/**
  ─────────────────────────────────────────────────────────────────────────────
  countersunk_drive_across_corners
  ─────────────────────────────────────────────────────────────────────────────
  Returns metric countersunk hex drive widths across the corners.

  **Example**:
  ```scad
  countersunk_drive_across_corners(1) // -> 1.73205
  countersunk_drive_across_corners(2) // -> 1.73205
  countersunk_drive_across_corners(3) // -> 2.3094
  countersunk_drive_across_corners(4) // -> 2.88675
  countersunk_drive_across_corners(5) // -> 3.4641
  countersunk_drive_across_corners(6) // -> 4.6188
  countersunk_drive_across_corners(7) // -> 4.6188
  countersunk_drive_across_corners(8) // -> 5.7735
  countersunk_drive_across_corners(9) // -> 5.7735
  countersunk_drive_across_corners(10) // -> 6.9282
  countersunk_drive_across_corners(11) // -> 8.0829
  countersunk_drive_across_corners(12) // -> 9.2376

  ```
  */
function countersunk_drive_across_corners(d) =
  countersunk_drive_across_flats(d) / cos(30);

/**
  ─────────────────────────────────────────────────────────────────────────────
  nut_thickness
  ─────────────────────────────────────────────────────────────────────────────

  Returns standard metric nut thickness for the given d.

  **Example**:
  ```scad
  nut_thickness(0) // -> 1.6
  nut_thickness(1) // -> 1.6
  nut_thickness(2) // -> 1.6
  nut_thickness(3) // -> 2.4
  nut_thickness(4) // -> 3.2
  nut_thickness(5) // -> 4.7
  nut_thickness(6) // -> 5.2
  nut_thickness(7) // -> 6
  nut_thickness(8) // -> 6.8
  nut_thickness(9) // -> 7.6
  nut_thickness(10) // -> 8.4
  nut_thickness(11) // -> 9.6
  nut_thickness(12) // -> 10.8
  ```
  */
function nut_thickness(d) =
  (d <= 64) ?
  lookup(d,
         [[2, 1.6],
          [2.5, 2],
          [3, 2.4],
          [3.5, 2.8],
          [4, 3.2],
          [5, 4.7],
          [6, 5.2],
          [7, 6.0],
          [8, 6.8],
          [10, 8.4],
          [12, 10.8],
          [14, 12.8],
          [16, 14.8],
          [18, 15.8],
          [20, 18.0],
          [22, 21.1],
          [24, 21.5],
          [27, 23.8],
          [30, 25.6],
          [33, 28.7],
          [36, 31.0],
          [42, 34],
          [48, 38],
          [56, 45],
          [64, 51]]) :
  d * 51 / 64;

/**
   ─────────────────────────────────────────────────────────────────────────────
   recurse_avg
   ─────────────────────────────────────────────────────────────────────────────

   Computes the running average of a list of 3D vectors recursively.

   This function updates the average incrementally, so it does not need to sum
   the whole array first. At each step, `p` stores the average of the first `n`
   elements processed so far.

   When all elements have been processed, the final average vector is returned.

   **Parameters:**

   `arr`: array of 3D vectors
   `n`: current index / number of processed elements (default: `0`)
   `p`: current running average vector (default: `[0, 0, 0]`)

   **Returns:**
   The average 3D vector of all elements in `arr`.

   **Example:**

   ```scad
   recurse_avg([[1, 2, 3], [3, 4, 5], [5, 6, 7]]) // -> [3, 4, 5]
   ```
*/
function recurse_avg(arr, n=0, p=[0, 0, 0]) =
  (n>=len(arr))
  ? p
  : recurse_avg(arr,
                n + 1,
                p + (arr[n] - p) / (n + 1));

/**
   ─────────────────────────────────────────────────────────────────────────────
   tooth_width
   ─────────────────────────────────────────────────────────────────────────────

   Returns the radial width of a thread tooth at a given angular and axial
   position.

   The tooth profile is evaluated over one pitch as a triangular ramp. The
   width rises linearly from `0` to `extent` over the first half of the tooth,
   then falls linearly back to `0` over the second half. Outside the tooth
   region, the returned width is `0`.

   The phase is determined from the combination of angular position `a` and
   height `h`, so the tooth shape repeats helically with period `pitch`.

   **Parameters:**

   `a`: angular position in degrees
   `h`: axial position along the thread
   `pitch`: thread pitch
   `tooth_height`: axial height occupied by one tooth
   `extent`: maximum radial tooth extent

   **Returns:**
   The radial tooth width at the sampled position.

   **Example:**

   ```scad
   tooth_width(254.11821.99373.081420.0131758); // -> 0.000253065
   tooth_width(252.60521.99373.081420.0131758); // -> 1.5429e-6
   ```
*/
function tooth_width(a, h, pitch, tooth_height, extent) =
  let (ang_full = h * 360.0 / pitch-a,
       ang_pn = atan2(sin(ang_full), cos(ang_full)),
       ang = ang_pn < 0 ? ang_pn + 360 : ang_pn,
       frac = ang / 360,
       tfrac_half = tooth_height / (2*pitch),
       tfrac_cut = 2 * tfrac_half)
  (frac > tfrac_cut)
  ? 0
  : ((frac <= tfrac_half)
     ? ((frac / tfrac_half) * extent)
     : ((1 - (frac - tfrac_half) / tfrac_half) * extent));

function clamp(x, lo, hi) =
  x < lo ? lo : (x > hi ? hi : x);
