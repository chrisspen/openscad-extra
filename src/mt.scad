// mt.scad - movable type for simple at-home stamps (e.g. tooling titles
// onto leather book covers and spines).
//
// Standalone: this file does not depend on any other file in this project.
//
// Usage:
//     use <mt.scad>
//     mt_rack(length=80);                         // holder the type slides into
//     mt_letter("A", font="Liberation Serif:style=Bold", size=6);
//     mt_base(width=3);                           // blank spacer, no glyph
//
// Every part is modelled in its print orientation and prints without supports:
//
//   * Rack: printed groove-up. The dovetail groove runs along X. Its undercut
//     walls overhang by dt_angle (measured from vertical), so keep
//     dt_angle <= 45.
//   * Letter: printed with the dovetail tenon on the bed. Going up, the tenon
//     narrows, then a short neck clears the rack's top surface, then the body
//     flares out at 45 degrees (Y only) to the full body depth. A box of
//     configurable `height` follows, and the raised glyph sits on top.
//
// Letters go into the rack in the same orientation they print in: tenon down
// into the groove, glyph facing up. A letter fully seated in a rack sits at
// translate([x, 0, rack_floor]).
//
// Coordinates:
//   X = along the rack (the direction the line of type reads)
//   Y = across the rack (the glyph's "up" is +Y)
//   Z = up (the glyph face is on top)
//
// Glyphs are mirrored by default so that the stamped impression reads
// correctly. The line of type is a mirror image too: seen from the face side,
// set the letters right-to-left.

// ---------------------------------------------------------------------------
// Shared defaults. The rack and the letters must agree on the dt_* values
// (and usually on depth), so change them in both places or pass the same
// arguments to both.
// ---------------------------------------------------------------------------

MT_FONT       = "Liberation Serif:style=Bold"; // bundled with OpenSCAD
MT_SIZE       = 6;     // text() size, ~= cap height in mm
MT_DEPTH      = 10;    // letter body size across the rack (Y)
MT_HEIGHT     = 3;     // height of the body box above the 45 degree flare
MT_RELIEF     = 1;     // how far the glyph stands up off the body
MT_BEARING    = 0.5;   // auto width: space added each side of the glyph's ink
MT_MIN_WIDTH  = 2;     // auto width: narrowest body allowed (keeps tenon strong)
MT_SPACE      = 0.3;   // width of a " " letter, as a fraction of size

MT_DT_WIDTH   = 3.5;   // groove width at the rack's top surface (the neck)
MT_DT_DEPTH   = 2;     // groove depth == tenon height
MT_DT_ANGLE   = 30;    // dovetail wall angle from vertical (<= 45 to print)
MT_BUFFER     = 0.5;   // dovetail fit gap per side, square to the angled faces.
                       // 0 = exact match, which won't fit once printed; the
                       // gap is taken up by squish-out. Comes off the tenon.
MT_GAP        = 0.3;   // neck height between the rack top and the flare
MT_FOOT       = 0.2;   // chamfer on the tenon's bed edges (elephant's foot)

MT_RACK_FLOOR = 3;     // rack material under the groove
MT_RACK_STOP  = 3;     // length of the closed end that stops the letters

// ---------------------------------------------------------------------------
// Functions
// ---------------------------------------------------------------------------

// Width of the dovetail at its wide (deep) end.
function mt_dovetail_wide(dt_width=MT_DT_WIDTH, dt_depth=MT_DT_DEPTH, dt_angle=MT_DT_ANGLE) =
    dt_width + 2 * dt_depth * tan(dt_angle);

// Width of a letter's tenon at the neck (where it leaves the rack). The
// buffer is a gap square to the angled faces, so the tenon shrinks by
// buffer / cos(dt_angle) on each side.
function mt_tenon_neck(dt_width=MT_DT_WIDTH, dt_angle=MT_DT_ANGLE, buffer=MT_BUFFER) =
    dt_width - 2 * buffer / cos(dt_angle);

// Height of a letter's face (top of the body box, bottom of the glyph)
// above the bottom of its tenon.
function mt_base_height(depth=MT_DEPTH, height=MT_HEIGHT,
                        dt_width=MT_DT_WIDTH, dt_depth=MT_DT_DEPTH,
                        dt_angle=MT_DT_ANGLE, buffer=MT_BUFFER, gap=MT_GAP) =
    dt_depth + gap + (depth - mt_tenon_neck(dt_width, dt_angle, buffer)) / 2 + height;

// Total height of a rack.
function mt_rack_height(floor=MT_RACK_FLOOR, dt_depth=MT_DT_DEPTH) = floor + dt_depth;

// YZ cross-section of a letter body: tenon, neck, 45 degree flare and box.
function _mt_letter_profile(depth, height, dt_width, dt_depth, dt_angle,
                            buffer, gap, foot) =
    let(
        t  = tan(dt_angle),
        w1 = mt_tenon_neck(dt_width, dt_angle, buffer),  // tenon at the neck
        w0 = w1 + 2 * dt_depth * t,      // tenon on the bed
        zf = dt_depth + gap,             // flare starts
        zb = zf + (depth - w1) / 2,      // box starts (45 degrees: rise == run)
        zt = zb + height,                // face
        right = concat(
            foot > 0 ? [[w0 / 2 - foot, 0], [w0 / 2 - foot * t, foot]]
                     : [[w0 / 2, 0]],
            [[w1 / 2, dt_depth], [w1 / 2, zf], [depth / 2, zb], [depth / 2, zt]]
        )
    )
    concat(right, [for (i = [len(right) - 1 : -1 : 0]) [-right[i][0], right[i][1]]]);

// YZ cross-section of the rack's groove, extended past the top surface so it
// cuts cleanly.
function _mt_groove_profile(dt_width, dt_depth, dt_angle) =
    let(w = mt_dovetail_wide(dt_width, dt_depth, dt_angle))
    [[-w / 2, 0], [w / 2, 0],
     [dt_width / 2, dt_depth], [dt_width / 2, dt_depth + 1],
     [-dt_width / 2, dt_depth + 1], [-dt_width / 2, dt_depth]];

function _mt_blank(s) = len([for (c = s) if (c != " ") c]) == 0;

// ---------------------------------------------------------------------------
// Internal modules
// ---------------------------------------------------------------------------

// Extrude a 2D profile drawn in (Y, Z) along +X from x=0 to x=length.
module _mt_extrude_x(length) {
    rotate([90, 0, 90]) linear_extrude(height=length) children();
}

module _mt_check(depth, dt_width, dt_depth, dt_angle, buffer) {
    assert(dt_angle > 0 && dt_angle < 90, "mt: dt_angle must be between 0 and 90");
    assert(buffer >= 0, "mt: buffer can't be negative");
    assert(mt_tenon_neck(dt_width, dt_angle, buffer) > 0,
           "mt: buffer is too large for dt_width");
    assert(depth >= mt_dovetail_wide(dt_width, dt_depth, dt_angle),
           "mt: depth must be at least the dovetail's wide end (mt_dovetail_wide())");
    if (dt_angle > 45)
        echo(str("WARNING: mt: dt_angle=", dt_angle,
                 " overhangs more than 45 degrees, so the rack will need supports"));
}

// The glyph in 2D, mirrored for stamping, with its baseline at y=baseline.
module _mt_glyph(char, font, size, baseline, mirrored) {
    translate([0, baseline])
    scale([mirrored ? -1 : 1, 1])
    text(char, size=size, font=font, halign="center", valign="baseline");
}

// A 2D band that spans the glyph's ink in X (plus bearings) and runs well
// past the body in Y. The hull of two copies of the glyph, one far above the
// other, covers exactly the glyph's X extent in between.
module _mt_ink_band(char, font, size, baseline, mirrored, depth, bearing, min_width) {
    L = 2 * depth + 2 * size;
    hull() {
        offset(delta=bearing) hull() {
            translate([0,  L]) _mt_glyph(char, font, size, baseline, mirrored);
            translate([0, -L]) _mt_glyph(char, font, size, baseline, mirrored);
        }
        square([min_width, 2 * L], center=true);
    }
}

// ---------------------------------------------------------------------------
// 1) Rack: a long bar with a dovetail groove along X, groove facing up.
//
// length      usable groove length (the space available for type)
// width       rack size across the groove (Y); defaults to the letter depth
// floor       material under the groove
// stop        true closes the x=0 end so letters stop there; letters load
//             from the +X end. false leaves both ends open.
// stop_length length of the closed end
//
// The rack spans x = [0, length (+ stop_length)], is centered in Y and sits on
// z=0. A letter seated against the stop is at
//     translate([stop_length + letter_width/2, 0, floor]).
// ---------------------------------------------------------------------------
module mt_rack(length=100, width=MT_DEPTH, floor=MT_RACK_FLOOR,
               stop=true, stop_length=MT_RACK_STOP,
               dt_width=MT_DT_WIDTH, dt_depth=MT_DT_DEPTH, dt_angle=MT_DT_ANGLE) {
    _mt_check(width, dt_width, dt_depth, dt_angle, 0);
    x0 = stop ? stop_length : 0;
    total = x0 + length;

    difference() {
        translate([0, -width / 2, 0])
            cube([total, width, floor + dt_depth]);
        translate([stop ? x0 : -1, 0, floor])
            _mt_extrude_x(total + 2)
            polygon(_mt_groove_profile(dt_width, dt_depth, dt_angle));
    }
}

// ---------------------------------------------------------------------------
// 2) Base letter: the type body with no glyph, made to fit mt_rack(). It also
//    works as a blank spacer between words.
//
// width   body size along the rack (X), i.e. the set width
// depth   body size across the rack (Y)
// height  height of the box between the 45 degree flare and the face
// buffer  fit gap between each angled side of the tenon and the groove,
//         measured square to the faces. 0 matches the groove exactly, which
//         won't fit once printed. The default 0.5 leaves room for squish-out
//         so the letter slides. The rack is cut at nominal size, so the whole
//         buffer comes off the tenon.
//
// It is centered in X and Y, with the bottom of the tenon on z=0. The face is
// at z = mt_base_height(...).
// ---------------------------------------------------------------------------
module mt_base(width=MT_SIZE, depth=MT_DEPTH, height=MT_HEIGHT,
               dt_width=MT_DT_WIDTH, dt_depth=MT_DT_DEPTH, dt_angle=MT_DT_ANGLE,
               buffer=MT_BUFFER, gap=MT_GAP, foot=MT_FOOT) {
    _mt_check(depth, dt_width, dt_depth, dt_angle, buffer);
    translate([-width / 2, 0, 0])
        _mt_extrude_x(width)
        polygon(_mt_letter_profile(depth, height, dt_width, dt_depth, dt_angle,
                                   buffer, gap, foot));
}

// ---------------------------------------------------------------------------
// 3) Letter: a base letter with a raised glyph of `char` in `font` on its face.
//
// char       the character to set (any string works, e.g. a ligature)
// font       any OpenSCAD font name, e.g. "Liberation Sans:style=Italic"
// size       text() size; roughly the cap height in mm
// width      undef: fit the body to the glyph's ink plus `bearing` each side
//            (proportional spacing, never narrower than min_width).
//            number: a fixed set width with the glyph centered in it.
// relief     how far the glyph stands up off the face
// baseline   Y position of the baseline relative to the body center. The
//            default puts it at the same place for every letter of the same
//            size, so a line of type stays on one baseline.
// mirrored   mirror the glyph so the impression reads correctly
//
// The remaining parameters are the same as mt_base().
//
// A glyph wider than a fixed `width`, or taller than `depth`, hangs past the
// body and would need supports, so make the body bigger instead.
// ---------------------------------------------------------------------------
module mt_letter(char, font=MT_FONT, size=MT_SIZE, width=undef,
                 relief=MT_RELIEF, baseline=undef, mirrored=true,
                 bearing=MT_BEARING, min_width=MT_MIN_WIDTH,
                 depth=MT_DEPTH, height=MT_HEIGHT,
                 dt_width=MT_DT_WIDTH, dt_depth=MT_DT_DEPTH, dt_angle=MT_DT_ANGLE,
                 buffer=MT_BUFFER, gap=MT_GAP, foot=MT_FOOT) {
    blank = _mt_blank(char);
    bl = is_undef(baseline) ? -0.35 * size : baseline;
    face = mt_base_height(depth, height, dt_width, dt_depth, dt_angle, buffer, gap);
    w = !is_undef(width) ? width
      : blank            ? max(min_width, MT_SPACE * size)
      :                    undef;

    module body(bw) {
        mt_base(width=bw, depth=depth, height=height,
                dt_width=dt_width, dt_depth=dt_depth, dt_angle=dt_angle,
                buffer=buffer, gap=gap, foot=foot);
    }

    if (is_undef(w)) {
        intersection() {
            body(1000);
            translate([0, 0, -1])
                linear_extrude(height=face + 2)
                _mt_ink_band(char, font, size, bl, mirrored, depth, bearing, min_width);
        }
    } else {
        body(w);
    }

    if (!blank)
        translate([0, 0, face - 0.01])
            linear_extrude(height=relief + 0.01)
            _mt_glyph(char, font, size, bl, mirrored);
}

// ---------------------------------------------------------------------------
// Example usage. Open this file in OpenSCAD and press F5 to see it.
// It is skipped when another file loads the library with `use <mt.scad>`
// (but not with `include <mt.scad>`).
// ---------------------------------------------------------------------------

$fn = 48;   // smoother glyph curves

// A rack with 40 mm of room for type, closed at the left end.
mt_rack(length=40);

// "PROSE" set in the rack. A stamp is a mirror image of what it prints, so
// the glyphs are mirrored and, seen from above, the letters go in
// right-to-left: E, S, O, R, P. They use a fixed 7 mm width so their
// positions are easy to work out. A seated letter sits at z = MT_RACK_FLOOR,
// starting after the stop at x = MT_RACK_STOP.
module _mt_example_type() {
    translate([MT_RACK_STOP +  3.5, 0, MT_RACK_FLOOR]) mt_letter("E", width=7);
    translate([MT_RACK_STOP + 10.5, 0, MT_RACK_FLOOR]) mt_letter("S", width=7);
    translate([MT_RACK_STOP + 17.5, 0, MT_RACK_FLOOR]) mt_letter("O", width=7);
    translate([MT_RACK_STOP + 24.5, 0, MT_RACK_FLOOR]) mt_letter("R", width=7);
    translate([MT_RACK_STOP + 31.5, 0, MT_RACK_FLOOR]) mt_letter("P", width=7);
}
_mt_example_type();

// What the stamp leaves on the leather (the brown lettering at the front):
// the type above, flipped face-down over the rack's middle, keeping the slice
// that presses in. It reads "PROSE".
color("saddlebrown")
    translate([0, -32, 0])
    linear_extrude(height=0.4)
    translate([MT_RACK_STOP + 40, 0]) mirror([1, 0])
    projection(cut=true)
    translate([0, 0, 0.5 - (MT_RACK_FLOOR + mt_base_height() + MT_RELIEF)])
    _mt_example_type();

// Loose pieces as they sit on the print bed (tenon down, glyph up).
translate([ 5, -16, 0]) mt_letter("A");                                  // auto width, default font
translate([15, -16, 0]) mt_letter("g", font="Liberation Sans");          // another font
translate([25, -16, 0]) mt_letter("R", font="Liberation Serif:style=Bold Italic");
translate([35, -16, 0]) mt_base(width=3);                                // blank spacer
