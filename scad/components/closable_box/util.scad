/**
 * Module: Common box utilities
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <../../lib/functions.scad>

function cumsums(a) = [for (i =
                              [0 : len(a) - 1]) sum([for (j = [0 : i]) a[j]])];
function spec_to_mm(spec, span) = spec > 1 ? spec : spec * span;

function max_corner_rad(size,
                        side_thickness=2,
                        front_thickness=2,
                        rim_h=0,
                        rim_w=0,
                        rim_front_w=0,
                        include_rim_sizing=false,
                        use_inner_round=false,
                        fudge = 0.4) =
  let (w0 = size[0],
       l0 = size[1],
       h0 = size[2],
       rim_enabled = (rim_h > 0) && (rim_w > 0 || rim_front_w > 0),
       rim_should_subtract = rim_enabled && include_rim_sizing,
       w = w0 - (rim_should_subtract ? rim_w * 2 : 0),
       l = l0 - (rim_should_subtract ? rim_front_w * 2 : 0),
       h = h0 - (rim_should_subtract ? rim_h : 0),
       h_eff = use_inner_round ? (h - fudge) : h,
       inner_x = w - side_thickness * 2,
       inner_y = l - front_thickness * 2,
       limits2d = [w / 2, l / 2, inner_x / 2, inner_y / 2],
       all_limits = use_inner_round ? concat(limits2d, [h_eff]) : limits2d,
       positive_limits = [for (t = all_limits) (t < 0 ? 0 : t)])
  min(positive_limits);
