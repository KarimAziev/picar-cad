/**
  * Module: Threading modules
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  *
  * Adapted in part from Ryan A. Colyer's threads-scad:
  *   https://github.com/rcolyer/threads-scad
  *   Original work released under CC0 1.0 Universal.
  *
  * Credit and thanks to Ryan Colyer for the original work and inspiration.
  * License: GPL-3.0-or-later
  *
  */

use <thread_funcs.scad>

screw_resolution = 0.2;  // in mm

/**
   ─────────────────────────────────────────────────────────────────────────────
   close_points
   ─────────────────────────────────────────────────────────────────────────────

   Generates a closed polyhedron from an array of arrays of points, with each
   inner array tracing one loop outlining the polyhedron.

   `pointarrays` should contain `N` arrays of `P` points describing a closed
   manifold. Each inner array is one closed loop, and all loops must have the
   same number of points.

   The points must obey the right-hand rule. For example, when viewed from
   above, the `P` points in each inner array should run counter-clockwise,
   while the `N` point arrays progress upward along the shape.

   Points in each inner array do not need to have equal height, but they
   usually should not meet or cross the line segments formed with adjacent
   points in neighboring arrays.

   Requires `N >= 2` and `P >= 3`.

   Adjacent loops are connected using the core triangle pattern:

   ```text
   [j][i], [j+1][i], [j+1][(i+1)%P]
   [j][i], [j+1][(i+1)%P], [j][(i+1)%P]
   ```

   The first and last loops are then closed with triangle fans using the
   average point of each loop as the cap center.

   **Parameters:**

   `pointarrays`: array of `N` point loops, each containing `P` 3D points

   **Example:**

   ```scad
   close_points([
     [[1,0,0],[0,1,0],[-1,0,0],[0,-1,0]],
     [[1,0,1],[0,1,1],[-1,0,1],[0,-1,1]]
   ]);
   ```
*/

module close_points(pointarrays) {
  N = len(pointarrays);
  P = len(pointarrays[0]);

  NP = N * P;

  midbot = recurse_avg(pointarrays[0]);
  midtop = recurse_avg(pointarrays[N-1]);

  faces_bot = [for (i=[0:P-1]) [0, i + 1, 1 + (i + 1) % len(pointarrays[0])]];

  loop_offset = 1;

  faces_loop = [for (j=[0:N-2], i=[0:P-1], t=[0:1])
      [loop_offset, loop_offset, loop_offset] +
        (t==0
         ? [j * P + i, (j + 1) * P + i, (j + 1) * P + (i + 1) % P]
         : [j * P + i, (j + 1) * P + (i + 1) % P, j * P + (i + 1) % P])];

  top_offset = loop_offset + NP - P;

  midtop_offset = top_offset + P;

  faces_top = [for (i=[0:P-1]) [midtop_offset,
                                top_offset+(i + 1) % P,
                                top_offset + i]];

  points = [for (i=[-1:NP])
      (i < 0)
        ? midbot
        : ((i == NP)
           ? midtop
           : pointarrays[floor(i / P)][i % P])];

  faces = concat(faces_bot, faces_loop, faces_top);

  polyhedron(points=points, faces=faces);
}

/**
   ─────────────────────────────────────────────────────────────────────────────
   screw_thread
   ─────────────────────────────────────────────────────────────────────────────

   Generates a closed polyhedral model of an external screw thread.

   The thread is formed by sampling rings of points around the axis and
   advancing them helically along the height. These sampled loops are then
   connected and capped using `close_points()` to produce a closed manifold.

   If `pitch` is `0`, a default pitch is obtained from `thread_pitch(od)`.
   If `tooth_height` is `0`, it defaults to `pitch`.

   The outer diameter is adjusted slightly by `tolerance` to compensate for
   printing shrinkage. The top of the thread may optionally be tapered using
   `tip_height`, and the taper may preserve a minimum fractional tooth width
   using `tip_min_fract`.

   The generated geometry is resolution-limited by `screw_resolution`, which
   also sets lower bounds for radius, height, and circumferential sampling.

   **Parameters:**

   `od`: nominal outer diameter
   `height`: total thread height
   `pitch`: thread pitch, or `0` to use `thread_pitch(od)`
   `tooth_angle`: flank angle in degrees
   `tolerance`: print compensation applied to the outer diameter
   `tip_height`: height of the tapered thread tip
   `tooth_height`: axial height of one tooth, or `0` to use `pitch`
   `tip_min_fract`: minimum retained fraction of the tip width, clamped to
   `[0, 0.9999]`

   **Returns:**
   No value. Produces a threaded solid.

   **Example:**

   ```scad
   screw_thread(od=12, height=20, pitch=2);
  ```
*/
module screw_thread(od,
                    height,
                    pitch=0,
                    tooth_angle=30,
                    tolerance=0.4,
                    tip_height=0,
                    tooth_height=0,
                    tip_min_fract=0) {

  pitch = (pitch==0) ? thread_pitch(od) : pitch;

  tooth_height = (tooth_height==0) ? pitch : tooth_height;

  tip_min_fract = (tip_min_fract<0) ? 0 :
    ((tip_min_fract>0.9999) ? 0.9999 : tip_min_fract);

  outer_diam_cor = od + 0.25 * tolerance; // Plastic shrinkage correction

  inner_diam = od - tooth_height / tan(tooth_angle);

  or = (outer_diam_cor < screw_resolution) ?
    screw_resolution/2 : outer_diam_cor / 2;
  ir = (inner_diam < screw_resolution) ? screw_resolution / 2 : inner_diam / 2;
  height = (height < screw_resolution) ? screw_resolution : height;

  steps_per_loop_try = ceil(2 * PI * or / screw_resolution);
  steps_per_loop = (steps_per_loop_try < 4) ? 4 : steps_per_loop_try;
  hs_ext = 3;
  hsteps = ceil(3 * height / pitch) + 2 * hs_ext;

  extent = or - ir;

  tip_start = height-tip_height;
  tip_height_sc = tip_height / (1-tip_min_fract);

  tip_height_ir = (tip_height_sc > tooth_height/2) ?
    tip_height_sc - tooth_height/2 : tip_height_sc;

  tip_height_w = (tip_height_sc > tooth_height) ? tooth_height : tip_height_sc;
  tip_wstart = height + tip_height_sc - tip_height - tip_height_w;

  pointarrays = [for (hs=[0:hsteps])
      [for (s=[0:steps_per_loop - 1])
          let (ang_full = s * 360.0 / steps_per_loop,
               ang_pn = atan2(sin(ang_full), cos(ang_full)),
               ang = ang_pn < 0 ? ang_pn + 360 : ang_pn,

               h_fudge = pitch*0.001,

               h_mod = (hs%3 == 2)
               ? ((s == steps_per_loop-1)
                  ? tooth_height - h_fudge
                  : ((s == steps_per_loop-2)
                     ? tooth_height/2
                     : 0))
               : ((hs%3 == 0) ?
                  ((s == steps_per_loop-1)
                   ? pitch-tooth_height/2
                   : ((s == steps_per_loop-2)
                      ? pitch-tooth_height + h_fudge : 0))
                  : ((s == steps_per_loop-1)
                     ? pitch-tooth_height/2 + h_fudge :
                     ((s == steps_per_loop-2)
                      ? tooth_height/2 : 0))),

               h_level = (hs % 3 == 2)
               ? tooth_height - h_fudge
               : ((hs % 3 == 0) ? 0 : tooth_height / 2),

               h_ub = floor((hs-hs_ext)/3) * pitch
               + h_level + ang * pitch/360.0 - h_mod,
               h_max = height - (hsteps - hs) * h_fudge,
               h_min = hs * h_fudge,
               h = (h_ub < h_min) ? h_min : ((h_ub > h_max) ? h_max : h_ub),

               ht = h - tip_start,
               hf_ir = ht/tip_height_ir,
               ht_w = h - tip_wstart,
               hf_w_t = ht_w/tip_height_w,
               hf_w = (hf_w_t < 0) ? 0 : ((hf_w_t > 1) ? 1 : hf_w_t),

               ext_tip = (h <= tip_wstart) ? extent : (1-hf_w) * extent,
               wnormal = tooth_width(ang, h, pitch, tooth_height, ext_tip),
               w = (h <= tip_wstart) ? wnormal :
               (1-hf_w) * wnormal +
               hf_w * (0.1 * screw_resolution
                       + (wnormal * wnormal * wnormal /
                          (ext_tip*ext_tip + 0.1 * screw_resolution))),
               r = (ht <= 0) ? ir + w :
               ((ht < tip_height_ir ? ((2/(1+(hf_ir*hf_ir))-1) * ir)
                 : 0) + w))

            [r * cos(ang), r * sin(ang), h]]];

  close_points(pointarrays);
}

module screw_hole_thread(d,
                         h,
                         pitch=0,
                         tooth_angle=30,
                         tolerance=0.4,
                         tooth_height=0) {
  screw_thread(1.01 * d + 1.25 * tolerance,
               h,
               pitch,
               tooth_angle,
               tolerance,
               tooth_height=tooth_height);
}

// This creates a threaded hole in its children using metric standards by
// default.
module screw_hole(od,
                  height,
                  position=[0, 0, 0],
                  rotation=[0, 0, 0],
                  pitch=0,
                  tooth_angle=30,
                  tolerance=0.4,
                  tooth_height=0) {
  extra_height = height + 1;

  module _hole() {
    translate(position) {
      rotate(rotation) {
        translate([0, 0, -extra_height / 2]) {
          screw_thread(1.01*od + 1.25*tolerance,
                       height + extra_height,
                       pitch,
                       tooth_angle,
                       tolerance,
                       tooth_height=tooth_height);
        }
      }
    }
  }

  if ($children > 0) {
    difference() {
      children();
      _hole();
    }
  } else {
    _hole();
  }
}

// This creates a vertical rod at the origin with external auger-style
// threads.
module auger_thread(od,
                    inner_diam,
                    height,
                    pitch,
                    tooth_angle=30,
                    tolerance=0.4,
                    tip_height=0,
                    tip_min_fract=0) {
  tooth_height = tan(tooth_angle)*(od-inner_diam);
  screw_thread(od,
               height,
               pitch,
               tooth_angle,
               tolerance,
               tip_height,
               tooth_height,
               tip_min_fract);
}

// This creates an auger-style threaded hole in its children.
module auger_hole(od,
                  inner_diam,
                  height,
                  pitch,
                  position=[0, 0, 0],
                  rotation=[0, 0, 0],
                  tooth_angle=30,
                  tolerance=0.4) {
  tooth_height = tan(tooth_angle)*(od-inner_diam);
  screw_hole(od,
             height,
             position,
             rotation,
             pitch,
             tooth_angle,
             tolerance,
             tooth_height=tooth_height) children();
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  clearance_hole
  ─────────────────────────────────────────────────────────────────────────────

  Inserts a clearance_hole in its children.

  The rotation vector is applied first, then the position translation, starting
  from a position upward from the z-axis at z=0.

  */
module clearance_hole(d,
                      height,
                      position=[0, 0, 0],
                      rotation=[0, 0, 0],
                      tolerance=0.4) {
  extra_height = 0.001 * height;

  difference() {
    children();
    translate(position) {
      rotate(rotation) {
        translate([0, 0, -extra_height/2]) {
          cylinder(h=height + extra_height, r=(d/2 + tolerance));
        }
      }
    }
  }
}

// This inserts a clearance_hole with a recessed bolt hole in its children.
// The rotation vector is applied first, then the position translation,
// starting from a position upward from the z-axis at z=0.  The default
// recessed parameters fit a standard metric bolt.
module recessed_clearance_hole(d,
                               height,
                               position=[0, 0, 0],
                               rotation=[0, 0, 0],
                               recessed_diam=-1,
                               recessed_height=-1,
                               tolerance=0.4) {
  recessed_diam = (recessed_diam < 0) ?
    hex_across_corners(d) : recessed_diam;
  recessed_height = (recessed_height < 0) ? d : recessed_height;
  extra_height = 0.001 * height;

  difference() {
    children();
    translate(position)
      rotate(rotation)
      translate([0, 0, -extra_height/2])
      cylinder(h=height + extra_height, r=(d/2 + tolerance));
    translate(position)
      rotate(rotation)
      translate([0, 0, -extra_height/2])
      cylinder(h=recessed_height + extra_height/2,
               r=(recessed_diam/2 + tolerance));
  }
}

// This inserts a countersunk clearance_hole in its children.
// The rotation vector is applied first, then the position translation,
// starting from a position upward from the z-axis at z=0.
// The countersunk side is on the bottom by default.
module countersunk_clearance_hole(d,
                                  height,
                                  position=[0, 0, 0],
                                  rotation=[0, 0, 0],
                                  sinkdiam=0,
                                  sinkangle=45,
                                  tolerance=0.4) {
  extra_height = 0.001 * height;
  sinkdiam = (sinkdiam==0) ? 2*d : sinkdiam;
  sinkheight = ((sinkdiam-d)/2)/tan(sinkangle);

  difference() {
    children();
    translate(position)
      rotate(rotation)
      translate([0, 0, -extra_height/2])
      union() {
      cylinder(h=height + extra_height, r=(d/2 + tolerance));
      cylinder(h=sinkheight + extra_height,
               r1=(sinkdiam/2 + tolerance),
               r2=(d/2 + tolerance),
               $fn=24*d);
    }
  }
}

// This inserts a Phillips tip shaped hole into its children.
// The rotation vector is applied first, then the position translation,
// starting from a position upward from the z-axis at z=0.
module phillips_tip(width=7,
                    thickness=0,
                    straightdepth=0,
                    position=[0, 0, 0],
                    rotation=[0, 0, 0]) {
  thickness = (thickness <= 0) ? width*2.5/7 : thickness;
  straightdepth = (straightdepth <= 0) ? width*3.5/7 : straightdepth;
  angledepth = (width-thickness)/2;
  height = straightdepth + angledepth;
  extra_height = 0.001 * height;

  difference() {
    children();
    translate(position) {
      rotate(rotation) {
        union() {
          hull() {
            translate([-width/2, -thickness/2, -extra_height/2]) {
              cube([width, thickness, straightdepth + extra_height]);
            }
            translate([-thickness/2, -thickness/2, height-extra_height]) {
              cube([thickness, thickness, extra_height]);
            }
          }
          hull() {
            translate([-thickness/2, -width/2, -extra_height/2]) {
              cube([thickness, width, straightdepth + extra_height]);
            }
            translate([-thickness/2, -thickness/2, height-extra_height]) {
              cube([thickness, thickness, extra_height]);
            }
          }
        }
      }
    }
  }
}

// Create a standard sized metric bolt with hex head and hex key.
module metric_bolt(d, l, tolerance=0.4) {
  drive_tolerance = pow(3 * tolerance / hex_drive_across_corners(d), 2) + 0.75 * tolerance;

  difference() {
    cylinder(h=d,
             r=(hex_across_corners(d)/2-0.5 * tolerance),
             $fn=6);
    cylinder(h=d,
             r=(hex_drive_across_corners(d) + drive_tolerance) / 2,
             $fn=6,
             center=true);
  }
  translate([0, 0, d - 0.01]) {
    screw_thread(d,
                 l + 0.01,
                 tolerance=tolerance,
                 tip_height=thread_pitch(d),
                 tip_min_fract=0.75);
  }
}

// Create a standard sized metric countersunk (flat) bolt with hex key drive.
// In compliance with convention, the l for this includes the head.
module metric_countersunk_bolt(d, l, tolerance=0.4) {
  drive_tolerance = pow(3*tolerance/countersunk_drive_across_corners(d),
                        2)
    + 0.75*tolerance;

  difference() {
    cylinder(h=d/2, r1=d, r2=d/2, $fn=24*d);
    cylinder(h=0.8*d,
             r=(countersunk_drive_across_corners(d) + drive_tolerance)/2,
             $fn=6,
             center=true);
  }
  translate([0, 0, d/2-0.01])
    screw_thread(d,
                 l-d/2 + 0.01,
                 tolerance=tolerance,
                 tip_height=thread_pitch(d),
                 tip_min_fract=0.75);
}

// Create a standard sized metric countersunk (flat) bolt with hex key drive.
// In compliance with convention, the l for this includes the head.
module metric_wood_screw(d, l, tolerance=0.4) {
  echo("d", d, "l", l);
  phillips_tip(d - 2) {
    union() {
      cylinder(h=d / 2, r1=d, r2=d / 2, $fn=24 * d);

      translate([0, 0, d / 2-0.01]) {
        screw_thread(od=d,
                     height=l - d / 2 + 0.01,
                     tolerance=tolerance,
                     tip_height=d);
      }
    }
  }
}

// Create a standard sized metric hex nut.
module metric_nut(d, thickness, tolerance=0.4) {
  thickness = (is_undef(thickness) || thickness==0)
    ? nut_thickness(d)
    : thickness;
  screw_hole(d, thickness, tolerance=tolerance) {
    cylinder(h=thickness,
             r=hex_across_corners(d) / 2 - 0.5 * tolerance,
             $fn=6);
  }
}

// Create a convenient washer size for a metric nominal thread d.
module metric_washer(d) {
  difference() {
    cylinder(h=d/5, r=1.15*d, $fn=24*d);
    cylinder(h=2*d, r=0.575*d, $fn=12*d, center=true);
  }
}

// Solid rod on the bottom, external threads on the top.
module rod_start(d, height, thread_len=0, thread_diam=0, thread_pitch=0) {
  // A reasonable default.
  thread_diam = (thread_diam==0) ? 0.75*d : thread_diam;
  thread_len = (thread_len==0) ? 0.5*d : thread_len;
  thread_pitch = (thread_pitch==0) ? thread_pitch(thread_diam) : thread_pitch;

  cylinder(r=d/2, h=height, $fn=24*d);

  translate([0, 0, height])
    screw_thread(thread_diam,
                 thread_len,
                 thread_pitch,
                 tip_height=thread_pitch,
                 tip_min_fract=0.75);
}

// Solid rod on the bottom, internal threads on the top.
// Flips around x-axis after printing to pair with rod_start.
module rod_end(d, height, thread_len=0, thread_diam=0, thread_pitch=0) {
  // A reasonable default.
  thread_diam = (thread_diam==0) ? 0.75*d : thread_diam;
  thread_len = (thread_len==0) ? 0.5*d : thread_len;
  thread_pitch = (thread_pitch==0) ? thread_pitch(thread_diam) : thread_pitch;

  screw_hole(thread_diam,
             thread_len,
             [0, 0, height],
             [180, 0, 0],
             thread_pitch)
    cylinder(r=d/2, h=height, $fn=24*d);
}

// Internal threads on the bottom, external threads on the top.
module rod_extender(d,
                    height,
                    thread_len=0,
                    thread_diam=0,
                    thread_pitch=0) {
  // A reasonable default.
  thread_diam = (thread_diam==0) ? 0.75*d : thread_diam;
  thread_len = (thread_len==0) ? 0.5*d : thread_len;
  thread_pitch = (thread_pitch==0) ? thread_pitch(thread_diam) : thread_pitch;

  max_bridge = height - thread_len;
  // Use 60 degree slope if it will fit.
  bridge_height = ((thread_diam/4) < max_bridge) ? thread_diam/4 : max_bridge;

  difference() {
    union() {
      screw_hole(thread_diam, thread_len, pitch=thread_pitch) {
        cylinder(r=d/2, h=height, $fn=24*d);
      }

      translate([0, 0, height]) {
        screw_thread(thread_diam,
                     thread_len,
                     pitch=thread_pitch,
                     tip_height=thread_pitch,
                     tip_min_fract=0.75);
      }
    }
    // Carve out a small conical area as a bridge.
    translate([0, 0, thread_len]) {
      cylinder(h=bridge_height, r1=thread_diam/2, r2=0.1);
    }
  }
}

// Produces a matching set of metric bolts, nuts, and washers.
module metric_bolt_set(d, l, quantity=1) {
  for (i=[0:quantity-1]) {
    translate([0, i * 4 * d, 0]) {
      metric_bolt(d, l);
    }
    translate([4 * d, i * 4 *d, 0]) {
      metric_nut(d);
    }
    translate([8*d, i*4*d, 0]) {
      metric_washer(d);
    }
  }
}

module demo() {
  translate([0,-0, 0]) metric_bolt_set(3, 8);
  translate([0,-20, 0]) metric_bolt_set(4, 8);
  translate([0,-40, 0]) metric_bolt_set(5, 8);
  translate([0,-60, 0]) metric_bolt_set(6, 8);
  translate([0,-80, 0]) metric_bolt_set(8, 8);

  translate([0, 25, 0]) metric_countersunk_bolt(5, 10);
  translate([23, 18, 5])
    scale([1, 1,-1])
    countersunk_clearance_hole(5, 8, [7, 7, 0], [0, 0, 0])
    cube([14, 14, 5]);

  translate([70, -10, 0]) {
    rod_start(20, 30);
  }
  translate([70, 20, 0]) {
    rod_end(20, 30);
  }

  translate([70, -45, 0]) {
    metric_wood_screw(8, 20);
  }

  translate([12, 50, 0])
    union() {
    translate([0, 0, 5.99])
      auger_thread(15, 3.5, 22, 7, tooth_angle=15, tip_height=7);
    translate([-4, -9, 0]) cube([8, 18, 6]);
  }
}

screw_thread(od=12, height=20, pitch=2);