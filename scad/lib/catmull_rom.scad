/**
  Module: Catmull–Rom spline utilities

  Usage example with wiring module:

  @example
  ```scad
  d=1.5;
  x_spacing=5;
  y_spacing=5;
  step = 2;

  pts=[[0, 0, 0],
       [0, -5, -2],
       [-22, -15, -1],
       [-22, 10, -60],
       [-70, 10, -60]];

  // [...["centripetal" | "uniform" | "chordal", step, color]]
  examples = [["uniform", step, "blue"],
              ["centripetal", step, "green"],
              ["chordal", step, "red"]];

  union() {
    for (i = [0 : len(examples) - 1]) {
      let (mode=examples[i][0],
           st = examples[i][1],
           points = smooth_path(pts, mode=mode, step=st),
           colr = examples[i][2],
           x = i * x_spacing,
           y = i * y_spacing) {

        translate([x, y, 0]) {
          wire_path(points=points,
                    d=d,
                    colr=colr,
                    put_joints=false);
        }
      }
    }
  }
  ```



Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
  */

use <functions.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  smooth_path
  ─────────────────────────────────────────────────────────────────────────────
  Main combined function.

  **Parameters:**

  `points`: Polyline points.
  `step`: Desired spacing between samples.
  `mode`: "centripetal" (default) | "uniform" | "chordal"


  **Example**:
  ```scad
  pts = [[0, 0, 0],
         [0, -5, -2],
         [-22, -15, -1],
         [-22, 10, -60],
         [-70, 10, -60]];
  smooth_path(pts, step=2, mode="centripetal")

  ```
  */
function smooth_path(points, step=2, mode="centripetal") =
  let (p = drop_consecutive_dups(points))
  mode=="uniform"      ? cr_resample_adaptive(p, step=step) :
  mode=="centripetal"  ? cr_c_resample_adaptive(p, step=step, alpha=0.5) :
  mode=="chordal"      ? cr_c_resample_adaptive(p, step=step, alpha=1.0) :
  p;

/**
  ─────────────────────────────────────────────────────────────────────────────
  catmull_rom
  ─────────────────────────────────────────────────────────────────────────────

  Catmull-Rom point for parameter t in [0..1] between p1 and p2.
  Standard uniform Catmull-Rom basis.

  **Example**:
  ```scad
  catmull_rom([-22, -15, -1],
              [-22, 10, -60],
              [-70, 10, -60],
              [-70, 10, -60],
              0.8);          // -> [-62.704, 10.4, -60.944]

  catmull_rom([-22, -15, -1],
              [-22, 10, -60],
              [-70, 10, -60],
              [-70, 10, -60],
              1);            // -> [-70, 10, -60]

  ```
  */
function catmull_rom(p0, p1, p2, p3, t) =
  let (t2=t * t,
       t3=t2 * t)
  vmul(vadd(vadd(vadd(vmul(p1, 2),
                      vmul(vsub(p2, p0), t)),
                 vmul(vadd(vsub(vmul(p0, 2), vmul(p1, 5)),
                           vsub(vmul(p2, 4), p3)), t2)),
            vmul(vadd(vsub(vmul(p1, 3), vmul(p0, 1)),
                      vsub(p3, vmul(p2, 3))), t3)),
       0.5)
  ;

/**
  ─────────────────────────────────────────────────────────────────────────────
  cr_point
  ─────────────────────────────────────────────────────────────────────────────
  Endpoint handling: "clamped" by repeating end points.
  Segment i goes from points[i] to points[i+1].

  **Example**:
  ```scad
  cr_point(points=[[0, 0, 0],
                   [0, -5, -2],
                   [-22, -15, -1],
                   [-22, 10, -60],
                   [-70, 10, -60]],
           i=3,
           t=1) // -> [-70, 10, -60]

  ```
  */
function cr_point(points, i, t) =
  let (n = len(points),
       p0 = points[max(i-1, 0)],
       p1 = points[i],
       p2 = points[i + 1],
       p3 = points[min(i + 2, n-1)])
  catmull_rom(p0, p1, p2, p3, t);

/**
  ─────────────────────────────────────────────────────────────────────────────
  cr_resample
  ─────────────────────────────────────────────────────────────────────────────

  Resample whole polyline into a smooth, dense list.

  **Parameters:**

  `points`: polyline points.
  `samples_per_seg`: more = smoother (typical 10..40).


  **Example**:
  ```scad
  cr_resample([[0, 0, 0],
               [0, -5, -2],
               [-22, -15, -1],
               [-22, 10, -60],
               [-70, 10, -60]]);

  ```


  */
function cr_resample(points, samples_per_seg=20) =
  len(points) < 2
  ? points
  : concat([points[0]],
           [for (i=[0:len(points)-2])
               for (k=[1:samples_per_seg]) // start at 1 to avoid duplicating segment start
                 cr_point(points, i, k / samples_per_seg)]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  cr_resample_adaptive
  ─────────────────────────────────────────────────────────────────────────────

  Adaptive sampling based on segment length.

   **Parameters:**

  `points`: polyline points.
  `step`: desired spacing between samples

  **Example**:
  ```scad
  cr_resample_adaptive(points=[[0, 0, 0],
                               [0, -5, -2],
                               [-22, -15, -1],
                               [-22, 10, -60],
                               [-70, 10, -60]],
                       step=10);

  ```
  */
function cr_resample_adaptive(points, step=2) =
  let (st = max(step, 1e-6))
  len(points) < 2 ? points :
  concat([points[0]],
         [for (i=[0:len(points)-2])
             let (seglen = vlen(vsub(points[i + 1], points[i])),
                  s = max(3, ceil(seglen / st)))
               for (k=[1:s])
                 cr_point(points, i, k / s)]);

// ─────────────────────────────────────────────────────────────────────────────
// Centripetal Catmull-Rom (3D) + resampling
// ─────────────────────────────────────────────────────────────────────────────

/**
  ─────────────────────────────────────────────────────────────────────────────
  vlerp
  ─────────────────────────────────────────────────────────────────────────────

  **Example**:
  ```scad
  vlerp([-22, 10, -60], [-70, 10, -60], 1); // ->  [-70, 10, -60]
  vlerp([-22, -15, -1], [-22, 10, -60], 1.8655); // -> [-22, 31.6374, -111.064]

  ```
  */
function vlerp(a, b, t) =
  vadd(vmul(a, 1-t), vmul(b, t));

/**
  ─────────────────────────────────────────────────────────────────────────────
  tj
  ─────────────────────────────────────────────────────────────────────────────

  Centripetal parameter increment.

  Alpha = 0.5 is centripetal;
  alpha = 0.0 uniform;
  alpha = 1.0 chordal

  **Example**:
  ```scad
  tj(ti=0, pi=[-22, -15, -1], pj=[-22, 10, -60], alpha=0.5) // -> 8.00488
  tj(ti=8.00488, pi=[-22, 10, -60], pj=[-70, 10, -60], alpha=0.5) // -> 14.9331

  ```
  */
function tj(ti, pi, pj, alpha=0.5) =
  let (d = vlen(vsub(pj, pi)))
  ti + pow(max(d, 1e-9), alpha);

/**
  ─────────────────────────────────────────────────────────────────────────────
  catmull_rom_centripetal
  ─────────────────────────────────────────────────────────────────────────────
  Evaluate centripetal Catmull-Rom at u in [0..1] between p1 and p2

  **Example**:
  ```scad
  catmull_rom_centripetal(p0=[-22, -15, -1],
                          p1=[-22, 10, -60],
                          p2=[-70, 10, -60],
                          p3=[-70, 10, -60],
                          u=1,
                          alpha=0.5); // -> [-70, 10, -60]
  ```
  */
function catmull_rom_centripetal(p0, p1, p2, p3, u, alpha=0.5) =
  let (t0 = 0,
       t1 = tj(t0, p0, p1, alpha),
       t2 = tj(t1, p1, p2, alpha),
       t3 = tj(t2, p2, p3, alpha),
       t  = t1 + (t2 - t1) * u,
       eps = 1e-9,
       dt01 = max(eps, t1 - t0),
       dt12 = max(eps, t2 - t1),
       dt23 = max(eps, t3 - t2),
       dt02 = max(eps, t2 - t0),
       dt13 = max(eps, t3 - t1),

       A1 = vlerp(p0, p1, (t - t0)/dt01),
       A2 = vlerp(p1, p2, (t - t1)/dt12),
       A3 = vlerp(p2, p3, (t - t2)/dt23),

       B1 = vlerp(A1, A2, (t - t0)/dt02),
       B2 = vlerp(A2, A3, (t - t1)/dt13),

       C  = vlerp(B1, B2, (t - t1)/dt12))
  C;

/**
  ─────────────────────────────────────────────────────────────────────────────
  cr_c_point
  ─────────────────────────────────────────────────────────────────────────────

  Endpoint handling: clamp by repeating end points

  */
function cr_c_point(points, i, u, alpha=0.5) =
  let (n = len(points),
       p0 = points[max(i-1, 0)],
       p1 = points[i],
       p2 = points[i + 1],
       p3 = points[min(i + 2, n - 1)])
  catmull_rom_centripetal(p0, p1, p2, p3, u, alpha);

/**
  ─────────────────────────────────────────────────────────────────────────────
  cr_c_resample
  ─────────────────────────────────────────────────────────────────────────────

  Fixed samples per segment

  **Example**:
  ```scad
  cr_c_resample()

  ```
  */
function cr_c_resample(points, samples_per_seg=20, alpha=0.5) =
  len(points) < 2
  ? points
  : concat([points[0]],
           [for (i=[0:len(points)-2])
               for (k=[1:samples_per_seg]) // avoid duplicating segment starts
                 cr_c_point(points, i, k/samples_per_seg, alpha)]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  cr_c_resample_adaptive
  ─────────────────────────────────────────────────────────────────────────────

  Adaptive sampling by segment length.

  **Parameters:**

  `step`: desired spacing between samples.

  **Example**:
  ```scad
  pts = [[0, 0, 0],
         [0, -5, -2],
         [-22, -15, -1],
         [-22, 10, -60],
         [-70, 10, -60]];
  cr_c_resample_adaptive(pts, step=2, alpha=0.5)

  ```
  */
function cr_c_resample_adaptive(points, step=2, alpha=0.5) =
  let (st = max(step, 1e-6))
  len(points) < 2 ? points :
  concat([points[0]],
         [for (i=[0:len(points)-2])
             let (seglen = vlen(vsub(points[i + 1], points[i])),
                  s = max(3, ceil(seglen/st)))
               for (k=[1:s])
                 cr_c_point(points, i, k/s, alpha)]);

function drop_consecutive_dups(pts, eps=1e-9) =
  len(pts) <= 1 ? pts :
  concat([pts[0]],
         [for (i=[1:len(pts)-1])
             if (vlen(vsub(pts[i], pts[i-1])) > eps) pts[i]]);