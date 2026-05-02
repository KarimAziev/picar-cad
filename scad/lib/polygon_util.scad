/**
  * Module: Polygon helpers
  *
  * This file provides small helpers for extracting extents from 2D point lists.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

/**
  ─────────────────────────────────────────────────────────────────────────────
  point_x
  ─────────────────────────────────────────────────────────────────────────────

  Return the X coordinate of a 2D point.

  **Parameters:**
  - `p`: Point vector where `p[0]` is the X component.

  **Returns:**
  The first element of `p`.
 */
function point_x(p) = p[0];

/**
  ─────────────────────────────────────────────────────────────────────────────
  point_y
  ─────────────────────────────────────────────────────────────────────────────

  Return the Y coordinate of a 2D point.

  **Parameters:**
  - `p`: Point vector where `p[1]` is the Y component.

  **Returns:**
  The second element of `p`.
 */
function point_y(p) = p[1];

/**
  ─────────────────────────────────────────────────────────────────────────────
  polygon_min_y
  ─────────────────────────────────────────────────────────────────────────────

  Return the minimum Y value found in a polygon point list.

  **Parameters:**
  - `pts`: List of 2D points.

  **Returns:**
  The smallest Y coordinate in `pts`.
 */
function polygon_min_y(pts) = min([for (p = pts) point_y(p)]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  polygon_max_y
  ─────────────────────────────────────────────────────────────────────────────

  Return the maximum Y value found in a polygon point list.

  **Parameters:**
  - `pts`: List of 2D points.

  **Returns:**
  The largest Y coordinate in `pts`.
 */
function polygon_max_y(pts) = max([for (p = pts) point_y(p)]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  polygon_y_len
  ─────────────────────────────────────────────────────────────────────────────

  Return the height of a polygon's axis-aligned bounding box.

  **Parameters:**
  - `pts`: List of 2D points.

  **Returns:**
  `polygon_max_y(pts) - polygon_min_y(pts)`.
 */
function polygon_y_len(pts) = polygon_max_y(pts) - polygon_min_y(pts);

/**
  ─────────────────────────────────────────────────────────────────────────────
  polygon_min_x
  ─────────────────────────────────────────────────────────────────────────────

  Return the minimum X value found in a polygon point list.

  **Parameters:**
  - `pts`: List of 2D points.

  **Returns:**
  The smallest X coordinate in `pts`.
 */
function polygon_min_x(pts) = min([for (p = pts) point_x(p)]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  polygon_max_x
  ─────────────────────────────────────────────────────────────────────────────

  Return the maximum X value found in a polygon point list.

  **Parameters:**
  - `pts`: List of 2D points.

  **Returns:**
  The largest X coordinate in `pts`.
 */
function polygon_max_x(pts) = max([for (p = pts) point_x(p)]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  polygon_x_len
  ─────────────────────────────────────────────────────────────────────────────

  Return the width of a polygon's axis-aligned bounding box.

  **Parameters:**
  - `pts`: List of 2D points.

  **Returns:**
  `polygon_max_x(pts) - polygon_min_x(pts)`.
 */
function polygon_x_len(pts) = polygon_max_x(pts) - polygon_min_x(pts);

/**
  ─────────────────────────────────────────────────────────────────────────────
  polygon_size
  ─────────────────────────────────────────────────────────────────────────────

  Return the axis-aligned bounding-box size of a polygon point list.

  **Parameters:**
  - `pts`: List of 2D points. Empty or `undef` input returns `[0, 0]`.

  **Returns:**
  `[width, height]` derived from the polygon extents.
 */
function polygon_size(pts) = is_undef(pts) || len(pts) == 0
  ? [0, 0]
  : [polygon_x_len(pts), polygon_y_len(pts)];
