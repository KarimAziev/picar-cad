# HSP 94122 rear suspension reference

Dimensions are in millimeters. A seller's dimensioned photograph establishes
the labels printed on that photograph; perspective views do not establish
unlabelled hole centers, fits, or bearing shoulders. Mechanical fit requires
measurements of the hardware used in the assembly.

## Reference identity

The on-road manual identifies the rear lower arm as **02149**, rear wheel
carrier as **02166**, rear housing as **06046**, and complete rear gearbox as
**06064**. Its differential is **02024**, with crown gear **02029**, input
pinion **02030**, differential output cups **02032**, and wheel axles
**02168**. The rear shock tower is **02042**, body-post support **02064**,
anti-squat plate **02150**, and shock absorber **02175**.

The manual images are available locally in
`~/Downloads/hsp-94122/on-road-car/`:

| File | Printed pages | Relevant content |
| --- | --- | --- |
| `1-10-GP-Car-Buggy-Monster-08.jpg` | 13–14 | Suspension adjustment diagrams and shock construction |
| `1-10-GP-Car-Buggy-Monster-09.jpg` | 15–16 | Rear differential and gearbox exploded view |
| `1-10-GP-Car-Buggy-Monster-10.jpg` | 17–18 | Dogbone dimensions; differential and tower part identities |
| `1-10-GP-Car-Buggy-Monster-11.jpg` | 19–20 | Bearing sizes; rear arm and anti-squat plate identities |
| `1-10-GP-Car-Buggy-Monster-12.jpg` | 21–22 | Rear carrier, wheel axle, housing, and shock identities |
| `1-10-GP-Car-Buggy-Monster-13.jpg` | 23–24 | Aluminum upgrade identities and shapes |
| `1-10-GP-Car-Buggy-Monster-26.jpg` | 49–50 | Vehicle exploded assembly and rear ball-joint fittings |

## Physical reference measurements

The fitted motor and differential input accept the direct 4 mm-to-5 mm sleeve.
This establishes physical coupling compatibility. Shaft-center heights and the
crown envelope must reproduce that fit in CAD; seller dimensions alone do not
establish those installation datums.

| Component | Measured dimension | Reference |
| --- | --- | --- |
| Differential crown | OD 38; axial thickness 4 | [`differential.scad`](../scad/placeholders/differential.scad), caliper model |
| Differential case | Capsule profile 25 × 20; axial length 12.6 excluding crown | Same caliper model |
| Differential journals | OD 9.17; axial length 4.25 each | Same caliper model; independent of bearing dimensions |
| Differential cups | OD 9.17; wall 1.63; bore 5.91; length/bore depth 10; slots 2.25 wide × 8.3 deep | Same caliper model |
| Differential axial stack | Crown/case span 16.6; overall 45.1 | 4 + 12.6 + 2 × (4.25 + 10) |
| Lower arm | Overall envelope 48.6–49 | Calipers |
| Rear carrier | Main barrel OD 18.3; lower bosses OD 12; lower ball to axle 10; axle to upper eye 28–29; overall width approximately 33.4 and height 50.4 | Caliper and annotated carrier measurements; axial eye offset remains unverified |
| Dogbone | Overall 61.2; ball OD 5.8; shank OD 3.8; cross pins 9.82 × 2 | Caliper measurements recorded in `rear_dogbone_spec` in [`hardware_params.scad`](../scad/suspension/rear_axle/hardware_params.scad) |
| Dogbone centers | 55.4, derived as 61.2 − 5.8 | Balls are inset one radius from each overall end |
| Camber-link hardware | Rod ends and shaft match the steering-link dimensions | [`steering_link.scad`](../scad/suspension/knuckle/steering_link.scad), confirmed matching hardware |

The carrier outside diameters do not specify its lower-ball, axle, and upper-link
center positions. These datums control wheel-barrel clearance independently of
bearing-wall and socket-wall thickness.

## Dimensions supported by labelled references

| Component | Value | Evidence and interpretation |
| --- | --- | --- |
| Differential support bearing | OD 15, ID 10, width 4 | Manual page 15, rear gearbox item 3; ball-bearing part 02138 on page 20 |
| Pinion support bearing | OD 10, ID 5, width 4 | Manual page 15, rear gearbox item 15; ball-bearing part 02139 on page 20 |
| Rear dogbone 02003T | Pin-center distance 54.5; overall length 60 | Manual page 17 calls the pin-center distance “Hole Track” |
| Front/center dogbone 02003 | Pin-center distance 55; overall length 61 | Manual page 17; distinct from the 02003T rear part |
| Differential cross pin | Diameter 3, length 24 | Manual page 15, item 8 |
| Differential 02024 | Overall axial length 45; crown outside diameter 38; 38 teeth | [Seller's dimensioned photograph](https://cdn11.bigcommerce.com/s-2nb5ti21/images/stencil/1280x1280/products/1004/33377/3__50574.1711158099.jpg?c=2) on the [02024 product page](https://www.monkeyhobby.com/hsp-rc-car-parts-02024-diff-gear-complete/) |
| Differential 02024 cups | Opening 6; cross slot width 2; exposed cup length 10 | Same dimensioned photograph; slot depth and cup floor are unlabelled |
| Differential 02024 case | Labelled transverse extent 25; body-and-crown axial extent 17 | Same photograph; another transverse label is 20, so a round case diameter alone does not describe its flat-sided shape |
| Rear lower arm, physical sample | Overall length approximately 48.6–49 | Caliper measurement of the reference arm; supports the 49 mm nominal envelope |
| Rear lower arm 02149 | Long-axis envelope 49; wide-end envelope 40; wide-end gap 25 | [Seller's dimensioned photograph](https://cdn11.bigcommerce.com/s-2nb5ti21/images/stencil/1280x1280/products/2993/33361/18__35774.1711101982.jpg?c=2) on the [02149 product page](https://www.monkeyhobby.com/hsp-rc-car-parts-02149-rear-lower-suspension-arm/) |
| Rear lower arm 02149 outer end | Labels 29.5, 21, and 11 | Same photograph. A plausible interpretation is full envelope 29.5, boss-center separation 21, and clear gap 11; the endpoint assignment needs measurement |
| Anti-squat plate 02150 | Overall length 49.5; end-hole centers 42; side-hole centers 22; height 7 | [Seller's dimensioned photograph](https://cdn11.bigcommerce.com/s-2nb5ti21/images/stencil/1280x1280/products/2992/33364/22__97503.1711277624.jpg?c=2) on the [02150 product page](https://www.monkeyhobby.com/hsp-rc-car-parts-02150-rear-anti-squat-plate/) |
| Rear shock tower 02042 | Overall width 82; overall height 34; lower labels 32 and 26 | [Seller's dimensioned photograph](https://cdn11.bigcommerce.com/s-2nb5ti21/images/stencil/1280x1280/products/2998/33355/10__50923.1711208651.jpg?c=2) on the [02042 product page](https://www.monkeyhobby.com/hsp-rc-car-parts-02042-rear-shock-tower/). The lower 32/26 dimensions do not establish a complete mounting-hole pattern |
| Input pinion 02030 | 13 teeth | [Redcat 02030 product specification](https://www.redcatracing.com/products/02030) |
| Wheel axle 02168 | Overall length 31 | [Seller's dimensioned photograph](https://modelisme-rc.net/1298-large_default/axe-de-roue-wheel-axle-hsp-1-10-02168.jpg) on the [02168 product page](https://modelisme-rc.net/direction-modelisme-rc/517-axe-de-roue-wheel-axle-hsp-1-10-02168.html) |
| Wheel axle 02168 axial labels | 16 from cup end to near cross-hole edge; 12 from far cross-hole edge to threaded tip | Same photograph; these are not independently verified thread length or bearing-seat length |

The 02007 arm photograph carries dimensions 69, 41, 26, 23, and 13.
Its identity and envelope differ from the manual's 02149 arm. The 86005
product belongs to the 1/16 HSP family. Both are useful shape references,
but their dimensions do not establish a 94122 interface.

## Mechanical relationships

The rear assembly carries the differential on two transverse bearings.
The longitudinal input pinion meshes with its crown gear. The motor shaft
coupling requires a 4 mm motor bore and a 5 mm pinion bore. Wheel drive uses
two dogbones between the differential cups and the wheel-axle cups.

The fixed 38-tooth crown and 13-tooth pinion produce a nominal speed reduction
of `38 / 13`, approximately 2.923. The external motor coupling does not set
the crown-to-pinion mesh position.

The 02166 rear carrier has two lower ball-joint sockets and an upper link
attachment. Manual page 49 identifies the lower fittings as 02152 ball-head
screws, 02164 caps, and 02153 retaining nuts. The [carrier product
photograph](https://cdn11.bigcommerce.com/s-2nb5ti21/images/stencil/1280x1280/products/1132/6332/HSP02166__65245.1407202999.jpg?c=2)
shows the paired sockets and stepped axle bore. The lower ball-joint spacing,
wheel-axis offset, and camber-link point must share one coordinate definition
with the arm and assembly placement.

The existing front knuckle uses an inner bearing of OD 15 / ID 10 / width 4
and an outer bearing of OD 10 / ID 5 / width 4, as specified in
[`rc_params.scad`](../scad/rc_params.scad). The 02168 stepped axle and 02166
carrier photographs support the same arrangement as a design inference;
the rear carrier's bearing shoulder positions require measurement.

Dogbone length is a hardware dimension. At each suspension pose, the distance
between cup engagement centers must accommodate that length with the
available plunge at both ends. The measured 45.1 mm differential envelope measures cup
mouths, not dogbone ball centers. Cup depth, slot depth, and the minimum
retained pin engagement determine the permitted center positions.

## Measurements required for a fitted assembly

The shared front housing establishes the hinge height and mounting pattern.
The measured lower-ball-to-axle distance is 10 mm; axle-to-upper-link height is
28–29 mm. These vertical dimensions are sufficient for the reference ride pose.
The fixed input-axis height is an explicit installation setting, independent of
crown diameter and housing floor thickness.

For the remaining static fit, prioritize the illustrated axial datums in
[`rear_measurements.scad`](../scad/suspension/rear_axle/rear_measurements.scad):

- E: lower ball-center plane relative to the inner bearing opening face.
- F: installed ball-center projection from the lower arm end face.
- H: upper camber-link hole center relative to the inner bearing opening face.

Cup engagement and the actual upper-link adjustment establish mechanical
closure. Wheel-level agreement alone does not verify those constraints.

1. **Differential bearing interface:** identify the physical bearing bore and
   any intermediate sleeve. The measured 9.17 mm journals differ from the
   installation preset's assumed 10 mm bearing bores. Confirm bearing seating
   against the crown/case shoulders and dogbone ball depth in the cups.
2. **Pinion installation:** tooth-envelope diameter and length, total length,
   shoulder-to-tip length, bearing seat positions, shaft flat length, and the
   crown/pinion shaft intersection or offset. Gear backlash must be checked
   with the actual matching gears.
3. **Arm joints:** inner hinge-center position from the arm envelope, hinge
   barrel diameter and thickness, outer ball-stud center separation, and
   shock-hole coordinates. The dimension labels on 02149 do not provide
   these centers directly.
4. **Rear carrier:** both bearing-seat depths, shoulder separation, wheel
   axial lower-socket and upper-link positions, and the axle cup's axial position.
5. **Shock and upper link:** extended and compressed eye-center distance,
   spring outside diameter, eye width and bore, ball-spacer stand-off, and
   the upper link's usable adjustment range.
6. **Input drive:** differential/input axis relationship and motor coupling
   engagement lengths. The housing and chassis share the front mounting pattern.

The [S102004G / 02114 upgrade shock listing](https://www.bspspares.co.uk/collections/shock-absorbers/products/s102004g-02114-1-10-car-rc-alloy-oil-filled-shock-absorber-damper-2-green-55mm)
provides 55 mm between fixing holes, 66 mm overall, and a 17 mm spring diameter.
Those dimensions identify that upgrade part; they do not establish the
compressed length or the original 02175 shock's dimensions.
