/**
 * Module: Raspberry Pi 5 component layout.
 *
 * Nested PCB grid for the visible components and silkscreen. Mounting holes,
 * ribbon cutouts and accessory mounting remain in the board interface.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>
include <../parameters.scad>

use <../lib/plist.scad>
use <pcb/pcb_button.scad>

// Encode a measured distance without treating distances <= 1 mm as fractions.
function _rpi_grid_mm(value, parent) = value > 1 ? value : value / parent;

/**
  ─────────────────────────────────────────────────────────────────────────────
  rpi_5_grid
  ─────────────────────────────────────────────────────────────────────────────

  Build the default Raspberry Pi component grid from its hardware dimensions.

  **Parameters:**
  - `size`: PCB `[width, length, thickness]`.
  - `bolt_offset`: Mounting-hole inset; also sets the GPIO strip's lower margin.
  - `header_height`, `header_width`, `pin_height`, `header_cols`, `header_rows`:
    GPIO housing, pitch, pin height and positive integer contact counts.
  - `usb_a_size`, `csi_size`, `io_size`, `wifi_bt_size`, `pci_size`,
    `ethernet_jack_size`: Canonical component reference sizes.
  - `usb_a_x_gap`, `usb_a_edge_gap`, `usb_a_y_offset`: USB stack spacing,
    left margin and USB/Ethernet overhang beyond the PCB's +Y edge.
  - `usb_a_n`: Number of USB-A stacks; zero omits them.
  - `plugged_usb_a`: Plist of inserted plug indices, keyed by `right` (first
    stack) and `left` (subsequent stacks).
  - `ram_size`, `processor_size`, `usb_c_size`, `hdmi_size`, `rtc_size`,
    `uart_size`: Remaining component reference sizes.
  - `csi_position`: CSI row datum `[x, y]`, independent of ribbon slot cutters.
  - `csi_n`, `csi_gap`: CSI connector count and edge-to-edge row gap.
  - `button`: Power-button plist, or `[]` to omit it. `offsets` are relative to
    the PCI connector's right edge and the PCB's -Y edge.
  - `detailed`: Detailed processor and shrouded-connector geometry.

  **Returns:** A `pcb_grid` plist with reference size
  `[size[0], size[1] + usb_a_y_offset]`. Place its top-left origin at
  `[0, size[1] + usb_a_y_offset, 0]` and pass PCB thickness to `pcb_grid`.

  **Behavior:**
  Rows descend from +Y. Small gaps belong to the layout; component dimensions
  come from the hardware interfaces. USB-A and RP1 retain their historical
  extra PCB-thickness elevation through explicit cell `z_offset` values.
  Component reference boxes may overhang cells (ports, latches and labels).
 */
function rpi_5_grid(size=[rpi_width, rpi_len, rpi_thickness],
                    bolt_offset=rpi_bolts_offset,
                    header_height=rpi_pin_header_height,
                    header_width=rpi_pin_header_width,
                    pin_height=rpi_pin_height,
                    header_cols=rpi_pin_headers_cols,
                    header_rows=rpi_pin_headers_rows,
                    usb_a_size=rpi_usb_a_size,
                    csi_size=rpi_csi_size,
                    io_size=rpi_io_size,
                    wifi_bt_size=rpi_wifi_bt_size,
                    pci_size=rpi_pci_size,
                    ethernet_jack_size=rpi_ethernet_jack_size,
                    usb_a_x_gap=rpi_usb_a_gap,
                    usb_a_edge_gap=rpi_usb_a_edge_gap,
                    usb_a_y_offset=rpi_usb_y_offset,
                    usb_a_n=rpi_usb_a_n,
                    plugged_usb_a=rpi_plugged_usb_a,
                    ram_size=rpi_ram_size,
                    processor_size=rpi_processor_size,
                    usb_c_size=rpi_usb_c_jack_size,
                    hdmi_size=rpi_micro_hdmi_jack_size,
                    rtc_size=rpi_rtc_connector_size,
                    uart_size=rpi_uart_connector_size,
                    csi_position=[rpi_csi_position_x, rpi_csi_position_y],
                    csi_n=rpi_csi_cameras_n,
                    csi_gap=rpi_csi_camera_gap,
                    button=rpi_on_off_button_plist,
                    detailed=rpi_model_detailed) =
  assert(header_cols > 0 && header_cols == floor(header_cols)
         && header_rows > 0 && header_rows == floor(header_rows),
         "GPIO rows and columns must be positive integers")
  assert(usb_a_n >= 0 && usb_a_n == floor(usb_a_n)
         && csi_n >= 0 && csi_n == floor(csi_n),
         "USB and CSI counts must be nonnegative integers")
  let (w = size[0],
       length = size[1] + usb_a_y_offset,
       gpio_w = header_width * header_rows,
       gpio_l = header_width * header_cols,
       body_l = length - ethernet_jack_size[1],
       chip_y = header_width * 10,
       chip_l = max(ram_size[1], processor_size[1]),
       middle_l = chip_y + chip_l + 5,
       side_x = w + 2 - usb_c_size[0],
       core_w = side_x - gpio_w,
       upper_l = body_l - middle_l,
       io_x = usb_a_edge_gap + usb_a_size[0] / 2 + usb_a_x_gap,
       io_y = length - 2 * usb_a_size[1],
       pci_box = orientation_size("lwh", pci_size),
       button_offsets = plist_get("offsets", button, [0, 0]),
       button_props = plist_merge(button, ["type", "pcb_button",
                                           "orientation", "whl"]),
       // Side ports share their centerline; the small connectors sit between.
       usb_c_y = usb_c_size[1] / 2 + m25_hole_dia * 2 + 0.8,
       hdmi_y = usb_c_y + usb_c_size[1] + hdmi_size[1],
       hdmi2_y = hdmi_y + hdmi_size[0] + uart_size[1] + 1.2,
       rtc_y = usb_c_y + usb_c_size[1] / 2 + rtc_size[1] / 2,
       uart_y = hdmi_y + hdmi_size[1] - uart_size[1] / 2,
       model_text = textmetrics(rpi_model_text, size=2, font=rpi_text_font,
                                halign="left", valign="bottom"),
       hdmi_text = textmetrics("HDMI", size=4, font=rpi_text_font,
                               halign="left", valign="center"))
  ["type", "grid",
   "size", [w, length],
   "rows", [// Connector bank: all port mouths end at the same +Y edge.
            ["h", _rpi_grid_mm(ethernet_jack_size[1], length),
             "cells", concat(usb_a_n > 0 ? [["w", _rpi_grid_mm(usb_a_edge_gap, w)]] : [],
                             [for (i = [0:1:usb_a_n - 1]) each
                               [["w", _rpi_grid_mm(usb_a_size[0], w),
                                 "align_y", 1,
                                 "z_offset", size[2],
                                 "placeholder", ["type", "multi_usb_socket",
                                                 "size", usb_a_size,
                                                 "color", metallic_yellow_silver,
                                                 "offsets", [0, 0, 1],
                                                 "usb_plist", usb_a_plist,
                                                 "plugged_usb_idxes", plist_get(i == 0 ? "right" : "left", plugged_usb_a, [])]],
                                ["w", _rpi_grid_mm(i == usb_a_n - 1
                                   ? usb_a_x_gap - usb_a_edge_gap : usb_a_x_gap, w)]]],
                             [["w", _rpi_grid_mm(ethernet_jack_size[0], w),
                               "align_y", 1,
                               "placeholder", ["type", "ethernet_socket",
                                               "size", ethernet_jack_size]]])],
            ["h", _rpi_grid_mm(body_l, length),
             "cells", [// The GPIO strip keeps its own full-height column.
                       ["w", _rpi_grid_mm(gpio_w, w),
                        "grid", ["type", "grid",
                                 "rows", [["h", _rpi_grid_mm(body_l - bolt_offset * 2 - gpio_l,
                                                             body_l),
                                           "cells", [["w", 1]]],
                                          ["h", _rpi_grid_mm(gpio_l, body_l),
                                           "cells", [["w", 1,
                                                      "placeholder", ["type", "pin_header",
                                                                      "cols", header_cols,
                                                                      "rows", header_rows,
                                                                      "header_width", header_width,
                                                                      "header_height", header_height,
                                                                      "pin_height", pin_height,
                                                                      "z_offset", size[2] + 0.5,
                                                                      "p", 0.65]]]]]]],
                       ["w", _rpi_grid_mm(w - gpio_w, w),
                        "grid", ["type", "grid",
                                 "rows", [// RP1 and camera connectors, below the tall connector bank.
                                          ["h", _rpi_grid_mm(upper_l, body_l),
                                           "cells", [["w", _rpi_grid_mm(io_x - gpio_w, w - gpio_w)],
                                                     ["w", _rpi_grid_mm(io_size[0], w - gpio_w),
                                                      "grid", ["type", "grid",
                                                               "rows", [["h", _rpi_grid_mm(body_l - io_y - io_size[1],
                                                                                           upper_l),
                                                                         "cells", [["w", 1]]],
                                                                        ["h", _rpi_grid_mm(io_size[1], upper_l),
                                                                         "cells", [["w", 1,
                                                                                    "z_offset", size[2],
                                                                                    "placeholder", ["type", "cuboid",
                                                                                                    "size", io_size,
                                                                                                    "corner_rad", min(io_size[0],
                                                                                                                      io_size[1]) * 0.05,
                                                                                                    "fn", 40]]]]]]],
                                                     ["w", _rpi_grid_mm(csi_position[0] - io_x - io_size[0], w - gpio_w)],
                                                     ["w", _rpi_grid_mm(csi_size[1], w - gpio_w),
                                                      "grid", ["type", "grid",
                                                               "rows", concat([["h", _rpi_grid_mm(body_l - csi_position[1] - csi_size[0] / 2, upper_l),
                                                                                "cells", [["w", 1]]]],
                                                                              [for (i = [0:1:csi_n - 1]) each
                                                                                concat([["h", _rpi_grid_mm(csi_size[0], upper_l),
                                                                                         "cells", [["w", 1,
                                                                                                    "placeholder", ["type", "pci_connector",
                                                                                                                    "size", csi_size]]]]],
                                                                                       i < csi_n - 1
                              ? [["h", _rpi_grid_mm(csi_gap, upper_l),
                                  "cells", [["w", 1]]]]
                              : [])])]]]],
                                          ["h", _rpi_grid_mm(middle_l, body_l),
                                           "cells", [["w", _rpi_grid_mm(core_w, w - gpio_w),
                                                      "grid", ["type", "grid",
                                                               "rows", [["h", 5,
                                                                         "cells", [["w", 1]]],
                                                                        ["h", _rpi_grid_mm(chip_l, middle_l),
                                                                         "cells", [["w", 5,
                                                                                    "spin", 90,
                                                                                    "align_x", 1,
                                                                                    "align_y", -1,
                                                                                    "x_offset", -1 - model_text.position[1],
                                                                                    "y_offset", model_text.position[0],
                                                                                    "placeholder", ["type", "pcb_text",
                                                                                                    "text", rpi_model_text,
                                                                                                    "font", rpi_text_font,
                                                                                                    "size", 2,
                                                                                                    "valign", "bottom"]],
                                                                                   ["w", _rpi_grid_mm(ram_size[0], core_w),
                                                                                    "align_y", -1,
                                                                                    "placeholder", ["type", "cuboid",
                                                                                                    "size", ram_size]],
                                                                                   ["w", _rpi_grid_mm(ram_size[1] + 2 - 5 - ram_size[0], core_w)],
                                                                                   ["w", _rpi_grid_mm(processor_size[0], core_w),
                                                                                    "align_y", -1,
                                                                                    "placeholder", ["type", "bcm_processor",
                                                                                                    "size", processor_size,
                                                                                                    "detailed", detailed]]]],
                                                                        ["h", _rpi_grid_mm(chip_y - bolt_offset * 2, middle_l),
                                                                         "cells", [["w", wifi_bt_size[0] + 1,
                                                                                    "align_x", 1,
                                                                                    "align_y", -1,
                                                                                    "placeholder", ["type", "cuboid",
                                                                                                    "size", wifi_bt_size,
                                                                                                    "corner_rad", min(wifi_bt_size[0],
                                                                                                                      wifi_bt_size[1]) * 0.05,
                                                                                                    "color", metallic_silver_1,
                                                                                                    "fn", 40]]]],
                                                                        ["h", _rpi_grid_mm(bolt_offset * 2, middle_l),
                                                                         "cells", concat([["w", _rpi_grid_mm(w / 2 - pci_box[0] / 2 - gpio_w, core_w)],
                                                                                          ["w", _rpi_grid_mm(pci_box[0], core_w),
                                                                                           "align_y", -1,
                                                                                           "y_offset", -pci_box[1] / 2,
                                                                                           "placeholder", ["type", "pci_connector",
                                                                                                           "size", pci_size]]],
                                                                                         len(button) > 0
                      ? [["w", _rpi_grid_mm(button_offsets[0], core_w)],
                         ["w", _rpi_grid_mm(pcb_button_size_from_plist(button_props)[0], core_w),
                          "align_y", -1,
                          "y_offset", button_offsets[1],
                          "placeholder", button_props]]
                      : [])]]]],
                                                     // Side-port column intentionally overhangs the board by 2 mm.
                                                     ["w", _rpi_grid_mm(usb_c_size[0], w - gpio_w),
                                                      "grid", ["type", "grid",
                                                               "rows", [["h", _rpi_grid_mm(middle_l - hdmi2_y - hdmi_size[1] / 2,
                                                                                           middle_l),
                                                                         "cells", [["w", 1]]],
                                                                        ["h", _rpi_grid_mm(hdmi_size[1], middle_l),
                                                                         "cells", [["w", 1,
                                                                                    "placeholder", ["type", "board_edge_socket",
                                                                                                    "size", hdmi_size]]]],
                                                                        ["h", _rpi_grid_mm(hdmi2_y - hdmi_size[1] / 2 - uart_y - uart_size[1],
                                                                                           middle_l),
                                                                         "cells", [["w", 1]]],
                                                                        ["h", _rpi_grid_mm(uart_size[1], middle_l),
                                                                         "cells", [["w", 1,
                                                                                    "align_x", -1,
                                                                                    "x_offset", (usb_c_size[0] - hdmi_size[0]) / 2 + 2,
                                                                                    "placeholder", ["type", "shrouded_connector",
                                                                                                    "size", uart_size,
                                                                                                    "detailed", detailed]]]],
                                                                        ["h", _rpi_grid_mm(uart_y - hdmi_y - hdmi_size[1] / 2, middle_l),
                                                                         "cells", [["w", 1]]],
                                                                        ["h", _rpi_grid_mm(hdmi_size[1], middle_l),
                                                                         "cells", [// Zero-width annotation cell places the legend beside this port.
                                                                                   ["w", 0,
                                                                                    "spin", 90,
                                                                                    "align_x", 1,
                                                                                    "align_y", -1,
                                                                                    "x_offset", -usb_c_size[0] / 2 - hdmi_text.position[1],
                                                                                    "y_offset", hdmi_text.position[0],
                                                                                    "placeholder", ["type", "pcb_text",
                                                                                                    "text", "HDMI",
                                                                                                    "size", 4,
                                                                                                    "font", rpi_text_font,
                                                                                                    "valign", "center"]],
                                                                                   ["w", 1,
                                                                                    "placeholder", ["type", "board_edge_socket",
                                                                                                    "size", hdmi_size]]]],
                                                                        ["h", _rpi_grid_mm(hdmi_y - hdmi_size[1] / 2 - rtc_y - rtc_size[1],
                                                                                           middle_l),
                                                                         "cells", [["w", 1]]],
                                                                        ["h", _rpi_grid_mm(rtc_size[1], middle_l),
                                                                         "cells", [["w", 1,
                                                                                    "align_x", -1,
                                                                                    "x_offset", (usb_c_size[0] - hdmi_size[0]) / 2 + 1,
                                                                                    "placeholder", ["type", "shrouded_connector",
                                                                                                    "size", rtc_size,
                                                                                                    "detailed", detailed]]]],
                                                                        ["h", _rpi_grid_mm(rtc_y - usb_c_y - usb_c_size[1] / 2, middle_l),
                                                                         "cells", [["w", 1]]],
                                                                        ["h", _rpi_grid_mm(usb_c_size[1], middle_l),
                                                                         "cells", [["w", 1,
                                                                                    "placeholder", ["type", "board_edge_socket",
                                                                                                    "size", usb_c_size]]]]]]]]]]]]]]]];
