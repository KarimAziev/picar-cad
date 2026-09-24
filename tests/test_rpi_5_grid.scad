include <../scad/parameters.scad>

use <../scad/core/grid.scad>
use <../scad/core/pcb_placeholder_renderer.scad>
use <../scad/lib/functions.scad>
use <../scad/lib/plist.scad>
use <../scad/placeholders/pin_header.scad>
use <../scad/placeholders/rpi_5_grid.scad>

// Resolve observable leaf reference boxes independently of the RPi factory.
// Each result is [placeholder plist, canonical minimum XYZ, spun reference size].
function leaf_box(cell, cell_size, origin, thickness) =
  let (placeholder = plist_get("placeholder", cell),
       type = plist_get("type", placeholder),
       size = type == "pin_header"
       ? concat(pin_header_size_from_plist(placeholder),
                [plist_get("header_height", placeholder)])
       : pcb_placeholder_size(placeholder),
       rotated = calc_rotated_bbox(size[0], size[1], plist_get("spin", cell, 0)),
       alignment = [plist_get("align_x", cell, 0), plist_get("align_y", cell, 0)],
       offsets = [plist_get("x_offset", cell, 0), plist_get("y_offset", cell, 0)],
       minimum = [for (i = [0:1]) origin[i] + offsets[i]
                    + (cell_size[i] - rotated[i]) * (alignment[i] + 1) / 2])
  [placeholder,
   concat(minimum, [thickness + plist_get("z_offset", cell, 0)]),
   [rotated[0], rotated[1], size[2]]];

function row_boxes(row, size, origin, thickness) =
  let (cells = plist_get("cells", row),
       widths = [for (cell = cells) maybe_to_mm(plist_get("w", cell), size[0])])
  [for (ci = [0:1:len(cells)-1])
    let (cell = cells[ci],
         cell_size = [widths[ci], size[1]],
         cell_origin = origin + [sum_prefix(widths, ci), 0],
         nested = plist_get("grid", cell))
      each !is_undef(nested)
      ? grid_boxes(nested, cell_size, cell_origin + [0, size[1]], thickness)
      : is_undef(plist_get("placeholder", cell)) ? []
      : [leaf_box(cell, cell_size, cell_origin, thickness)]];

function grid_boxes(grid, size, origin, thickness) =
  let (rows = plist_get("rows", grid),
       heights = [for (row = rows) maybe_to_mm(plist_get("h", row), size[1])])
  [for (ri = [0:1:len(rows)-1]) each
     row_boxes(rows[ri], [size[0], heights[ri]],
                origin - [0, sum_prefix(heights, ri + 1)], thickness)];

function board_boxes(grid, thickness) =
  let (size = plist_get("size", grid))
  grid_boxes(grid, size, [0, size[1]], thickness);

function of_type(boxes, type) =
  [for (box = boxes) if (plist_get("type", box[0]) == type) box];

function with_size(boxes, size) =
  [for (box = boxes) if (plist_get("size", box[0]) == size) box];

function close(a, b, epsilon=0.000001) = norm(a - b) < epsilon;

module at(box, position) {
  assert(close(box[1], position),
         str(plist_get("type", box[0]), " expected ", position, " got ", box[1]));
}

defaults = board_boxes(rpi_5_grid(), rpi_thickness);
assert(len(defaults) == 19);
for (expected = [["pin_header", 1], ["cuboid", 3], ["bcm_processor", 1],
                 ["multi_usb_socket", 2], ["ethernet_socket", 1],
                 ["pci_connector", 3], ["pcb_button", 1],
                 ["board_edge_socket", 3], ["shrouded_connector", 2],
                 ["pcb_text", 2]]) {
  assert(len(of_type(defaults, expected[0])) == expected[1], expected[0]);
}

// Fixed reference datums from the pre-grid board model, in canonical PCB axes.
at(of_type(defaults, "pin_header")[0], [0, 6, 1.9]);
at(with_size(defaults, [14, 11, 1.5])[0], [6.08, 6, 1.9]);
at(with_size(defaults, [10.2, 15, 1])[0], [10.08, 25.4, 1.9]);
at(of_type(defaults, "bcm_processor")[0], [22.08, 25.4, 1.9]);
at(of_type(defaults, "multi_usb_socket")[0], [2, 70.4, 3.8]);
at(of_type(defaults, "multi_usb_socket")[1], [20.25, 70.4, 3.8]);
at(of_type(defaults, "ethernet_socket")[0], [36.5, 66.66, 1.9]);
at(with_size(defaults, [14, 10, 1.5])[0], [13.625, 52.8, 3.8]);
at(with_size(defaults, [2, 16, 2.5])[0], [40, 54.4, 1.9]);
at(with_size(defaults, [2, 16, 2.5])[1], [40, 48.56, 1.9]);
at(with_size(defaults, [2, 12.85, 3])[0], [21.575, -1, 1.9]);
at(of_type(defaults, "pcb_button")[0], [37.545, 0, 1.9]);
at(with_size(defaults, [8.2, 7.8, 3])[0], [49.8, 6, 1.9]);
at(with_size(defaults, [8.2, 6.5, 3])[0], [49.8, 34.35, 1.9]);
at(with_size(defaults, [8.2, 6.5, 3])[1], [49.8, 20.95, 1.9]);
at(with_size(defaults, [2.5, 4, 5])[0], [51.8, 28.7, 1.9]);
at(with_size(defaults, [2.5, 3.4, 5])[0], [50.8, 15.5, 1.9]);

// Board and header overrides move dependent components and remain in the plist.
custom = board_boxes(rpi_5_grid(size=[70, 100, 2.4], bolt_offset=3.5,
                                header_width=3, header_rows=3, header_cols=12,
                                header_height=4, pin_height=10,
                                usb_a_n=0, csi_n=0, button=[]), 2.4);
assert(len(custom) == 14);
assert(len(of_type(custom, "multi_usb_socket")) == 0);
assert(len(with_size(custom, rpi_csi_size)) == 0);
assert(len(of_type(custom, "pcb_button")) == 0);
header = of_type(custom, "pin_header")[0];
at(header, [0, 7, 2.4]);
assert(close(header[2], [9, 36, 4]));
assert(plist_get("pin_height", header[0]) == 10);
assert(plist_get("z_offset", header[0]) == 2.9);
at(with_size(custom, rpi_wifi_bt_size)[0], [10, 7, 2.4]);
at(with_size(custom, rpi_ram_size)[0], [14, 30, 2.4]);
at(of_type(custom, "bcm_processor")[0], [26, 30, 2.4]);
at(of_type(custom, "ethernet_socket")[0], [0, 81.66, 2.4]);
at(with_size(custom, rpi_pci_size)[0], [28.575, -1, 2.4]);
at(with_size(custom, rpi_usb_c_jack_size)[0], [63.8, 6, 2.4]);

// Submillimeter distances are measured gaps, not fractions of a parent grid.
small = board_boxes(rpi_5_grid(usb_a_edge_gap=0.25, usb_a_x_gap=0.5,
                               csi_gap=0.4,
                               plugged_usb_a=["right", [0], "left", [1]]), 1.9);
usb = of_type(small, "multi_usb_socket");
at(usb[0], [0.25, 70.4, 3.8]);
at(usb[1], [14, 70.4, 3.8]);
assert(abs(usb[1][1][0] - usb[0][1][0] - usb[0][2][0] - 0.5) < 0.000001);
assert(plist_get("plugged_usb_idxes", usb[0][0]) == [0]);
assert(plist_get("plugged_usb_idxes", usb[1][0]) == [1]);
at(of_type(small, "ethernet_socket")[0], [27.5, 66.66, 1.9]);
at(with_size(small, rpi_csi_size)[1], [40, 52, 1.9]);

// A physical one-millimeter connector must not become a whole grid row.
thin_csi = board_boxes(rpi_5_grid(csi_size=[1, 16, 2.5]), 1.9);
thin_cameras = with_size(thin_csi, [1, 16, 2.5]);
assert(len(thin_cameras) == 2);
at(thin_cameras[0], [40, 54.9, 1.9]);
at(thin_cameras[1], [40, 50.06, 1.9]);
assert(close(thin_cameras[0][2], [16, 1, 2.5]));

// Partial button specs retain the reusable button's body-size defaults.
partial_button = of_type(board_boxes(rpi_5_grid(button=["button_d", 2]), 1.9),
                          "pcb_button")[0];
at(partial_button, [34.425, 0, 1.9]);
assert(close(partial_button[2], [4.5, 3, 3.3]));
assert(plist_get("button_d", partial_button[0]) == 2);

echo("RPi 5 grid placement assertions passed");
