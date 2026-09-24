use <../scad/core/grid.scad>
use <../scad/core/pcb_placeholder_renderer.scad>
use <../scad/lib/functions.scad>
use <../scad/lib/plist.scad>

// Retain the existing mixed absolute/fractional dimension contract.
assert(maybe_to_mm(14, 80) == 14);
assert(maybe_to_mm(0.25, 80) == 20);
assert(maybe_to_mm(1, 80) == 80);
assert(maybe_to_mm(0, 80) == 0);
assert(sum_prefix([8, 20, 7], 2) == 28);

for (type = ["cuboid", "bcm_processor", "ethernet_socket",
             "board_edge_socket", "shrouded_connector", "multi_usb_socket"]) {
  assert(pcb_placeholder_size(["type", type, "size", [12, 8, 3]]) == [12, 8, 3]);
}

// Orientation must inform cell fitting rather than using the unrotated size.
assert(pcb_placeholder_size(["type", "pci_connector", "size", [12, 2, 3]])
       == [2, 12, 3]);
assert(pcb_placeholder_size(["type", "pcb_button", "size", [4, 2, 3]])
       == [4, 2, 3]);
for (type = ["pci_connector", "pcb_button"],
     orientation = ["wlh", "whl", "lwh", "lhw", "hwl", "hlw"]) {
  assert(pcb_placeholder_size(["type", type,
                               "size", [12, 2, 3],
                               "orientation", orientation])
         == orientation_size(orientation, [12, 2, 3]));
}

// Legacy sizes stay with the legacy dispatcher, preserving its special cases.
assert(is_undef(pcb_placeholder_size(["type", "smd_chip",
                                      "placeholder_size", [10, 8]])));
assert(is_undef(pcb_placeholder_size(["type", "text", "text", "PCB"])));

text_props = ["type", "pcb_text", "text", "Pi gj",
              "font", "Liberation Sans", "size", 3, "spacing", 1.1,
              "halign", "center", "valign", "center", "height", 0.2];
text_bounds = textmetrics(text="Pi gj", font="Liberation Sans", size=3,
                           spacing=1.1, halign="center", valign="center");
assert(pcb_placeholder_size(text_props)
       == [text_bounds.size[0], text_bounds.size[1], 0.2]);

// Child callbacks must retain mode and receive sizes from each nested cell.
grid = ["type", "grid", "size", [80, 60],
        "rows", [["h", 0.5,
                   "cells", [["w", 0.25, "id", "outer"],
                             ["w", 0.75, "grid",
                              ["type", "grid", "rows",
                               [["h", 0.5,
                                 "cells", [["w", 1, "id", "inner"]]]]]]]]]];
for (mode = ["placeholder", "slot"]) {
  grid_plist(grid, mode=mode) {
    assert($mode == mode, "Nested callbacks must retain the requested mode");
    assert($cell_size == (plist_get("id", $cell) == "outer" ? [20, 30] : [60, 15]),
           "Nested fractions must use the cell's dimensions");
  }
}

// Empty layouts and spacer-only rows must not invoke child callbacks.
for (rows = [[], [["h", 1, "cells", []]]]) {
  grid_plist(["type", "grid", "size", [80, 60], "rows", rows]) {
    assert(false, "Empty grids must not create phantom cells");
  }
}

echo("PCB grid assertions passed");
