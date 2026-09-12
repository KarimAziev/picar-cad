include <../scad/parameters.scad>

use <../scad/lib/plist.scad>
use <../scad/placeholders/motors/rc/rc_gearbox.scad>
use <../scad/placeholders/motors/rc/rc_gearmotor.scad>

module check_gearbox(spec=rc_motor_plist) {
  layout = rc_gearbox_layout(spec);
  ps = plist_get("centers", layout);
  ds = plist_get("lobe_ds", layout);
  distances = plist_get("mesh_distances", layout);
  center = plist_get("center", layout);
  size = rc_gearbox_size(spec);
  assert(ps[0] == [0, 0]);
  for (i = [0:2]) {
    assert(abs(norm(ps[i + 1] - ps[i]) - distances[i]) < 0.000001);
  }
  for (axis = [0:1]) {
    low = min([for (i = [0:3]) ps[i][axis] - ds[i] / 2]);
    high = max([for (i = [0:3]) ps[i][axis] + ds[i] / 2]);
    assert(abs(high - low - size[axis]) < 0.000001);
    assert(abs((low + high) / 2 - center[axis]) < 0.000001);
  }
  assert(norm(rc_gearmotor_size(spec)
              - [size[0], size[2] + rc_motor_total_h(spec), size[1]]) < 0.000001);
}

assert(rc_gearbox_size() == [42, 31.5, 14.75]);
assert(abs(rc_motor_total_h() - 39.3) < 0.000001);
assert(plist_get("body", rc_motor_plist) == ["d", 24.3, "h", 27.7, "color", matte_black]);
assert(plist_get("bearing_d", plist_get("gearbox", rc_motor_plist)) == 7);
assert(plist_get("bearing_h", plist_get("gearbox", rc_motor_plist)) == 2);
assert(plist_get("rear_shaft_h", plist_get("gearbox", rc_motor_plist)) == 9.3);
check_gearbox();
check_gearbox(plist_put("gearbox", plist_put("size", [43, 31.5, 14.75],
                                             plist_get("gearbox", rc_motor_plist)), rc_motor_plist));
check_gearbox(plist_put("gearbox", plist_put("mesh_module", 0.55,
                                             plist_get("gearbox", rc_motor_plist)), rc_motor_plist));
echo("PASS: measured gearbox envelope, motor stack and all three gear-center constraints");
