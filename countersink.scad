/*
Countersink depression for tapered screw heads.
*/

module make_countersink(d1=0, d2=0, h=0, outer=10, inner=0, $fn=25){
    /*
    d1 = shaft diameter
    d2 = head diameter
    h = height of taper
    outer = height of head mass
    inner = height of shaft mass, including taper
    */
    default_taper_height = 2;
    d1 = d1 ? d1 : 2.5;
    d2 = d2 ? d2 : 5;
    h = h ? h : default_taper_height;
    inner = (inner ? inner : 10) - default_taper_height;
    
    translate([0, 0, -default_taper_height/2])
    union(){
        
        // taper
        cylinder(d1=d1, d2=d2, h=h, center=true, $fn=$fn);
    
        // big top
    	translate([0, 0, h/2])
    	cylinder(d=d2, h=outer, center=false, $fn=$fn);
        
    	// lower bottom
    	translate([0, 0, -h/2-inner])
    	cylinder(d=d1, h=inner, center=false, $fn=$fn);
	}
}

make_countersink(inner=10);

color("blue")
translate([0,2,0])
cylinder(d=2.5, h=20, center=true, $fn=100);
