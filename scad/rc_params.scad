include <colors.scad>
include <parameters.scad>

use <lipo_pack_case/multi_lipo_pack_case.scad>

// ─────────────────────────────────────────────────────────────────────────────
// Bellcrank link arm. Part of both the drive and idler arms.
// It has two bolt holes:
// - For the center link. This hole has both upper and lower bosses.
//   The lower boss is for the center link bushing.
// - For the knuckle steering link, with an upper boss only.
// ─────────────────────────────────────────────────────────────────────────────

chassis_bolt_d                                     = m3_hole_dia;
chassis_countersunk_bore_d                         = 6.2;
chassis_countersunk_bore_h                         = min(m3_countersunk_head_h + 0.2,
                                                         chassis_thickness / 2);

// Diameter of the bolt holes in the bellcrank idler and bellcrank drive arms
bellcrank_arm_bolt_d                               = 3.6;

// Height of the heat-set insert nut
bellcrank_arm_heat_insert_nut_h                    = 5.2;

// Diameter of the cylindrical recess around the bolt holes for the heat-set insert nut
bellcrank_arm_bolt_bore_d                          = 4.4;

// Depth of the cylindrical recess around the bolt hole for the heat-set insert nut
bellcrank_arm_bolt_bore_h                          = 1.5;

// Total length of the arm, measured from the center of the bellcrank
bellcrank_arm_l                                    = 25.45;

// Thickness of the arm
bellcrank_arm_thickness                            = bellcrank_arm_heat_insert_nut_h + 1.8;

// Width at the outer/tip end
bellcrank_arm_tip_w                                = 6.10;

// Width at the cylinder/pivot end
bellcrank_arm_root_w                               = 9.10;

// Height of the lower boss
bellcrank_arm_lower_boss_h                         = 2.4;

// Outer diameter of the lower boss
bellcrank_arm_lower_boss_d                         = 7.0;

// Distance from the edge of the arm to the start of the hole
bellcrank_arm_bolt_edge_offset                     = 2;

// Distance between hole centers
bellcrank_arm_bolt_spacing                         = 9.5;

// Distance from the bottom of the pivot base to the bellcrank arm root
bellcrank_arm_z                                    = 12.1;

// ─────────────────────────────────────────────────────────────────────────────
// Bellcrank idler (shared with the bellcrank drive)
// ─────────────────────────────────────────────────────────────────────────────

// Outer diameter of the bearing
bellcrank_idler_bearing_od                         = 8;
// Inner (bore) diameter of the bearing
bellcrank_idler_bearing_d                          = 5;

// Width of the bearing
bellcrank_idler_bearing_w                          = 2.5;

bellcrank_idler_bearing_outer_recess_d             = 7;

bellcrank_idler_bearing_shoulder_d                 = 6.5;

// The clearance for the bearing diameter
bellcrank_bearing_clearance                        = 0.2;

// The clearance for the bellcrank post's hole
bellcrank_post_hole_clearance                      = 0.5;

// The outer diameter of the bellcrank cylinder
bellcrank_idler_od                                 = bellcrank_idler_bearing_od + 4.5;

bellcrank_idler_extra_h                            = 0.8;

bellcrank_idler_support_thickness                  = 2;

// The addional height of the bellcrank for the upper's bearing chamfer
bellcrank_idler_chamfer_h                          = 0.0;

bellcrank_idler_chamfer_angle                      = 30;

// ─────────────────────────────────────────────────────────────────────────────
// Bellcrank lever (used both in bellcrank drive and idler)
// ─────────────────────────────────────────────────────────────────────────────
bellcrank_lever_border_w                           = 1.5;

// If true, the lever's outer end will be wider and smoothly "hulled"
bellcrank_lever_use_hull                           = false;

// Whether to add a hole in the lever for a screw to secure it to the bellcrank thread
bellcrank_lever_add_through_hole                   = true;

// Diameter of the hole in the lever for a screw to secure it to the bellcrank thread
bellcrank_lever_through_hole_d                     = 1.4;

// ─────────────────────────────────────────────────────────────────────────────
// Pivot bush
// The pivot bush is a cylindrical shaft that is inserted into the bellcrank
// cylinder. Two bearings are placed on the bush-one at the top and one at the
// bottom. The bush has a through-hole for a bolt, and at the bottom it has a
// wider, thin cylinder (shoulder) to prevent the bottom bearing from sliding out.
// ─────────────────────────────────────────────────────────────────────────────

// The height of the pivot bush where the top and bottom bearings are inserted
bellcrank_post_h                                   = 32.55;

// The outer diameter of the pivot bush
bellcrank_post_od                                  = bellcrank_idler_bearing_d - 0.1;

// The hole diameter for the bolt
bellcrank_post_bolt_d                              = 3.1;

// The diameter of the bottom flange (shoulder)
bellcrank_post_flang_d                             = bellcrank_idler_bearing_d + 1.2;

// The height of the bottom flange (shoulder)
bellcrank_post_flang_h                             = 1.0;

// The depth of the bolt hole at the bottom
bellcrank_post_lower_hole_depth                    = 12.0;

// The depth of the bolt hole at the top
bellcrank_post_upper_hole_depth                    = 12.0;

// Whether to use threads for the bolt hole
bellcrank_post_use_threading                       = false;

// ─────────────────────────────────────────────────────────────────────────────
// Bellcrank drive (servo lever parameters)
// ─────────────────────────────────────────────────────────────────────────────

// Distance between the lower bellcrank lever and the upper servo lever
bellcrank_servo_lever_z_offset                     = 2.6;
// Distance between the edges of the holes in the servo lever
bellcrank_servo_lever_holes_gap                    = 1.5;
// Distance between the edge of the lever and the edge of the holes
bellcrank_servo_lever_holes_edge_offset            = 1.2;
// Height of the upper boss
bellcrank_servo_lever_boss_h                       = 3.5;
// Number of mounting holes for the servo tie-rod end
bellcrank_servo_lever_holes_n                      = 3;
// Padding between the center pivot cylinder and the servo lever holes
bellcrank_servo_lever_boss_pad_x                   = 2;

// Total length of the arm starting from the center of bellcrank
bellcrank_servo_lever_l                            = 25.45;

bellcrank_servo_lever_thickness                    = 4;

// ─────────────────────────────────────────────────────────────────────────────
// Bellcrank positioning on the chassis
// ─────────────────────────────────────────────────────────────────────────────

// The distance from the end of the bulkhead housing to the center of the
// bellcrank drive/idler holes
bellcrank_y_distance_from_bulkhead                 = 27.5;

// Spacing between the centers of the bellcrank drive and bellcrank idler holes
chassis_bellcrank_spacing                          = 48.8;

// ─────────────────────────────────────────────────────────────────────────────
// Steering servo DSSERVO
// ─────────────────────────────────────────────────────────────────────────────

dsservo_size                                       = [40.00, 20.0, 40.5];
dsservo_bolt_dia                                   = 4.05;

dsservo_bolt_spacing                               = [49.5, 10];

// offset between the servo slot and the fastening bolts
dsservo_bolts_offset                               = 3.2;

dsservo_flange_w                                   = 54.5;

dsservo_flange_h                                   = 18.63;
dsservo_flange_thickness                           = 4.0;
dsservo_flange_z_offset                            = 12.8;
dsservo_gearbox_x_offset                           = 0;
dsservo_gearbox_mode                               = "union";
dsservo_text                                       = [["20KG", "size", 9,
                                                       "color", "white"],
                                                      ["__________________________",
                                                       "size", 2,
                                                       "halign", "center",
                                                       "gap_before", 1,
                                                       "color", "white"],
                                                      ["DSSERVO",
                                                       "translation", [2, 0, 0],
                                                       "gap_before", 2,
                                                       "halign", "left",
                                                       "color", "white",
                                                       "size", 2,],
                                                      ["(S) DIGITAL SERVO",
                                                       "size", 2,
                                                       "translation", [2, 0, 0],
                                                       "gap_before", 1,
                                                       "halign", "left",
                                                       "color", "white"]];
dsservo_text_size                                  = 2;
dsservo_text_plist                                 = ["font", "Lucida Grande:style=Bold",
                                                      "text_both_sides", true,
                                                      "background", ["color", pink_1,
                                                                     "pad_left", -0.1,
                                                                     "pad_right", -0.1,]];

dsservo_gearbox_h                                  = 0;
dsservo_gearbox_size                               = [[1, 12.95, matte_black, 20],
                                                      [3.9, 5.9, metallic_gold_2, 25],
                                                      [0.05, 4.2, dark_gold_2, 25],
                                                      [0.05, 2.8, licorice, 25]];
dsservo_gearbox_d1                                 = 12.95 + 3.8;

dsservo_gearbox_d2                                 = 6;
dsservo_color                                      = jet_black;
dsservo_cut_len                                    = 0;
dsservo_cut_len_top                                = 7.7;
dsservo_cut_top_depth                              = 3.0;

dsservo_socket_size                                = [5.3, 6.3, 3.4];
dsservo_socket_z_offset                            = 3.0;
dsservo_socket_side                                = -1;

// ─────────────────────────────────────────────────────────────────────────────
// Bulkhead slots
// ─────────────────────────────────────────────────────────────────────────────
// The upper spacing above the bulkhead slots
front_chassis_bulkhead_padding_y                   = 4;

// The x-padding for the bulkhead slots
front_chassis_bulkhead_padding_x                   = 12.8;

// ─────────────────────────────────────────────────────────────────────────────
// Bellcrank slots
// ─────────────────────────────────────────────────────────────────────────────
front_chassis_bellcrank_bolt_d                     = m3_hole_dia;
front_chassis_bellcrank_bolt_bore_d                = m3_countersunk_head_dia + 0.2;
front_chassis_bellcrank_bolt_bore_h                = m3_countersunk_head_h + 0.15;

// The hole for easier access to the bellcrank (e.g., for fastening the steering arm)
front_chassis_bellcrank_tool_access_hole_d         = 8;

// The x-padding of the access hole
front_chassis_bellcrank_tool_access_hole_pad_x     = 1.5;

// ─────────────────────────────────────────────────────────────────────────────
// Front chassis ears above the bulkhead slots
// ─────────────────────────────────────────────────────────────────────────────
// Width of the ear
front_chassis_ear_w                                = 6.3;

// Additional width near the chassis for a smoother shape
front_chassis_ear_extra_w                          = 0.8;

// Outer X-length of the ear
front_chassis_ear_l                                = 5.1;

// ─────────────────────────────────────────────────────────────────────────────
// Bumper slot
// ─────────────────────────────────────────────────────────────────────────────
front_bumper_bolt_d                                = m3_hole_dia;
front_bumper_bolt_spacing_x                        = 38.0;
front_bumper_bolt_pad_x                            = 4.4;
front_bumper_center_bolt_y_offset                  = 7;
front_bumper_bolt_pad_y                            = 4;
front_bumper_bolt_y_offset                         = 11.4;

// ─────────────────────────────────────────────────────────────────────────────
// Front chasssis joint
// ─────────────────────────────────────────────────────────────────────────────
front_chassis_joint_rail_angle                     = 20;
front_chassis_joint_rail_corner_r                  = 0.4;
front_chassis_joint_bolt_d                         = 3;
front_chassis_joint_bolt_pad                       = 2;
// Keep the wide rail clear of tangent bolt cutters, including binary STL export.
front_chassis_joint_rail_bolt_clearance            = 0.05;
front_chassis_joint_bolt_spacing                   = 42.8;
front_chassis_joint_use_dovetail_rib               = true;

front_chassis_joint_pin_l                          = 41.0;
front_chassis_joint_pin_d                          = 3.1;
front_chassis_joint_pin_pad_l                      = 5.5;
front_chassis_joint_pin_pad_w                      = 2.5;

front_chassis_joint_clearance                      = 0.4;
front_chassis_joint_boolean_overlap                = 0.02;

// ─────────────────────────────────────────────────────────────────────────────
// Head mount on the front chassis
// ─────────────────────────────────────────────────────────────────────────────
// Suspension chassis cable passages; placement derives from component datums.
// Preserve the proven head-side ribbon threading bank, not a single cable exit.
front_chassis_head_ribbon_slot_rows                = 3;
front_chassis_head_ribbon_slot_w                   = 20;
front_chassis_head_ribbon_slot_l                   = 3;
front_chassis_head_ribbon_slot_gap                 = 3;
front_chassis_ribbon_slot_corner_r                 = 0.6;
front_chassis_head_side_slot_w                     = 7.5;
front_chassis_head_side_slot_l                     = 11.0;
front_chassis_head_side_slot_rows                  = 2;

// Pan-servo mounting interface retained from the proven head mount.
front_chassis_head_pan_servo_slot_dia              = 6.5;
front_chassis_head_pan_servo_slot_recess           = constraint(2.0,
                                                                0,
                                                                chassis_thickness - 1);
front_chassis_head_pan_servo_top_ribbon_cutout_len = 18;
front_chassis_head_pan_servo_top_ribbon_cutout_h   = 2;
front_chassis_head_pan_servo_recess_y_len          = 14;
front_chassis_head_pan_servo_recess_x_len          = 16;
front_chassis_head_pan_servo_recess_thickness      = 5;
front_chassis_head_pan_servo_screw_d               = 1.5;
front_chassis_head_pan_servo_screws_gap            = 0.5;

front_chassis_head_mount_padding                   = 2.0;
front_chassis_head_wire_land                       = 3.0;

// Two of the four available 23.8 x 3 mm pins reinforce the removable head.
front_chassis_head_joint_pin_l                     = 23.8;
front_chassis_head_joint_pin_d                     = 3.1;
front_chassis_head_joint_pin_spacing               = 33;
front_chassis_head_joint_rail_w                    = 40;

// ─────────────────────────────────────────────────────────────────────────────
// Middle chassis
// ─────────────────────────────────────────────────────────────────────────────
middle_chassis_mount_land                          = 3.0;

suspension_chassis_joint_wide_bolt_cols            = 5;

// ─────────────────────────────────────────────────────────────────────────────
// Front suspension arm pad (geometry parameters)
//
// The pad surrounds the hinge-pin holes and provides a center hook that locks
// the hinge pins in place.
// ─────────────────────────────────────────────────────────────────────────────

// Radial padding around each hinge-pin hole (added to the hole radius)
front_suspension_arm_pad_pin_hole_pad_r            = 2.6;

// Overall pad thickness (Z)
front_suspension_arm_pad_thickness                 = 2.5;

// Pad length along the Y axis (up to the start of the center hook)
front_suspension_arm_pad_len_y                     = 4.6;

// ─────────────────────────────────────────────────────────────────────────────
// Knuckle's and wishbone arm's ball stud
// ─────────────────────────────────────────────────────────────────────────────
// The ball stud is a critical component that connects the suspension arms to
// the knuckle. It consists of a threaded shank that screws into the arm, and a
// ball end that fits into the knuckle's ball stud housing. The dimensions of
// the ball stud are important for ensuring proper fit and function of the
// suspension system.
// ─────────────────────────────────────────────────────────────────────────────
// Diameter of the threaded shank that screws into the arm.
front_arm_ball_stud_shank_d                        = 4.8;
// Diameter of the ball end that fits into the knuckle's ball stud housing. This
// should be slightly smaller than the hole diameter in the knuckle for a proper
// fit.
front_arm_ball_stud_ball_d                         = 8.8;
// The diameter of the hole at the head of the ball stud, which is used for securing
front_arm_ball_stud_ball_hole_d                    = 3.3;

// The total length of the shank that screws into the arm. The threaded length
// is front_arm_ball_stud_len - front_arm_ball_stud_unthreaded_h
front_arm_ball_stud_len                            = 17.8;
// The length of the unthreaded portion of the shank near the ball end. This
// part is not threaded and provides a smooth surface for the ball to sit
// against.
front_arm_ball_stud_unthreaded_h                   = 5;

front_arm_heat_insert_nut_hole_d                   = 5.0;

// ─────────────────────────────────────────────────────────────────────────────
// Front lower wishbone arm
// ─────────────────────────────────────────────────────────────────────────────

// Overall length of the lower arm (X direction), from hinge end to ball-stud end.
front_lower_arm_len                                = 48.8;

// Overall height/envelope of the arm profile (Y direction).
front_lower_arm_h                                  = 39.25;

// Main body thickness of the arm (Z direction) for the extruded profile.
front_lower_arm_thickness                          = 7.5;

// Width of the apex/bridge region near the ball-stud end used in profile shaping/cutouts.
front_lower_arm_apex_width                         = 9.1;

// Nominal width of each “leg” of the A-arm in the 2D profile.
front_lower_arm_leg_width                          = 4.0;

// Outer fillet radius applied to the arm outline (rounded outer edges).
front_lower_arm_corner_r                           = 1.5;

// Length of a hinge barrel (one of the cylindrical hinge lugs) along X.
front_lower_arm_hinge_barrel_len                   = 10.3;

// Height envelope of the upper hinge barrel feature (used by the 2D barrel sketch).
front_lower_arm_upper_hinge_barrel_h               = 7.85;

// Height envelope of the lower hinge barrel feature (used by the 2D barrel sketch).
front_lower_arm_lower_hinge_barrel_h               = 6.6;

// Diameter of the hinge pin hole through each hinge barrel.
front_lower_arm_hinge_barrel_hole_d                = 3.4;

// Offset from the barrel’s left edge to the hinge hole edge (sets hole position).
front_lower_arm_hinge_barrel_hole_offset           = 1.7;

// Height (projection) of the damper mounting boss.
front_lower_arm_damper_boss_h                      = 8.2;

// Diameter of the damper mounting boss (outer).
front_lower_arm_damper_boss_d                      = 5.6;

// Diameter of the through-hole in the damper boss for the damper fastener.
front_lower_arm_damper_boss_hole_d                 = 3;

// Corner radius used for the inner profile hole.
front_lower_arm_relief_hole_corner_r               = 2;

// X-offset used when positioning the damper boss relative to the arm end.
front_lower_arm_upper_boss_x_offset                = 5.9;

// Y-offset used when positioning the damper boss / upper cutout reference.
front_lower_arm_upper_boss_y_offset                = 3.7;

// Size of the ball-stud/rod-end mounting block: [length(X), width(Y), thickness(Z)]
front_lower_arm_ball_stud_mount_size               = [14, 6.5, 7.5];

// If printing is difficult, you can disable the cutout on the outer bottom edge
// and print it on that edge.
front_lower_arm_use_lower_edge_cutout              = true;

// The depth of the hole for the ball stud
front_lower_arm_ball_stud_hole_depth               = front_arm_ball_stud_len
                                                      - front_arm_ball_stud_unthreaded_h;

// How far to screw out the ball stud. A higher value means the bolt is screwed in less
front_lower_arm_ball_stud_insert_out_depth         = 1;

front_lower_arm_pin_l                              = front_lower_arm_h + front_suspension_arm_pad_thickness + 1.4;

front_lower_arm_pin_groove_offset                  = 0.85;

front_lower_arm_y_offset                           = 0.0;

// ─────────────────────────────────────────────────────────────────────────────
// Upper front wishbone arm
// ─────────────────────────────────────────────────────────────────────────────

// Overall length of the upper arm (X direction), from hinge end to ball-stud end.
front_upper_arm_len                                = 41.8;

// Overall height/envelope of the arm profile (Y direction) excluding
// upper_arm_ball_stud_mount_extra_h
front_upper_arm_h                                  = 24;

// Rounding radius of the hole on the arm
front_upper_arm_hole_corner_r                      = 2.5;

// Outer fillet radius applied to the arm outline (rounded outer edges).
front_upper_arm_corner_r                           = 0.5;

// Main body thickness of the arm (Z direction) for the extruded profile.
front_upper_arm_thickness                          = 6.5;

// Length of a hinge barrel (one of the cylindrical hinge lugs) along X.
front_upper_arm_hinge_barrel_len                   = 9;

// Height envelope of the hinge barrel feature (used by the 2D barrel sketch).
front_upper_arm_hinge_barrel_h                     = 6.9;

// Diameter of the hinge pin hole through each hinge barrel.
front_upper_arm_hinge_barrel_hole_d                = 3.6;

// Offset from the barrel’s left edge to the hinge hole center (sets hole position).
front_upper_arm_hinge_barrel_hole_offset           = 1.7;

// Size of the ball-stud/rod-end mounting block: [length(X), width(Y), thickness(Z)]
front_upper_arm_ball_stud_mount_size               = [15.19, 9.5, front_upper_arm_thickness + 1.5];

// the addional height for ball stud
front_upper_arm_ball_stud_mount_extra_h            = front_upper_arm_ball_stud_mount_size[1] / 2;

// Nominal width of each “leg” of the A-arm in the 2D profile.
front_upper_arm_leg_width                          = 4.5;

// The depth of the hole for the ball stud
front_upper_arm_ball_stud_hole_depth               = front_arm_ball_stud_len - front_arm_ball_stud_unthreaded_h;

// How far to screw out the ball stud. A higher value means the bolt is screwed in less
front_upper_arm_ball_stud_insert_out_depth         = 1;

// The length of the pin which inserted into arm hinges
front_upper_arm_pin_len                            = 39.5;

front_upper_arm_y_offset                           = -0.0;

// ─────────────────────────────────────────────────────────────────────────────
// Front bulkhead and it's housing
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// Front bulkhead housing and shared parameters for the bulkhead
//
// Bulkhead housing is the lower removable part of the front bulkhead. It has an
// elongated rectangular shape, with cylindrical “barrels” on the sides into
// which the suspension arm pins are inserted, allowing the arms to move. Each
// cylindrical “barrel” has a cutout in the center shaped like a semicircle.
// `front_bulkhead_hinge_cutout_bolt_offset` controls the lateral offset of this
// circle, and `front_bulkhead_hinge_cutout_d_factor` controls the diameter of
// this cutout relative to the overall length of these barrels. The allowed
// value is from 0 to 1: 0 removes the cutout completely, and 1 makes it as
// large as possible. The barrels on the bulkhead housing also have 4 holes
// each: 2 for mounting to the chassis and 2 for mounting the bulkhead itself.
// In addition, there is an extra hole at the rear center of the housing that
// can be used for a more secure attachment.
// ─────────────────────────────────────────────────────────────────────────────

// The base width of the bulkhead housing. It doesn't include the length of the
// ear hinge protrusion, so the total width at the hinge area will be larger.
front_bulkhead_w                                   = 25.9;

// The overall length of the bulkhead housing along the Y-axis,
front_bulkhead_len                                 = 39.5;

// Additional rear length for the upper steering plate
front_bulkhead_extra_len                           = 4.7;

// The thickness of the bulkhead housing and barrel hinges (Z-axis extrusion height)
front_bulkhead_housing_h                           = 7.9;

// The distance from the front face of the bulkhead to the protective barrel
// around the hinge pin holes. This sets how far the hinge pin holes are
// recessed from the front face.
front_bulkhead_barrel_y_offset                     = 8.40;

// The diameter of the hinge barrel (the cylindrical protrusion that surrounds the hinge pin hole and provides reinforcement).
front_bulkhead_barrel_hinge_w                      = 13.15;

// The distance from the edge of the hinge barrel to the edge of the hinge pin
// hole (sets the position of the hole within the barrel).
front_bulkhead_barrel_pin_hole_offset              = 2.5;

// Clearance between the outer diameter of the hinge barrel and the hole diameter for the hinge pin.
front_bulkhead_barrel_hinge_clearance              = 1.0;

// The diameter of the hole for the rear bolt on the bulkhead housing, which can be used for a more secure attachment to the chassis.
front_bulkhead_rear_bolt_d                         = m3_hole_dia;

// The diameter of the counterbore for the rear bolt head / washer pocket.
front_bulkhead_rear_bolt_cbore_d                   = 6.10;

// The depth of the counterbore for the rear bolt head / washer pocket.
front_bulkhead_rear_bolt_offset                    = 2.20;

// ─────────────────────────────────────────────────────────────────────────────
// Bulkhead bolt spacing
// The bulkhead housing has 4 rows, each with 2 bolt holes (8 holes total):
// two rows for fastening to the chassis, and two rows for fastening the
// bulkhead to the housing.
// ─────────────────────────────────────────────────────────────────────────────

// Distance between hole centers along the X-axis
front_bulkhead_mount_bolt_spacing_x                = 34.0;

// [X spacing, outer Y spacing - first and fourth rows]
front_bulkhead_mount_bolt_spacing_1                = [front_bulkhead_mount_bolt_spacing_x, 18.45];

// [X spacing, inner Y spacing - second and third rows]
front_bulkhead_mount_bolt_spacing_2                = [front_bulkhead_mount_bolt_spacing_x, 5.5];

// Distance from the upper row of the outer group
// (`front_bulkhead_mount_bolt_spacing_1`) to the upper row of the inner group
// (`front_bulkhead_mount_bolt_spacing_2`)
front_bulkhead_mount_bolt_padding                  = 4.6;

// Diameter of the holes used to mount the bulkhead housing to the chassis
// and the bulkhead itself.
front_bulkhead_mount_bolt_d                        = m3_hole_dia;

front_bulkhead_mount_bolt_bore_d                   = m3_countersunk_head_dia + 0.2;
front_bulkhead_mount_bolt_bore_h                   = m3_countersunk_head_h + 0.15;

front_bulkhead_mount_hinge_pad_x                   = 2;
front_bulkhead_mount_hinge_pad_y                   = 1.5;

// Lateral offset of the semicircular cutout in the hinge barrel in mm
front_bulkhead_hinge_cutout_bolt_offset            = 1;

// Diameter of the semicircular cutout in the hinge barrel, expressed as a
// factor of the overall barrel length. Allowed values: 0 to 1.
front_bulkhead_hinge_cutout_d_factor               = 1;  // [0:0.1:1]

// ─────────────────────────────────────────────────────────────────────────────
// Front bulkhead shock tower
// ─────────────────────────────────────────────────────────────────────────────
// Shock tower mounting tab thickness (Z height after extrusion)
front_bulkhead_shock_tower_mount_thickness         = 5.1;
// X-axis padding around the shock tower bolt pattern on the mounting tab
front_bulkhead_shock_tower_mount_pad_x             = 2.7;
// Extra material above the bolt pattern (positive Y direction)
front_bulkhead_shock_tower_mount_pad_y_top         = 2;

// Fillet radius for the shock tower mounting tab corners
front_bulkhead_shock_tower_mount_corner_r          = 1.5;

// Vertical offset (Z) from the bulkhead base to the lower shock-tower bolt line
front_bulkhead_shock_tower_mount_offset            = 19.5;

// Mounting hinge thickness (extrusion height)
front_bulkhead_hinge_thickness                     = 3;

// Extra length added to the cylindrical support for the front upper suspension holder
front_bulkhead_support_extra_len                   = 4;

// ─────────────────────────────────────────────────────────────────────────────
// Front bulkhead suspension arm pad recess and retainer walls
// ─────────────────────────────────────────────────────────────────────────────
// Thickness of the bulkhead “retainer walls” around the suspension arm pad recess.
// The pad sits in a bottom recess to prevent hinge pins from sliding out.
front_bulkhead_suspension_pad_thickness            = 2;
// Clearance added around the suspension arm pad recess for easy insertion
front_bulkhead_suspension_pad_clearance            = 0.6;

// Depth of the upper suspension holder mounting holes into the bulkhead
front_bulkhead_upper_holder_hole_depth             = 14;

// The spacing between the holes for the arm hinges
front_bulkhead_pin_spacing                         = 55.8;

// ─────────────────────────────────────────────────────────────────────────────
// Center hook parameters
// The hook is part of the bottom recess and keeps hinge pins from backing out.
// ─────────────────────────────────────────────────────────────────────────────

// Lower chamfer/fillet size at the hook corners (in the 2D profile)
front_suspension_arm_pad_hook_lower_corner_r       = 1;

// Upper chamfer/fillet size at the hook corners (in the 2D profile)
front_suspension_arm_pad_hook_upper_corner_r       = 1;

// Hook height (extends in +Y from the pad end)
front_suspension_arm_pad_hook_len_y                = 4.8;

// Hook width (X)
front_suspension_arm_pad_hook_w                    = 5.2;

// ─────────────────────────────────────────────────────────────────────────────
// Front Shock Tower
// ─────────────────────────────────────────────────────────────────────────────

// The overall height of the tower on the Y-axis
front_shock_tower_h                                = 28.9;

// Overall corner radius of the shape
front_shock_tower_corner_r                         = 4;

// Corner radius for the rectangular cutout
front_shock_tower_cutout_corner_r                  = 0.5;

// Corner radius for the lower mount panel with bolt holes
front_shock_tower_mount_corner_r                   = 2;

// The overall thickness of the shock tower
front_shock_tower_thickness                        = 6.0;

// The thickness of the thinner part near the cutout, with bottom mounting holes
front_shock_tower_lower_thickness                  = 2.7;

// The diameter of the holes for mounting to the bulkhead
front_shock_tower_bolt_d                           = m3_hole_dia;

// Bolt spacing for mounting to the bulkhead
front_shock_tower_bolt_spacing                     = [33.3, 9.6];

// The diameter of the holes for mounting the damper
front_shock_tower_shock_damper_bolt_d              = m3_hole_dia;

// The X spacing for the damper holes closest to the center.
// Other holes will be placed at an angle relative to these holes.
front_shock_tower_damper_spacing_x                 = 45;

// The angle of the "ears" that hold the damper holes
front_shock_tower_damper_holes_angle               = 150;

// Gap between mounting holes for the damper
front_shock_tower_damper_holes_gap                 = 1.7;

// X-padding around the damper holes
front_shock_tower_damper_holes_pad_x               = 1.8;

// Y-padding around the damper holes
front_shock_tower_damper_holes_pad_y               = 1.8;

// The number of damper holes
front_shock_tower_damper_holes_amount              = 3;

// The vertical offset of the holes for the arm hinges
front_shock_tower_pin_y_offset                     = 3;

// Padding for the "ears" that hold the arm-hinge holes
front_shock_tower_pin_hole_pad                     = 1;

// ─────────────────────────────────────────────────────────────────────────────
// Front Upper suspension holder
// ─────────────────────────────────────────────────────────────────────────────

// Overall length of the holder body (derived from bulkhead pin spacing plus a fixed margin)
front_upper_suspension_holder_l                    = front_bulkhead_pin_spacing + 7.7;

// Overall width of the holder body
front_upper_suspension_w                           = 5.7;

// Base extrusion thickness of the holder
front_upper_suspension_holder_thickness            = 4.5;

// Diameter of the circular relief cutout on the underside
front_upper_suspension_holder_round_cutout_d       = 14.0;

// Y-offset of the circular relief cutout center; increasing this shifts it further away and reduces overlap
front_upper_suspension_holder_round_cutout_offset  = 1.5;

// Width of the central rectangular cutout (on the side opposite the round cutout)
front_upper_suspension_holder_rect_cutout_w        = 30;

// Through-hole diameter for the mounting bolts (M3 clearance for heat insert nut)
front_upper_suspension_holder_bolt_d               = 3.7;

// Counterbore diameter for the bolt head / washer pocket
front_upper_suspension_holder_bolt_bore_d          = m3_hole_dia * 2 + 0.1;

front_bulkhead_counterbore_d                       = 4.65;
front_bulkhead_counterbore_h                       = 2.4;

// Center-to-center spacing of the mounting bolts
front_upper_suspension_holder_bolt_spacing         = 14.3;

// Counterbore depth (pocket height), measured from the top face
front_upper_suspension_holder_bolt_bore_h          = front_upper_suspension_holder_thickness / 2;

// Extra material/padding added below the bolt area (extends the mounting "tab" beyond the holes)
front_upper_suspension_holder_bolt_pad             = 2;

// Y-offset of the bolt counterbore centerline relative to the main body (from the rectangular cutout side)
front_upper_suspension_holder_bolt_y_offset        = 0.5;

// Outer diameter of the pin barrel (reinforcement ring) around the arm hinge pin hole
front_upper_suspension_holder_pin_barrel_d         = front_upper_arm_hinge_barrel_hole_d + 4.1;

// Height of the pin barrel (reinforcement ring) extrusion
front_upper_suspension_holder_pin_barrel_h         = 6.6;

front_upper_suspension_holder_grab_screw_d         = 3.1;

// ─────────────────────────────────────────────────────────────────────────────
// Knuckle
// ─────────────────────────────────────────────────────────────────────────────
// Independent suspension knuckle base; preserves the previous 14.15 mm default.
knuckle_base_d                                     = 14.15;

knuckle_total_len                                  = 42.7;

// ─────────────────────────────────────────────────────────────────────────────
// Knuckle's steering arm and it's outer ring
// ─────────────────────────────────────────────────────────────────────────────

knuckle_outer_wall_thickness                       = 1.7;

// ─────────────────────────────────────────────────────────────────────────────
// Knuckle's bearings
// ─────────────────────────────────────────────────────────────────────────────
// Knuckle uses two bearings: inner (bigger) and outer (smaller)

// ─────────────────────────────────────────────────────────────────────────────
// Inner (bigger) bearing
// ─────────────────────────────────────────────────────────────────────────────
// outer diameter
knuckle_inner_bearing_od                           = 15;
// hole diameter
knuckle_inner_bearing_bore_d                       = 10;
// width of the bearing
knuckle_inner_bearing_w                            = 4;

// Clearance between the bearing OD and the knuckle bearing seat diameter.
knuckle_inner_bearing_clearance                    = 0.1;

// The actual hole diameter in the knuckle for the bearing
knuckle_inner_bearing_seat_d                       = 15.1;
knuckle_inner_bearing_shoulder_d                   = 13;

// ─────────────────────────────────────────────────────────────────────────────
// Outer (smaller) bearing
// ─────────────────────────────────────────────────────────────────────────────

// outer diameter
knuckle_outer_bearing_od                           = 10;
// hole diameter
knuckle_outer_bearing_bore_d                       = 5;
// width of the bearing
knuckle_outer_bearing_w                            = 4;

// Clearance between the bearing OD and the knuckle bearing seat diameter.
knuckle_outer_bearing_clearance                    = 0.1;
// Clearance between the bearing width and the knuckle bearing seat depth
knuckle_outer_bearing_z_clearance                  = 0.1;

knuckle_bearing_spacer_h                           = 1.6;
knuckle_bearing_spacer_ring_d                      = 8;
// ─────────────────────────────────────────────────────────────────────────────
// Knuckle's steering arm mount with its ring
// ─────────────────────────────────────────────────────────────────────────────

// Thickness of the steering arm mount (Z direction for extrusion)
knuckle_arm_thickness                              = 4.2;

// The chamfer/fillet radius for the corners of the arm ears
knuckle_arm_corner_r                               = 3.02;

// Diameter of the hole for the bolt that secures the steering arm to the tie rod
knuckle_arm_bolt_d                                 = m3_hole_dia;

// Distance from the edge of the steering arm mount to the edge of the bolt hole
knuckle_arm_bolt_hole_offset                       = 2.0;

// The outer diameter of the ring that reinforces the steering arm mount in the knuckle
knuckle_arm_ring_outer_d                           = knuckle_inner_bearing_seat_d
                                                      + knuckle_outer_wall_thickness * 2;
// The width of the arm at the base where it connects to the knuckle
knuckle_arm_base_w                                 = 9;

// The width of the arm at the narrowest point near the bolt hole
knuckle_arm_narrow_w                               = 6.06;

// The length of the main part
knuckle_arm_base_len                               = 15.3;
// The length of the part, that connects arm with knuckle
knuckle_arm_ring_connector_l                       = 4.5;

// The length of the part with the bolt hole
knuckle_arm_ear_len                                = 13;

// The angle of the arm ears with bolt holes relative to the main part of the arm
knuckle_arm_angle                                  = 54;

// The number of bolt holes in the arm ears
knuckle_arm_holes_n                                = 2;

// The gap between the bolt holes in the arm ears
knuckle_arm_holes_gap                              = 2;

// ─────────────────────────────────────────────────────────────────────────────
// Knuckle's steering arm tie rod placeholder
// The tie rod end is the link between the steering arm and the steering servo arm.
// ─────────────────────────────────────────────────────────────────────────────
// Outer diameter of the eyelet where the tie rod connects to the steering arm
knuckle_tie_rod_eye_od                             = 8.9;

// Height of the eyelet where the tie rod connects to the steering arm
knuckle_tie_rod_eye_h                              = 4.0;

// Outer diameter of the shank where the tie rod connects to the steering arm
knuckle_tie_rod_shank_od                           = 4.6;

// Diameter of the hole in the shank for the bolt that secures the tie rod to the steering arm
knuckle_tie_rod_shank_bolt_d                       = m3_hole_dia;

// Length of the neck between the eyelet and the shank where the tie rod connects to the steering arm
knuckle_tie_rod_neck_len                           = 2.05;

// Height of the neck between the eyelet and the shank where the tie rod connects to the steering arm
knuckle_tie_rod_shank_len                          = 10.8 + knuckle_tie_rod_neck_len;

// Outer diameter of the bushing that fits into the eyelet of the steering arm
knuckle_tie_rod_bushing_od                         = 6.95;

// Diameter of the hole in the bushing for the bolt that secures the tie rod to the steering arm
knuckle_tie_rod_bushing_d                          = m3_hole_dia;

// Height of the bushing that fits into the eyelet of the steering arm
knuckle_tie_rod_bushing_h                          = 10.4;

knuckle_tie_rod_bushing_bolt_color                 = matte_black;
knuckle_tie_rod_bushing_bolt_head_d                = 6.62;

// Flat diameter of the bushing that fits into the eyelet of the steering arm (used for anti-rotation)
knuckle_tie_rod_bushing_flat_d                     = 5;

// Addional cylinders diameter for the cylindrical bushing type
knuckle_tie_rod_bushing_cap_d                      = 7;

// Addional cylinders height for the cylindrical bushing type
knuckle_tie_rod_bushing_cap_h                      = 5;

// Z-rotation angle of the tie rod placeholder relative to the steering arm (0 means the shank is parallel to the X-axis of the steering arm)
knuckle_tie_rod_angle                              = 0;

// Legacy unconstrained rod display. Solved linkage placement derives its angles.
knuckle_tie_rod_angles                             = [0, 6, 0];

knuckle_tie_tilt_shift                             = 0;

// Height of the tie rod neck
knuckle_tie_rod_neck_h                             = 4.95;

// Color of the tie rod bushing
knuckle_tie_rod_bushing_color                      = metallic_silver_9;

// Color of the tie rod placeholder
knuckle_tie_rod_color                              = cobalt_blue_metallic;

knuckle_tie_rod_link_len                           = 5.1;
knuckle_tie_rod_link_od                            = 5.9;
knuckle_tie_rod_link_end_len                       = 0.4;
knuckle_tie_rod_link_thread_l                      = 8.8;
knuckle_tie_rod_link_thread_d                      = m3_hole_dia;
knuckle_tie_rod_link_color                         = metallic_silver_2;

// ─────────────────────────────────────────────────────────────────────────────
// Knuckle's ball stud housing for lower and upper arms
// ─────────────────────────────────────────────────────────────────────────────
// The two ball studs is mounted in a cylindrical housing that is part of the
// knuckle. The housing has a hole for the ball stud, and a mounting flange with
// holes for bolts to secure it to the knuckle. The housing can be secured
// either by a threaded plug or by a horizontal stopper bolt.

// Inner diameter of the hole for the ball stud in the knuckle
knuckle_ball_stud_mount_hole_d                     = front_arm_ball_stud_ball_d + 0.8;

// Thickness of the wall of the mounting flange for the ball stud housing
knuckle_ball_stud_mount_thickness                  = 1.6;

// The outer diameter of the mounting flange for the ball stud housing, which includes clearance for the bolt holes.
knuckle_ball_stud_mount_outer_d                    = knuckle_ball_stud_mount_hole_d
                                                      + knuckle_ball_stud_mount_thickness * 2;

// The height of the mounting flange for the ball stud housing (Z direction for extrusion)
knuckle_ball_stud_house_h                          = 14.5;

knuckle_ball_stud_sphere_h                         = 2;
// The size of the hole for the ball stud in the knuckle, which is a clearance
// hole for the ball part of the stud. The diameter is set to be slightly
// smaller than the ball diameter to ensure a snug fit, while still allowing the
// ball to be inserted and move freely.
knuckle_ball_stud_cap_hole_size                    = [6.8, front_arm_ball_stud_ball_d];

/** The ball stud is secured either by:
 *   1. a bushing and a threaded plug with an internal hex (hex socket), or
 *   2. a simple horizontal stopper bolt threaded through the housing (past the
 *      bushing) to prevent the ball stud from falling out. To use this option,
 *      set `knuckle_ball_stud_stopper_d` to the desired bolt diameter.
 */
knuckle_ball_stud_stopper_d                        = 0;
knuckle_ball_stud_stopper_offset                   = 2;

// ─────────────────────────────────────────────────────────────────────────────
// Hex socket threaded plug for knuckle's ball stud
// ─────────────────────────────────────────────────────────────────────────────

 // Outer diameter of the threaded plug
knuckle_threaded_plug_d                            = 10.0;

// Length diameter of the threaded plug
knuckle_threaded_plug_l                            = 5.8;

// Hex socket size for the Allen key
knuckle_threaded_plug_hex_key_size                 = 4.8;

knuckle_threaded_plug_tolerance                    = 0.4;

// ─────────────────────────────────────────────────────────────────────────────
// Bushing for the ball stud
// ─────────────────────────────────────────────────────────────────────────────

knuckle_bushing_d                                  = 9;
knuckle_bushing_hole_d                             = 4;
knuckle_bushing_h                                  = 3;
knuckle_bushing_thickness                          = 0.6;
knuckle_bushing_hole_border_w                      = 0.8;

// ─────────────────────────────────────────────────────────────────────────────
// Knuckle assembly parameters
// ─────────────────────────────────────────────────────────────────────────────

// [caster_angle, camber_angle, z_angle]
knuckle_angles                                     = [0, 0, 0];
// How far to lower the knuckle in the assembly
knuckle_z_shift                                    = 0;

// ─────────────────────────────────────────────────────────────────────────────
// Center link for dual-bellcrank steering
// ─────────────────────────────────────────────────────────────────────────────

// Total length (bar plus two rings) of the “dogbone” plate
steering_center_link_len                           = 56.7;
// Overall width of the “dogbone” plate
steering_center_link_w                             = 4.8;
// Overall thickness of the “dogbone” plate
steering_center_link_thickness                     = 3.9;
// Diameter of the holes
steering_center_link_hole_d                        = 4.7;
// Outer diameter of the bosses
steering_center_link_boss_od                       = 8;
// Height of the bosses
steering_center_link_boss_h                        = 4.9;

// ─────────────────────────────────────────────────────────────────────────────
// Steering servo bracket
// ─────────────────────────────────────────────────────────────────────────────
// Hole diameter for mounting the servo to the bracket
steering_servo_bracket_servo_bolt_d                = m3_hole_dia;

// Thickness of the wall used to mount the steering servo
steering_servo_bracket_thickness                   = 3;

// Clearance used when calculating the bracket width, which is based on the
// width of the servo mounting flange. A higher value results in a narrower
// bracket, while setting it to 0.0 makes the bracket width equal to the flange
// width.
steering_servo_bracket_w_clearance                 = 0.1;

// ─────────────────────────────────────────────────────────────────────────────
// Lower wall (for mounting to the chassis)
// ─────────────────────────────────────────────────────────────────────────────
// Number of holes for mounting to the chassis
steering_servo_bracket_chassis_bolt_n              = 2;

// Distance from the edge of the lower wall to the chassis mounting bolt holes
steering_servo_bracket_lower_wall_bolt_edge_pad    = 2;

// Distance between the edges of the holes
steering_servo_bracket_chassis_bolt_gap            = 4;

// Additional clearance used when calculating the thickness of the chassis
// mounting wall
steering_servo_bracket_lower_thickness_clearance   = 0;

// ─────────────────────────────────────────────────────────────────────────────
// Steering servo mounting slots in the chassis
// ─────────────────────────────────────────────────────────────────────────────
// Hole diameter for mounting to the chassis
steering_servo_mount_bolt_d                        = m3_hole_dia;

// Shape to use: either "countersunk" (a conical/beveled enlargement around a
// hole) or "counterbore" (a cylindrical recess with a flat bottom concentric
// with the hole).
steering_servo_chassis_bore_type                   = "counterbore"; // [countersunk:Conical countersunk, counterbore:Cylindrical counterbore]

// Diameter of the enlargement around the bolt hole in the chassis
steering_servo_mount_bolt_bore_d                   = m3_countersunk_head_dia + 0.3;

// Depth of the enlargement around the bolt hole in the chassis
steering_servo_mount_bolt_bore_h                   = m3_countersunk_head_h + 0.25;

// ─────────────────────────────────────────────────────────────────────────────
// Assembly view
// ─────────────────────────────────────────────────────────────────────────────
// Bolt head type used for the servo mounting bolts in the assembly view
servo_l_bracket_bolt_head_type                     = "hex"; // [pan:Pan, hex:Hex, countersunk:Countersunk, round:Round, socket:Socket]

// Bolt length for mounting to the chassis, used in the assembly view
servo_l_bracket_chassis_bolt_h                     = 10;

// Bolt head type
steering_servo_chassis_mount_bolt_head_type        = "countersunk"; // [pan:Pan, hex:Hex, countersunk:Countersunk, round:Round, socket:Socket]

// ─────────────────────────────────────────────────────────────────────────────
// Bellcrank arm to steering servo arm tie rod
// ─────────────────────────────────────────────────────────────────────────────

steering_servo_tie_rod_angle                       = 0;

steering_servo_tie_rod_body_total_len              = 68.5;
steering_servo_tie_rod_thread_len                  = 8.8;
steering_servo_tie_rod_body_len                    = 20;
steering_servo_tie_rod_body_d                      = 5.65;
steering_servo_tie_rod_body_end_len                = 0.1;
steering_servo_tie_rod_thread_d                    = m3_hole_dia;
steering_servo_tie_rod_fn                          = 6;
steering_servo_tie_rod_color                       = metallic_silver_1;

servo_tie_rod_a_eye_od                             = 7.5;
servo_tie_rod_a_eye_h                              = 3.20;

servo_tie_rod_a_shank_od                           = 4.4;
servo_tie_rod_a_shank_bolt_d                       = steering_servo_tie_rod_thread_d;
servo_tie_rod_a_neck_len                           = 2.05;
servo_tie_rod_a_neck_h                             = 3.22;
servo_tie_rod_a_shank_len                          = 10.5;

servo_tie_rod_a_bushing_od                         = 3.6;
servo_tie_rod_a_bushing_d                          = 2.5;
servo_tie_rod_a_bushing_h                          = 7;
servo_tie_rod_a_bushing_flat_d                     = 4.4;

servo_tie_rod_a_bushing_color                      = metallic_silver_9;

servo_tie_rod_a_eye_bolt_h                         = 17;

servo_tie_rod_a_eye_bolt_lock_nut                  = true;

servo_tie_rod_a_color                              = steering_servo_tie_rod_color;
servo_tie_rod_a_screw_out_depth                    = 0;

servo_tie_rod_a_bushing_cap_h                      = undef;
servo_tie_rod_a_bushing_cap_d                      = undef;
servo_tie_rod_a_eye_bolt_color                     = undef;
servo_tie_rod_a_reverse_bolt                       = true;
servo_tie_rod_a_eye_bolt_head_d                    = undef;

servo_tie_rod_b_eye_od                             = 11.3;
servo_tie_rod_b_eye_h                              = 5.1;
servo_tie_rod_b_shank_od                           = 6;
servo_tie_rod_b_shank_bolt_d                       = m3_hole_dia;
servo_tie_rod_b_neck_len                           = 2.05;
servo_tie_rod_b_shank_len                          = 14.6;
servo_tie_rod_b_bushing_od                         = 6.95;
servo_tie_rod_b_bushing_d                          = m3_hole_dia;
servo_tie_rod_b_bushing_h                          = 6.7;
servo_tie_rod_b_bushing_flat_d                     = 5;
servo_tie_rod_b_bushing_cap_h                      = 5;
servo_tie_rod_b_bushing_cap_d                      = 7;
servo_tie_rod_b_neck_h                             = 5;
servo_tie_rod_b_eye_bolt_color                     = matte_black;
servo_tie_rod_b_bushing_color                      = metallic_silver_8;
servo_tie_rod_b_eye_bolt_head_d                    = 6.62;

servo_tie_rod_b_reverse_bolt                       = false;

servo_tie_rod_b_screw_out_depth                    = 0;
servo_tie_rod_b_color                              = cobalt_blue_metallic;

steering_servo_arm_total_l                         = 35.4;
steering_servo_arm_d                               = 14.75;
steering_servo_arm_len                             = steering_servo_arm_total_l
                                                      - steering_servo_arm_d;
steering_servo_arm_w                               = 7.6;
steering_servo_arm_base_h                          = 6.0;

steering_servo_arm_bolt_boss_h                     = 5.9;
steering_servo_arm_bolt_boss_w                     = 6;

steering_servo_arm_bolt_boss_spacing               = 1;
steering_servo_arm_bolt_boss_padding               = 1.2;
steering_servo_arm_bolt_boss_inner_padding         = 1.0;
steering_servo_arm_thickness                       = 3.75;
steering_servo_arm_bolt_d                          = m3_hole_dia;
steering_servo_arm_center_bolt_d                   = m3_hole_dia;
steering_servo_arm_center_bolt_bore_d              = 7.8;
steering_servo_arm_center_bolt_bore_h              = 1.2;

// ─────────────────────────────────────────────────────────────────────────────
// Steering servo encoder
// ─────────────────────────────────────────────────────────────────────────────

steering_encoder_plist                             = as5048A_encoder_plist;
steering_encoder_bottom_thickness                  = 1.6;
steering_encoder_side_thickness                    = 3;
steering_encoder_top_side_padding                  = 0;
steering_encoder_extra_left_w                      = 10;
steering_encoder_extra_right_w                     = 0;
steering_encoder_top_up_padding                    = 0;
steering_encoder_top_bolt_min_padding              = 1.5;
steering_encoder_top_corner_r                      = 1;
steering_encoder_bottom_pan_bolt_spacing           = 10;
steering_encoder_bottom_pan_bolt_d                 = m3_hole_dia;
steering_encoder_bottom_pan_bolt_pad               = 8;
steering_encoder_bottom_corner_r                   = 3;

steering_encoder_magnet_distance                   = 0.5;

steering_magnet_d                                  = 5;
steering_magnet_h                                  = 2;

// ─────────────────────────────────────────────────────────────────────────────
// Upper steering panel
// ─────────────────────────────────────────────────────────────────────────────
upper_steering_panel_bolt_d                        = m3_hole_dia;
upper_steering_panel_boss_od                       = 6;
upper_steering_panel_bulkhead_bore_d               = 4.6;
upper_steering_panel_bulkhead_bore_h               = 1;
upper_steering_panel_bulkhead_spacing              = 21;

// Sculpted bridge: stationary contact feet and clearance above rotating parts.
upper_steering_plate_thickness                     = 3;
upper_steering_plate_running_clearance             = 0.6;
upper_steering_plate_pad_d                         = 11;
upper_steering_plate_web_w                         = 6;
upper_steering_plate_window_r                      = 1.2;
upper_steering_plate_rear_scallop                  = 0.22;

// ─────────────────────────────────────────────────────────────────────────────
// Gearmotor shaft encoder, opposite the sleeve (near the motor contacts)
// ─────────────────────────────────────────────────────────────────────────────
// Set the plist to undef to omit the encoder mounting feature entirely.
motor_encoder_plist                                = as5048A_encoder_plist;
motor_encoder_bottom_thickness                     = 2;
motor_encoder_side_thickness                       = 3;
motor_encoder_pcb_padding                          = 1;
motor_encoder_mount_bolt_d                         = m3_hole_dia;
motor_encoder_mount_wall                           = 1.5;
motor_encoder_nut_clearance                        = 0.4; // radial and axial pocket clearance
motor_encoder_clearance                            = 0.6; // bolt-head and PCB clearance
motor_encoder_magnet_distance                      = 0.5; // IC package face to magnet face
motor_encoder_magnet_d                             = 5;
motor_encoder_magnet_h                             = 2;
// ─────────────────────────────────────────────────────────────────────────────
// Driveshaft magnet sleeve
// ─────────────────────────────────────────────────────────────────────────────
// Keyed shaft cup, open magnet pocket and retaining lip; dimensions are in mm.
motor_encoder_sleeve_mount_wall_thickness          = 1.0; // Wall thickness of the driveshaft cup
motor_encoder_sleeve_wall_thickness                = 1.2; // Wall thickness of the magnet holder
motor_encoder_sleeve_d_clearance                   = 0.1; // Diametral shaft-bore clearance
motor_encoder_magnet_d_clearance                   = 0.1; // Diametral magnet-pocket clearance
motor_encoder_sleeve_h_clearance                   = 0.4; // Shaft tip to magnet pocket shoulder
motor_encoder_magnet_h_clearance                   = -0.5; // Height clearance for the magnet; if negative, the magnet will protrude by this amount
motor_encoder_transition_h                         = 1.6; // Transition height for easier printing between the driveshaft cup and the start of the magnet holder

motor_plist                                        = ["body", ["d", 24.3,
                                                               "h", 27.7,
                                                               "color", matte_black],
                                                      "contact_cup", ["h", 1.6,
                                                                      "color", midnight_blue],
                                                      "contact", ["size", [0.8, 1.8, 3],
                                                                  "color", metallic_silver_3,
                                                                  "pad", 3],
                                                      "contact_stack", [["size", [8.6, 17.4, 4.8],
                                                                         "corner_r", 2,
                                                                         "color", midnight_blue],
                                                                        ["d", 8,
                                                                         "corner_r", 2,
                                                                         "color", midnight_blue,
                                                                         "h", 2.6]],
                                                      "pinion_hole_d", 8,
                                                      "pinion_gear_h", 2.6,
                                                      "pinion_gear_color", "silver",
                                                      "motor_shaft", ["h", 10.9,
                                                                      "d", 2,
                                                                      "gear_d", 7.3,
                                                                      "gear_h", 5.1,],
                                                      "drive_seeve", ["od", 19.7,
                                                                      "h", 25.7,
                                                                      "outer_dist", 1.8],
                                                      "drive_seeve_shaft", ["od", 4.95,
                                                                            "l", 24.3,
                                                                            "outer_l", 6.8,
                                                                            "pad_l", 6.8],
                                                      "drive_shaft", ["d", 3.95,
                                                                      "bearing", ["od", 7,
                                                                                  "w", 2],
                                                                      "rear_l", 14,
                                                                      "hole_edge_dist", 3.9,
                                                                      "flat_d", 3,
                                                                      "flat_both_sides", false,
                                                                      "hole_d", 2.1,
                                                                      "l", 61.1,
                                                                      "pad_l", 7.2],
                                                      "gearbox", ["side_ears", ["poses", [[-21.3, 2.84],
                                                                                          [-26, 29.5],
                                                                                          [11.8, 17.63]],
                                                                                "thickness", 8,
                                                                                "bolt_d", m2_hole_dia,
                                                                                "d", 5],
                                                                  "thickness", 18,
                                                                  "corner_r", 6,
                                                                  "color", red_4,
                                                                  "bottom_straight_w", 15.34,
                                                                  "bearing_boss_wall", 1.05,
                                                                  "bearing_boss_h", 2.5,
                                                                  "motor_shaft_y", 18.8,
                                                                  "motor_outer_shaft_x_pad", 11.65, // right width
                                                      // "motor_outer_shaft_x_pad", 15.65, // right width
                                                                  "motor_x_shift", 16.0, // left
                                                                  "outer_shaft_y_center", 10.65,
                                                                  "front_mount_ear_y_center", 10.65,
                                                                  "rear_mount_ear_y_center", 12.25,
                                                                  "mount_bolt_d", m3_hole_dia,
                                                                  "mount_ears", ["boss_d", 8.6,
                                                                 // "ear_l", 6.7,
                                                                                 "ear_l", 2.35,
                                                                                 "ear_y_pad", 3.35,
                                                                                 "ear_thickness", 3.24,
                                                                                 "rear_boss_h", 1.0,
                                                                                 "front_boss_h", 0.0],
                                                                  "mount_ear_x_dist", 3.2,
                                                      // "mount_ear_x_dist", 13.0,
                                                                  "mount_ear_y_shift", 1.8,
                                                                  "mount_ear_y_spacing", 26.0,
                                                      // "mount_ear_y_spacing", 25.6,
                                                                  "mount_ear_x_spacing", 19.8,
                                                                  "mount_cbore_h", 4,
                                                                  "mount_cbore_d", 6.8, // 6.6
                                                                  "upper_gear", ["x", 1.46,
                                                                                 "y", 22.09,
                                                                                 "d", 18.4],
                                                                  "motor_pad", 1.2]];

// Offsets locate the oriented reference box: minimum X and maximum Y.
// Y is relative to the front rear-frame main-section start.
front_rpi_y_offset                                 = 0;
front_rpi_x_offset                                 = -5;
front_rpi_orientation                              = "lwh"; // wlh | lwh (flat PCB)
front_rpi_rotate_z_180                             = true; // 180-degree turn in the PCB plane
// Material beyond the RPi standoffs/counterbores; connectors may overhang.
front_rpi_mount_pad                                = 2;

// Shared camera-ribbon threading bank beneath the Pi, turning toward the head.
front_chassis_ribbon_slot_rows                     = 5;
front_chassis_ribbon_land                          = 3;
front_chassis_wiring_slot_d                        = 14;
front_chassis_wiring_slot_clearance                = 3;

front_chassis_rear_frame_corner_r                  = 4;

lipo_pack_base_pl                                  = ["size", [lipo_pack_width,
                                                               lipo_pack_length,
                                                               lipo_pack_height],
                                                      "orientation", "lwh",
                                                      "rear_end_corner_r", "50%",
                                                      "lead_exit", "rear_side", // rear_side | front_side | front_end | rear_end
                                                      "power_lead", ["side", "left",
                                                                     "connector", "t-plug",
                                                                     "d", 4.35,
                                                                     "l", 80,
                                                                     "routing", "top"],
                                                      "balance_lead", ["side", "right",
                                                                       "d", 1.72,
                                                                       "colors", ["red", "white", "black"],
                                                                       "l", 40,
                                                                       "routing", "top"],
                                                      "rear_end_corner_r", "5%",
                                                      "orientation", "wlh", // wlh (default) | lwh | lhw | whl | hlw | hwl
                                                      "top_cover", ["bg", "gold",
                                                                    "texts", [["text", "3S",
                                                                               "size", 10,
                                                                               "halign", "center",
                                                                               "gap_before", 4],
                                                                              ["text", "5000MAH",
                                                                               "size", 10,
                                                                               "halign", "center",
                                                                               "gap_before", 10]],
                                                                    "props", ["halign", "center",
                                                                              "color", "#28282B"]],
                                                      "side_cover", ["bg", "silver"]];

lipo_packs                                         = [lipo_pack_base_pl];

power_ring_terminal_plist                          = ["d", 4.33,
                                                      "od", 6.61,
                                                      "w", 3.35,
                                                      "l", 9.1,
                                                      "t", 0.62,
                                                      "color", metallic_silver_5,
                                                      "insulate", ["color", "#3771E1",
                                                                   "l", 10.5,
                                                                   "d", 5.9]];

button_switch_default_plist                        = ["body_size", toggle_switch_size,
                                                      "thread_h", toggle_switch_thread_h,
                                                      "thread_d", toggle_switch_thread_d,
                                                      "nut_d", toggle_switch_nut_d,
                                                      "nut_bore_h", toggle_switch_nut_out_h,
                                                      "lever_dia_1", toggle_switch_lever_dia_1,
                                                      "lever_dia_2", toggle_switch_lever_dia_2,
                                                      "lever_h", toggle_switch_lever_h,
                                                      "terminal_size", toggle_switch_terminal_size,
                                                      "thread_border_w", toggle_switch_thread_border_w,
                                                      "metallic_head_h", toggle_switch_metallic_head_h,
                                                      "terminal_hole_z", 3.8,
                                                      "terminal_hole_d", m3_hole_dia,
                                                      "crimp_terminal", power_ring_terminal_plist];

toggle_switch_bracket_plist                        = ["button", button_switch_default_plist,
                                                      "bolt_d", m3_hole_dia,
                                                      "bottom_t", 3,
                                                      "vertical_r", 2,
                                                      "bottom_r", 2,
                                                      "vertical_extra_t", 2,
                                                      "vertical_top_pad", 2,
                                                      "d_tolerance", toggle_switch_slot_d_tolerance,
                                                      "side_pad", 4,
                                                      "bolt_pad", 5,
                                                      "color", white_smoke_1];

basic_vent_spec                                    = ["vent_h", 2,
                                                      "vent_corner_r", "40%",
                                                      "vent_w", "20%",
                                                      "vent_col_gap", "5%",
                                                      "vent_pad", 5];

function merge_vent_spec(pl) = plist_merge(basic_vent_spec, pl);

// Select "dual_wago" for separate power/GND connectors, or "meter" for a display.
multi_lipo_lid_equipment_preset                    = "dual_wago";
multi_lipo_lid_button_mount                        = ["kind", "button",
                                                      "component", plist_merge(toggle_switch_bracket_plist,
                                                                               ["terminal_extension",
                                                                                plist_get("terminal_size", button_switch_default_plist)[2]]),
                                                      "placement", "left",
                                                      "advance_to_rail", true,
                                                      // Counter-turn the switch so its lever faces the lid meters.
                                                      "rotation", 180];
multi_lipo_lid_equipment_presets                   = ["meter", [multi_lipo_lid_button_mount,
                                                                ["kind", "wago",
                                                                 "placement", "right",
                                                                 "rotation", 90],
                                                                ["kind", "voltmeter",
                                                                 "component", voltmeter_default_spec,
                                                                 "placement", "auto",
                                                                 "count", "fit"]],
                                                      "dual_wago", [multi_lipo_lid_button_mount,
                                                                    ["kind", "wago_pair",
                                                                     "component", ["spacing", 2,
                                                                                   "overhang", 7.9,
                                                                                   "wire_pad", 1.5,
                                                                                   "wire_r", 3],
                                                                     "placement", "right",
                                                                     "rotation", 0]]];
multi_lipo_lid_equipment                           = assert(multi_lipo_lid_equipment_preset == "meter"
                                                            || multi_lipo_lid_equipment_preset == "dual_wago",
                                                            "Unknown multi-LiPo lid equipment preset")
                                                      plist_get(multi_lipo_lid_equipment_preset,
                                                      multi_lipo_lid_equipment_presets);

multi_lipo_packs_case                              = ["lipo_packs", lipo_packs,
                                                      "power_rotation", 180,
                                                      "wiring", ["enabled", multi_lipo_lid_equipment_preset == "dual_wago",
                                                                 "d", 3.8,
                                                                 "cut_allowance", 20],
                                                      "color", cobalt_blue_metallic,
                                                      "corner_r", 3,
                                                      "inner_corner_r", 0, // clearance for the pack's square end
                                                      "orientation", "wlh",
                                                      "mount_nut_pockets", true,
                                                      "rail", ["axis", "auto",
                                                               "h", 4,
                                                               "angle", 12,
                                                               "clearance", 0.2,
                                                               "bolt_d", m2_hole_dia],
                                                      "lid", ["t", 3,
                                                              "corner_r", "5%",
                                                              "equipment", multi_lipo_lid_equipment,
                                                              "fuse", ["holder", atm_fuse_default_plist,
                                                                       "pos", [0, 2],
                                                                       "clearance", 1,
                                                                       "tie_recess", 1.6],
                                                              "perfboard", ["component", plist_merge(perfboard_default_plist,
                                                                                        ["bolt_idxes", [[1, 0], [1, 1]]]),
                                                                            "edge_pad", 1.25,
                                                                            "pos", [0, undef]],
                                                              "voltmeters", [for (x = [30, -30])
                                                      ["component", voltmeter_default_spec,
                                                       "edge_pad", 1.25,
                                                       "pos", [x, undef]]],
                                                              "adapter", ["t", 4,
                                                                          "bolt_d", 3,
                                                                          "corner_r", 3,
                                                                          "standoff_h", 0],
                                                              "side_t", 2,
                                                              "headroom", "auto",
                                                              "color", cobalt_blue_metallic,
                                                              "lidar", rplidar_c1_plist,
                                                              "lidar_target_h", 17,
                                                              "vents", ["vent_w", "12%",
                                                                        "vent_h", 4.5,
                                                                        "vent_col_gap", 5,
                                                                        "corner_r", "40%",
                                                                        "vent_pad", 1.5]],
                                                      "walls", ["front", merge_vent_spec(["t", 2.5,
                                                                                          "l", "90%",
                                                                                          "corner_r", "20%"]),
                                                                "rear", merge_vent_spec(["t", 2.5,
                                                                                         "l", "90%",
                                                                                         "corner_r", "20%"]),
                                                                "bottom", ["t", 6.2],
                                                                "left", merge_vent_spec(["t", 2.5,
                                                                                         "h", "90%"]),
                                                      // One continuous outline avoids lips where wiring cutouts met the band.
                                                      // Keep the rim clear of the case's rounded plan-view corners.
                                                                "right", ["t", 2.5,
                                                                          "l", "88%",
                                                                          "edge_r", 0.5,
                                                                          "shape", "custom",
                                                                          "shape_props", ["h", "75%",
                                                                                          "corner_r", 2,
                                                                                          "round_bottom", false,
                                                                                          "debug", false,
                                                                                          "points", [[0, 0],
                                                                                                     ["100%", 0],
                                                                                                     ["100%", "30%"],
                                                                                                     ["88%", "30%"],
                                                                                                     ["70%", "100%"],
                                                                                                     ["30%", "100%"],
                                                                                                     ["12%", "30%"],
                                                                                                     [0, "30%"]]]],
                                                                "inner", ["t", 2]],
                                                      "bolt_pad_x", 10,
                                                      "bolt_pad_y", 5,
                                                      "bolt_d", m3_hole_dia,
                                                      "bore_d", front_chassis_bellcrank_bolt_bore_d,
                                                      "bore_h", front_chassis_bellcrank_bolt_bore_h,];

// Rear harness: holes accept the complete insulated ring terminal end-first.
rear_power_wiring                                  = ["enabled", true,
                                                      "d", 3.8,
                                                      "hole_d", 12,
                                                      "black_holes", true,
                                                      "hole_gap", 3,
                                                      "fuse_hole_columns", 2,
                                                      "fuse_outlet", true,
                                                      "fuse_outlet_edge_margin", 12,
                                                      "terminal_clearance", 2,
                                                      "converter_run", 40,
                                                      "under_z", -8,
                                                      "ring_terminal", power_ring_terminal_plist];

multi_power_case_props                             = multi_lipo_pack_props(plist=multi_lipo_packs_case);
multi_power_case_size                              = plist_get("size",
                                                               multi_power_case_props);

chassis_body_min_w                                 = multi_power_case_size[0];

gearbox_bracket_thickness                          = 8.5;

gearbox_bracket_bolt_d                             = m3_hole_dia;
gearbox_bracket_bolt_pad_x                         = 2.4;
gearbox_bracket_bolt_pad_y                         = 2.5;
gearbox_bracket_ear_bolt_pad                       = 3;
gearbox_bracket_corner_r                           = 1;
gearbox_bracket_fillet_x_w                         = 0.5;
gearbox_bracket_fillet_y_w                         = 0;
gearbox_bracket_bolt_dist_from_cap                 = 2.6;

gearbox_bracket_bolt_dist_y_ear_bolt               = 3.0;

gearbox_bracket_nut_pocket_clearance               = 0.3;
gearbox_bracket_nut_pocket_h_clearance             = 0.5;

// The wall thickness of the bracket boss; the outer diameter is
// motor_plist.gearbox.mount_bolt_d + gearbox_bracket_boss_thickness * 2.
gearbox_bracket_boss_thickness                     = 1.4;

// clearance for the motor holder cylindric cutout.
gearbox_bracket_motor_carrier_clearance            = 2.0;

gearbox_bracket_boss_pocket_clearance              = 2.0; // Diametral socket allowance
gearbox_bracket_boss_pocket_depth                  = 2.0;
gearbox_bracket_boss_pocket_h_clearances           = ["front", 0.1,
                                                      "rear", 0.2];

// ─────────────────────────────────────────────────────────────────────────────
// Generic touring wheels: purchased-hardware visualization, not print geometry.
// mount_z is explicit backspacing; hub details are provisional.
// ─────────────────────────────────────────────────────────────────────────────
rc_wheel_plist                                     = ["tire_d", 65,
                                                      "width", 26,
                                                      "rim_d", 52,
                                                      "hex_af", 12,
                                                      "mount_z", 15];
rc_wheel_bearing_gap                               = 1;
rc_wheel_hex_h                                     = 5;

// Rear suspension is not yet modeled. Undef matches the front reference pose.
rc_rear_wheel_preview_track                        = undef;
rc_rear_wheel_preview_axis_z                       = undef;
rc_rear_wheel_preview_y_offset                     = 0;
