include <../scad/suspension/rear_suspension/computed_params.scad>
use <../scad/panel_stack/control_panel.scad>
use <../scad/panel_stack/fuse_panel.scad>
use <../scad/placeholders/standoff.scad>
use <../scad/lib/functions.scad>

function near(a, b) = (is_num(a) ? abs(a-b) : norm(a-b)) < 0.00001;
function outside(p, bounds, r) =
  p[0]+r <= bounds[0][0] || p[0]-r >= bounds[1][0]
  || p[1]+r <= bounds[0][1] || p[1]-r >= bounds[1][1];

// The efficient tall-column solver preserves the original hardware selection.
for (h=[0:0.5:24]) {
  assert(standoff_heights(h) == best_height_combo(h, [20,15,10,9,8,6,5], ceil(h/5)+1));
}
assert(sum(standoff_heights(106.2)) == 107);
assert(standoff_heights(8.1, [5.5, 3]) == [5.5,3]);

for (to=["wlh", "lwh", "whl", "lhw", "hlw", "hwl"]) {
  assert(control_panel_oriented_size(to) == orientation_size(to, control_panel_oriented_size()));
  assert(fuse_panel_oriented_size(to) == orientation_size(to, fuse_panel_oriented_size()));
}
assert(control_panel_clearance_height() > control_panel_height());
assert(fuse_panel_clearance_height() >= fuse_panel_height());

variants = [rear_panel_specs,
            [["type","control","side","right"], ["type","fuse","side","left"]],
            [["type","stack","side","left"], ["type","stack","side","right"]],
            [["type","fuse","side","left"], ["type","control","side","left"]],
            []];
for (specs = variants) {
  layout = rear_suspension_layout(panels=specs);
  panels = plist_get("panels", layout);
  payload = plist_get("power_case", layout);
  motor = plist_get("motor_bounds", layout);
  holes = plist_get("mount_holes", payload);
  radius = plist_get("radius", payload);
  assert(len(panels) == len(specs));
  assert(len(holes) == 4);
  assert(plist_get("mount_z", payload) >= front_chassis_thickness
         + rear_motor_clearance_height(plist_get("bracket", layout)) + rear_power_case_clearance);
  for (panel=panels) {
    for (region = plist_get("clearance_regions", panel)) {
      pos = plist_get("pos", payload);
      envelope = [max(plist_get("size", payload)[0], plist_get("lid_size", payload)[0]),
                  max(plist_get("size", payload)[1], plist_get("lid_size", payload)[1]), 0];
      overhead = [pos - envelope/2, pos + envelope/2];
      if (_rear_bounds_overlap(region, overhead)) {
        assert(plist_get("mount_z", payload) >= front_chassis_thickness
               + region[1][2] + rear_power_case_clearance);
      }
    }
    if (plist_get("outside_case", panel)) {
      assert(plist_get("type", panel) == "control");
      assert(plist_get("bounds", panel)[1][1] + rear_suspension_chassis_bolt_pad
             <= plist_get("transition_y_end", layout) + 0.00001);
    }
    for (hole=holes) {
      assert(outside(hole, plist_get("bounds", panel), radius + rear_power_standoff_clearance - 0.00001));
    }
  }
  for (hole=holes) {
    assert(outside(hole, motor, radius + rear_power_standoff_clearance - 0.00001));
    assert(abs(hole[0])+radius < plist_get("join_w",layout)/2);
    assert(hole[1]-radius > plist_get("min_y",layout));
  }
  assert(near(plist_get("pos", payload)[0], 0));
  resolved_case = plist_get("plist",payload);
  assert(plist_get("mount_nut_pockets",resolved_case));
  assert(plist_get("bottom_t",resolved_case)
         > plist_get("thread_h",calc_standoff_params(plist_get("bolt_d",resolved_case),5)[0]));
  props = multi_lipo_pack_props(resolved_case);
  assert(orientation_size(plist_get("orientation",props), concat(plist_get("bolt_spacing",props),[0]))
         == concat(plist_get("bolt_spacing",payload),[0]));
  assert(plist_get("bolt_spacing",rear_lidar_plist) == [43,43]);
}
plain = rear_suspension_layout(panels=[], power_case=undef);
assert(len(plist_get("panels",plain)) == 0 && is_undef(plist_get("power_case",plain)));
assert(multi_lipo_pack_mount_height(multi_lipo_packs_case, 0, 6) == 0);
assert(multi_lipo_pack_mount_height(multi_lipo_packs_case, 70.2, 6) == 71);
echo("PASS: standalone panel references, independent panels, tall columns, payload clearance and support layout");

// Only the tall lever needs to clear the overhead case and cover.
default_layout = rear_suspension_layout();
default_payload = plist_get("power_case", default_layout);
under_payload = plist_get("power_case", rear_suspension_layout(control_outside=false));
assert(len(control_panel_switch_button_specs) == 1);
assert(plist_get("standoff_h", default_payload) < plist_get("standoff_h", under_payload));
assert(near(plist_get("pos", default_payload)[0], 0));
for (panel = plist_get("panels", default_layout)) {
  motor_bounds = plist_get("motor_bounds", default_layout);
  bounds = plist_get("bounds", panel);
  assert(near(plist_get("side", panel) == "left"
              ? motor_bounds[0][0] - bounds[1][0]
              : bounds[0][0] - motor_bounds[1][0], panel_stack_side_x_dist_from_motor));
}
// Explicit overrides preserve the old under-case controls; combined stacks stay put.
for (outside = [false, true]) {
  custom = rear_suspension_layout(panels=[["type", "control", "outside_case", outside]],
                                   control_outside=!outside);
  assert(plist_get("outside_case", plist_get("panels", custom)[0]) == outside);
}
// Ears widen the support envelope without moving or enlarging the battery cells.
base_props = multi_lipo_pack_props(multi_lipo_packs_case);
rear_props = multi_lipo_pack_props(plist_get("plist", default_payload));
assert(plist_get("body_size", rear_props)[0] == plist_get("body_size", base_props)[0]);
assert(plist_get("body_size", rear_props)[1] == plist_get("body_size", base_props)[1]);
assert(plist_get("size", rear_props)[0] > plist_get("body_size", default_payload)[0]);
assert(near(plist_get("motor_pos",default_layout)[1]
             - plist_get("drive_end_y",plist_get("bracket",default_layout)),
            plist_get("maintenance_y",default_layout) - rc_motor_maintenance_hole_dist));


// The default uses the existing deck on the suspension side, with partial overlap.
under_layout = rear_suspension_layout(control_outside=false);
control = plist_get("panels", default_layout)[0];
control_bounds = plist_get("bounds", control);
lever_bounds = plist_get("clearance_regions", control)[1];
cover_edge = plist_get("pos", default_payload)[1] + plist_get("lid_size", default_payload)[1]/2;
assert(control_bounds[0][1] < plist_get("bounds", default_payload)[1][1]);
assert(lever_bounds[0][1] >= cover_edge + rear_control_case_gap - 0.00001);
assert(plist_get("pos", control)[1] > plist_get("pos", default_payload)[1]);
assert(near(plist_get("size", default_layout), plist_get("size", under_layout)));
assert(near(plist_get("transition_y_end", default_layout), plist_get("transition_y_end", under_layout)));
assert(plist_get("standoff_h", default_payload) == 47);
// With more longitudinal room the whole panel clears. With less, the case stays high.
roomy = rear_suspension_layout(motor_dist=20);
roomy_payload = plist_get("power_case", roomy);
assert(plist_get("bounds", plist_get("panels", roomy)[0])[0][1]
       >= plist_get("pos", roomy_payload)[1] + plist_get("lid_size", roomy_payload)[1]/2
       + rear_control_case_gap - 0.00001);
tight = rear_suspension_layout(panels=[["type", "control", "orientation", "lwh"],
                                      ["type", "fuse", "orientation", "lwh"]]);
assert(plist_get("standoff_h", plist_get("power_case", tight))
       >= plist_get("standoff_h", under_payload));
for (to = ["wlh", "lwh"]) {
  regions = control_panel_clearance_regions(to);
  assert(len(regions) == 1 + len(control_panel_switch_button_specs));
  assert(max([for (b = regions) b[1][2]]) == control_panel_clearance_height());
}
echo("PASS: suspension-side partial overlap, lever clearance, unchanged deck and safe height fallback");
