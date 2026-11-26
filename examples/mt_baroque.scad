// mt_baroque.scad: movable type in a Baroque italic.
//
// A rack set with "Leviathan" (Thomas Hobbes, 1651) in IM FELL DW Pica
// Italic, with a preview of the stamped title in front of it. Open this file
// in OpenSCAD and press F5.
//
// IM FELL is Igino Marini's revival of the Fell Types, the type Bishop John
// Fell gathered for the Oxford University Press in the 1670s. Its italic is
// semi-cursive: slanted, with the flowing strokes of handwriting, but each
// letter stands on its own, so it can be cast (or printed) one piece at a time.
//
// The font is free (SIL Open Font License) but isn't installed by default.
// Get "IM Fell DW Pica" from https://fonts.google.com/specimen/IM+Fell+DW+Pica
// and install the italic, IMFePIit28P.ttf. OpenSCAD 2021.01 silently swaps in
// a default font when one is missing, so if the letters come out upright, the
// font isn't installed. Help > Font List shows the fonts OpenSCAD can see.
//
// Without a download: Z003 (URW's version of Zapf Chancery, a chancery
// italic) comes with most Linux systems. Set FONT = "Z003:style=Medium Italic"
// and measure new INK values (see below).

use <../src/mt.scad>

$fn = 48;   // smoother glyph curves

FONT    = "IM FELL DW Pica:style=Italic";
SIZE    = 6;     // text size, mt.scad's default (MT_SIZE)
WORD    = "Leviathan";
BEARING = 0.2;   // space each side of a glyph. mt_letter()'s default is 0.5,
                 // but slanted letters already leave gaps between them.

// The ink of each letter in WORD along X at SIZE: [left, right] in mm from the
// glyph's centre. mt_letter() fits each piece's body to its glyph by itself,
// but setting pieces side by side needs their sizes as numbers, and OpenSCAD
// can't measure text, so they're written out here (read from an SVG export
// of each glyph). For another font or size, measure again, or give every
// letter one fixed width as the example in mt.scad does.
INK = [[-3.31, 2.71], [-1.27, 1.61], [-1.65, 2.25], [-1.07, 1.50], [-1.81, 1.55],
       [-1.17, 1.76], [-1.99, 1.70], [-1.81, 1.55], [-1.73, 2.05]];

// mt.scad's defaults for these. `use` brings in mt.scad's modules and
// functions but not its variables, so they're repeated here.
RACK_FLOOR = 3;   // MT_RACK_FLOOR
RACK_STOP  = 3;   // MT_RACK_STOP
RELIEF     = 1;   // MT_RELIEF

N = len(WORD);
assert(len(INK) == N, "INK needs one entry per letter of WORD");

function sum(v, n) = n <= 0 ? 0 : v[n - 1] + sum(v, n - 1);   // v[0] + ... + v[n-1]

WIDTHS = [for (k = INK) k[1] - k[0] + 2 * BEARING];   // each piece's set width
LINE = sum(WIDTHS, N);                                 // length of the set word
RACK_LENGTH = ceil(LINE) + 3;                          // room for type, past the stop

// Where piece i goes along the rack. The type is mirrored, so seen from above
// the word runs right-to-left from the stop (n, a, h, t, ...), and piece i's
// body starts after the pieces for letters N-1 down to i+1. Each body hugs its
// mirrored glyph, from -INK[i][1] - BEARING to -INK[i][0] + BEARING.
function piece_x(i) = RACK_STOP + LINE - sum(WIDTHS, i + 1) + INK[i][1] + BEARING;

// The rack, closed at the left end.
mt_rack(length=RACK_LENGTH, floor=RACK_FLOOR, stop_length=RACK_STOP);

// The word set in the rack.
for (i = [0 : N - 1])
    translate([piece_x(i), 0, RACK_FLOOR])
        mt_letter(WORD[i], font=FONT, size=SIZE, bearing=BEARING, relief=RELIEF);

// What the stamp leaves on the leather (the lettering at the front): the same
// glyphs as they land when the type is flipped face-down over the middle of
// the rack. It reads "Leviathan". It's drawn from the glyphs in 2D; a
// projection() of the type would show the same thing, but it forces a full
// render, which makes F5 take minutes.
color("saddlebrown")
    translate([0, -16, 0])
    linear_extrude(height=0.4)
    for (i = [0 : N - 1])
        translate([RACK_STOP + RACK_LENGTH - piece_x(i), -0.35 * SIZE])
            text(WORD[i], size=SIZE, font=FONT, halign="center", valign="baseline");
