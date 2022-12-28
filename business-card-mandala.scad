// Machi Koro Replacement Coins
// Kevin Cuzner
//
// Material: SLA Resin

// We use various dimensions, depending on where I pulled them from (PCB CAD is inches, physical measurements are mm)
inches = 25.4;
mm = 1;
degrees = 1;

//Set up for higher resolution circles
$fn = 180;

//Variables

pad_manifold = 0.01 * mm; //padding for maintaining a manifold (avoiding zero-width shapes)

// This is the final size of the cards within the case
card_width = 51 * mm; // 50.88mm measured
card_length = 89 * mm; // 88.80mm measured

// This is the size of the SVG
svg_width = 62.1 * mm;
svg_length = 100.0 * mm;

// Margin around cards for the "pit"
card_margin = 0.2 * mm;

// Margin between moving parts
slide_margin = 0.05 * mm;

// Holder dimension
wall_thickness = 2.5 * mm;
slide_size = wall_thickness / 3;
ramp_length = 5 * mm;

lid_width = card_width + 2 * card_margin + 2 * slide_size - 2 * slide_margin; // contact on 2 sides
lid_length = card_length + 2 * card_margin + wall_thickness - slide_margin; // contact on 1 side
lid_emboss = wall_thickness / 3;
lid_height = wall_thickness;

pit_width = card_width + 2 * card_margin + 2 * wall_thickness;
pit_length = card_length + 2 * card_margin + 2 * wall_thickness;
pit_height = 10 * mm;

module Lid() { // `make` me
  difference() {
    cube([lid_width, lid_length, lid_height]);
    translate([(lid_width - svg_width) / 2, (lid_length - svg_length) / 2, -pad_manifold]) {
      linear_extrude(height=lid_emboss+pad_manifold) {
        import("images/mandala.svg");
      }
    }
  }
}

// Creates a tray in the shape of the Pit section, aligned with the top at z=0
// and the non-sloped side aligned at y=0, heading towards +y
module PitTray(l, w, h, ramp=ramp_length) {
  translate([-w/2, l, h]) {
    rotate([-90 * degrees, 0, -90 * degrees]) {
      linear_extrude(height=w) {
        polygon(points=[
          [0, h],
          [l, h],
          [l, 0],
          [ramp, 0]
        ]);
      }
    }
  }
}

module Pit() { // `make` me
  difference() {
    PitTray(l=pit_length, w=pit_width, h=pit_height);
    translate([0, wall_thickness, -pad_manifold]) {
      PitTray(l=pit_length - 2 * wall_thickness, w=pit_width - 2*wall_thickness, h=pit_height - wall_thickness);
    }
    translate([-svg_width/2, 0, pit_height-lid_emboss]) {
      linear_extrude(height=lid_emboss+pad_manifold) {
        import("images/mandala.svg");
      }
    }
    slider_w = lid_width+2*slide_margin; // two contacts
    slider_l = lid_length+slide_margin; // one contact
    slider_h = lid_height+2*slide_margin; // two contacts
    translate([-slider_w/2, -pad_manifold, slide_size]) {
      cube([slider_w, slider_l+pad_manifold, slider_h]);
    }
  }
}

Pit();
