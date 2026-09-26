include <../scad/suspension/computed.scad>
use <../scad/suspension/rear_suspension/computed_params.scad>

rear = rear_suspension_layout();
width = suspension_chassis_width();
assert(width == front_chassis_rear_frame_w);
assert(width == plist_get("join_w", rear));
assert(width >= front_chassis_required_width());
assert(width >= plist_get("join_w", rear_suspension_layout(min_width=0)));

// A larger middle payload contributes only when that section is present.
wide_middle = plist_merge(multi_lipo_packs_case,
                           ["mount_ear_d", 10, "bolt_spacing", [400, 400]]);
assert(suspension_chassis_width(include_middle=false, middle_case=wide_middle) == width);
wide = suspension_chassis_width(include_middle=true, middle_case=wide_middle);
assert(wide == 410);
assert(plist_get("join_w", rear_suspension_layout(min_width=wide)) == wide);
assert(suspension_chassis_width(front_width=500) == 500);
echo("PASS: front/rear common width, optional middle candidate, and wider front hardware");
