/**
  * Module: Rear suspension datum and measurement cards A–H.
  *
  * Open in Top view with orthogonal projection. Select a card with `view`.
  * Arrows identify physical datums; silhouettes are CAD locating sketches,
  * not measured drawings. Purple crosses mark centers, including hidden ones.
  * This illustrated worksheet is not printable vehicle geometry.
  * Geometry uses `rear_lower_arm_spec` and `rear_hub_spec` from
  * `scad/suspension/rear_axle/arm_hub_params.scad`, hardware presets from
  * `scad/suspension/rear_axle/hardware_params.scad`, and `rear_housing_spec`
  * and `rear_tower_spec` from `scad/suspension/rear_axle/structure_params.scad`.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <arm_hub_params.scad>
include <hardware_params.scad>
include <structure_params.scad>

use <../../lib/plist.scad>
use <../../lib/shapes2d.scad>
use <../rear_chassis/computed_params.scad>
use <rear_bulkhead.scad>
use <rear_hub.scad>
use <rear_lower_arm.scad>

// Card selector and page settings are independent of hardware dimensions.
view              = "all"; // [all, housing, hub_front, hub_side, stud, gear, hub_link, key]
card_size         = [110, 100];
card_gap          = 4;
card_margin       = 5;
heading_y         = 92;
subtitle_y        = 85;
notes_y           = 16;
notes_pitch       = 4;
heading_size      = 3;
label_size        = 2.1;
dimension_size    = 4;
font              = "Liberation Sans";
line_w            = 0.3;
center_r          = 1.7;
arrow_l           = 1.8;
arrow_half_w      = 0.65;
label_gap         = 3;
extension_overrun = 1;
layer_h           = 0.15;
outline_fn        = 80;
hidden_segments   = 24;
hidden_duty       = 0.55;
body_color        = "#a7c6d8";
ink_color         = "#192f45";
dimension_color   = "#b90075";
face_color        = "#d26000";
page_color        = "white";
body_origins      = [[55, 32], [36, 30], [44, 30], [17, 42], [55, 50]];
housing_dim_x     = 37;
hub_dim_gap       = 10;
stud_dim_gap      = 12;
side_dim_gap      = 12;
gear_dim_gap      = 8;
link_card_origin  = [47, 22];
link_dim_gap      = 9;
direction_y       = 50;
direction_ranges  = [[37, 8], [73, 102]];
direction_labels  = [[22.5, 55], [87.5, 55]];

// Projection frames: page horizontal / page vertical / viewing depth.
front_frame       = [[1, 0, 0, 0], [0, 0, 1, 0],
                     [0, -1, 0, 0], [0, 0, 0, 1]];
hub_front_frame   = [[0, 1, 0, 0], [0, 0, 1, 0],
                     [1, 0, 0, 0], [0, 0, 0, 1]];

module _ink(c=ink_color, layer=2) {
  color(c) {
    translate([0, 0, layer * layer_h]) {
      linear_extrude(height=layer_h) {
        children();
      }
    }
  }
}

module _line(a, b, w=line_w) {
  hull() {
    translate(a) {
      circle(d=w, $fn=outline_fn);
    }
    translate(b) {
      circle(d=w, $fn=outline_fn);
    }
  }
}

module _label(p, value, size=label_size, align="left") {
  translate(p) {
    text(value, size=size, font=font, halign=align, valign="center");
  }
}

module _center(p) {
  _ink(dimension_color, layer=3) {
    _line(p - [center_r, 0], p + [center_r, 0]);
    _line(p - [0, center_r], p + [0, center_r]);
  }
}

module _ring(p, r, hidden=false) {
  _ink(dimension_color, layer=3) {
    if (hidden) {
      for (i = [0 : hidden_segments - 1]) {
        a = i * 360 / hidden_segments;
        b = (i + hidden_duty) * 360 / hidden_segments;
        _line(p + r * [cos(a), sin(a)], p + r * [cos(b), sin(b)]);
      }
    } else {
      translate(p) {
        difference() {
          circle(r=r + line_w / 2, $fn=outline_fn);
          circle(r=r - line_w / 2, $fn=outline_fn);
        }
      }
    }
  }
  _center(p);
}

// Dimension endpoints remain on component datums; offset only moves the arrow.
module _dimension(a, b, offset, letter, label_side=1) {
  delta = b - a;
  u = delta / norm(delta);
  n = [-u[1], u[0]];
  aa = a + offset;
  bb = b + offset;
  overrun = norm(offset) > 0
            ? offset / norm(offset) * extension_overrun
            : [0, 0];
  _ink(dimension_color, layer=4) {
    _line(a, aa + overrun);
    _line(b, bb + overrun);
    _line(aa, bb);
    for (end = [0, 1]) {
      p = end == 0 ? aa : bb;
      direction = end == 0 ? u : -u;
      polygon([p, p + direction * arrow_l + n * arrow_half_w,
               p + direction * arrow_l - n * arrow_half_w]);
    }
    _label((aa + bb) / 2 + n * label_gap * label_side,
           letter,
           dimension_size,
           "center");
  }
}

module _card(title, subtitle, notes) {
  _ink(page_color, layer=0) {
    square(card_size);
  }
  _ink() {
    _label([card_margin, heading_y], title, heading_size);
    _label([card_margin, subtitle_y], subtitle);
    for (i = [0 : len(notes) - 1]) {
      _label([card_margin, notes_y - i * notes_pitch], notes[i]);
    }
  }
  children();
}

module _housing_card() {
  hinge = rear_bulkhead_hinge_axis(rear_housing_spec, rear_lower_arm_spec);
  pinion = rear_bulkhead_pinion_origin(rear_housing_spec,
                                       rear_differential_spec,
                                       rear_pinion_spec);
  mounts = rear_bulkhead_mount_positions(rear_chassis_layout(),
                                         rear_bulkhead_bolt_spacing_x,
                                         rear_bulkhead_bolt_spacing_2[1]);
  _card("A / B   HOUSING REFERENCES",
        "Reference datums; no additional measurement needed",
        ["A: hinge height follows the shared front housing.",
         "B: input-shaft height follows the fixed motor datum.",
         "Orange line = underside mounting face."]) {
    translate(body_origins[0]) {
      _ink(body_color, layer=1) {
        projection(cut=false) {
          multmatrix(front_frame) {
            for (part = ["lower", "lid"]) {
              rear_bulkhead(rear_housing_spec,
                            rear_differential_spec,
                            rear_pinion_spec,
                            rear_lower_arm_spec,
                            rear_tower_spec,
                            mounts,
                            part=part,
                            anchor=[0, 0, 1],
                            slot_mode=false,
                            show_hardware=false);
            }
          }
        }
      }
      _ink(face_color) {
        _line([-housing_dim_x, 0], [housing_dim_x, 0]);
      }
      for (side = [-1, 1]) {
        _ring([side * hinge[0], hinge[2]],
              plist_get("hinge_pin_d", rear_housing_spec) / 2);
      }
      _ring([pinion[0], pinion[2]],
            plist_get("shaft_d", rear_pinion_spec) / 2);
      _dimension([-hinge[0], 0],
                 [-hinge[0], hinge[2]],
                 [-housing_dim_x + hinge[0], 0],
                 "A");
      _dimension([pinion[0], 0],
                 [pinion[0], pinion[2]],
                 [housing_dim_x - pinion[0], 0],
                 "B",
                 label_side=-1);
    }
  }
}

module _hub_front_card() {
  pivot = rear_hub_pivot(rear_hub_spec);
  axle = rear_hub_axle(rear_hub_spec);
  link = rear_hub_link(rear_hub_spec);
  balls = rear_hub_ball_positions(rear_hub_spec);
  size = rear_hub_size(rear_hub_spec);
  _card("C / D   HUB: MEASURED",
        "Look along the wheel axle; wheel removed",
        ["C = 10 mm: lower ball-center line to axle center.",
         "D = 28–29 mm: axle to upper link-hole center.",
         "Both values are VERTICAL distances."]) {
    translate(body_origins[1]) {
      _ink(body_color, layer=1) {
        projection(cut=false) {
          multmatrix(hub_front_frame) {
            rear_hub(rear_hub_spec,
                     anchor=[1, 1, 1],
                     slot_mode=false,
                     show_bearings=false,
                     show_socket_hardware=false);
          }
        }
      }
      for (p = balls) {
        _ring([p[1], p[2]],
              plist_get("ball_d", rear_hub_spec) / 2,
              hidden=true);
      }
      _ring([axle[1], axle[2]],
            plist_get("outer_bearing_id", rear_hub_spec) / 2);
      _center([link[1], link[2]]);
      _ink(dimension_color) {
        _line([balls[0][1], pivot[2]], [balls[1][1], pivot[2]]);
      }
      _dimension([pivot[1], pivot[2]],
                 [axle[1], axle[2]],
                 [-pivot[1] - hub_dim_gap, 0],
                 "C");
      _dimension([axle[1], axle[2]],
                 [link[1], link[2]],
                 [size[1] - axle[1] + hub_dim_gap, 0],
                 "D",
                 label_side=-1);
    }
  }
}

module _hub_side_card() {
  pivot = rear_hub_pivot(rear_hub_spec);
  axle = rear_hub_axle(rear_hub_spec);
  seat = rear_hub_bearing_positions(rear_hub_spec)[0];
  bearing_r = plist_get("inner_bearing_od", rear_hub_spec) / 2;
  _card("E   HUB: SIDE VIEW",
        "Differential is LEFT; wheel is RIGHT",
        ["E: orange opening face to lower ball center.",
         "Measure parallel to the axle. Dashed = hidden.",
         "Use bearing opening, not its internal shoulder."]) {
    translate(body_origins[2]) {
      _ink(body_color, layer=1) {
        projection(cut=false) {
          multmatrix(front_frame) {
            rear_hub(rear_hub_spec,
                     anchor=[1, 1, 1],
                     slot_mode=false,
                     show_bearings=false,
                     show_socket_hardware=false);
          }
        }
      }
      _ink(face_color, layer=3) {
        _line([seat[0], axle[2] - bearing_r],
              [seat[0], axle[2] + bearing_r],
              w=2 * line_w);
      }
      _ring([pivot[0], pivot[2]],
            plist_get("ball_d", rear_hub_spec) / 2,
            hidden=true);
      _ink(dimension_color) {
        _line([seat[0], axle[2] - bearing_r], [seat[0], pivot[2]]);
      }
      _dimension([seat[0], pivot[2]],
                 [pivot[0], pivot[2]],
                 [0, -side_dim_gap],
                 "E",
                 label_side=-1);
    }
  }
}

module _stud_card() {
  size = rear_lower_arm_size(rear_lower_arm_spec);
  ball = rear_lower_arm_outer_pivot(rear_lower_arm_spec);
  _card("F   ARM + INSTALLED BALL STUD",
        "Side view; leave the stud screwed into the arm",
        ["F: arm end face to center of the installed ball.",
         "Calipers: face to far edge of ball, then subtract",
         "half the ball diameter. Measure along the stud."]) {
    translate(body_origins[3]) {
      _ink(body_color, layer=1) {
        projection(cut=false) {
          multmatrix(front_frame) {
            rear_lower_arm(rear_lower_arm_spec,
                           anchor=[1, 1, 1],
                           slot_mode=false,
                           show_pins=false,
                           show_ball_studs=true);
          }
        }
      }
      _ink(face_color, layer=3) {
        _line([size[0], 0], [size[0], size[2]], w=2 * line_w);
      }
      _ring([ball[0], ball[2]],
            plist_get("ball_d", rear_lower_arm_spec) / 2);
      _dimension([size[0], ball[2]],
                 [ball[0], ball[2]],
                 [0, stud_dim_gap],
                 "F");
      _ink() {
        _label([0, -label_gap * 2], "ARM");
      }
    }
  }
}

module _gear_card() {
  r = plist_get("gear_d", rear_differential_spec) / 2;
  case_size = plist_get("case_size", rear_differential_spec);
  case_radius_factor = plist_get("case_radius_factor", rear_differential_spec);
  _card("G   CROWN GEAR: MEASURED",
        "Look along the differential output axle",
        [str("G = ", 2 * r, " mm outside diameter; thickness = ",
             plist_get("gear_h", rear_differential_spec), " mm."),
         "The rounded case sits inside the crown outline.",
         "The circle shows the tooth-tip envelope."]) {
    translate(body_origins[4]) {
      _ink(body_color, layer=1) {
        circle(r=r, $fn=outline_fn);
      }
      _ring([0, 0], r);
      _ink() {
        difference() {
          offset(delta=line_w / 2) {
            rounded_rect([case_size[0], case_size[1]],
                         center=true,
                         r_factor=case_radius_factor,
                         fn=outline_fn);
          }
          offset(delta=-line_w / 2) {
            rounded_rect([case_size[0], case_size[1]],
                         center=true,
                         r_factor=case_radius_factor,
                         fn=outline_fn);
          }
        }
        _label([0, 0], "case", align="center");
      }
      _dimension([-r, 0], [r, 0], [0, r + gear_dim_gap], "G");
    }
  }
}

module _hub_link_card() {
  axle = rear_hub_axle(rear_hub_spec);
  link = rear_hub_link(rear_hub_spec);
  seat = rear_hub_bearing_positions(rear_hub_spec)[0];
  bearing_r = plist_get("inner_bearing_od", rear_hub_spec) / 2;
  _card("H   UPPER LINK: AXIAL OFFSET",
        "Side view; use the large bearing opening as the reference",
        ["H = hole-center X minus orange-face X.", "Positive toward wheel; negative toward differential.",
         "Measure PARALLEL to axle, not along the sloping arm.", "Use the opening face, not the internal shoulder."]) {
    translate(link_card_origin) {
      _ink(body_color, layer=1) {
        projection(cut=false) {
          multmatrix(front_frame) {
            rear_hub(rear_hub_spec,
                     anchor=[1, 1, 1],
                     slot_mode=false,
                     show_bearings=false,
                     show_socket_hardware=false);
          }
        }
      }
      _ink(face_color, layer=3) {
        _line([seat[0], axle[2] - bearing_r],
              [seat[0], axle[2] + bearing_r],
              w=2 * line_w);
        _line([seat[0], axle[2] + bearing_r],
              [seat[0], link[2] + link_dim_gap + extension_overrun]);
      }
      _ring([link[0], link[2]],
            plist_get("link_bolt_d", rear_hub_spec) / 2);
      _dimension([seat[0], link[2]],
                 [link[0], link[2]],
                 [0, link_dim_gap],
                 "H");
    }
    _ink() {
      for (i = [0, 1]) {
        a = [direction_ranges[i][0], direction_y];
        b = [direction_ranges[i][1], direction_y];
        direction = (b - a) / norm(b - a);
        _line(a, b);
        polygon([b, b - direction * arrow_l + [0, arrow_half_w],
                 b - direction * arrow_l - [0, arrow_half_w]]);
        _label(direction_labels[i],
               i == 0 ? "TO DIFFERENTIAL (−)" : "TO WHEEL (+)",
               align="center");
      }
      _label([72, 69], "UPPER LINK");
      _label([72, 65], "HOLE CENTER");
      _line([70, 67], link_card_origin + [link[0] + center_r, link[2]]);
      _label([9, 34], "LARGE BEARING");
      _label([9, 30], "OPENING FACE");
      _line([37, 32], link_card_origin + [seat[0], axle[2]]);
    }
  }
}

module _legend_card() {
  _card("MEASUREMENT KEY",
        "E / F / H are axial checks, in millimeters",
        ["A / B are assembly references; C / D / G are measured.",
         "Sketches identify datums; do not scale images.",
         "Each card can be selected with the view setting."]) {
    _ink() {
      _label([card_margin, 70], "Cross = hole, shaft or ball CENTER.");
      _label([card_margin, 62], "Dashed circle = ball hidden inside socket.");
      _label([card_margin, 54], "Orange = physical reference FACE.");
      _label([card_margin, 42], "A / B: shared housing and fixed motor datums");
      _label([card_margin, 36],
             "C / D: measured hub center heights; G: crown OD");
      _label([card_margin, 30],
             "E / F / H: axial positions, parallel to wheel axle");
    }
  }
}

card_names = ["housing", "hub_front",
              "hub_side", "stud",
              "gear", "hub_link", "key"];
assert(view == "all" || len([for (name = card_names) if (name == view) name]) == 1,
       "Unknown measurement card");
for (i = [0 : len(card_names) - 1]) {
  if (view == "all" || view == card_names[i]) {
    position = view == "all"
               ? [i % 3 * (card_size[0] + card_gap),
                  (ceil(len(card_names) / 3) - 1 - floor(i / 3))
                  * (card_size[1] + card_gap)]
               : [0, 0];
    translate(position) {
      if (i == 0) {
        _housing_card();
      }
      if (i == 1) {
        _hub_front_card();
      }
      if (i == 2) {
        _hub_side_card();
      }
      if (i == 3) {
        _stud_card();
      }
      if (i == 4) {
        _gear_card();
      }
      if (i == 5) {
        _hub_link_card();
      }
      if (i == 6) {
        _legend_card();
      }
    }
  }
}
