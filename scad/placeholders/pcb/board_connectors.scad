/**
  * Module: Board connector placeholders.
  *
  * Anchored Ethernet, board-edge port and shrouded connector bodies.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>

use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  ethernet_socket
  ─────────────────────────────────────────────────────────────────────────────
  Create an Ethernet socket with its opening facing positive Y.

  **Parameters:**
  - `size`: Nominal shell `[width, length, height]`.
  - `anchor`: Placement against the shell reference box; defaults to `[1, 1, 1]`.

  **Examples:**
  ```scad
  ethernet_socket([16.15, 21.34, 13.4], anchor=[0, -1, 1]);
  ```
 */
module ethernet_socket(size, anchor=[1, 1, 1]) {
  hole_size = [size[0] * 0.9, size[1] * 0.2, size[2] * 0.8];
  x_offset = size[0] * 0.05;
  y_offset = size[1] * 0.8 + 1;

  with_anchor(size=size, anchor=anchor) {
    difference() {
      color(metallic_yellow_silver) {
        linear_extrude(height=size[2]) {
          rounded_rect(size=size, r=min(size[1], size[2]) * 0.1);
        }
      }
      translate([x_offset, y_offset, size[2] - hole_size[2] - 0.5]) {
        linear_extrude(height=hole_size[2]) {
          rounded_rect(size=hole_size, r=0.5);
        }
      }
    }
    color(matte_black) {
      translate([x_offset, y_offset, size[2] - hole_size[2] - 1]) {
        cuboid([hole_size[0], 1, hole_size[2]], anchor=[1, 1, 1]);
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  board_edge_socket
  ─────────────────────────────────────────────────────────────────────────────
  Create a simplified metal board-edge port with a plastic insert.

  **Parameters:**
  - `size`: Nominal shell `[width, length, height]`, also used to size the insert.
  - `anchor`: Placement against the shell reference box; defaults to `[1, 1, 1]`.

  The opening faces positive X. Positive anchoring places the shell footprint
  from `[0, 0]` to `[size[0], size[1]]`, with its bottom at Z=0.
  The shell and insert both follow `size`, including for micro-HDMI dimensions.

  **Examples:**
  ```scad
  board_edge_socket([8.2, 6.5, 3], anchor=[-1, 0, 1]);
  ```
 */
module board_edge_socket(size, anchor=[1, 1, 1]) {
  with_anchor(size=size, anchor=anchor) {
    translate([size[0] / 2, size[1] / 2, 0]) {
      color("silver") {
        difference() {
          linear_extrude(height=size[2]) {
            rounded_rect([size[0], size[1]], center=true,
                         r=min(size[0], size[1]) * 0.1);
          }
          translate([size[0] * 0.1 + 1, 0, size[2] * 0.1]) {
            cuboid([size[0] * 0.8, size[1] * 0.9, size[2] * 0.8]);
          }
        }
      }
      color(matte_black) {
        translate([size[0] * 0.05, 0, size[2] * 0.1]) {
          cuboid([size[0] * 0.8, size[1] * 0.9, size[2] * 0.8]);
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  shrouded_connector
  ─────────────────────────────────────────────────────────────────────────────
  Create a small board connector body, optionally with a top recess.

  **Parameters:**
  - `size`: Body `[width, length, height]`.
  - `detailed`: Include the top recess when true; defaults to false.
  - `anchor`: Placement against the body reference box; defaults to `[1, 1, 1]`.

  The caller supplies the body color. The recess preserves the simplified
  RTC/UART connector proportions used by the Raspberry Pi placeholder.
 */
module shrouded_connector(size, detailed=false, anchor=[1, 1, 1]) {
  with_anchor(size=size, anchor=anchor) {
    difference() {
      cuboid(size, anchor=[1, 1, 1]);
      if (detailed) {
        hole_w = size[0] * 0.6;
        hole_l = size[1] * 0.8;
        translate([hole_w / 2, (size[1] - hole_l) / 2, size[2] / 2 + 1]) {
          cuboid([hole_w, hole_l, size[2] * 0.5], anchor=[1, 1, 1]);
        }
      }
    }
  }
}
