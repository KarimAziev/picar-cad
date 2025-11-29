use <../lib/functions.scad>

function calc_knuckle_connector_full_len(length,
                                         parent_dia,
                                         outer_d,
                                         border_w) =
  let (notch_width = calc_notch_width(max(parent_dia, outer_d),
                                      min(parent_dia, outer_d)))
  notch_width + length + border_w;