/**
 * Module: Printable Wheel Tire
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 *
 * This module defines shapes used to construct a tire for a wheel.
 * We assume that it will be printed using TPU.
 *
 * For users of Bambulab printers using TPU 95A HF,
 * I recommend changing the following default preset settings:
 *
 * - Maximum volumetric speed: 2 mm³/s (default is 12)
 * - Retraction length: 1 mm (default is 0.8)
 *
 */

use <../wheels/tire.scad>

tire();
