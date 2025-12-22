/**
 * Module: Misc chassis utils
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../parameters.scad>
use <../../lib/functions.scad>

function scale_trapezoid_pts(x_top,
                             x_bottom,
                             y_top,
                             y_bottom,
                             target_w,
                             target_l) =
  let (m        = (x_top - x_bottom) / (y_top - y_bottom),
       w_bottom = target_w + m *
       target_l) [[0,         0],
                  [target_w, 0],
                  [w_bottom,    target_l],
                  [0,         target_l]];

function scale_upper_trapezoid_pts(x, y) =
  scale_trapezoid_pts(x_top=chassis_upper_half_w,
                      x_bottom=chassis_transition_half_w,
                      y_top=chassis_upper_len,
                      y_bottom=0,
                      target_w=x,
                      target_l=y);

function _unit(a, eps=1e-9) = let (n=norm(a)) (n>eps ? a/n : [1, 0]);
function _perp(a) = [-a[1], a[0]];

function _centroid4(pts) = (pts[0] + pts[1] + pts[2] + pts[3])/4;

function _order_around_centroid(pts) =
  let (c = _centroid4(pts),
       ang = [atan2(pts[0][1]-c[1], pts[0][0]-c[0]),
              atan2(pts[1][1]-c[1], pts[1][0]-c[0]),
              atan2(pts[2][1]-c[1], pts[2][0]-c[0]),
              atan2(pts[3][1]-c[1], pts[3][0]-c[0])]) _argsort4(ang);

function _argsort4(a) =
  let (idx=[0, 1, 2, 3],
       s01 = (a[idx[0]] <= a[idx[1]]) ? idx : [idx[1], idx[0], idx[2], idx[3]],
       i1=s01,
       s23 = (a[i1[2]] <= a[i1[3]]) ? i1 : [i1[0], i1[1], i1[3], i1[2]],
       i2=s23,
       s02 = (a[i2[0]] <= a[i2[2]]) ? i2 : [i2[2], i2[1], i2[0], i2[3]],
       i3=s02,
       s13 = (a[i3[1]] <= a[i3[3]]) ? i3 : [i3[0], i3[3], i3[2], i3[1]],
       i4=s13,
       s12 = (a[i4[1]] <= a[i4[2]]) ? i4 : [i4[0], i4[2], i4[1], i4[3]]) s12;

function _slant_score(a, b) = let (d=b-a) min(abs(d[0]), abs(d[1]));
function _argmax4(v) =
  (v[0]>=v[1] && v[0]>=v[2] && v[0]>=v[3]) ? 0 :
  (v[1]>=v[2] && v[1]>=v[3]) ? 1 :
  (v[2]>=v[3]) ? 2 : 3;

function trapezoid_slanted_frame(trapezoid_pts, eps=1e-9) =
  let (pts = trapezoid_pts,
       c   = _centroid4(pts),
       ord = _order_around_centroid(pts),
       p0 = pts[ord[0]], p1 = pts[ord[1]], p2 = pts[ord[2]], p3 = pts[ord[3]],
       E  = [[p0, p1],[p1, p2],[p2, p3],[p3, p0]],
       s  = [_slant_score(p0, p1), _slant_score(p1, p2), _slant_score(p2, p3),
             _slant_score(p3, p0)],
       i  = _argmax4(s),
       A  = E[i][0],
       B  = E[i][1],
       u  = _unit(B-A, eps),
       n0 = _perp(u),
       n  = ((n0*(c - A)) >= 0) ? n0 : -n0) [A, B, u, n];

module hole_along_slanted_side(trapezoid_pts, s, l, w, margin=0, eps=1e-9,
                               parallelogram=true) {
  f = trapezoid_slanted_frame(trapezoid_pts, eps);
  A = f[0]; u = f[2]; n = f[3];

  o = A + u*s + n*margin;
  pts = [o,
         o + u*l,
         o + u*l + n*w,
         o + n*w];
  if (!parallelogram) {
    polygon(pts);
  } else {
    y_coords = map_idx(pts, 1);
    new_y_coords = [y_coords[3],
                    y_coords[2],
                    y_coords[2],
                    y_coords[3]];
    points = [for (n = [0: len(pts) - 1]) [pts[n][0], new_y_coords[n]]];

    polygon(points);
  }
}
