include <colors.scad>
include <parameters.scad>


// ─────────────────────────────────────────────────────────────────────────────
// Bellcrank link arm. Part of both the drive and idler arms.
// It has two bolt holes:
// - For the Ackermann plate. This hole has both upper and lower bosses.
//   The lower boss is for the Ackermann plate bushing.
// - For the knuckle steering link, with an upper boss only.
// ─────────────────────────────────────────────────────────────────────────────

bellcrank_arm_bolt_d                              = m3_hole_dia;

// Total length of the arm starting from the center of bellcrank
bellcrank_arm_l                                   = 25.45;

bellcrank_drive_arm_l                             = 25.45;

// Thickness of the arm
bellcrank_arm_thickness                           = 3;
// Height of the upper bosses with bolt holes
bellcrank_arm_upper_boss_h                        = 1;
// Hole diameter of the upper bosses
bellcrank_arm_upper_boss_d                        = 4.3;

// Width at the edge of the arm
bellcrank_arm_w                                   = 6.10;
// Height of the lower boss
bellcrank_arm_lower_boss_h                        = 2.4;
// Outer diameter of the lower boss
bellcrank_arm_lower_boss_d                        = 6.0;

// Distance from the edge of the arm to the start of the hole
bellcrank_arm_bolt_edge_offset                    = 2;

// Distance between hole centers
bellcrank_arm_bolt_spacing                        = 9.5;

// Distance from the bottom of the pivot base to the bellcrank arm root
bellcrank_arm_z                                   = 11.1;

// ─────────────────────────────────────────────────────────────────────────────
// Bellcrank idler (shared with the bellcrank drive)
// ─────────────────────────────────────────────────────────────────────────────

// Outer diameter of the bearing
bellcrank_idler_bearing_od                        = 10;
// Inner (bore) diameter of the bearing
bellcrank_idler_bearing_d                         = 5;

// Width of the bearing
bellcrank_idler_bearing_w                         = 4;

bellcrank_idler_bearing_outer_recess_d            = 9;

bellcrank_idler_bearing_shoulder_d                = 6.5;

// The clearance for the bearing diameter
bellcrank_bearing_clearance                       = 0.2;

// The clearance for the bellcrank post's hole
bellcrank_post_hole_clearance                     = 0.5;

// The outer diameter of the bellcrank cylinder
bellcrank_idler_od                                = bellcrank_idler_bearing_od + 5.0;

bellcrank_idler_extra_h                           = 0.8;

bellcrank_idler_support_thickness                 = 2;

// The addional height of the bellcrank for the upper's bearing chamfer
bellcrank_idler_chamfer_h                         = 0.8;

bellcrank_idler_chamfer_angle                     = 30;

// ─────────────────────────────────────────────────────────────────────────────
// Bellcrank lever (used both in bellcrank drive and idler)
// ─────────────────────────────────────────────────────────────────────────────
bellcrank_lever_border_w                          = 1.5;

bellcrank_lever_use_hull                          = false;

bellcrank_lever_add_through_hole                  = true;
bellcrank_lever_through_hole_d                    = 2;

// ─────────────────────────────────────────────────────────────────────────────
// Pivot bush
// The pivot bush is a cylindrical shaft that is inserted into the bellcrank
// cylinder. Two bearings are placed on the bush-one at the top and one at the
// bottom. The bush has a through-hole for a bolt, and at the bottom it has a
// wider, thin cylinder (shoulder) to prevent the bottom bearing from sliding out.
// ─────────────────────────────────────────────────────────────────────────────

// The height of the pivot bush where the top and bottom bearings are inserted
bellcrank_post_h                                  = 32.55;

// The outer diameter of the pivot bush
bellcrank_post_od                                 = bellcrank_idler_bearing_d - 0.1;

// The hole diameter for the bolt
bellcrank_post_bolt_d                             = 3.1;

// The diameter of the bottom flange (shoulder)
bellcrank_post_flang_d                            = bellcrank_idler_bearing_d + 1.2;

// The height of the bottom flange (shoulder)
bellcrank_post_flang_h                            = 1.0;

// The depth of the bolt hole at the bottom
bellcrank_post_lower_hole_depth                   = 12.0;

// The depth of the bolt hole at the top
bellcrank_post_upper_hole_depth                   = 12.0;

// Whether to use threads for the bolt hole
bellcrank_post_use_threading                      = false;

// ─────────────────────────────────────────────────────────────────────────────
// Bellcrank drive (servo lever parameters)
// ─────────────────────────────────────────────────────────────────────────────

// Distance between the lower bellcrank lever and the upper servo lever
bellcrank_servo_lever_z_offset                    = 5.6;
// Distance between the edges of the holes in the servo lever
bellcrank_servo_lever_holes_gap                   = 1.5;
// Distance between the edge of the lever and the edge of the holes
bellcrank_servo_lever_holes_edge_offset           = 1.2;
// Height of the upper boss
bellcrank_servo_lever_boss_h                      = 3.5;
// Number of mounting holes for the servo tie-rod end
bellcrank_servo_lever_holes_n                     = 3;
// Padding between the center pivot cylinder and the servo lever holes
bellcrank_servo_lever_boss_pad_x                  = 2;

// ─────────────────────────────────────────────────────────────────────────────
// Bellcrank positioning on the chassis
// ─────────────────────────────────────────────────────────────────────────────

// The distance from the end of the bulkhead housing to the center of the
// bellcrank drive/idler holes
bellcrank_y_distance_from_bulkhead                = 30.0;

// Spacing between the centers of the bellcrank drive and bellcrank idler holes
chassis_bellcrank_spacing                         = 48.8;

chassis_center_mount_padding_y                    = 4;
chassis_center_mount_padding_x                    = 6;

// ─────────────────────────────────────────────────────────────────────────────
// Steering servo DSSERVO
// ─────────────────────────────────────────────────────────────────────────────

dsservo_size                                      = [40.00, 20.0, 40.5];
dsservo_bolt_dia                                  = 4.05;

dsservo_bolt_spacing                              = [49.5, 10];

// offset between the servo slot and the fastening bolts
dsservo_bolts_offset                              = 3.2;

dsservo_flange_w                                  = 54.5;

dsservo_flange_h                                  = 18.63;
dsservo_flange_thickness                          = 4.0;
dsservo_flange_z_offset                           = 12.8;
dsservo_gearbox_x_offset                          = 0;
dsservo_gearbox_mode                              = "union";
dsservo_text                                      = [["20KG", "size", 9,
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
dsservo_text_size                                 = 2;
dsservo_text_plist                                = ["font", "Lucida Grande:style=Bold",
                                                     "text_both_sides", true,
                                                     "background",
                                                     ["color",
                                                      pink_1,
                                                      "pad_left", -0.1,
                                                      "pad_right", -0.1,]];

dsservo_gearbox_h                                 = 0;
dsservo_gearbox_size                              = [[1, 12.95, matte_black, 20],
                                                     [3.9, 5.9, metallic_gold_2, 25],
                                                     [0.05, 4.2, dark_gold_2, 25],
                                                     [0.05, 2.8, licorice, 25]];
dsservo_gearbox_d1                                = 12.95 + 3.8;

dsservo_gearbox_d2                                = 6;
dsservo_color                                     = jet_black;
dsservo_cut_len                                   = 0;
dsservo_cut_len_top                               = 7.7;
dsservo_cut_top_depth                             = 3.0;

dsservo_socket_size                               = [5.3, 6.3, 3.4];
dsservo_socket_z_offset                           = 3.0;
dsservo_socket_side                               = -1;

// ─────────────────────────────────────────────────────────────────────────────
// Front suspension arm pad (geometry parameters)
//
// The pad surrounds the hinge-pin holes and provides a center hook that locks
// the hinge pins in place.
// ─────────────────────────────────────────────────────────────────────────────

// Radial padding around each hinge-pin hole (added to the hole radius)
front_suspension_arm_pad_pin_hole_pad_r           = 2.6;

// Overall pad thickness (Z)
front_suspension_arm_pad_thickness                = 2.5;

// Pad length along the Y axis (up to the start of the center hook)
front_suspension_arm_pad_len_y                    = 4.6;

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
front_arm_ball_stud_shank_d                       = 4.8;
// Diameter of the ball end that fits into the knuckle's ball stud housing. This
// should be slightly smaller than the hole diameter in the knuckle for a proper
// fit.
front_arm_ball_stud_ball_d                        = 8.8;
// The diameter of the hole at the head of the ball stud, which is used for securing
front_arm_ball_stud_ball_hole_d                   = 3.3;

// The total length of the shank that screws into the arm. The threaded length
// is front_arm_ball_stud_len - front_arm_ball_stud_unthreaded_h
front_arm_ball_stud_len                           = 17.8;
// The length of the unthreaded portion of the shank near the ball end. This
// part is not threaded and provides a smooth surface for the ball to sit
// against.
front_arm_ball_stud_unthreaded_h                  = 5;

front_arm_heat_insert_nut_hole_d                  = 5.0;

// ─────────────────────────────────────────────────────────────────────────────
// Front lower wishbone arm
// ─────────────────────────────────────────────────────────────────────────────

// Overall length of the lower arm (X direction), from hinge end to ball-stud end.
front_lower_arm_len                               = 48.8;

// Overall height/envelope of the arm profile (Y direction).
front_lower_arm_h                                 = 39.25;

// Main body thickness of the arm (Z direction) for the extruded profile.
front_lower_arm_thickness                         = 7.5;

// Width of the apex/bridge region near the ball-stud end used in profile shaping/cutouts.
front_lower_arm_apex_width                        = 9.1;

// Nominal width of each “leg” of the A-arm in the 2D profile.
front_lower_arm_leg_width                         = 4.0;

// Outer fillet radius applied to the arm outline (rounded outer edges).
front_lower_arm_corner_r                          = 1.5;

// Length of a hinge barrel (one of the cylindrical hinge lugs) along X.
front_lower_arm_hinge_barrel_len                  = 10.3;

// Height envelope of the upper hinge barrel feature (used by the 2D barrel sketch).
front_lower_arm_upper_hinge_barrel_h              = 7.85;

// Height envelope of the lower hinge barrel feature (used by the 2D barrel sketch).
front_lower_arm_lower_hinge_barrel_h              = 6.6;

// Diameter of the hinge pin hole through each hinge barrel.
front_lower_arm_hinge_barrel_hole_d               = 3.4;

// Offset from the barrel’s left edge to the hinge hole edge (sets hole position).
front_lower_arm_hinge_barrel_hole_offset          = 1.7;

// Height (projection) of the damper mounting boss.
front_lower_arm_damper_boss_h                     = 8.2;

// Diameter of the damper mounting boss (outer).
front_lower_arm_damper_boss_d                     = 5.6;

// Diameter of the through-hole in the damper boss for the damper fastener.
front_lower_arm_damper_boss_hole_d                = 3;

// Corner radius used for the inner profile hole.
front_lower_arm_relief_hole_corner_r              = 2;

// X-offset used when positioning the damper boss relative to the arm end.
front_lower_arm_upper_boss_x_offset               = 5.9;

// Y-offset used when positioning the damper boss / upper cutout reference.
front_lower_arm_upper_boss_y_offset               = 3.7;

// Size of the ball-stud/rod-end mounting block: [length(X), width(Y), thickness(Z)]
front_lower_arm_ball_stud_mount_size              = [14, 6.5, 7.5];

// If printing is difficult, you can disable the cutout on the outer bottom edge
// and print it on that edge.
front_lower_arm_use_lower_edge_cutout             = true;

// The depth of the hole for the ball stud
front_lower_arm_ball_stud_hole_depth              = front_arm_ball_stud_len
                                                     - front_arm_ball_stud_unthreaded_h;

// How far to screw out the ball stud. A higher value means the bolt is screwed in less
front_lower_arm_ball_stud_insert_out_depth        = 1;

front_lower_arm_pin_l                             = front_lower_arm_h + front_suspension_arm_pad_thickness + 2.75;

front_lower_arm_pin_groove_offset                 = 0.85;

front_lower_arm_y_offset                          = 0.0;

// ─────────────────────────────────────────────────────────────────────────────
// Upper front wishbone arm
// ─────────────────────────────────────────────────────────────────────────────

// Overall length of the upper arm (X direction), from hinge end to ball-stud end.
front_upper_arm_len                               = 41.8;

// Overall height/envelope of the arm profile (Y direction) excluding
// upper_arm_ball_stud_mount_extra_h
front_upper_arm_h                                 = 24;

// Rounding radius of the hole on the arm
front_upper_arm_hole_corner_r                     = 2.5;

// Outer fillet radius applied to the arm outline (rounded outer edges).
front_upper_arm_corner_r                          = 0.5;

// Main body thickness of the arm (Z direction) for the extruded profile.
front_upper_arm_thickness                         = 6.5;

// Length of a hinge barrel (one of the cylindrical hinge lugs) along X.
front_upper_arm_hinge_barrel_len                  = 9;

// Height envelope of the hinge barrel feature (used by the 2D barrel sketch).
front_upper_arm_hinge_barrel_h                    = 6.9;

// Diameter of the hinge pin hole through each hinge barrel.
front_upper_arm_hinge_barrel_hole_d               = 3.6;

// Offset from the barrel’s left edge to the hinge hole center (sets hole position).
front_upper_arm_hinge_barrel_hole_offset          = 1.7;

// Size of the ball-stud/rod-end mounting block: [length(X), width(Y), thickness(Z)]
front_upper_arm_ball_stud_mount_size              = [15.19, 9.5, front_upper_arm_thickness + 1.5];

// the addional height for ball stud
front_upper_arm_ball_stud_mount_extra_h           = front_upper_arm_ball_stud_mount_size[1] / 2;

// Nominal width of each “leg” of the A-arm in the 2D profile.
front_upper_arm_leg_width                         = 4.5;

// The depth of the hole for the ball stud
front_upper_arm_ball_stud_hole_depth              = front_arm_ball_stud_len - front_arm_ball_stud_unthreaded_h;

// How far to screw out the ball stud. A higher value means the bolt is screwed in less
front_upper_arm_ball_stud_insert_out_depth        = 1;

// The length of the pin which inserted into arm hinges
front_upper_arm_pin_len                           = 38.6;

front_upper_arm_pin_washer_od                     = 5.5;
front_upper_arm_pin_washer_thickness              = 0.5;
front_upper_arm_pin_washer_d                      = 3.1;

front_upper_arm_y_offset                          = -0.0;

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
front_bulkhead_w                                  = 25.9;

// The overall length of the bulkhead housing along the Y-axis,
front_bulkhead_len                                = 39.5;

// Additional rear length for the upper steering plate
front_bulkhead_extra_len                          = 4.7;

// The thickness of the bulkhead housing and barrel hinges (Z-axis extrusion height)
front_bulkhead_housing_h                          = 7.9;

// The distance from the front face of the bulkhead to the protective barrel
// around the hinge pin holes. This sets how far the hinge pin holes are
// recessed from the front face.
front_bulkhead_barrel_y_offset                    = 8.40;

// The diameter of the hinge barrel (the cylindrical protrusion that surrounds the hinge pin hole and provides reinforcement).
front_bulkhead_barrel_hinge_w                     = 13.15;

// The distance from the edge of the hinge barrel to the edge of the hinge pin
// hole (sets the position of the hole within the barrel).
front_bulkhead_barrel_pin_hole_offset             = 2.5;

// Clearance between the outer diameter of the hinge barrel and the hole diameter for the hinge pin.
front_bulkhead_barrel_hinge_clearance             = 1.0;

// The diameter of the hole for the rear bolt on the bulkhead housing, which can be used for a more secure attachment to the chassis.
front_bulkhead_rear_bolt_d                        = m3_hole_dia;

// The diameter of the counterbore for the rear bolt head / washer pocket.
front_bulkhead_rear_bolt_cbore_d                  = 6.10;

// The depth of the counterbore for the rear bolt head / washer pocket.
front_bulkhead_rear_bolt_offset                   = 2.20;

// The diameter of the holes for mounting the bulkhead housing to the chassis and bulkhead itself.
front_bulkhead_mount_bolt_spacing_1               = [34.0, 18.45];

// The diameter of the holes for mounting the bulkhead housing to the chassis and bulkhead itself.
front_bulkhead_mount_bolt_spacing_2               = [34.0, 5.5];

// The diameter of the holes for mounting the bulkhead housing to the chassis and bulkhead itself.
front_bulkhead_mount_bolt_d                       = m3_hole_dia;

front_bulkhead_mount_bolt_bore_d                  = m3_countersunk_head_dia + 0.2;
front_bulkhead_mount_bolt_bore_h                  = m3_countersunk_head_h + 0.15;

// The diameter of the counterbore for the mounting bolt head / washer pocket.
front_bulkhead_mount_bolt_padding                 = 4.6;

// Lateral offset of the semicircular cutout in the hinge barrel in mm
front_bulkhead_hinge_cutout_bolt_offset           = 1;
// Diameter of the semicircular cutout in the hinge barrel, expressed as a
// factor of the overall barrel length. Allowed values: 0 to 1.
front_bulkhead_hinge_cutout_d_factor              = 1;  // [0:0.1:1]

// ─────────────────────────────────────────────────────────────────────────────
// Front bulkhead shock tower
// ─────────────────────────────────────────────────────────────────────────────
// Shock tower mounting tab thickness (Z height after extrusion)
front_bulkhead_shock_tower_mount_thickness        = 5.1;
// X-axis padding around the shock tower bolt pattern on the mounting tab
front_bulkhead_shock_tower_mount_pad_x            = 2.7;
// Extra material above the bolt pattern (positive Y direction)
front_bulkhead_shock_tower_mount_pad_y_top        = 2;

// Fillet radius for the shock tower mounting tab corners
front_bulkhead_shock_tower_mount_corner_r         = 1.5;

// Vertical offset (Z) from the bulkhead base to the lower shock-tower bolt line
front_bulkhead_shock_tower_mount_offset           = 19.5;

// Mounting hinge thickness (extrusion height)
front_bulkhead_hinge_thickness                    = 3;

// Extra length added to the cylindrical support for the front upper suspension holder
front_bulkhead_support_extra_len                  = 4;

// ─────────────────────────────────────────────────────────────────────────────
// Front bulkhead suspension arm pad recess and retainer walls
// ─────────────────────────────────────────────────────────────────────────────
// Thickness of the bulkhead “retainer walls” around the suspension arm pad recess.
// The pad sits in a bottom recess to prevent hinge pins from sliding out.
front_bulkhead_suspension_pad_thickness           = 2;
// Clearance added around the suspension arm pad recess for easy insertion
front_bulkhead_suspension_pad_clearance           = 0.6;

// Depth of the upper suspension holder mounting holes into the bulkhead
front_bulkhead_upper_holder_hole_depth            = 14;

// ─────────────────────────────────────────────────────────────────────────────
// Center hook parameters
// The hook is part of the bottom recess and keeps hinge pins from backing out.
// ─────────────────────────────────────────────────────────────────────────────

// Lower chamfer/fillet size at the hook corners (in the 2D profile)
front_suspension_arm_pad_hook_lower_corner_r      = 1;

// Upper chamfer/fillet size at the hook corners (in the 2D profile)
front_suspension_arm_pad_hook_upper_corner_r      = 1;

// Hook height (extends in +Y from the pad end)
front_suspension_arm_pad_hook_len_y               = 4.8;

// Hook width (X)
front_suspension_arm_pad_hook_w                   = 5.2;

// ─────────────────────────────────────────────────────────────────────────────
// Front Shock Tower
// ─────────────────────────────────────────────────────────────────────────────

// The spacing between the holes for the arm hinges
front_bulkhead_pin_spacing                        = 55.8;

// The overall height of the tower on the Y-axis
front_shock_tower_h                               = 28.9;

// Overall corner radius of the shape
front_shock_tower_corner_r                        = 4;

// Corner radius for the rectangular cutout
front_shock_tower_cutout_corner_r                 = 0.5;

// Corner radius for the lower mount panel with bolt holes
front_shock_tower_mount_corner_r                  = 2;

// The overall thickness of the shock tower
front_shock_tower_thickness                       = 6.0;

// The thickness of the thinner part near the cutout, with bottom mounting holes
front_shock_tower_lower_thickness                 = 2.7;

// The diameter of the holes for mounting to the bulkhead
front_shock_tower_bolt_d                          = m3_hole_dia;

// Bolt spacing for mounting to the bulkhead
front_shock_tower_bolt_spacing                    = [33.3, 9.6];

// The diameter of the holes for mounting the damper
front_shock_tower_shock_damper_bolt_d             = m3_hole_dia;

// The X spacing for the damper holes closest to the center.
// Other holes will be placed at an angle relative to these holes.
front_shock_tower_damper_spacing_x                = 45;

// The angle of the "ears" that hold the damper holes
front_shock_tower_damper_holes_angle              = 150;

// Gap between mounting holes for the damper
front_shock_tower_damper_holes_gap                = 1.7;

// X-padding around the damper holes
front_shock_tower_damper_holes_pad_x              = 1.8;

// Y-padding around the damper holes
front_shock_tower_damper_holes_pad_y              = 1.8;

// The number of damper holes
front_shock_tower_damper_holes_amount             = 3;

// The vertical offset of the holes for the arm hinges
front_shock_tower_pin_y_offset                    = 3;

// Padding for the "ears" that hold the arm-hinge holes
front_shock_tower_pin_hole_pad                    = 1;

// ─────────────────────────────────────────────────────────────────────────────
// Front Upper suspension holder
// ─────────────────────────────────────────────────────────────────────────────

// Overall length of the holder body (derived from bulkhead pin spacing plus a fixed margin)
front_upper_suspension_holder_l                   = front_bulkhead_pin_spacing + 7.7;

// Overall width of the holder body
front_upper_suspension_w                          = 5.7;

// Base extrusion thickness of the holder
front_upper_suspension_holder_thickness           = 4.5;

// Diameter of the circular relief cutout on the underside
front_upper_suspension_holder_round_cutout_d      = 14.0;

// Y-offset of the circular relief cutout center; increasing this shifts it further away and reduces overlap
front_upper_suspension_holder_round_cutout_offset = 1.5;

// Width of the central rectangular cutout (on the side opposite the round cutout)
front_upper_suspension_holder_rect_cutout_w       = 30;

// Through-hole diameter for the mounting bolts (M3 clearance)
front_upper_suspension_holder_bolt_d              = m3_hole_dia;

// Counterbore diameter for the bolt head / washer pocket
front_upper_suspension_holder_bolt_bore_d         = m3_hole_dia * 2 + 0.1;

// Center-to-center spacing of the mounting bolts
front_upper_suspension_holder_bolt_spacing        = 14.3;

// Counterbore depth (pocket height), measured from the top face
front_upper_suspension_holder_bolt_bore_h         = front_upper_suspension_holder_thickness / 2;

// Extra material/padding added below the bolt area (extends the mounting "tab" beyond the holes)
front_upper_suspension_holder_bolt_pad            = 2;

// Y-offset of the bolt counterbore centerline relative to the main body (from the rectangular cutout side)
front_upper_suspension_holder_bolt_y_offset       = 0.5;

// Outer diameter of the pin barrel (reinforcement ring) around the arm hinge pin hole
front_upper_suspension_holder_pin_barrel_d        = front_upper_arm_hinge_barrel_hole_d + 4.1;

// Height of the pin barrel (reinforcement ring) extrusion
front_upper_suspension_holder_pin_barrel_h        = 6.6;

front_bulkhead_counterbore_d                      = 4.6;
front_bulkhead_counterbore_h                      = 1.7;

// ─────────────────────────────────────────────────────────────────────────────
// Knuckle
// ─────────────────────────────────────────────────────────────────────────────
knuckle_total_len                                 = 42.7;

// ─────────────────────────────────────────────────────────────────────────────
// Knuckle's steering arm and it's outer ring
// ─────────────────────────────────────────────────────────────────────────────

knuckle_outer_wall_thickness                      = 1.7;

// ─────────────────────────────────────────────────────────────────────────────
// Knuckle's bearings
// ─────────────────────────────────────────────────────────────────────────────
// Knuckle uses two bearings: inner (bigger) and outer (smaller)

// ─────────────────────────────────────────────────────────────────────────────
// Inner (bigger) bearing
// ─────────────────────────────────────────────────────────────────────────────
// outer diameter
knuckle_inner_bearing_od                          = 15;
// hole diameter
knuckle_inner_bearing_bore_d                      = 10;
// width of the bearing
knuckle_inner_bearing_w                           = 4;

// Clearance between the bearing OD and the knuckle bearing seat diameter.
knuckle_inner_bearing_clearance                   = 0.1;

// The actual hole diameter in the knuckle for the bearing
knuckle_inner_bearing_seat_d                      = 15.1;
knuckle_inner_bearing_shoulder_d                  = 13;

// ─────────────────────────────────────────────────────────────────────────────
// Outer (smaller) bearing
// ─────────────────────────────────────────────────────────────────────────────

// outer diameter
knuckle_outer_bearing_od                          = 10;
// hole diameter
knuckle_outer_bearing_bore_d                      = 5;
// width of the bearing
knuckle_outer_bearing_w                           = 4;

// Clearance between the bearing OD and the knuckle bearing seat diameter.
knuckle_outer_bearing_clearance                   = 0.1;
// Clearance between the bearing width and the knuckle bearing seat depth
knuckle_outer_bearing_z_clearance                 = 0.1;

knuckle_bearing_spacer_h                          = 1.6;
knuckle_bearing_spacer_ring_d                     = 8;
// ─────────────────────────────────────────────────────────────────────────────
// Knuckle's steering arm mount with its ring
// ─────────────────────────────────────────────────────────────────────────────

// Thickness of the steering arm mount (Z direction for extrusion)
knuckle_arm_thickness                             = 4.2;

// The chamfer/fillet radius for the corners of the arm ears
knuckle_arm_corner_r                              = 3.02;

// Diameter of the hole for the bolt that secures the steering arm to the tie rod
knuckle_arm_bolt_d                                = m3_hole_dia;

// Distance from the edge of the steering arm mount to the edge of the bolt hole
knuckle_arm_bolt_hole_offset                      = 2.0;

// The outer diameter of the ring that reinforces the steering arm mount in the knuckle
knuckle_arm_ring_outer_d                          = knuckle_inner_bearing_seat_d
                                                     + knuckle_outer_wall_thickness * 2;
// The width of the arm at the base where it connects to the knuckle
knuckle_arm_base_w                                = 9;

// The width of the arm at the narrowest point near the bolt hole
knuckle_arm_narrow_w                              = 6.06;

// The length of the main part
knuckle_arm_base_len                              = 15.3;
// The length of the part, that connects arm with knuckle
knuckle_arm_ring_connector_l                      = 4.5;

// The length of the part with the bolt hole
knuckle_arm_ear_len                               = 13;

// The angle of the arm ears with bolt holes relative to the main part of the arm
knuckle_arm_angle                                 = 54;

// The number of bolt holes in the arm ears
knuckle_arm_holes_n                               = 2;

// The gap between the bolt holes in the arm ears
knuckle_arm_holes_gap                             = 2;

// ─────────────────────────────────────────────────────────────────────────────
// Knuckle's steering arm tie rod placeholder
// The tie rod end is the link between the steering arm and the steering servo arm.
// ─────────────────────────────────────────────────────────────────────────────
// Outer diameter of the eyelet where the tie rod connects to the steering arm
knuckle_tie_rod_eye_od                            = 8.9;

// Height of the eyelet where the tie rod connects to the steering arm
knuckle_tie_rod_eye_h                             = 4.0;

// Outer diameter of the shank where the tie rod connects to the steering arm
knuckle_tie_rod_shank_od                          = 4.6;

// Diameter of the hole in the shank for the bolt that secures the tie rod to the steering arm
knuckle_tie_rod_shank_bolt_d                      = m3_hole_dia;

// Length of the neck between the eyelet and the shank where the tie rod connects to the steering arm
knuckle_tie_rod_neck_len                          = 2.05;

// Height of the neck between the eyelet and the shank where the tie rod connects to the steering arm
knuckle_tie_rod_shank_len                         = 10.8 + knuckle_tie_rod_neck_len;

// Outer diameter of the bushing that fits into the eyelet of the steering arm
knuckle_tie_rod_bushing_od                        = 6.95;

// Diameter of the hole in the bushing for the bolt that secures the tie rod to the steering arm
knuckle_tie_rod_bushing_d                         = m3_hole_dia;

// Height of the bushing that fits into the eyelet of the steering arm
knuckle_tie_rod_bushing_h                         = 10.4;

knuckle_tie_rod_bushing_bolt_color                = matte_black;
knuckle_tie_rod_bushing_bolt_head_d               = 6.62;

// Flat diameter of the bushing that fits into the eyelet of the steering arm (used for anti-rotation)
knuckle_tie_rod_bushing_flat_d                    = 5;

// Addional cylinders diameter for the cylindrical bushing type
knuckle_tie_rod_bushing_cap_d                     = 7;

// Addional cylinders height for the cylindrical bushing type
knuckle_tie_rod_bushing_cap_h                     = 5;

// Z-rotation angle of the tie rod placeholder relative to the steering arm (0 means the shank is parallel to the X-axis of the steering arm)
knuckle_tie_rod_angle                             = 0;

knuckle_tie_tilt_shift                            = 0;

// Height of the tie rod neck
knuckle_tie_rod_neck_h                            = 4.95;

// Color of the tie rod bushing
knuckle_tie_rod_bushing_color                     = metallic_silver_9;

// Color of the tie rod placeholder
knuckle_tie_rod_color                             = cobalt_blue_metallic;

knuckle_tie_rod_link_len                          = 5.1;
knuckle_tie_rod_link_od                           = 5.9;
knuckle_tie_rod_link_end_len                      = 0.4;
knuckle_tie_rod_link_thread_l                     = 8.8;
knuckle_tie_rod_link_thread_d                     = m3_hole_dia;
knuckle_tie_rod_link_color                        = metallic_silver_2;

// ─────────────────────────────────────────────────────────────────────────────
// Knuckle's ball stud housing for lower and upper arms
// ─────────────────────────────────────────────────────────────────────────────
// The two ball studs is mounted in a cylindrical housing that is part of the
// knuckle. The housing has a hole for the ball stud, and a mounting flange with
// holes for bolts to secure it to the knuckle. The housing can be secured
// either by a threaded plug or by a horizontal stopper bolt.

// Inner diameter of the hole for the ball stud in the knuckle
knuckle_ball_stud_mount_hole_d                    = front_arm_ball_stud_ball_d + 0.8;

// Thickness of the wall of the mounting flange for the ball stud housing
knuckle_ball_stud_mount_thickness                 = 1.6;

// The outer diameter of the mounting flange for the ball stud housing, which includes clearance for the bolt holes.
knuckle_ball_stud_mount_outer_d                   = knuckle_ball_stud_mount_hole_d
                                                     + knuckle_ball_stud_mount_thickness * 2;

// The height of the mounting flange for the ball stud housing (Z direction for extrusion)
knuckle_ball_stud_house_h                         = 14.5;

knuckle_ball_stud_sphere_h                        = 2;
// The size of the hole for the ball stud in the knuckle, which is a clearance
// hole for the ball part of the stud. The diameter is set to be slightly
// smaller than the ball diameter to ensure a snug fit, while still allowing the
// ball to be inserted and move freely.
knuckle_ball_stud_cap_hole_size                   = [6.8, front_arm_ball_stud_ball_d];

/** The ball stud is secured either by:
 *   1. a bushing and a threaded plug with an internal hex (hex socket), or
 *   2. a simple horizontal stopper bolt threaded through the housing (past the
 *      bushing) to prevent the ball stud from falling out. To use this option,
 *      set `knuckle_ball_stud_stopper_d` to the desired bolt diameter.
 */
knuckle_ball_stud_stopper_d                       = 0;
knuckle_ball_stud_stopper_offset                  = 2;

// ─────────────────────────────────────────────────────────────────────────────
// Hex socket threaded plug for knuckle's ball stud
// ─────────────────────────────────────────────────────────────────────────────

 // Outer diameter of the threaded plug
knuckle_threaded_plug_d                           = 10.0;

// Length diameter of the threaded plug
knuckle_threaded_plug_l                           = 5.8;

// Hex socket size for the Allen key
knuckle_threaded_plug_hex_key_size                = 4.8;

knuckle_threaded_plug_tolerance                   = 0.4;

// ─────────────────────────────────────────────────────────────────────────────
// Bushing for the ball stud
// ─────────────────────────────────────────────────────────────────────────────

knuckle_bushing_d                                 = 9;
knuckle_bushing_hole_d                            = 4;
knuckle_bushing_h                                 = 3;
knuckle_bushing_thickness                         = 0.6;
knuckle_bushing_hole_border_w                     = 0.8;

// ─────────────────────────────────────────────────────────────────────────────
// Knuckle assembly parameters
// ─────────────────────────────────────────────────────────────────────────────

// [caster_angle, camber_angle, z_angle]
knuckle_angles                                    = [0, 0, 0];
// How far to lower the knuckle in the assembly
knuckle_z_shift                                   = 0;

// ─────────────────────────────────────────────────────────────────────────────
// Center link for dual-bellcrank steering
// ─────────────────────────────────────────────────────────────────────────────

// Total length (bar plus two rings) of the “dogbone” plate
steering_center_link_len                          = 56.7;
// Overall width of the “dogbone” plate
steering_center_link_w                            = 4.8;
// Overall thickness of the “dogbone” plate
steering_center_link_thickness                    = 3.9;
// Diameter of the holes
steering_center_link_hole_d                       = 4.7;
// Outer diameter of the bosses
steering_center_link_boss_od                      = 8;
// Height of the bosses
steering_center_link_boss_h                       = 4.9;

// ─────────────────────────────────────────────────────────────────────────────
// Steering servo bracket
// ─────────────────────────────────────────────────────────────────────────────
// Hole diameter for mounting the servo to the bracket
steering_servo_bracket_servo_bolt_d               = m3_hole_dia;

// Thickness of the wall used to mount the steering servo
steering_servo_bracket_thickness                  = 3;

// Clearance used when calculating the bracket width, which is based on the
// width of the servo mounting flange. A higher value results in a narrower
// bracket, while setting it to 0.0 makes the bracket width equal to the flange
// width.
steering_servo_bracket_w_clearance                = 0.1;

// ─────────────────────────────────────────────────────────────────────────────
// Lower wall (for mounting to the chassis)
// ─────────────────────────────────────────────────────────────────────────────
// Number of holes for mounting to the chassis
steering_servo_bracket_chassis_bolt_n             = 2;

// Distance from the edge of the lower wall to the chassis mounting bolt holes
steering_servo_bracket_lower_wall_bolt_edge_pad   = 2;

// Distance between the edges of the holes
steering_servo_bracket_chassis_bolt_gap           = 4;

// Additional clearance used when calculating the thickness of the chassis
// mounting wall
steering_servo_bracket_lower_thickness_clearance  = 0;

// ─────────────────────────────────────────────────────────────────────────────
// Steering servo mounting slots in the chassis
// ─────────────────────────────────────────────────────────────────────────────
// Hole diameter for mounting to the chassis
steering_servo_mount_bolt_d                       = m3_hole_dia;

// Shape to use: either "countersunk" (a conical/beveled enlargement around a
// hole) or "counterbore" (a cylindrical recess with a flat bottom concentric
// with the hole).
steering_servo_chassis_bore_type                  = "counterbore"; // [countersunk:Conical countersunk, counterbore:Cylindrical counterbore]

// Diameter of the enlargement around the bolt hole in the chassis
steering_servo_mount_bolt_bore_d                  = m3_countersunk_head_dia + 0.3;

// Depth of the enlargement around the bolt hole in the chassis
steering_servo_mount_bolt_bore_h                  = m3_countersunk_head_h + 0.15;

// ─────────────────────────────────────────────────────────────────────────────
// Assembly view
// ─────────────────────────────────────────────────────────────────────────────
// Bolt head type used for the servo mounting bolts in the assembly view
servo_l_bracket_bolt_head_type                    = "hex"; // [pan:Pan, hex:Hex, countersunk:Countersunk, round:Round, socket:Socket]

// Bolt length for mounting to the chassis, used in the assembly view
servo_l_bracket_chassis_bolt_h                    = 10;

// Bolt head type
steering_servo_chassis_mount_bolt_head_type       = "countersunk"; // [pan:Pan, hex:Hex, countersunk:Countersunk, round:Round, socket:Socket]

// ─────────────────────────────────────────────────────────────────────────────
// Bellcrank arm to steering servo arm tie rod
// ─────────────────────────────────────────────────────────────────────────────

steering_servo_tie_rod_angle                      = 0;

steering_servo_tie_rod_body_total_len             = 68.5;
steering_servo_tie_rod_thread_len                 = 8.8;
steering_servo_tie_rod_body_len                   = 20;
steering_servo_tie_rod_body_d                     = 5.65;
steering_servo_tie_rod_body_end_len               = 0.1;
steering_servo_tie_rod_thread_d                   = m3_hole_dia;
steering_servo_tie_rod_fn                         = 6;
steering_servo_tie_rod_color                      = metallic_silver_1;

servo_tie_rod_a_eye_od                            = 7.5;
servo_tie_rod_a_eye_h                             = 3.20;

servo_tie_rod_a_shank_od                          = 4.4;
servo_tie_rod_a_shank_bolt_d                      = steering_servo_tie_rod_thread_d;
servo_tie_rod_a_neck_len                          = 2.05;
servo_tie_rod_a_neck_h                            = 3.22;
servo_tie_rod_a_shank_len                         = 10.5;

servo_tie_rod_a_bushing_od                        = 3.6;
servo_tie_rod_a_bushing_d                         = 2.5;
servo_tie_rod_a_bushing_h                         = 7;
servo_tie_rod_a_bushing_flat_d                    = 4.4;

servo_tie_rod_a_bushing_color                     = metallic_silver_9;

servo_tie_rod_a_eye_bolt_through_h                = 1;
servo_tie_rod_a_eye_bolt_h                        = 17;
servo_tie_rod_a_y_angle                           = 0;

servo_tie_rod_a_eye_bolt_lock_nut                 = true;

servo_tie_rod_a_color                             = steering_servo_tie_rod_color;
servo_tie_rod_a_screw_out_depth                   = 0;

servo_tie_rod_a_bushing_cap_h                     = undef;
servo_tie_rod_a_bushing_cap_d                     = undef;
servo_tie_rod_a_eye_bolt_color                    = undef;
servo_tie_rod_a_reverse_bolt                      = true;
servo_tie_rod_a_eye_bolt_head_d                   = undef;

servo_tie_rod_b_eye_od                            = 11.3;
servo_tie_rod_b_eye_h                             = 5.1;
servo_tie_rod_b_shank_od                          = 6;
servo_tie_rod_b_shank_bolt_d                      = m3_hole_dia;
servo_tie_rod_b_neck_len                          = 2.05;
servo_tie_rod_b_shank_len                         = 14.6;
servo_tie_rod_b_bushing_od                        = 6.95;
servo_tie_rod_b_bushing_d                         = m3_hole_dia;
servo_tie_rod_b_bushing_h                         = 6.7;
servo_tie_rod_b_bushing_flat_d                    = 5;
servo_tie_rod_b_bushing_cap_h                     = 5;
servo_tie_rod_b_bushing_cap_d                     = 7;
servo_tie_rod_b_neck_h                            = 5;
servo_tie_rod_b_eye_bolt_color                    = matte_black;
servo_tie_rod_b_bushing_color                     = metallic_silver_8;
servo_tie_rod_b_eye_bolt_head_d                   = 6.62;
servo_tie_rod_b_show_eye_bolt                     = false;
servo_tie_rod_b_reverse_bolt                      = false;
servo_tie_rod_b_bushing_rotation                  = [0, 0, 0];
servo_tie_rod_b_y_angle                           = 0;
servo_tie_rod_b_screw_out_depth                   = 0;
servo_tie_rod_b_color                             = cobalt_blue_metallic;

steering_servo_arm_total_l                        = 35.4;
steering_servo_arm_d                              = 14.75;
steering_servo_arm_len                            = steering_servo_arm_total_l
                                                     - steering_servo_arm_d;
steering_servo_arm_w                              = 7.6;
steering_servo_arm_base_h                         = 6.0;

steering_servo_arm_bolt_boss_h                    = 5.9;
steering_servo_arm_bolt_boss_w                    = 6;

steering_servo_arm_bolt_boss_spacing              = 1;
steering_servo_arm_bolt_boss_padding              = 1.2;
steering_servo_arm_bolt_boss_inner_padding        = 1.0;
steering_servo_arm_thickness                      = 3.75;
steering_servo_arm_bolt_d                         = m3_hole_dia;
steering_servo_arm_center_bolt_d                  = m3_hole_dia;
steering_servo_arm_center_bolt_bore_d             = 7.8;
steering_servo_arm_center_bolt_bore_h             = 1.2;

// ─────────────────────────────────────────────────────────────────────────────
// Upper chassis
// ─────────────────────────────────────────────────────────────────────────────
upper_chassis_bellcrank_bolt_d                    = m3_hole_dia;
upper_chassis_bellcrank_bolt_bore_d               = m3_countersunk_head_dia + 0.2;
upper_chassis_bellcrank_bolt_bore_h               = m3_countersunk_head_h + 0.15;
upper_chassis_t                                   = 4;

// ─────────────────────────────────────────────────────────────────────────────
// Upper steering panel
// ─────────────────────────────────────────────────────────────────────────────
upper_steering_panel_bolt_d                       = m3_hole_dia;
upper_steering_panel_boss_od                      = 6;
upper_steering_panel_bulkhead_bore_d              = 4.6;
upper_steering_panel_bulkhead_bore_h              = 1;
upper_steering_panel_bulkhead_spacing             = 21;
