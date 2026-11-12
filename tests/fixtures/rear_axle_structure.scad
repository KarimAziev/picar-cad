/**
  * Module: Rear axle structural solid and assembled clearance probes.
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../scad/rc_params.scad>
include <../../scad/suspension/rear_axle/arm_hub_params.scad>
include <../../scad/suspension/rear_axle/hardware_params.scad>
include <../../scad/suspension/rear_axle/structure_params.scad>

use <../../scad/lib/plist.scad>
use <../../scad/placeholders/hsp_rear_drivetrain.scad>
use <../../scad/placeholders/rc_touring_wheel.scad>
use <../../scad/suspension/rear_axle/rear_axle_assembly.scad>
use <../../scad/suspension/rear_axle/rear_bulkhead.scad>
use <../../scad/suspension/rear_axle/rear_hub.scad>
use <../../scad/suspension/rear_axle/rear_lower_arm.scad>
use <../../scad/suspension/rear_axle/rear_shock_tower.scad>
use <../../scad/suspension/rear_chassis/computed_params.scad>
use <../../scad/suspension/rear_chassis/rear_chassis_frame.scad>
use <../../scad/suspension/rear_suspension_assembly.scad>

part                  = "lower";
probe_wall            = 1;
probe_edge_gap        = 0.1;
probe_face_gap        = 0.25;
probe_fn              = 96;
mount_floor_probe_h   = rear_bulkhead_split_z(rear_housing_spec);
nut_floor             = plist_get("mount_nut_floor", rear_housing_spec);
nut_wall_probe_w      = 0.5;
nut_wall_probe_offset = 0.5;
layout                = rear_chassis_layout();
mounts                = rear_bulkhead_mount_positions(layout,
                                       rear_bulkhead_bolt_spacing_x,
                                       rear_bulkhead_bolt_spacing_2[1]);
assert(len(mounts) == 8,
       "Rear bulkhead requires the eight shared front mounting datums");
arm_position          = rear_axle_arm_origin(rear_housing_spec, rear_lower_arm_spec);
hub_position          = rear_axle_hub_origin(rear_housing_spec,
                                    rear_lower_arm_spec,
                                    rear_hub_spec);

module housing(which) {
  rear_bulkhead(pl=rear_housing_spec,
                differential=rear_differential_spec,
                pinion=rear_pinion_spec,
                arm=rear_lower_arm_spec,
                tower=rear_tower_spec,
                mounts=mounts,
                part=which,
                anchor=[0, 0, 1],
                slot_mode=false,
                show_hardware=false);
}

module all_housing() {
  housing("lower");
  housing("lid");
}

module arms() {
  for (side = [-1, 1]) {
    scale([side, 1, 1]) {
      rear_axle_place_arm(rear_axle_settings,
                          rear_housing_spec,
                          rear_lower_arm_spec,
                          rear_hub_spec) {
        rear_lower_arm(rear_lower_arm_spec,
                       show_pins=false,
                       show_ball_studs=false);
      }
    }
  }
}

module hubs() {
  for (side = [-1, 1]) {
    scale([side, 1, 1]) {
      translate(hub_position) {
        rear_hub(rear_hub_spec,
                 show_bearings=false,
                 show_socket_hardware=false);
      }
    }
  }
}

module assembly_hardware(which) {
  settings = plist_merge(rear_axle_settings,
                         ["show_housing", false,
                          "show_lid", false,
                          "show_arms", false,
                          "show_hubs", false,
                          "show_tower", false,
                          "show_drivetrain", false,
                          "show_bearings", false,
                          "show_shocks", which == "shocks",
                          "show_links", which == "links",
                          "show_sleeve", false,
                          "show_mount", false,
                          "show_fit_markers", false,
                          "show_fasteners", which == "fasteners"]);
  rear_axle_assembly(settings=settings,
                     housing=rear_housing_spec,
                     arm=rear_lower_arm_spec,
                     hub=rear_hub_spec,
                     tower=rear_tower_spec,
                     differential=rear_differential_spec,
                     pinion=rear_pinion_spec,
                     dogbone=rear_dogbone_spec,
                     axle=rear_wheel_axle_spec,
                     sleeve=rear_motor_sleeve_spec,
                     shock=rear_shock_spec,
                     fastener=rear_fastener_spec,
                     layout=layout);
}

module annular_land(p, d, h) {
  translate(p + [0, 0, probe_face_gap]) {
    difference() {
      cylinder(d=d + 2 * probe_wall,
               h=h - 2 * probe_face_gap,
               $fn=probe_fn);
      translate([0, 0, -probe_face_gap]) {
        cylinder(d=d + 2 * probe_edge_gap, h=h, $fn=probe_fn);
      }
    }
  }
}

module tower_lands(land=true) {
  module probe(p, d, h) {
    if (land) {
      annular_land(p, d, h);
    } else {
      translate(p - [0, 0, probe_face_gap]) {
        cylinder(d=d - 2 * probe_edge_gap,
                 h=h + 2 * probe_face_gap,
                 $fn=probe_fn);
      }
    }
  }
  t = land
      ? plist_get("thickness", rear_tower_spec)
      : rear_shock_tower_size(rear_tower_spec)[2];
  for (p = rear_shock_tower_mounts(rear_tower_spec)) {
    probe(p, plist_get("mount_bolt_d", rear_tower_spec), t);
  }
  for (i = [0:len(plist_get("shock_hole_x", rear_tower_spec)) - 1],
       p = rear_shock_tower_shocks(rear_tower_spec, i)) {
    probe([p[0], p[1], 0],
          plist_get("shock_bolt_d", rear_tower_spec),
          t);
  }
  for (side = [-1, 1]) {
    probe([plist_get("w", rear_tower_spec) / 2
           + side * plist_get("link_x", rear_tower_spec),
           plist_get("link_z", rear_tower_spec), 0],
          plist_get("link_bolt_d", rear_tower_spec),
          t);
  }
}

// Sample the crown roof above the pinion mesh opening across its axial span.
// The probe stays inside the specified wall to allow for faceted surfaces.
module crown_roof_material() {
  gear = hsp_rear_differential_gear_position(rear_differential_spec)
         - hsp_rear_differential_axis(rear_differential_spec)
         + rear_bulkhead_axis(rear_housing_spec, rear_differential_spec);
  cavity_r = plist_get("gear_d", rear_differential_spec) / 2
             + plist_get("gear_clearance", rear_housing_spec);
  wall = plist_get("crown_cover_wall", rear_housing_spec);
  span = plist_get("gear_h", rear_differential_spec);
  mesh_top = rear_bulkhead_pinion_origin(rear_housing_spec,
                                         rear_differential_spec,
                                         rear_pinion_spec)[2]
             + plist_get("gear_d", rear_pinion_spec) / 2
             + plist_get("gear_clearance", rear_housing_spec);
  roof_start = mesh_top - gear[2] + probe_face_gap;
  translate(gear) {
    intersection() {
      rotate([0, 90, 0]) {
        difference() {
          cylinder(r=cavity_r + wall - probe_face_gap,
                   h=span,
                   center=true,
                   $fn=probe_fn);
          cylinder(r=cavity_r + probe_face_gap,
                   h=span + 2 * probe_face_gap,
                   center=true,
                   $fn=probe_fn);
        }
      }
      translate([-span / 2, -cavity_r - wall, roof_start]) {
        cube([span, 2 * (cavity_r + wall), cavity_r + wall - roof_start]);
      }
    }
  }
}

if (part == "lower" || part == "lid") {
  housing(part);
} else if (part == "tower") {
  rear_shock_tower(rear_tower_spec);
} else if (part == "missing_crown_roof") {
  difference() {
    crown_roof_material();
    housing("lid");
  }
} else if (part == "split_collision") {
  intersection() {
    housing("lower");
    housing("lid");
  }
} else if (part == "housing_arm_collision") {
  intersection() {
    all_housing();
    arms();
  }
} else if (part == "arm_hub_collision") {
  intersection() {
    arms();
    hubs();
  }
} else if (part == "hub_shock_collision") {
  intersection() {
    hubs();
    assembly_hardware("shocks");
  }
} else if (part == "hub_link_collision") {
  intersection() {
    hubs();
    assembly_hardware("links");
  }
} else if (part == "fastener_housing_collision") {
  intersection() {
    all_housing();
    assembly_hardware("fasteners");
  }
} else if (part == "link_shock_collision") {
  intersection() {
    assembly_hardware("links");
    assembly_hardware("shocks");
  }
} else if (part == "missing_tower_lands") {
  difference() {
    tower_lands();
    rear_shock_tower(rear_tower_spec);
  }
} else if (part == "blocked_tower_holes") {
  intersection() {
    tower_lands(land=false);
    rear_shock_tower(rear_tower_spec);
  }
} else if (part == "missing_mount_lands") {
  difference() {
    union() {
      for (p = mounts) {
        annular_land(p,
                     plist_get("mount_bolt_d", rear_housing_spec),
                     mount_floor_probe_h);
      }
    }
    housing("lower");
  }
} else if (part == "missing_nut_walls") {
  difference() {
    union() {
      for (p = rear_bulkhead_fastener_positions(rear_housing_spec, mounts),
           side = [-1, 1]) {
        translate(p + [-nut_wall_probe_w / 2,
                       side * (plist_get("mount_nut_af", rear_housing_spec) / 2
                               + nut_wall_probe_offset)
                       - nut_wall_probe_w / 2,
                       nut_floor + probe_face_gap]) {
          cube([nut_wall_probe_w, nut_wall_probe_w,
                plist_get("mount_nut_h", rear_housing_spec)
                - 2 * probe_face_gap]);
        }
      }
    }
    housing("lid");
  }
} else if (part == "blocked_nut_insertion") {
  intersection() {
    union() {
      for (p = rear_bulkhead_fastener_positions(rear_housing_spec, mounts)) {
        translate(p + [0, 0, nut_floor + probe_face_gap]) {
          cylinder(d=(plist_get("mount_nut_af", rear_housing_spec)
                      - 2 * probe_edge_gap) / cos(30),
                   h=rear_bulkhead_size(rear_housing_spec, rear_differential_spec,
                                        rear_pinion_spec, rear_tower_spec)[2],
                   $fn=6);
        }
      }
    }
    housing("lid");
  }
} else if (part != "chassis_axle_collision"
           && part != "wheel_shaft_collision" && part != "wheel_hub_collision") {
  assert(false, str("Unknown rear axle structural fixture: ", part));
}

// Intersections in the assembled reference pose, including the existing deck.
if (part == "chassis_axle_collision") {
  intersection() {
    rear_chassis_frame(layout=layout,
                       anchor=undef,
                       slot_mode=false,
                       show_rear_suspension_mount=true,
                       rear_suspension_joint_spacing=0,
                       front_joint=split_rear_chassis,
                       suspension_joint=split_rear_suspension,
                       debug=false);
    translate(rear_suspension_chassis_datum(layout, suspension_chassis_mount_h, 0)) {
      rotate([0, 0, 180]) {
        all_housing();
        arms();
        hubs();
      }
    }
  }
}
if (part == "wheel_shaft_collision" || part == "wheel_hub_collision") {
  intersection() {
    translate(rear_suspension_wheel_origin(rear_housing_spec, rear_lower_arm_spec,
                                           rear_hub_spec, rear_wheel_axle_spec,
                                           rc_wheel_plist)) {
      rotate([0, 90, 0]) {
        rc_touring_wheel(pl=rc_wheel_plist,
                         anchor=[0, 0, 1],
                         show_tire=true,
                         slot_mode=false,
                         clearance=0);
      }
    }
    if (part == "wheel_hub_collision") {
      arms();
      hubs();
    } else {
      translate(rear_axle_wheel_shaft_origin(rear_housing_spec, rear_lower_arm_spec,
                                             rear_hub_spec, rear_wheel_axle_spec)) {
        rotate([0, 90, 0]) {
          hsp_rear_wheel_axle(pl=rear_wheel_axle_spec,
                              anchor=[0, 0, 1],
                              slot_mode=false,
                              show_bearings=true,
                              show_hex=true);
        }
      }
    }
  }
}
