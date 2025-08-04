/**
 * Gear Module
 *
 *
 * This module generates a parametric involute spur gear with customizable pitch
 * radius, number of teeth, pressure angle, backlash, clearance, thickness, and
 * central bore diameter for fitting onto servos or motors.
 *
 * Functions:
 * - polar_to_cartesian(rad, theta): Converts polar coordinates to Cartesian.
 * - involute_angle(b, d): Calculates the involute angle for a given base and current radius.
 * - involute_point(b, s, t, d): Generates an involute curve point for gear tooth geometry.
 * - involute_point_at_fraction(f, r, b, r2, t, s): Interpolates involute point along the tooth.
 * - radius_pitch(circular_pitch, teeth_count): Calculates pitch radius.
 * - outer_radius(r_pitch, circular_pitch, clearance): Computes gear's outer radius.
 * - calc_circular_pitch(r_pitch, teeth_count): Computes circular pitch.
 * - calc_tooth_height(r_pitch, teeth_count, clearance): Computes total tooth height.
 *
 * Module:
 * gear(...)
 *   Creates a 3D involute gear with the specified parameters.
 *
 * Parameters:
 * - r_pitch          : Pitch radius of the gear.
 * - teeth_count      : Number of teeth on the gear.
 * - thickness        : Gear thickness in the Z direction.
 * - servo_dia        : Diameter of the center hole for motor shaft.
 * - teeth_to_hide    : Number of teeth to omit for partial gears.
 * - pressure_angle   : Pressure angle in degrees (typically 20-28 deg).
 * - clearance        : Radial clearance from gear root.
 * - backlash         : Amount of intentional tooth space increase.
 *
 * Example usage:
 *   gear(teeth_count=24, r_pitch=30, backlash=0.5);
 *
 * Notes:
 * - Default gear will render with 12 teeth and 14.4 mm pitch radius.
 * - You can nest modules or geometry inside gear{} to subtract their shape from the final gear.
 * - Set backlash > 0 to ensure intermeshing gears have space for proper mesh fit.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

/* Convert a length and polar angle to Cartesian coordinates */
function polar_to_cartesian(rad, theta) = [rad * sin(theta), rad * cos(theta)];

/**
 * Compute the involute angle (in degrees) for a given base radius (b) and
 * current radius (d).
 * The current radius (d) should be greater than or equal to b.
 *
 * Returns the involute angle in degrees.
 */

function involute_angle(b, d) =
  sqrt((d / b) * (d / b) - 1) * (180 / PI) - acos(b / d);

/* Linearly interpolate between max(b, r) and r2 using fraction f,
   and then compute the involute point at that radius.
   f = 0 corresponds to max(b, r) and f = 1 corresponds to r2.
*/
function involute_point_at_fraction(f, r, b, r2, t, s) =
  involute_point(b, s, t, (1 - f) * max(b, r) + f * r2);

/* Compute the involute point (in Cartesian coordinates) for a given base radius (b),
   scaling factor (s), angular offset (t) and the computed radius (d) along the involute.
   In other words, we first compute the involute angle and then compute the Cartesian point.
*/
function involute_point(b, s, t, d) =
  polar_to_cartesian(d, s * (involute_angle(b, d) + t));

function radius_pitch(circular_pitch, teeth_count) =
  circular_pitch * teeth_count / PI / 2;;

function outer_radius(r_pitch, circular_pitch, clearance) =
  r_pitch + circular_pitch / PI - clearance;

function calc_circular_pitch(r_pitch, teeth_count) =
  (r_pitch * 2 * PI) / teeth_count;

function calc_tooth_height(r_pitch, teeth_count, clearance) =
  2 * (calc_circular_pitch(r_pitch, teeth_count) / PI) - clearance;

module gear(r_pitch         = 14.4,
            teeth_count     = 12,
            thickness       = 2,
            servo_dia       = 6.5,
            teeth_to_hide   = 0,
            pressure_angle  = 20,
            clearance       = 0.0,
            backlash        = 0.0) {

  circular_pitch = calc_circular_pitch(r_pitch, teeth_count);

  outer_rad       = outer_radius(r_pitch, circular_pitch, clearance);
  base_circle_rad = r_pitch * cos(pressure_angle);
  root_rad        = r_pitch - (outer_rad - r_pitch) - clearance;
  tooth_thickness = circular_pitch / 2 - backlash / 2;

  inv_angle  = -involute_angle(base_circle_rad, r_pitch)
    - tooth_thickness / (2 * r_pitch) / PI * 180;

  linear_extrude(height=thickness, center=true, convexity=10) {
    difference() {
      for (i = [0:teeth_count - teeth_to_hide - 1]) {
        let (right_side = [for (f = [0 : 5])
                 involute_point_at_fraction(f / 5,
                                            root_rad,
                                            base_circle_rad,
                                            outer_rad,
                                            inv_angle,
                                            1)],
             left_side = [for (f = [5: -1: 0])
                 involute_point_at_fraction(f / 5,
                                            root_rad,
                                            base_circle_rad,
                                            outer_rad,
                                            inv_angle,
                                            -1)],
             pts =
             concat([[0, -servo_dia / 10]],
                    [polar_to_cartesian(root_rad, -181 / teeth_count)],
                    [polar_to_cartesian(root_rad,
                                        root_rad < base_circle_rad
                                        ? inv_angle
                                        : -180 / teeth_count)],
                    right_side,
                    left_side,
                    [polar_to_cartesian(root_rad,
                                        root_rad < base_circle_rad
                                        ? -inv_angle
                                        : 180 / teeth_count)],
                    [polar_to_cartesian(root_rad, 181 / teeth_count)])) {
          rotate([0, 0, i * 360 / teeth_count])
            polygon(points=pts);
        }
      }
      circle(r=servo_dia / 2, $fn = 100);
      children();
    }
  }
}

gear(backlash=1);
