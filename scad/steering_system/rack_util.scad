include <../parameters.scad>

rack_offset_default_min_dist = rack_len / 2
  - bracket_bearing_outer_d
  - steering_bracket_linkage_thickness * 2;

function rack_offset(t, min_dist=rack_offset_default_min_dist) =
  (t < 0.25) ?
  ((t / 0.25) * min_dist) :
  (t < 0.5) ?
  (min_dist * (1 - ((t - 0.25) / 0.25))) :
  (t < 0.75) ?
  (- min_dist * ((t - 0.5) / 0.25)) :
  (- min_dist * (1 - ((t - 0.75) / 0.25)));

function pinion_angle_sync(t) =
  rack_offset(t) / steering_pinion_d / 2 * (180 / PI);

function pinion_angle(t,
                      r=steering_pinion_d / 2,
                      min_dist=rack_offset_default_min_dist) =
  let (offst = (t < 0.25) ?
       ((t / 0.25) * min_dist) :
       (t < 0.5) ?
       (min_dist*(1 - ((t - 0.25) / 0.25))) :
       (t < 0.75) ?
       (- min_dist * ((t - 0.5) / 0.25)) :
       (- min_dist*(1 - ((t - 0.75) / 0.25))))
  offst / r * (180 / PI);