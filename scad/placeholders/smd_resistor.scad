include <../colors.scad>

use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/transforms.scad>

function with_default(val, default) = is_undef(val) ? default : val;

module smd_resistor(size=[3.2, 1.4, 0.4],
                    border_color="white",
                    body_h=0.1,
                    border_w,
                    border_p=0.2,
                    body_color=matte_black,
                    fillet_factor=0.2,
                    pad_color="lightyellow",
                    pad_factor_x=0.5,
                    pad_factor_y=0.9,
                    marking,
                    mark_color,
                    mark_size,
                    mark_font="Liberation Sans:style=Bold",
                    mark_spacing=0.8,
                    use_inner_round=false,
                    center=false) {
  has_border = !is_undef(border_w) && !is_undef(border_p);
  adjusted_size = !has_border
    ? size
    : [size[0] - border_w - border_p,
       size[1] - border_w - border_p,
       size[2]];

  body_size = [adjusted_size[0] * pad_factor_x,
               adjusted_size[1] * pad_factor_y,
               adjusted_size[2]];

  translate([center ? 0 : size[0] / 2, center ? 0 : size[1] / 2, 0]) {
    union() {

      let (bsize = [body_size[0] <= 0 ? adjusted_size[0] : body_size[0],
                    body_size[1] <= 0 ? adjusted_size[1] : body_size[1],
                    body_h]) {
        translate([-bsize[0] / 2, -bsize[1] / 2, body_h]) {
          color(body_color, alpha=1) {
            cube(size=body_size);
          }
          if (!is_undef(marking)) {
            text_size = is_undef(mark_size)
              ? min(bsize[0], bsize[1]) / len(marking)
              : mark_size;
            tm = textmetrics(text=marking,
                             spacing=mark_spacing,
                             font=mark_font,
                             size=text_size);

            translate([bsize[0] / 2 - tm.size[0] / 2,
                       bsize[1] / 2 - tm.size[1] / 2,
                       adjusted_size[2]]) {
              color(is_undef(mark_color) ? pad_color : mark_color, alpha=1) {
                linear_extrude(height=body_h + 0.01, center=false) {
                  text(text=marking,
                       spacing=mark_spacing,
                       font=mark_font,
                       size=text_size);
                }
              }
            }
          }
        }
      }
      color(pad_color, alpha=1) {
        if (use_inner_round) {
          rounded_cube(size=adjusted_size, r_factor=fillet_factor);
        } else {
          linear_extrude(height=adjusted_size[2],
                         center=false) {
            rounded_rect(size=[adjusted_size[0], adjusted_size[1]],
                         r_factor=fillet_factor,
                         center=true);
          }
        }
      }
      if (has_border) {
        color(border_color, alpha=1) {
          difference() {
            linear_extrude(height=0.01, center=false, convexity=2) {
              square(size=[size[0], size[1]], center=true);
            }

            translate([0, 0, -0.2]) {
              linear_extrude(height=2, center=false, convexity=2) {
                square(size=[size[0] - border_w, size[1] - border_w,],
                       center=true);
              }
            }
          }
        }
      }
    }
  }
}

module smd_resistors_row(size,
                         amount=0,
                         gap=0,
                         border_color="white",
                         pad_color="lightyellow",
                         body_color=matte_black,
                         body_h=0.1,
                         border_w=0.1,
                         border_p=0.2,
                         fillet_factor=0.2,
                         pad_factor_x=0.5,
                         pad_factor_y=0.9,
                         marking = "103",
                         mark_font="Liberation Sans:style=Bold",
                         mark_spacing=0.8,
                         prefix,
                         text_rotation,
                         text_translation,
                         text_font="Liberation Sans:style=Bold",
                         text_color="white",
                         text_spacing=1,
                         text_size=0.8,
                         text_h=0.2,
                         mark_color,
                         mark_size,
                         text_valign="bottom",
                         text_gap=1,
                         axle="y",
                         center=false,
                         use_inner_round=false,) {

  y_axle = axle == "y";
  val_idx = y_axle ? 1 : 0;
  step = gap + size[val_idx];
  total_w = step * amount;

  translate([!center
             ? 0
             : y_axle
             ? -size[0] / 2
             : -total_w / 2,
             !center
             ? 0
             : y_axle
             ? -total_w / 2
             : -size[1] / 2,
             0]) {
    if (amount > 0) {
      for (i = [0:amount - 1]) {
        let (v = i * step) {

          translate([y_axle ? 0 : v, y_axle ? v : 0, 0]) {
            smd_resistor(size=size,
                         center=false,
                         mark_color=mark_color,
                         pad_color=pad_color,
                         body_color=body_color,
                         border_color=border_color,
                         body_h=body_h,
                         border_w=border_w,
                         border_p=border_p,
                         fillet_factor=fillet_factor,
                         pad_factor_x=pad_factor_x,
                         pad_factor_y=pad_factor_y,
                         marking = marking,
                         mark_font=mark_font,
                         mark_size=mark_size,
                         mark_spacing=mark_spacing,
                         use_inner_round=use_inner_round);
            children();
            if (!is_undef(prefix)) {
              let (txt = str(prefix, i),
                   rotation = !is_undef(text_rotation)
                   ? text_rotation
                   : y_axle
                   ? [0, 0, 90]
                   : [0, 0, 0],
                   text_metrics = textmetrics(text=txt,
                                              size=text_size,
                                              font=text_font,
                                              spacing=text_spacing),
                   translation = !is_undef(text_translation)

                   ? text_translation
                   : y_axle
                   ? [(text_valign == "top"
                       ? -text_gap
                       : text_valign == "bottom"
                       ? size[0] + text_size + text_gap
                       : 0),
                      size[1] / 2 - text_metrics.size[0] / 2,
                      0]
                   : [size[0] / 2 - text_metrics.size[0] / 2,
                      (text_valign == "top"
                       ? (size[1] + text_gap)
                       : text_valign == "bottom"
                       ? -(text_size + text_gap)
                       : 0),
                      0]) {

                translate(translation) {
                  rotate(rotation) {
                    color(text_color, alpha=1) {
                      linear_extrude(height=text_h, center=false) {
                        text(text=txt,
                             size=text_size,
                             font=text_font,
                             spacing=text_spacing);
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

/**
   specs: [size_spec, pad_spec, body_spec, mark_spec, translation_spec, rotation_spec]

   size_spec: [x, y, z, fillet_factor, use_inner_round],
   pad_spec: [pad_color, pad_factor_x, pad_factor_y, border_w, border_p, border_color],
   body_spec: [body_color, body_height],
   mark_spec: [text, color, spacing, size?, font?],
   translation_spec: [x, y, z, center],
   rotation_spec: [x, y, z],

*/
module smd_resistors_from_specs(specs=[[[2.0, 3.3, 2.5, 0.1, false],
                                        ["lightyellow", 0.5, 0.9, 0.1, 0.2, "white"],
                                        [matte_black, 0.1],
                                        ["101"],
                                        [5.75, 3.2, 0],
                                        []],
                                       [[2.0, 3.3, 2.5, 0.01, false],
                                        [metallic_silver_1, 1.05, 0.6],
                                        [brown_2, 0.1],
                                        [],
                                        [-10.75, 2.3, 0],
                                        []]]) {
  for (spec = specs) {
    let (size = [spec[0][0], spec[0][1], spec[0][2]],
         fillet_factor=spec[0][3],
         use_inner_round=with_default(spec[0][4], false),
         pad_spec = with_default(spec[1], [0.5, 0.9, "lightyellow"]),
         body_spec = with_default(spec[2], []),
         mark_spec = with_default(spec[3], []),
         translation_spec = with_default(spec[4], []),
         rotation_spec = with_default(spec[5], []),
         pad_color = with_default(pad_spec[0], "lightyellow"),
         pad_factor_x = with_default(pad_spec[1], 0.5),
         pad_factor_y = with_default(pad_spec[2], 0.9),
         border_w = pad_spec[3],
         border_p=with_default(pad_spec[4], 0.2),
         border_color = with_default(pad_spec[5], "white"),
         body_color = with_default(body_spec[0], matte_black),
         body_h = with_default(body_spec[1], 0.1),

         marking=mark_spec[0],
         mark_color=mark_spec[1],
         mark_spacing=with_default(mark_spec[2], 0.8),
         mark_size=mark_spec[3],
         mark_font=with_default(mark_spec[4], "Liberation Sans:style=Bold"),
         translation_x= with_default(translation_spec[0], 0),
         translation_y= with_default(translation_spec[1], 0),
         translation_z= with_default(translation_spec[2], 0),
         center=with_default(translation_spec[3], false),
         rotation_x=with_default(rotation_spec[0], 0),
         rotation_y=with_default(rotation_spec[1], 0),
         rotation_z=with_default(rotation_spec[2], 0)) {

      translate([translation_x, translation_y, translation_z]) {
        if (rotation_x != 0 || rotation_y != 0 || rotation_z != 0) {
          rotate([rotation_x, rotation_y, rotation_z]) {
            smd_resistor(size=size,
                         border_color=border_color,
                         body_h=body_h,
                         border_w=border_w,
                         border_p=border_p,
                         body_color=body_color,
                         fillet_factor=fillet_factor,
                         pad_color=pad_color,
                         pad_factor_x=pad_factor_x,
                         pad_factor_y=pad_factor_y,
                         marking=marking,
                         mark_color=mark_color,
                         mark_size=mark_size,
                         mark_font=mark_font,
                         mark_spacing=mark_spacing,
                         center=center,
                         use_inner_round=use_inner_round);
          }
        } else {
          smd_resistor(size=size,
                       border_color=border_color,
                       body_h=body_h,
                       border_w=border_w,
                       border_p=border_p,
                       body_color=body_color,
                       fillet_factor=fillet_factor,
                       pad_color=pad_color,
                       pad_factor_x=pad_factor_x,
                       pad_factor_y=pad_factor_y,
                       marking=marking,
                       mark_color=mark_color,
                       mark_size=mark_size,
                       mark_font=mark_font,
                       mark_spacing=mark_spacing,
                       center=center,
                       use_inner_round=use_inner_round);
        }
      }
    }
  }
}

smd_resistors_from_specs(specs=[[[6.15, 6.15, 2.7, 0.01, false],
                                 [metallic_silver_1, 0.00, 1.0],
                                 [metallic_silver_1, 0.1],
                                 ["100", "white"],
                                 [-5.60, 1.5, 0],
                                 []]]);

// smd_resistor(size=[3.2, 1.4, 0.4],
//              border_color="white",
//              body_h=0.1,
//              border_w=0.1,
//              border_p=0.2,
//              body_color=matte_black,
//              fillet_factor=0.2,
//              pad_color="lightyellow",
//              pad_factor_x=0.5,
//              pad_factor_y=0.9,
//              marking = "103",
//              mark_font="Liberation Sans:style=Bold",
//              mark_spacing=0.8,
//              center=false);

// smd_resistors_row(amount=5,
//                   gap=0.2,
//                   size=[2.0, 1.0, 0.4],
//                   text_gap=0.2,
//                   border_w=0.1,
//                   border_p=0.3,
//                   text_spacing=0.9,
//                   text_size=0.4,
//                   prefix="A",
//                   axle="y",
//                   text_valign="bottom");

// smd_resistor();