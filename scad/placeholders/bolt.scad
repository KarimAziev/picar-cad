/**
 * Module: Bolt placeholder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <../lib/shapes2d.scad>
use <../lib/functions.scad>
use <../lib/shapes3d.scad>
use <../lib/transforms.scad>

// m2 - 3.5

function default_pitch(d) =
  (d <= 2) ? 0.4 :
  (d <= 3) ? 0.65 :
  (d <= 4) ? 0.7 :
  (d <= 5) ? 0.8 :
  (d <= 6) ? 1.0 :
  (d <= 8) ? 1.25 :
  (d <= 10) ? 1.5 :
  (d <= 12) ? 1.75 : 2.0;

// create a triangular helical ridge via linear_extrude(..., twist=...)
// major: outer thread diameter; depth: radial height of triangular profile
// start_phase: rotate the profile around Z before twisting (degrees)
module thread_ridge(major = 6,
                    pitch = 1,
                    h = 20,
                    depth = 0.6,
                    segments = 120,
                    start_phase = 0) {
  turns = h / pitch;
  outer_r = major / 2;
  minor_r_est = outer_r - depth;
  profile_r = minor_r_est + depth/2;

  base_half = pitch * 0.45;

  pts = [[profile_r, 0],
         [profile_r - depth,  base_half],
         [profile_r - depth, -base_half]];

  rotate([0, 0, start_phase]) {
    linear_extrude(height = h,
                   twist = 360 * turns,
                   slices = segments,
                   convexity = 10) {
      polygon(points = pts);
    }
  }
}

// Head generator - head base is at z=0 (so translate([0,0,h]) above places it flush)
module bolt_head(type = "hex", head_d = 9, head_h = 4, shaft_r = 2.5, $fn = 64) {
  if (type == "hex") {
    R = head_d / sqrt(3); // circumradius for given flat-to-flat distance
    points = [for (i=[0:5]) [R*cos(60*i), R*sin(60*i)]];
    union() {
      linear_extrude(height = head_h) {
        polygon(points);
      }
      // cut a small counterbore to accept shaft / ensure flush
      difference() {
        // make a small recess on underside to visually seat on shank (optional)
        translate([0, 0,-0.001]) {
          cylinder(h = head_h + 0.002, r = head_d/2 + 0.01, $fn = 6* $fn); // hull-like shape
        }
      }
    }
    // ensure there's a clearance hole for the shaft so the head is flush: subtract shaft hole
    difference() {
      linear_extrude(height = head_h) {
        polygon(points);
      }
      translate([0, 0,-0.01]) {
        cylinder(h = head_h + 0.02, r = shaft_r + 0.02, $fn = $fn);
      }
    }
  } else if (type == "round") {
    difference() {
      cylinder(h = head_h, r = head_d/2, $fn = $fn);
      translate([0, 0,-0.01]) {
        cylinder(h = head_h + 0.02, r = shaft_r + 0.02, $fn = $fn);
      }
    }
  } else if (type == "countersunk") {
    // countersunk head: truncated cone with central hole for shaft
    // Base (where it meets shaft) will be at z=0 so it sits flush
    top_r = head_d/2;         // small top
    base_r = max(shaft_r, head_d*0.9); // base radius at the plane z=0 (slightly > shaft)
    difference() {
      translate([0, 0, 0]) {
        cylinder(h = head_h, r1 = top_r, r2 = base_r, $fn = $fn);
      }

      translate([0, 0,-0.01]) {
        cylinder(h = head_h + 0.02, r = shaft_r + 0.02, $fn = $fn);
      }
    }
  } else if (type == "pan") {
    bolt_head_pan_phillips(head_d=head_d,
                           head_h=head_h,
                           shaft_r=shaft_r,
                           $fn=$fn);
  }
  else {
    // fallback: simple hex
    R = head_d / sqrt(3);
    pts = [for (i=[0:5]) [R*cos(60*i), R*sin(60*i)]];
    difference() {
      linear_extrude(height = head_h) polygon(pts);
      translate([0, 0,-0.01]) cylinder(h = head_h + 0.02, r = shaft_r + 0.02, $fn = $fn);
    }
  }
}

module phillips_recess(arm_w = 0.8, arm_len = 3.0, corner_r = 0.3, depth = 1.0, $fn=24) {
  union() {

    linear_extrude(height = depth) {
      rounded_rect(size=[arm_w, arm_len],
                   r=corner_r,
                   fn=$fn,
                   center=true);
    }
    rotate([0, 0, 90]) {
      linear_extrude(height = depth) {
        rounded_rect(size=[arm_w, arm_len],
                     r=corner_r,
                     fn=$fn,
                     center=true);
      }
    }
  }
}

module bolt_head_pan_phillips(head_d = 4.8, head_h = 1.6, shaft_r = 1.0,
                              ph_arm_w = 0.8, ph_arm_len = 3.0, ph_depth = 1.0,
                              dome_scale = 0.45, $fn = 48) {
  rad = head_d / 2;
  dome_scaled_h = dome_scale * rad;
  difference() {

    union() {
      cylinder(h = head_h - dome_scaled_h, r = rad, $fn = $fn);
      difference() {
        translate([0, 0, head_h - dome_scaled_h]) {
          difference() {
            scale([1, 1, dome_scale]) {
              sphere(r = rad, $fn = $fn);
            }
            translate([0, 0, -dome_scaled_h]) {
              cylinder(h=dome_scaled_h, d=head_d);
            }
          }
        }
      }
    }

    translate([0, 0,-0.01]) {
      cylinder(h = head_h + 0.02, r = shaft_r + 0.02, $fn = $fn);
    }

    translate([0, 0, head_h - ph_depth + 0.1]) {
      phillips_recess(arm_w = ph_arm_w,
                      arm_len = ph_arm_len,
                      corner_r = ph_arm_w * 0.35,
                      depth = ph_depth,
                      $fn = $fn);
    }
  }
}

module helical_thread(major_d = 2.5, pitch = 0.45, h = 10, depth = 0.27, slices = 90) {
  turns = h / pitch;
  outer_r = major_d / 2;
  minor_r = outer_r - depth;

  base_half = pitch * 0.45;
  profile_r = minor_r + depth/2;

  pts = [[profile_r, 0],
         [profile_r - depth,  base_half],
         [profile_r - depth, -base_half]];

  linear_extrude(height = h,
                 twist = 360 * turns,
                 slices = slices,
                 convexity = 10) {
    polygon(points = pts);
  }
}

module bolt_m_pan_phillips(d = 2.5, h = 10,
                           pitch = undef, thread_len = undef,
                           head_d = 4.8, head_h = 1.6,
                           ph_arm_w = 0.8, ph_arm_len = 3.0, ph_depth = 1.0,
                           thread_depth = undef, threaded = true,
                           $fn = 64) {
  let (pitch_v = (pitch != undef) ? pitch : default_pitch(d),
       thread_len_v = (thread_len != undef) ? thread_len : h,
       thread_depth_v = (thread_depth != undef) ? thread_depth : pitch_v * 0.6,
       major_r = d / 2,
       minor_r = max(0.0001, major_r - thread_depth_v) // радиус сердечника
      )
    union() {
    if (threaded) {
      cylinder(h = thread_len_v, r = minor_r, $fn = $fn);
      if (thread_len_v < h)
        translate([0, 0, thread_len_v]) {
          cylinder(h = h - thread_len_v, r = minor_r, $fn = $fn);
        }
      translate([0, 0,-0.02]) {
        helical_thread(major_d = d,
                       pitch = pitch_v,
                       h = thread_len_v + 0.04,
                       depth = thread_depth_v,
                       slices = 120);
      }
    } else {
      cylinder(h = h, r = minor_r, $fn = $fn);
    }

    translate([0, 0, h])
      bolt_head_pan_phillips(head_d = head_d,
                             head_h = head_h, shaft_r = minor_r,
                             ph_arm_w = ph_arm_w,
                             ph_arm_len = ph_arm_len,
                             ph_depth = ph_depth, $fn = $fn);
  }
}

// Primary bolt module
// d: nominal (major) thread diameter
// h: axial h of the bolt shank (threaded + optionally unthreaded portion)
// thread_len: h of threaded portion (<= h)
// pitch: thread pitch (if undef, default_pitch(d))
// head_type: "pan" | "hex" | "round" | "countersunk" | "none"
// head_d: head across-flats (for hex) or diameter for cap
// head_h: head thickness
// Parametric bolt module - corrected
// - no reassignments (uses let/local)
// - heads sit flush with shaft (all types)
// - proper helical thread ridge joined to core
// - optional multi-start thread (1 or 2 starts)

module bolt(d = 2.5,                   // major diameter (mm)
            h = 8,               // shank h (mm) - head sits on top (z = h)
            thread_len = undef,      // h of threaded portion (undef -> h)
            pitch = undef,           // thread pitch (undef -> default metric)
            threaded = true,         // produce thread ridges
            thread_depth = undef,    // radial thread depth (undef -> 0.6*pitch)
            thread_segments = 120,   // quality of the linear_extrude twist
            thread_starts = 2,       // 1 = single-start, 2 = two-start (parallel helices)
            head_type = "pan",       // "pan" | "hex" | "round" | "countersunk" | "none"
            head_d,        // across-flats for hex or diameter for round/countersunk
            head_h,        // head height
            unthreaded = 0,          // h at top (next to head) that's unthreaded
            $fn = 64) {

  let (pitch_v   = pitch != undef ? pitch : default_pitch(d),
       thread_len_v = thread_len != undef ? max(0, thread_len) : max(0, h - unthreaded),
       thread_depth_v = thread_depth != undef ? thread_depth : pitch_v * 0.6,
       minor_r = max(0, d/2 - (thread_depth != undef ? thread_depth : pitch_v * 0.6)),
       head_d = is_undef(head_d) ? d * 1.5 : head_d)
    union() {
    // Shank core (minor diameter) for the threaded region
    if (threaded) {
      translate([0, 0, 0]) {
        cylinder(h = thread_len_v, r = minor_r, $fn = $fn);
      }

      if (thread_len_v < h) {
        translate([0, 0, thread_len_v]) {
          cylinder(h = h - thread_len_v,
                   r = minor_r, $fn = $fn);
        }
      }

      for (s = [0:thread_starts-1]) {
        // offset phase for multi-start
        phase_deg = 360 * s / thread_starts;
        // slightly overlap downwards and upwards to ensure clean boolean union
        translate([0, 0,-0.02]) {
          thread_ridge(major = d,
                       pitch = pitch_v,
                       h = thread_len_v + 0.04,
                       depth = thread_depth_v,
                       segments = thread_segments,
                       start_phase = phase_deg);
        }
      }
    } else {
      // entire smooth shank (no threads)
      cylinder(h = h, r = minor_r, $fn = $fn);
    }

    // Head: place with its base at z = h so it is flush on the shank top
    if (head_type != "none") {
      translate([0, 0, h]) {
        bolt_head(type = head_type,
                  head_d = head_d,
                  head_h = with_default(head_h, 0.7 * d),
                  shaft_r = minor_r,
                  $fn=$fn);
      };
    }
  }
}

// Single-start M6 bolt
// bolt(d=6, h=30, thread_len=30, pitch=1.0, head_type="hex", head_d=10, head_h=4);

// Two-start thread (will show two intertwined helical ridges)
// bolt(d=6, h=30, thread_len=30, pitch=1.0, thread_starts=2, head_type="round", head_d=10, head_h=4);

// Countersunk M4 bolt
// bolt(d=4, h=20, thread_len=16, head_type="countersunk", head_d=8, head_h=3);

// bolt(d = 2.5, h = 10, thread_len = 10, pitch = 0.45, threaded = true,
//      head_type = "pan", head_d = 4.8, head_h = 1.6);

// ----- Пример: M2.5 пан-головка с крестовым пазом -----
// bolt_m_pan_phillips(d = 2.5,
//                     h = 10,
//                     pitch = 0.45,        // стандартный шаг для M2.5 ~0.45 мм
//                     thread_len = 10,
//                     head_d = 4.8,        // типичный диаметр пан-головки для M2.5
//                     head_h = 1.6,        // типичная высота
//                     ph_arm_w = 0.8,      // ширина "плеча" креста (регулируйте под биту)
//                     ph_arm_len = 3.0,    // длина плеча (регулирует внешний диаметр паза)
//                     ph_depth = 1.0       // глубина паза (регулируйте)
//                    );

h = 10;
head_h = 1.6;
head_d = 4.8;
d = 2.5;

rotate([0, 0, 0]) {
  bolt(d = d,
       h = h,
       threaded = true,
       head_type = "round",
       head_d = head_d,
       head_h = head_h);
}
