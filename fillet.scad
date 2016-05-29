
module make_2d_corner_fillet(width=1, depth=1, height=1, $fn=50){
    difference(){
        cube([width, depth, height], center=true);
        
        scale([1*width, 1, 1*height])
        translate([0,0,0])
        rotate([90,0,0])
        cylinder(d=1, h=depth*2, center=true, $fn=$fn);
        
        translate([width/2,0,0])
        cube([width,depth*2,height*2], center=true);
        
        translate([0,0,-height/2])
        cube([width*2,depth*2,height], center=true);
    }
}

make_2d_corner_fillet();

translate([2,0,0])
make_2d_corner_fillet(width=2);

translate([-2,0,0])
make_2d_corner_fillet(height=2);
