/**
 * Module: Wiring primitives
 *
 * Helpers to render insulated wires and simple wire harnesses along 3D paths.
 *
 * The main entry points are:
 * - `wire_path()`   : draw a single wire along a polyline or a smoothed spline.
 * - `wire_bundle()` : draw multiple parallel wires (a harness) offset from the
 *                     same centerline path.
 *
 * Path smoothing is enabled by default and uses Catmull-Rom resampling to
 * produce a smooth curve. To keep the original sharp polyline, set
 * `mode="none"` or `mode=undef`.
 *
 * Features:
 * - optional endpoint “cut” exposing an inner conductor on the last segment
 * - optional joint markers at original control points
 * - optional length reporting via `echo()`
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>

use <catmull_rom.scad>
use <functions.scad>

function total_wire_length(points) =
  len(points) < 2 ? 0 :
  sum([for (i = [0 : len(points) - 2]) vlen(points[i + 1] - points[i])]);

function suffix_lengths(pts) =
  let (n=len(pts))
  n < 2 ? [] :
  let (seg=[for (i=[0:n-2]) vlen(pts[i + 1]-pts[i])])
  // suf[i] = sum(seg[i..end])
  [for (i=[0:n-2]) sum([for (k=[i:n-2]) seg[k]])];

/**
  ─────────────────────────────────────────────────────────────────────────────
  wire_path
  ─────────────────────────────────────────────────────────────────────────────

  Create a 3D wire that follows a sequence of 3D points.

  The input `points` define a polyline (control points). By default the path is
  resampled into a smooth Catmull-Rom spline using `smooth_path()`. The wire is
  then built from capsule-like segments (cylinder + spherical ends). Optionally
  the last segment can be "cut" to reveal an inner metal conductor.

  **Parameters:**
  - `points` (list of vec3):
      Control points of the wire centerline (must contain at least 2 points).
  - `d` (number, default 2):
      Outer diameter of the insulated wire.
  - `colr` (color, optional):
      Wire insulation color passed to `color()`.
  - `mode` (string, default "uniform"):
      Smoothing mode for `smooth_path()`:
      - "uniform" | "centripetal" | "chordal"
      - "none" or `undef` disables smoothing and uses `points` as-is.
  - `quality` (string, default "medium"):
      Sampling density hint for adaptive resampling ("low" | "medium" | "high").
  - `step` (number, optional):
      Target spacing between generated samples; overrides quality-based default.
  - `cut_len` (number, default 5):
      If numeric, only the final segment is cut back by this length, exposing an
      inner conductor. Use `undef` to disable cutting entirely.
  - `put_joints` (bool, default false):
      If true, draws spheres at the *original* control points (not resampled
      points). Useful for debugging routing.
  - `$fn_sph` (int, default 12):
      Fragment count for the endpoint spheres (visual smoothness).
  - `print_wire_len` (bool, default false):
      If true, prints the total length (after smoothing/resampling) via `echo()`.

  Notes:
  - Length is computed on the generated path (`smooth_points`), so smoothing and
    sampling affect the reported value slightly.
  - Very short/degenerate segments are handled by drawing a sphere instead.

  **Example:**
  ```scad
  wire_path(
    points=concat([[0, 0, 0]],
                  [[0, -5, -2],
                   [-22, -15, -1],
                   [-22, 10, -60],
                   [-70, 10, -60]]),
    d=1.5,
    colr="red",
    mode="centripetal",
    quality="medium",
    cut_len=5,
    put_joints=true,
    print_wire_len=true
  );
  ```
 */
module wire_path(points,
                 d=2,
                 put_joints=false,
                 $fn_sph=12,
                 print_wire_len=false,
                 cut_len=5,
                 mode="uniform", // "centripetal" | "uniform" (default) | "chordal" | undef | "none"
                 quality="medium", // "low" | "medium" (default) | "high" - affects adaptive step size.
                 step,
                 colr) {
  smooth_points = mode == "none" || is_undef(mode)
    ? points
    : smooth_path(points=points,
                  mode=mode,
                  quality=quality,
                  step=step,
                  d=d);
  n = len(smooth_points);
  suf = suffix_lengths(smooth_points);

  for (i = [0 : len(smooth_points) -  2]) {
    let (remaining_cut =
         (!is_num(cut_len) || cut_len <= 0) ? 0 :
// distance that should be cut starting from the very end, measured backward
// For segment i, the part within cut_len is: clamp(cut_len - length_after_this_segment, 0..seglen)
         max(0, cut_len - (i + 1 <= n-2 ? suf[i + 1] : 0)),

         cut_l = (is_num(cut_len) && (len(smooth_points) - 1 == i + 1))
         ? cut_len : undef) {
      wire_segment_capsule(smooth_points[i],
                           smooth_points[i + 1],
                           colr=colr,
                           cut_len=(remaining_cut > 0 ? remaining_cut : undef),
                           d=d,
                           $fn_sph=$fn_sph);
    }
  }

  if (print_wire_len) {
    echo("Total wire length: ", total_wire_length(smooth_points));
  }

  if (put_joints)
    for (i = [0 : len(points) - 2]) {
      translate(points[i]) {
        color(colr, alpha=1) {
          sphere(d=d, $fn=$fn_sph);
        }
      }
    }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  wire_bundle
  ─────────────────────────────────────────────────────────────────────────────

  Draw a bundle (harness) of multiple parallel wires routed along a single
  centerline path.

  Each wire is generated by offsetting the input `points` sideways (in the plane
  defined by `up`) and then calling `wire_path()` for each color in `colors`.
  Offsets are symmetric about the original path, with spacing determined by
  `d + gap`.

  **Parameters:**
  - `points` (list of vec3):
      Centerline control points of the harness (must contain at least 2 points).
  - `colors` (list, default ["black","red","white"]):
      One wire is created per entry. Values are passed to `color()`.
  - `d` (number, default 1.5):
      Outer diameter of each individual wire.
  - `gap` (number, default 0.2):
      Extra spacing between adjacent wires (pitch = d + gap).
  - `up` (vec3, default [0,0,1]):
      Reference "up" direction used to compute the lateral offset direction for
      `offset_path()`. Change this if your harness should spread in another plane.
  - `mode`, `quality`, `step`:
      Passed through to `wire_path()` to control smoothing/resampling.
  - `cut_len` (number, default 5):
      Passed through to `wire_path()` (applies to the last segment of each wire).
  - `put_joints` (bool, default false):
      Passed through to `wire_path()`. Note that joints refer to each wire’s
      control points after offsetting.
  - `print_wire_len` (bool, default false):
      If true, length is printed only once (for the first wire) to avoid spam.

  **Example:**
  ```scad
  wire_bundle(
    d=1.5,
    gap=0.4,
    points=[[0, 0, 0],
            [0, -5, -2],
            [-22, -15, -1],
            [-22, 10, -60],
            [-70, 10, -60]],
    colors=["black", "red", "white"],
    mode="centripetal",
    quality="medium"
  );
  ```
 */
module wire_bundle(points,
                   d=1.5,
                   gap=0.2,
                   colors=["black", "red", "white"],
                   put_joints=false,
                   print_wire_len=false,
                   cut_len=5,
                   mode="uniform",
                   quality="medium",
                   step,
                   up=[0, 0, 1]) {

  n = len(colors);
  pitch = d + gap;

  for (i = [0:n-1]) {
    offset = (i - (n - 1) / 2) * pitch;
    pts = offset_path(points, offset, up);

    wire_path(points=pts,
              d=d,
              put_joints=put_joints,
              print_wire_len=print_wire_len && i == 0,
              mode=mode,
              quality=quality,
              step=step,
              cut_len=cut_len,
              colr=colors[i]);
  }
}

/**
 * Draw cylinder from p1 to p2, axis along segment.
 */
module cylinder_between_points(p1, p2, d=2, $fn=16) {
  v = p2 - p1;
  len = vlen(v);

  if (len > 1e-9) {
    translate(p1)
      rotate(rot_from_z(v))
      cylinder(h=len, d=d, center=false, $fn=$fn);
  }
}

/**
 * Capsule-like segment:
 * cylinder + endpoint spheres
 */
module wire_segment(d, p1, p2, colr, $fn_sph=16, $fn_cyl=16) {
  color(colr, alpha=1) {
    if (vlen(p2 - p1) > 1e-6) {
      union() {
        cylinder_between_points(p1, p2, d=d, $fn=$fn_cyl);
        translate(p1) {
          sphere(d=d, $fn=$fn_sph);
        }
        translate(p2) sphere(d=d, $fn=$fn_sph);
      }
    } else {
      translate(p1) {
        sphere(d=d, $fn=$fn_sph);
      }
    }
  }
}

/**
 * Cuttable wire segment with inner metal lead.
 */
module wire_segment_capsule(p1,
                            p2,
                            d=2,
                            colr,
                            $fn_sph=16,
                            $fn_cyl=16,
                            wire_lead_color=metallic_silver_1,
                            cut_len) {

  if (is_num(cut_len) && vlen(p2 - p1) > 1e-6) {
    dir = vunit(p2 - p1);

    union() {
      difference() {
        wire_segment(p1=p1,
                     p2=p2,
                     d=d,
                     colr=colr,
                     $fn_sph=$fn_sph,
                     $fn_cyl=$fn_cyl);

        wire_segment(p1=p2,
                     p2=p2 - dir * cut_len,
                     d=d + 1,
                     colr=colr,
                     $fn_sph=$fn_sph,
                     $fn_cyl=$fn_cyl);
      }

      color(wire_lead_color, alpha=1) {
        wire_segment(p1=p1,
                     p2=p2,
                     d=d / 2,
                     colr=wire_lead_color,
                     $fn_sph=max(8, floor($fn_sph * 0.75)),
                     $fn_cyl=max(8, floor($fn_cyl * 0.75)));
      }
    }
  } else {
    wire_segment(p1=p1,
                 p2=p2,
                 d=d,
                 colr=colr,
                 $fn_sph=$fn_sph,
                 $fn_cyl=$fn_cyl);
  }
}

module wire(p1=[0, 0, 0], p2=[10, 0, 0], d=2, $fn_sph=12) {
  wire_segment_capsule(p1, p2, d=d, $fn_sph=$fn_sph);
}
