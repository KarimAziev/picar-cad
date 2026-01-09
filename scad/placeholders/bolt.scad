/**
 * Module: Bolt placeholder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/text.scad>
use <../lib/transforms.scad>
use <nut.scad>

function default_pitch(d) =
  (d <= 2) ? 0.4 :
  (d <= 3) ? 0.65 :
  (d <= 4) ? 0.7 :
  (d <= 5) ? 0.8 :
  (d <= 6) ? 1.0 :
  (d <= 8) ? 1.25 :
  (d <= 10) ? 1.5 :
  (d <= 12) ? 1.75 : 2.0;

function snap_bolt_d(d) =
  d >= 2.5 && d < 3
  ? 2.5
  : floor(d);

function find_bolt_nut_spec(inner_d, specs=bolt_specs, default) =
  let (sorted_specs = sort_by_idx(specs, idx=0, asc=true),
       candidates = [for (i = [0 : len(sorted_specs) - 1])
           let (spec = sorted_specs[i],
                next_spec = with_default(sorted_specs[i + 1], []),
                dia = spec[0],
                next_dia = next_spec[0])
             if (inner_d == dia || (dia < inner_d
                                    && (is_undef(next_dia)
                                        || next_dia > inner_d)))
               spec],
       found = with_default(candidates[0], [], type="list"))
  with_default(drop(found, 1)[0], []);

function find_bolt_head_prop(prop, inner_d, head_type, specs=bolt_specs) =
  is_undef(head_type) || head_type == "none" ?
  0
  : let (bolt_spec = find_bolt_nut_spec(d, specs=specs, default=[]),
         head_spec = plist_get(head_type,
                               plist_get("head", bolt_spec, []),
                               []))
  plist_get(prop,
            plist_merge(["dia", d * 1.5,
                         "height", 0.7 * d],
                        head_spec));

function find_bolt_head_h(inner_d, head_type, specs=bolt_specs) =
  find_bolt_head_prop(prop="height",
                      inner_d=inner_d,
                      head_type=head_type,
                      specs=specs);

function find_bolt_head_d(inner_d, head_type, specs=bolt_specs) =
  find_bolt_head_prop(prop="dia",
                      inner_d=inner_d,
                      head_type=head_type,
                      specs=specs);

module bolt_info_text(d,
                      h,
                      prefix,
                      suffix,
                      plist) {

  txt = str(is_undef(prefix) ? "" : prefix,
            "M",
            snap_bolt_d(d),
            " x ",
            h,
            "mm",
            is_undef(suffix) ? "" : suffix);
  text_from_plist(txt=txt,
                  plist=plist,
                  default_size=d,
                  default_color=dark_gold_1);
}

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

      difference() {
        translate([0, 0,-0.001]) {
          cylinder(h = head_h + 0.002, r = head_d/2 + 0.01, $fn = 6* $fn);
        }
      }
    }

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

    top_r = head_d/2;
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
      translate([0, 0,-0.01]) cylinder(h = head_h + 0.02,
                                       r = shaft_r + 0.02,
                                       $fn = $fn);
    }
  }
}

module phillips_recess(arm_w = 0.8,
                       arm_len = 3.0,
                       corner_r = 0.3,
                       depth = 1.0,
                       $fn=24) {
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

module bolt_head_pan_phillips(head_d = 4.8,
                              head_h = 1.6,
                              shaft_r = 1.0,
                              ph_arm_w = 0.8,
                              ph_arm_len = 3.0,
                              ph_depth = 1.0,
                              dome_scale = 0.45,
                              $fn = 48) {
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

module helical_thread(major_d = 2.5,
                      pitch = 0.45,
                      h = 10,
                      depth = 0.27,
                      slices = 90) {
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

module bolt_m_pan_phillips(d = 2.5,
                           h = 10,
                           pitch = undef,
                           thread_len = undef,
                           head_d = 4.8,
                           head_h = 1.6,
                           ph_arm_w = 0.8,
                           ph_arm_len = 3.0,
                           ph_depth = 1.0,
                           thread_depth = undef,
                           threaded = true,
                           $fn = 64) {
  let (pitch_v = (pitch != undef) ? pitch : default_pitch(d),
       thread_len_v = (thread_len != undef) ? thread_len : h,
       thread_depth_v = (thread_depth != undef) ? thread_depth : pitch_v * 0.6,
       major_r = d / 2,
       minor_r = max(0.0001, major_r - thread_depth_v))
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
                             head_h = head_h,
                             shaft_r = minor_r,
                             ph_arm_w = ph_arm_w,
                             ph_arm_len = ph_arm_len,
                             ph_depth = ph_depth,
                             $fn = $fn);
  }
}

module bolt(d = 2.5,                 // major diameter (mm)
            h = 8,                   // shank h (mm) - head sits on top (z = h)
            thread_len = undef,      // h of threaded portion (undef -> h)
            pitch = undef,           // thread pitch (undef -> default metric)
            threaded = true,         // produce thread ridges
            thread_depth = undef,    // radial thread depth (undef -> 0.6*pitch)
            thread_segments = 120,   // quality of the linear_extrude twist
            thread_starts = 2,       // 1 = single-start, 2 = two-start (parallel helices)
            head_type = "pan",       // "pan" | "hex" | "round" | "countersunk" | "none"
            head_d,                  // head diameter
            head_h,                  // head height
            unthreaded = 0,          // h at top (next to head) that's unthreaded
            show_nut=false,
            nut_head_distance=1,
            lock_nut=false,
            bolt_color,
            nut_color,
            $fn = 64) {

  d = snap_bolt_d(d);

  nut_type = lock_nut ? "lock_nut" : "nut";
  bolt_spec = find_bolt_nut_spec(d, specs=bolt_specs, default=[]);

  nut_spec=plist_get(nut_type, bolt_spec, []);
  nut_color=with_default(nut_color, plist_get("color", nut_spec));
  nut_h = plist_get("height", nut_spec, 0);
  standard_nut_h = plist_get("height", plist_get("nut", bolt_spec, []), 0);
  bolt_color = with_default(bolt_color,
                            plist_get(head_type,
                                      plist_get("colors", bolt_spec, []),
                                      nut_color));

  let (pitch_v   = pitch != undef ? pitch : default_pitch(d),
       thread_len_v = thread_len != undef ? max(0, thread_len) : max(0, h - unthreaded),
       thread_depth_v = thread_depth != undef ? thread_depth : pitch_v * 0.6,
       minor_r = max(0, d/2 - (thread_depth != undef ? thread_depth : pitch_v * 0.6)))

    union() {
    color(bolt_color, alpha=1) {
      union() {
        if (threaded) {
          translate([0, 0, 0]) {
            cylinder(h = thread_len_v, r = minor_r, $fn = $fn);
          }

          if (thread_len_v < h) {
            translate([0, 0, thread_len_v]) {
              cylinder(h = h - thread_len_v,
                       r = minor_r,
                       $fn = $fn);
            }
          }

          for (s = [0:thread_starts-1]) {

            phase_deg = 360 * s / thread_starts;

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
          cylinder(h = h, r = minor_r, $fn = $fn);
        }

        if (head_type != "none") {

          let (head_spec = plist_get(head_type,
                                     plist_get("head", bolt_spec, []),
                                     []),
               head_d = with_default(head_d,
                                     plist_get("dia",
                                               head_spec,
                                               d * 1.5)),
               head_h = with_default(head_h,
                                     plist_get("height",
                                               head_spec,
                                               with_default(head_h, 0.7 * d)))) {

            translate([0, 0, h]) {
              bolt_head(type = head_type,
                        head_d = head_d,
                        head_h = head_h,
                        shaft_r = minor_r,
                        $fn=$fn);
            }
          };
        }
      }
    }
    if (show_nut) {
      effective_h = h - unthreaded - nut_h;

      translate([0,
                 0,
                 effective_h - min(effective_h + (lock_nut ? nut_h * 0.2 : 0),
                                   nut_head_distance)]) {
        if (nut_type == "nut") {
          nut(d=d,
              outer_d=plist_get("outer_dia", nut_spec),
              h=nut_h,
              nut_color=with_default(nut_color, bolt_color));
        } else if (nut_type == "lock_nut") {
          lock_nut(d=d,
                   h=nut_h,
                   flanged_h=nut_h - standard_nut_h,
                   outer_d=plist_get("outer_dia", nut_spec),
                   nut_color=with_default(nut_color, bolt_color));
        }
      }
    }
  }
}

h = 10;
head_h = 1.6;
head_d = 4.8;
d = 3.0;
nut_distance = 4;

rotate([0, 0, 0]) {
  bolt(d = d,
       h = h,
       threaded = true,
       unthreaded=0,
       show_nut=true,
       lock_nut=false,
       nut_head_distance=nut_distance,
       head_type = "pan",
       head_d = head_d);
}
