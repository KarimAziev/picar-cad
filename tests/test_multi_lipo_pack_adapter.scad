include <../scad/steering_params.scad>
use <../scad/lib/plist.scad>
use <../scad/lipo_pack_case/multi_lipo_pack_lid.scad>
use <../scad/lipo_pack_case/multi_lipo_pack_adapter.scad>

p=multi_lipo_pack_lid_props(multi_lipo_packs_case);
a=plist_get("adapter_props",p);
assert(plist_get("enabled",a));
assert(plist_get("size",a)==[55.6,55.6,4]);
assert(plist_get("holes",a)==[[-21.5,-13.975],[-21.5,13.975],[21.5,-13.975],[21.5,13.975]]);
assert(plist_get("sensor_holes",a)==[[-21.5,-21.5],[-21.5,21.5],[21.5,-21.5],[21.5,21.5]]);
assert(plist_get("bolt_l",a)==12);
assert(plist_get("nut_z",a)>=1);
assert(abs(plist_get("lidar_base_z",p)-plist_get("canonical_size",p)[2]-17)<0.000001);
assert(abs(plist_get("corner_r",p)-2.98)<0.000001);
for(r=[2.98,"5%"]) {
  lid=plist_merge(plist_get("lid",multi_lipo_packs_case),["corner_r",r]);
  assert(abs(plist_get("corner_r",multi_lipo_pack_lid_props(
    plist_merge(multi_lipo_packs_case,["lid",lid])))-2.98)<0.000001);
}
plain=plist_merge(plist_get("lid",multi_lipo_packs_case),["adapter",["enabled",false]]);
plain_props=multi_lipo_pack_lid_props(plist_merge(multi_lipo_packs_case,["lid",plain]));
assert(!plist_get("enabled",plist_get("adapter_props",plain_props)));
assert(plist_get("adapter_h",plain_props)==0);
assert(plist_get("canonical_size",plain_props)==plist_get("canonical_size",p));
assert(plist_get("lidar_base_z",plain_props)==plist_get("lidar_base_z",p));
echo("PASS: adapter patterns, nut shoulders, hardware length, sensor height and roof radius units");

no_sensor=plist_merge(plist_get("lid",multi_lipo_packs_case),["lidar",undef]);
assert(!plist_get("enabled",plist_get("adapter_props",multi_lipo_pack_lid_props(
  plist_merge(multi_lipo_packs_case,["lid",no_sensor])))));
