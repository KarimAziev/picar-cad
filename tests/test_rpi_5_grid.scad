include <../scad/parameters.scad>

use <../scad/core/grid.scad>
use <../scad/core/pcb_placeholder_renderer.scad>
use <../scad/lib/functions.scad>
use <../scad/lib/plist.scad>
use <../scad/placeholders/pin_header.scad>
use <../scad/placeholders/micro_sd.scad>
use <../scad/placeholders/rpi_5.scad>
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
    row_boxes(rows[ri],
              [size[0], heights[ri]],
              origin - [0, sum_prefix(heights, ri + 1)],
              thickness)];

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
assert(len(defaults) == 22);
for (expected = [["pin_header", 2], ["cuboid", 3], ["bcm_processor", 1],
                 ["multi_usb_socket", 2], ["ethernet_socket", 1],
                 ["pci_connector", 3], ["pcb_button", 1],
                 ["board_edge_socket", 2], ["shrouded_connector", 3],
                 ["usb_socket", 1], ["micro_sd_socket", 1],
                 ["pcb_text", 2]]) {
  assert(len(of_type(defaults, expected[0])) == expected[1], expected[0]);
}

// PCB-relative component bounds measured in rpi-5b_with_graphics.stl.
at(of_type(defaults, "pin_header")[0], [0.96, 7.1, 1.306]);
at(of_type(defaults, "pin_header")[1], [43.96, 58.96, 1.306]);
at(with_size(defaults, [13, 10.8, 1.7])[0], [6.8, 6.9, 1.306]);
at(with_size(defaults, [10, 14.5, 0.72])[0], [11.8, 25.9, 1.586]);
at(of_type(defaults, "bcm_processor")[0], [24.75, 24.65, 1.556]);
at(of_type(defaults, "multi_usb_socket")[0], [2.45, 70.47, 1.306]);
at(of_type(defaults, "multi_usb_socket")[1], [20.35, 70.47, 1.306]);
at(of_type(defaults, "ethernet_socket")[0], [37.835, 66.45, 1.306]);
at(with_size(defaults, [12, 12, 0.99])[0], [14.9, 52.5, 1.516]);
at(with_size(defaults, [2.3, 16, 3.45])[0], [39.5, 54.055, 1.406]);
at(with_size(defaults, [2.3, 16, 3.45])[1], [39.5, 47.855, 1.406]);
at(with_size(defaults, [2.3, 13, 3.45])[0], [19.5, 1.855, 1.406]);
at(of_type(defaults, "pcb_button")[0], [35.35, 0.4, 1.306]);
at(of_type(defaults, "usb_socket")[0], [49.6, 7.1, 1.406]);
at(with_size(defaults, [8.5, 6.5, 2.9])[0], [49.13, 35.95, 1.406]);
at(with_size(defaults, [8.5, 6.5, 2.9])[1], [49.13, 22.55, 1.406]);
at(with_size(defaults, [2.9, 5, 4.25])[0], [50.6, 30, 1.356]);
at(with_size(defaults, [2.9, 4, 4.25])[0], [49.8, 17, 1.356]);
at(with_size(defaults, [2.9, 6, 4.25])[0], [1, 65.3, 1.356]);
at(of_type(defaults, "micro_sd_socket")[0], [21.94, 2.25, -1.45]);

// GPIO and PoE contact tips share the same height in the reference STL.
for (header = of_type(defaults, "pin_header")) {
  tip_z = header[1][2] + plist_get("pin_height", header[0])
          - plist_get("z_offset", header[0], 0);
  assert(abs(tip_z - 9.846) < 0.000001);
}
processor = of_type(defaults, "bcm_processor")[0];
assert(abs(processor[1][2] + processor[2][2]
           + plist_get("extra_h", processor[0]) - 3.624) < 0.000001);

// Connector centerlines are dimensioned on the mechanical drawing.
usb_centers = of_type(defaults, "multi_usb_socket");
for (i = [0:1]) {
  assert(abs(56 - usb_centers[i][1][0] - usb_centers[i][2][0] / 2
             - [47, 29.1][i]) < 0.000001);
}
ethernet = of_type(defaults, "ethernet_socket")[0];
assert(abs(56 - ethernet[1][0] - ethernet[2][0] / 2 - 10.2) < 0.000001);
for (spec = [[[8.2, 7.6, 3.16], [11.2]],
             [[8.5, 6.5, 2.9], [39.2, 25.8]]]) {
  ports = with_size(defaults, spec[0]);
  for (i = [0:len(ports) - 1]) {
    assert(abs(ports[i][1][1] + ports[i][2][1] / 2 - spec[1][i]) < 0.000001);
  }
}

// Board and header overrides move dependent components and remain in the plist.
custom = board_boxes(rpi_5_grid(size=[70, 100, 2.4], bolt_offset=3.5,
                                header_width=3, header_rows=3, header_cols=12,
                                header_height=4, pin_height=10,
                                usb_a_n=0, csi_n=0, button=[]),
                     2.4);
assert(len(custom) == 17);
assert(len(of_type(custom, "multi_usb_socket")) == 0);
assert(len(with_size(custom, rpi_csi_size)) == 0);
assert(len(of_type(custom, "pcb_button")) == 0);
header = of_type(custom, "pin_header")[0];
at(header, [-1, 14.5, 2.43]);
assert(close(header[2], [9, 36, 4]));
assert(plist_get("pin_height", header[0]) == 10);
assert(plist_get("z_offset", header[0]) == 1.9);
at(with_size(custom, rpi_wifi_bt_size)[0], [8.76, 14.3, 2.43]);
at(with_size(custom, rpi_ram_size)[0], [13.76, 25.9, 2.71]);
at(of_type(custom, "bcm_processor")[0], [26.71, 24.65, 2.68]);
at(of_type(custom, "ethernet_socket")[0], [0, 81.45, 2.43]);
at(with_size(custom, rpi_pci_size)[0], [26.5, 1.855, 2.53]);
at(with_size(custom, rpi_usb_c_jack_size)[0], [63.6, 7.1, 2.53]);

// Submillimeter distances are measured gaps, not fractions of a parent grid.
small = board_boxes(rpi_5_grid(usb_a_edge_gap=0.25, usb_a_x_gap=0.5,
                               csi_gap=0.4,
                               plugged_usb_a=["right", [0],
                                              "left", [1]]),
                    1.9);
usb = of_type(small, "multi_usb_socket");
at(usb[0], [0.25, 70.47, 1.93]);
at(usb[1], [13.85, 70.47, 1.93]);
assert(abs(usb[1][1][0] - usb[0][1][0] - usb[0][2][0] - 0.5) < 0.000001);
assert(plist_get("plugged_usb_idxes", usb[0][0]) == [0]);
assert(plist_get("plugged_usb_idxes", usb[1][0]) == [1]);
at(of_type(small, "ethernet_socket")[0], [31.335, 66.45, 1.93]);
at(with_size(small, rpi_csi_size)[1], [39.5, 51.355, 2.03]);

// A physical one-millimeter connector must not become a whole grid row.
thin_csi = board_boxes(rpi_5_grid(csi_size=[1, 16, 2.5]), 1.9);
thin_cameras = with_size(thin_csi, [1, 16, 2.5]);
assert(len(thin_cameras) == 2);
at(thin_cameras[0], [39.5, 54.705, 2.03]);
at(thin_cameras[1], [39.5, 49.805, 2.03]);
assert(close(thin_cameras[0][2], [16, 1, 2.5]));

// Partial button specs retain the reusable button's body-size defaults.
partial_button = of_type(board_boxes(rpi_5_grid(button=["button_d", 2]), 1.9),
                         "pcb_button")[0];
at(partial_button, [32.5, 0, 1.93]);
assert(close(partial_button[2], [4.5, 3, 3.3]));
assert(plist_get("button_d", partial_button[0]) == 2);

echo("RPi 5 grid placement assertions passed");

// Routing datums agree with the observable CSI connector boxes.
csi_boxes = with_size(defaults, rpi_csi_size);
csi_centers = rpi_5_csi_centers();
assert(len(csi_centers) == len(csi_boxes));
for (i = [0:len(csi_centers) - 1]) {
  near_center = [csi_boxes[i][1][0] + csi_boxes[i][2][0] / 2,
                 csi_boxes[i][1][1] + csi_boxes[i][2][1] / 2, 0];
  assert(close(csi_centers[i], near_center));
}
assert(close(rpi_5_csi_centers([10, 30], [3, 12, 2], 2, 4)[1], [16, 23, 0]));

// USB-C width is across the mouth; depth changes along the insertion axis.
wider_usb = board_boxes(rpi_5_grid(usb_c_size=[10, 7.6, 3.16]), rpi_thickness);
deeper_usb = board_boxes(rpi_5_grid(usb_c_size=[8.2, 9, 3.16]), rpi_thickness);
at(of_type(wider_usb, "usb_socket")[0], [49.6, 6.2, 1.406]);
at(of_type(deeper_usb, "usb_socket")[0], [48.2, 7.1, 1.406]);
for (boxes = [wider_usb, deeper_usb]) {
  at(with_size(boxes, rpi_micro_hdmi_jack_size)[0], [49.13, 35.95, 1.406]);
  at(with_size(boxes, rpi_uart_connector_size)[0], [50.6, 30, 1.356]);
}

// Inserted accessories do not change the grid's placement reference.
accessories = rpi_5_grid(show_usb_c_plug=true, sd_card_overhang=4);
assert(plist_get("size", accessories) == plist_get("size", rpi_5_grid()));
accessory_boxes = board_boxes(accessories, rpi_thickness);
assert(plist_get("show_usb_plug", of_type(accessory_boxes, "usb_socket")[0][0]));
sd_socket = of_type(accessory_boxes, "micro_sd_socket")[0];
card_size = plist_get("size", plist_get("card", sd_socket[0]));
card_min = sd_socket[1] + micro_sd_card_position(sd_socket[2], card_size,
                                               plist_get("insertion", sd_socket[0]));
assert(close(card_min, [22.415, -4, -1.24]));
hidden = board_boxes(rpi_5_grid(show_sd_card=false), rpi_thickness);
assert(!plist_get("show_card", of_type(hidden, "micro_sd_socket")[0][0]));
