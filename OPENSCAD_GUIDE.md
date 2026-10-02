# Good OpenSCAD

This guide collects the project's modeling principles and practical conventions for working within OpenSCAD's limitations.

## Contents

- [Component responsibilities](#component-responsibilities)
- [Coordinates and deliberate exceptions](#coordinates-and-deliberate-exceptions)
- [Anchors](#anchors)
- [Hardware placeholders and consumers](#hardware-placeholders-and-consumers)
- [Dimensions, naming, and layouts](#dimensions-naming-and-layouts)
- [Readable code and file organization](#readable-code-and-file-organization)
- [Reusable components and polygon tools](#reusable-components-and-polygon-tools)
- [Migration status and examples to evaluate carefully](#migration-status-and-examples-to-evaluate-carefully)

## Component responsibilities

Each model should be standalone and self-contained, with a coherent interface that consumers can reuse. Reuse existing modules wherever they serve the required purpose.

A component with mounting features exposes both:

- **Normal solid mode**, including toggleable hardware placeholders such as `show_bolt` and `show_nuts` where applicable.
- **Slot mode**, providing its mounting holes, cutouts, and other geometry needed to accommodate or attach it.

Construct the body and its holes or slots in the same local coordinate system before applying assembly orientations. The body, slot mode, and associated placeholders must retain consistent placement references so they remain aligned when reused.

Provide printable models through separate files in pure printable mode, already oriented for printing.

Each component owns its input contract. It decides whether an omitted or `undef` value is allowed, receives a default, or causes an assertion. `normalize_anchor(undef)` is an accepted way to obtain the default anchor; this does not require every component to accept `undef` for every parameter.

## Coordinates and deliberate exceptions

The standard canonical orientation is:

| Axis | Dimension   | Default extent |
| ---- | ----------- | -------------- |
| X    | Width, `w`  | `0` to `w`     |
| Y    | Length, `l` | `0` to `l`     |
| Z    | Height, `h` | `0` to `h`     |

The bottom face is at `z=0`, and the model extends upward. Build the component in this orientation even when the assembly will use it in another orientation. Construct its holes and slots before the assembly rotation.

Models expose an `anchor` vector `[x, y, z]`, with each component chosen from `1`, `0`, and `-1`. The standard default is `[1, 1, 1]`.

Use these orientation and anchor conventions by default. Complex or asymmetric models may use a different origin, reference box, or orientation when it makes their construction or mechanical interfaces clearer. Explain that choice in the component's interface documentation and keep placement consistent across its supported modes.

## Anchors

An `anchor` chooses which point of the model's reference bounding box is placed at the local origin. Each component controls one axis independently, in `[x, y, z]` order.

### Per-axis meaning

For geometry built from `0` to `size[i]` on an axis:

| Anchor component | Point placed at the origin    | Translation  | Resulting bounds          | Where the model extends |
| ---------------- | ----------------------------- | ------------ | ------------------------- | ----------------------- |
| `1`              | Minimum coordinate: `0`       | `0`          | `[0, size[i]]`            | Positive direction      |
| `0`              | Midpoint: `size[i]/2`         | `-size[i]/2` | `[-size[i]/2, size[i]/2]` | Both directions         |
| `-1`             | Maximum coordinate: `size[i]` | `-size[i]`   | `[-size[i], 0]`           | Negative direction      |

**Positive anchor means the model extends in the positive direction from the origin; negative anchor means it extends in the negative direction; zero centers it on that axis.** Thus `1` puts the minimum side at the origin, and `-1` puts the maximum side there.

### The default anchor leaves a normal cube in place

These expressions produce exactly the same geometry at exactly the same coordinates:

```scad
with_anchor(size=[20, 10, 20], anchor=[1, 1, 1]) {
  cube([20, 10, 20]);
}

cube([20, 10, 20]);
```

Both occupy X `[0, 20]`, Y `[0, 10]`, and Z `[0, 20]`. With the default `centered=false`, the computed translation is `[0, 0, 0]`, and `with_anchor` directly emits its children.

Other useful placements for the same cube are:

| Anchor         | Translation       | X bounds    | Y bounds   | Z bounds    |
| -------------- | ----------------- | ----------- | ---------- | ----------- |
| `[1, 1, 1]`    | `[0, 0, 0]`       | `[0, 20]`   | `[0, 10]`  | `[0, 20]`   |
| `[0, 0, 0]`    | `[-10, -5, -10]`  | `[-10, 10]` | `[-5, 5]`  | `[-10, 10]` |
| `[-1, -1, -1]` | `[-20, -10, -20]` | `[-20, 0]`  | `[-10, 0]` | `[-20, 0]`  |
| `[0, 0, 1]`    | `[-10, -5, 0]`    | `[-10, 10]` | `[-5, 5]`  | `[0, 20]`   |
| `[-1, 0, 1]`   | `[-20, -5, 0]`    | `[-20, 0]`  | `[-5, 5]`  | `[0, 20]`   |

`[0, 0, 1]` centers the footprint on X/Y and keeps the bottom at `z=0`. For this cube, `[0, 0, 0]` produces the same result as `cube([20, 10, 20], center=true)`.

### Helper responsibilities

The implementation lives in [transforms.scad](scad/lib/transforms.scad) and [functions.scad](scad/lib/functions.scad).

- `normalize_anchor(anchor)` validates a three-element vector of `-1`, `0`, or `1`. An omitted anchor or whole `undef` becomes `[1, 1, 1]`. These are discrete placement values whose magnitudes are preserved.
- `to_anchor(anchor, size, centered=false)` returns the translation vector. Under the default input convention, each component is `(anchor[i] - 1) * size[i] / 2`. It computes coordinates only. Pass a valid anchor vector and a three-element size vector to this function.
- `with_anchor(anchor, size, centered=false)` normalizes the anchor, expands a scalar size to `[size, size, size]`, computes the translation, and applies it to all children. A zero translation passes children through directly.

The wrapper uses the supplied reference size and input-coordinate convention. It does not measure children, infer their bounding box, resize them, rotate them, or mirror them. Supply the reference box you intend to anchor. Negative anchors change placement while preserving orientation.

Individual `undef` entries are replaced with `1`, so
`normalize_anchor([undef, 0, 1])` returns `[1, 0, 1]`. Individual components
still own their optional-input and validation decisions.

### `centered=true` describes the input geometry

With `centered=true`, X and Y are assumed to already span `[-size[i]/2, size[i]/2]`. Z is still assumed to span `[0, size[2]]`.

The requested output bounds above stay the same. The translation changes to account for the input's starting coordinates: centered X/Y use `anchor[i] * size[i] / 2`, while Z always uses the default formula.

For example:

```scad
echo(to_anchor([1, 1, 1], [20, 10, 20], false)); // [0, 0, 0]
echo(to_anchor([1, 1, 1], [20, 10, 20], true));  // [10, 5, 0]
echo(to_anchor([0, 0, 0], [20, 10, 20], true));  // [0, 0, -10]
```

OpenSCAD's `cube(..., center=true)` centers all three axes. To use it as input to `with_anchor(..., centered=true)`, first raise it by half its height:

```scad
with_anchor(size=[20, 10, 20], anchor=[1, 1, 1], centered=true) {
  translate([0, 0, 10]) {
    cube([20, 10, 20], center=true);
  }
}
```

This produces the same placement as `cube([20, 10, 20])`. Passing an ordinary non-centered cube with `centered=true` would describe its input coordinates incorrectly.

### Assembly placement

Build the body, holes, slots, and associated placeholders in the same canonical coordinate system and apply the same anchor transform. Slot mode preserves the solid model's reference box so mounting features remain aligned.

An outer `translate(position)` places the selected anchor at `position`. An outer rotation rotates the already-anchored geometry about that anchor:

```scad
translate([100, 50, 30]) {
  rotate([0, 0, 90]) {
    with_anchor(size=[20, 10, 20], anchor=[0, 0, 1]) {
      cube([20, 10, 20]);
    }
  }
}
```

The bottom-face center is at `[100, 50, 30]`, and the cube rotates around it. Anchor components refer to the canonical axes before the outer rotation. Rotating children inside `with_anchor` changes the input coordinates; the supplied reference size and centering assumptions must still hold.

## Hardware placeholders and consumers

### LiPo pack example

Orient the long dimension along Y, the narrow dimension along X, and the height from `z=0` to `z=h`. Use the pack's actual height for `h`; the draft's phrase “0 to 1” is treated here as a wording error in light of its stated `0` to `h` convention.

Place the hardware placeholder in its own file or subdirectory under [scad/placeholders/](scad/placeholders/). Expose useful reusable functions for its dimensions and placement. Put the parts that accommodate it in the corresponding feature directory, such as `suspension/` or `power/`, and have consumers reuse those functions.

The placeholder file also exposes a module accepting a property list (plist) and forwarding its properties as arguments to the main module. Use [plist.scad](scad/lib/plist.scad) for the project's plist representation. Assembly-related parameters, dynamic or mapped parameters, and toggles such as `show_bolt` and `show_nuts` remain explicit arguments where appropriate.

### PCB example

A PCB placeholder exposes its mounting slots together with useful rotation and placement options. A corresponding power case is a natural consumer and may combine multiple placeholders. Its mounting geometry should stay tied to the PCB's interface.

### Dimensions and physical detail

Placeholder dimensions drive dynamically calculated dimensions of the parts that accommodate them. Keep these values linked so hardware, clearances, mounting features, and surrounding parts do not drift apart.

Detailed placeholders and hardware toggles serve physical checks as well as visualization. For example, showing the head and nut of a horizontal bolt can reveal that one will not fit in a bottom-mounted position. Include the detail needed to catch such problems before or after printing.

## Dimensions, naming, and layouts

Use snake_case and established parameter names such as `size` and `anchor`.

| Name                          | Meaning                                                                                                                                                                                                     |
| ----------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `w`                           | Width along X                                                                                                                                                                                               |
| `l`                           | Length along Y                                                                                                                                                                                              |
| `h`                           | Height along Z                                                                                                                                                                                              |
| `d`                           | Diameter                                                                                                                                                                                                    |
| `bolt_d`                      | Bolt diameter                                                                                                                                                                                               |
| `bore_d`                      | Larger diameter accompanying `bolt_d` or `d`, optionally with a countersunk shape controlled by `sink`; see [slots.scad](scad/lib/slots.scad).                                                              |
| `bolt_spacing`                | `[x, y]` spacing with holes at the centers of the rectangle's corners. See `four_corner_children` in [transforms.scad](scad/lib/transforms.scad), used with `counterbore` and bolt placeholders.            |
| `dist`, `distance`, `spacing` | For holes, the distance between hole or counterbore edges. At zero distance the holes remain separate rather than collapsing to the same center. This also makes the value easier to measure with calipers. |

Keep the distinction between the explicit `bolt_spacing` convention and edge-to-edge hole distances clear.

Shared configuration and major presets belong in the project's parameter files. Keep component-specific dimensions with the component or its domain parameter files, and derive consumer dimensions from the exposed hardware interface. Avoid duplicating a hardware measurement in each consumer.

Layouts should be configurable: changing row counts, gaps, and similar properties should update the arrangement and dependent dimensions. Reuse the project's grid and mapping facilities where applicable:

- [grid.scad](scad/core/grid.scad)
- [smd_placeholder_renderer.scad](scad/core/smd_placeholder_renderer.scad)
- [slot_layout_components.scad](scad/core/slot_layout_components.scad)

## Readable code and file organization

### Braces

Always use braces for transforms, child-module calls with bodies, loops, and conditionals, even when the body contains one statement.

Avoid:

```scad
translate(coords) children();
```

Use:

```scad
translate(coords) {
  children();
}
```

### Property lists

Format plists so keys, values, and nested entries are readable, as with a formatted dictionary or JSON object. The following are fragments of a containing plist.

Avoid:

```scad
"motor_shaft_gears", [["d", 15, "inner_d", 6.5], ["d", 15, "inner_d", 6.5]],
```

Use:

```scad
"motor_shaft_gears", [["d", 15,
                       "inner_d", 6.5],
                      ["d", 15,
                       "inner_d", 6.5]],
```

### Logical files and useful abstractions

Split code into logical files. Keep related geometry and helpers together. Extract a module or file when it represents a useful concept, enables actual reuse, or makes a substantial construction easier to follow. File count and abstraction count do not establish code quality.

The [power directory](scad/power/) illustrates meaningful separation:

```text
scad/power/
├── printable.scad
├── power_socket_lid.scad
├── power_socket_case.scad
├── power_lid.scad
├── power_case_rail.scad
├── power_case_assembly.scad
├── power_case.scad
└── common.scad
```

These files correspond to logical entities and shared functionality. There is no requirement to give every module its own file. A reader should be able to follow a part's geometry and dimension relationships without chasing trivial wrappers.

## Reusable components and polygon tools

Before adding similar functionality, inspect the relevant existing helpers and a representative component. Use examples for the specific behavior they demonstrate, with the migration caveats below.

For polygons, use [debug.scad](scad/lib/debug.scad), including `debug_polygon_text`, and [polygon_util.scad](scad/lib/polygon_util.scad). The [front chassis front frame](scad/suspension/front_chassis/front_chassis_front_frame.scad) and [front chassis rear frame](scad/suspension/front_chassis/front_chassis_rear_frame.scad) are useful examples of polygon construction and debugging.

Frequently reused hardware placeholders:

- [bolt.scad](scad/placeholders/bolt.scad)
- PCB components in [smd/](scad/placeholders/smd/)
- [screw_terminal.scad](scad/placeholders/screw_terminal.scad)
- [standoff.scad](scad/placeholders/standoff.scad)

Frequently reused library files:

- [transforms.scad](scad/lib/transforms.scad)
- [placement.scad](scad/lib/placement.scad)
- [shapes3d.scad](scad/lib/shapes3d.scad)
- [shapes2d.scad](scad/lib/shapes2d.scad)
- [plist.scad](scad/lib/plist.scad)
- [functions.scad](scad/lib/functions.scad)
- [slots.scad](scad/lib/slots.scad)
- [text.scad](scad/lib/text.scad)
- [trapezoids.scad](scad/lib/trapezoids.scad)
- [slider.scad](scad/lib/slider.scad)

## Migration status and examples to evaluate carefully

The project is migrating toward these principles and a more complex vehicle with suspension and a single RC motor. Existing code varies in quality and conformance.

### Deprecated components

- [scad/simple_robot/chassis/](scad/simple_robot/chassis/): legacy chassis and rack-and-pinion steering, migrated from `components/chassis/` and `steering_system/`. Do not use the old steering for new work; the chassis contains useful examples and parts worth preserving in an improved implementation.
- [scad/simple_robot/parameters.scad](scad/simple_robot/parameters.scad): legacy assembly presets, split into chassis, steering, power, and wheel parameter files alongside it. Shared hardware remains in `scad/parameters.scad`; suspension head-mount and knuckle defaults live independently in `scad/rc_params.scad`.
- [scad/simple_robot/wheels/](scad/simple_robot/wheels/): legacy wheel, hub, and tire models. These are not the design reference for suspension-vehicle wheels.
- [scad/simple_robot/assembly.scad](scad/simple_robot/assembly.scad) and [scad/simple_robot/assembly_guide.scad](scad/simple_robot/assembly_guide.scad): deprecated entry points. Existing build commands may still target them; their presence does not make them the design reference for new assemblies.

### Code needing refactoring

The author identifies agent-written code in [middle_chassis/](scad/suspension/middle_chassis/) and [rear_chassis/](scad/suspension/rear_chassis/) as needing manual refactoring. Treat these areas as existing implementations to understand and improve where relevant, rather than automatically copying their structure into new components.

The draft also calls out [front_chassis_rear_frame.scad](scad/suspension/front_chassis/front_chassis_rear_frame.scad), while explaining that it is mostly the author's own work: imperfect, but readable. It remains useful for the polygon techniques mentioned above. An example can demonstrate a useful technique without every aspect of its structure being a project standard.
