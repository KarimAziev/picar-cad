/**
  * Module: Polygon helpers
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

function point_x(p) = p[0];
function point_y(p) = p[1];

function polygon_min_y(pts) = min([for (p = pts) point_y(p)]);
function polygon_max_y(pts) = max([for (p = pts) point_y(p)]);
function polygon_y_len(pts) = polygon_max_y(pts) - polygon_min_y(pts);

function polygon_min_x(pts) = min([for (p = pts) point_x(p)]);
function polygon_max_x(pts) = max([for (p = pts) point_x(p)]);
function polygon_x_len(pts) = polygon_max_x(pts) - polygon_min_x(pts);

function polygon_size(pts) = is_undef(pts) || len(pts) == 0
  ? [0, 0]
  : [polygon_x_len(pts), polygon_y_len(pts)];