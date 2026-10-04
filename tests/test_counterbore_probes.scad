/**
  * Module: Probe expansion, spacing, and text-bound assertions.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../scad/counterbore_probes.scad>
use <../scad/lib/plist.scad>

specs = [["d", [2, 2.2],
          "bore_h", [1, 1.5],
          "bore_d", [4, 5, 6],
          "gap", 1.5],
         ["d", 3,
          "bore_h", 2,
          "bore_d", 6.5,
          "sink", true]];
rows  = hole_probe_rows(specs);
assert(len(rows) == 5);
assert([for (r = rows) plist_get("d", r)] == [2, 2, 2.2, 2.2, 3]);
assert([for (r = rows) plist_get("bore_h", r)] == [1, 1.5, 1, 1.5, 2]);
assert(plist_get("sink", rows[4]));

plain = hole_probes_layout(specs, label_mode="none");
assert(plist_get("size", plain) == [22, 38.5, 4]);
assert(plist_get("labels", plain) == []);
assert(plist_get("size", hole_probes_layout(specs, thickness=6))[2] == 6);
holes = plist_get("holes", plain);
assert(len(holes) == 13);
assert(norm(plist_get("pos", holes[1]) - plist_get("pos", holes[0])) == 6);
assert(plist_get("pos", holes[0])[1] > plist_get("pos", holes[3])[1]);
assert(plist_get("bore_d", holes[12]) == 6.5);

for (mode = ["raised", "engraved", "none"]) {
  layout = hole_probes_layout(specs, label_mode=mode);
  size = plist_get("size", layout);
  holes = plist_get("holes", layout);
  labels = plist_get("labels", layout);
  bounds = concat([for (hole = holes)
    let (p = plist_get("pos", hole),
         r = plist_get("bore_d", hole) / 2)
    [p[0] - r, p[1] - r, p[0] + r, p[1] + r]],
                  [for (label = labels)
                    let (p = label[2], s = label[1].size)
                    [p[0], p[1], p[0] + s[0], p[1] + s[1]]]);
  for (b = bounds) {
    assert(b[0] >= 2 - 0.00001 && b[1] >= 2 - 0.00001);
    assert(b[2] <= size[0] - 2 + 0.00001);
    assert(b[3] <= size[1] - 2 + 0.00001);
  }
  for (i = [0 : len(bounds) - 2], j = [i + 1 : len(bounds) - 1]) {
    a = bounds[i];
    b = bounds[j];
    assert(a[2] <= b[0] || b[2] <= a[0] || a[3] <= b[1] || b[3] <= a[1],
           str("Overlapping layout items: ", i, ", ", j));
  }
  assert(abs(max([for (b = bounds) b[2]]) + 2 - size[0]) < 0.00001);
  assert(abs(max([for (b = bounds) b[3]]) + 2 - size[1]) < 0.00001);
}

single = hole_probes_layout([["d", 2,
                              "bore_h", 1,
                              "bore_d", 4]],
                            label_mode="none");
assert(plist_get("size", single) == [8, 8, 3]);
assert(len(plist_get("holes", single)) == 1);
echo("PASS probe expansion, compact bounds, spacing, and nonoverlapping labels");
