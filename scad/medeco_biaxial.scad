use <keygen.scad>
include <medeco.scad>

module medeco_biaxial(bitting="",
                      outline_name="1515",
                      warding_name="1515", 
                      m3_master_depth=0, 
                      m3_service_depth=0) {

    name = "Medeco Biaxial";

    /*
        "A" variants of key outlines indicates 6-pin version.

        Bitting is specified from bow to tip, 1-6, with 1 being the shallowest cut and 6 being the deepest.

        After each number, a letter K,B,Q,M,D,S is specified for the cut angle and offset.

        Example: 2K5B3Q6M3S
    */

    outlines_k = ["A1515",
                  "1515",
                  "A1517",
                  "1517",
                  "1518",
                  "1542",
                  "1543",
                  "A1638",
                  "1638",
                  "1644",
                  "1655"];

    wardings_k = ["1515",
                  "1517",
                  "1518",
                  "1542",
                  "1543",
                  "1638",
                  "1644",
                  "1655",
                  "m3_eagle_??"];

    outline_param = key_lkup(outlines_k, outlines_v, outline_name);
    outline_points = outline_param[0];
    outline_paths = outline_param[1];
    offset = outline_param[2];
    engrave_points = outline_param[3];
    engrave_paths = outline_param[4];

    warding_points = key_lkup(wardings_k, wardings_v, warding_name);
    
    cut_locations = [for(i=[0.244, 0.414, 0.584, 0.754, 0.924, 1.094]) i*25.4];
    depth_table = [for(i=[0.272+0.025:-0.025:0.141]) i*25.4];
    // 0 = uncut
    m3_depth_table = [for(i=[0.2835, 0.6085, 0.5585, 0.5085, 0.4585, 0.4085, 0.3585]) i*25.4];

    angles_k = ["K", "B", "Q", "M", "D", "S"];
    angles_v = [[20, -.7874], [0, -.7874], [-20, -.7874],
                [20, .7874],  [0, .7874],  [-20, .7874]];

    bitting_depth = [for(i=[0:2:len(bitting)-1]) bitting[i]];
    bitting_angle = [for(i=[1:2:len(bitting)-1]) bitting[i]];
    heights = key_code_to_heights(bitting_depth, depth_table);
    angles_and_offsets = [for(c=bitting_angle) key_lkup(angles_k, angles_v, c)];
    angles = [for(c=angles_and_offsets) c[0]];
    offsets = [for(c=angles_and_offsets) c[1]];

    difference() {
        if($children == 0) {
            key_blank(outline_points,
                      warding_points,
                      outline_paths=outline_paths,
                      engrave_right_points=engrave_points,
                      engrave_right_paths=engrave_paths,
                      engrave_left_points=engrave_points,
                      engrave_left_paths=engrave_paths,
                      offset=offset,    
                      plug_diameter=12.7);
        } else {
            children(0);
        }
        key_bitting(heights, cut_locations + offsets,
                    flat=.381, angle=86, // from CW-1012 cutter specs
                    angles=angles);
        

        if (m3_service_depth != 0 || m3_master_depth != 0) {
            m3_master_depth_mm=m3_depth_table[m3_master_depth];
            m3_service_depth_mm=m3_depth_table[m3_service_depth];
    
            translate([-0.25,(0-m3_service_depth_mm)-0.65,1.8]) 
                rotate([0,-90,0]) 
                    cylinder(h=2, r=0.65, $fn=15);
            translate([-0.25-2,(0-m3_service_depth_mm)-100,0])
                cube([2,100,1.8]);
            translate([-0.95-2,(0-m3_master_depth_mm)-100,0])
                cube([2,100,1.8]);
        }
    }


}

// Defaults
bitting="";
outline="1515";
warding="1515";
m3_service_depth=0;
m3_master_depth=0;
medeco_biaxial(bitting, outline, warding, m3_master_depth, m3_service_depth);
