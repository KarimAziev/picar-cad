
function calc_gear_teeth(pinion_d, tooth_pitch) =
  round((PI * pinion_d) / tooth_pitch);
function calc_actual_pitch(pinion_d, gear_teeth) =
  (PI * pinion_d) / gear_teeth;
function calc_rack_teeth(rack_len, actual_pitch) =
  floor(rack_len / actual_pitch);

// Returns [gear_teeth, actual_pitch]
function pinion_compute_shared_params(pinion_d, tooth_pitch) =
  [calc_gear_teeth(pinion_d, tooth_pitch),
   calc_actual_pitch(pinion_d, calc_gear_teeth(pinion_d, tooth_pitch))];

// Returns [gear_teeth, actual_pitch, rack_teeth, rack_margin]
function pinion_add_rack_margin(core_params, rack_len) =
  [core_params[0],
   core_params[1],
   calc_rack_teeth(rack_len, core_params[1]),
   (rack_len - calc_rack_teeth(rack_len, core_params[1]) * core_params[1])];

// Returns [gear_teeth, actual_pitch, rack_teeth, rack_margin]
function pinion_sync_params(pinion_d, tooth_pitch, rack_len) =
  pinion_add_rack_margin(pinion_compute_shared_params(pinion_d, tooth_pitch),
                         rack_len);
