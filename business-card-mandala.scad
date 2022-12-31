// Business Card Holder - Mandala
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
card_margin = 0.25 * mm;

// Margin between moving parts
slide_margin = 0.08 * mm;

// Thickness of a business card
card_thickness = 0.45 * mm;

// Number of cards to hold
card_count = 8;

// Holder dimension
wall_thickness = 2.0 * mm;
slide_depth = wall_thickness / 3; // depth into the walls
slide_z = 1 * mm; // distance from the top
ramp_length = 12 * mm;

// Detent sizing
detent_r = wall_thickness * 0.5;
detent_size = detent_r / 2;
detent_overlap = slide_margin * 2.1; // deform ever so slightly, use a little more than x2 to put some strain
detent_pos = ramp_length + 1 * mm; // from the end of the lid

lid_width = card_width + 2 * card_margin + 2 * slide_depth - 2 * slide_margin; // contact on 2 sides
lid_length = card_length + 2 * card_margin + wall_thickness + ramp_length - slide_margin; // contact on 1 side
lid_emboss = wall_thickness / 4;
lid_height = wall_thickness;

pit_width = card_width + 2 * card_margin + 2 * wall_thickness;
pit_length = card_length + 2 * card_margin + 2 * wall_thickness + ramp_length;
pit_height = slide_z + lid_height + slide_margin*2 + (card_count * card_thickness) + wall_thickness;

// Creates a ramp triangle in the same place where the internal ramp appears
module Ramp() {
  translate([-pit_width/2, pit_length - wall_thickness, pit_height]) {
    rotate([-90 * degrees, 0, -90 * degrees]) {
      linear_extrude(height=pit_width) {
        polygon(points=[
          [0, pit_height],
          [ramp_length, wall_thickness],
          [0, wall_thickness]
        ]);
      }
    }
  }
}

// Creates a slot for a detent, aligned the correct place on the y/z axes, but
// centered at x=0 (so translate later). Note that the width is 2x the detent
// depth so it can be used for either side.
module DetentSlotNegative() {
  w = (slide_depth+slide_margin)*2;
  l = detent_pos+detent_size*3;
  h = detent_size+slide_margin;
  translate([-w/2, lid_length, lid_height+slide_z+slide_margin-h]) {
    difference() {
      // Slot for the Pit detent
      translate([0, -l, 0]) {
        cube([w, l, h+pad_manifold]);
      }
      // Lid detent, placed so it touches the pit detent on the side facing the
      // ramp. Note that the top of the slot is at z=0, with the slot going +z.
      detent_z = -detent_r+detent_overlap; // protrude into the slot by the overlap
      detent_dist = detent_r*2 - detent_overlap; // vertical distance between circles
      detent_hyp = 2*detent_r+slide_margin; // distance between circle centers when touching
      detent_y = detent_pos - sin(acos(detent_dist/detent_hyp))*detent_hyp;
      translate([w/2, -detent_y, detent_z]) {
        rotate([-90 * degrees, 0, -90 * degrees]) {
          cylinder(r=detent_r, h=w+pad_manifold*2, center=true);
        }
      }
    }
  }
}

module Lid() { // `make` me
  difference() {
    // The lid is a top-embossed rectangle
    translate([-lid_width/2, 0, slide_z+slide_margin]) {
      difference() {
        cube([lid_width, lid_length-slide_margin, lid_height]);
        translate([(lid_width - svg_width) / 2, (lid_length - svg_length) / 2, -pad_manifold]) {
          linear_extrude(height=lid_emboss+pad_manifold) {
            import("images/mandala.svg");
          }
        }
      }
    }
    // Cut a slot for the detents
    translate([lid_width/2, 0, 0]) {
      DetentSlotNegative();
    }
    translate([-lid_width/2, 0, 0]) {
      DetentSlotNegative();
    }
    // Slope the end to match the ramp in the Pit
    translate([0, -slide_margin, 0]) {
      Ramp();
    }
    // Trim excess pattern after the ramp hits the embossing. This will prevent
    // floating sections.
    ramp_angle = atan(ramp_length/(pit_height-wall_thickness));
    pattern_z = slide_z + slide_margin + lid_emboss;
    cutoff = tan(ramp_angle) * pattern_z;
    translate([-lid_width/2-pad_manifold, lid_length+pad_manifold-cutoff, -pad_manifold])  {
      cube([lid_width+2*pad_manifold, cutoff+pad_manifold, pit_height+2*pad_manifold]);
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

// Creates a negative of the lid which is used to make a slot in the pit
module LidNegative() {
  difference() {
    slider_w = lid_width+2*slide_margin; // two contacts
    slider_l = lid_length+slide_margin; // one contact
    slider_h = lid_height+2*slide_margin; // two contacts
    translate([-slider_w/2, -pad_manifold, slide_z]) {
      cube([slider_w, slider_l-pad_manifold, slider_h]);
    }
    // Cut out some detents
    translate([0, lid_length-detent_pos, slide_z+slider_h+(detent_r-detent_size)]) {
      rotate([0, 90 * degrees, 0]) {
        cylinder(h=slider_w+2*pad_manifold, r=detent_r, center=true);
      }
    }
    // Slope the end to avoid interrupting the smooth finish of the ramp
    translate([0, -pad_manifold, 0]) {
      Ramp();
    }
  }
}

module Pit() { // `make` me
  difference() {
    // Outer shell
    PitTray(l=pit_length, w=pit_width, h=pit_height);
    // Inner shell
    translate([0, wall_thickness, -pad_manifold]) {
      PitTray(l=pit_length - 2 * wall_thickness, w=pit_width - 2*wall_thickness, h=pit_height - wall_thickness);
    }
    // Emboss the bottom
    translate([-svg_width/2, 0, pit_height-lid_emboss]) {
      linear_extrude(height=lid_emboss+pad_manifold) {
        import("images/mandala.svg");
      }
    }
    // Add a slot for the lid
    LidNegative();
  }
}

// This includes animation capabilities
$vpr = [248.6, 0, 146.1];
$vpt = [4.66, 52.25, 4.24];
$vpd = 248.82;
$vpf = 22.5;

//intersection() {
translate([0, -(lid_length+10)*$t, 0]) {
  Lid();
}
Pit();
//}

echo(pit_height=pit_height, ramp_angle=atan(pit_height/ramp_length));
