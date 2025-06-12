module dotted_lines_fill_y(y_length, starts, y_offset, r) {
  step = y_offset + 2*r;
  amount = floor(y_length / step) + 1;
  for(i = [0 : amount - 1]) {
    translate([starts[0], starts[1] + i * step])
      circle(r = r, $fn = 50);
  }
}
module dotted_lines_y(amount, starts, y_offset, r) {
  for (i = [0:amount-1]) {
    translate([starts[0], starts[1] + i*(y_offset + r*2)]) {
      circle(r = r, $fn = 50);
    }
  }
}

module rounded_rect(size, r=5, center=false) {
  w = size[0];
  h = size[1];
  offset = center ? [-w/2, -h/2] : [0, 0];

  hull() {
    translate([ r, r ] + offset)         circle(r);
    translate([ w - r, r ] + offset)     circle(r);
    translate([ r, h - r ] + offset)     circle(r);
    translate([ w - r, h - r ] + offset) circle(r);
  }
}
