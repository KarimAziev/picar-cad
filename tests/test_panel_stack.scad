use <../scad/panel_stack/control_panel.scad>
use <../scad/panel_stack/fuse_panel.scad>
use <../scad/panel_stack/panel_stack.scad>

size         = panel_stack_size();
bolts        = panel_stack_bolt_spacing();
fuse_h       = fuse_panel_size()[2];
control_h    = control_panel_size()[2];
assert(len(size) == 2 && len(bolts) == 2,
       "Keep canonical footprint interfaces");
assert(size[0] > bolts[0] && size[1] > bolts[1]);
assert(panel_stack_height(false, false) == 0);
assert(panel_stack_height(true, false, false) == control_h);
assert(panel_stack_height(false, true, false) == fuse_h);
assert(panel_stack_height(true, true, false) == control_h + fuse_h);
assert(panel_stack_height(true, false) == control_panel_height());
assert(panel_stack_height(false, true) == fuse_panel_height());
assert(panel_stack_height() > control_panel_height() + fuse_panel_height());

orientations = ["wlh", "whl",
                "lwh", "lhw",
                "hlw", "hwl"];
axis_orders  = [[0, 1, 2], [0, 2, 1], [1, 0, 2],
                [1, 2, 0], [2, 1, 0], [2, 0, 1]];
for (buttons = [false, true], fuses = [false, true], standoffs = [false, true]) {
  canonical = concat(size, [panel_stack_height(buttons, fuses, standoffs)]);
  for (i = [0 : 5]) {
    order = axis_orders[i];
    expected_size = [for (axis = order) canonical[axis]];
    canonical_bolts = concat(bolts, [0]);
    expected_bolts = [for (axis = order) canonical_bolts[axis]];
    assert(panel_stack_oriented_size(orientations[i], buttons, fuses, standoffs)
           == expected_size);
    assert(panel_stack_oriented_bolt_spacing(orientations[i]) == expected_bolts);
  }
}
echo("PASS: panel stack structural sizes, toggles, and all six oriented hole spans");
