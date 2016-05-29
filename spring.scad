/*
2016-5-22 Chris Spencer

Flat spring generator.

Creates a simple flat spring suitable for use as a compression, tension or torsion spring.
*/

module make_spring_container(width, length, thickness, height=1, buffer=1){
    
    difference(){
        translate([0,length/2 + (buffer+thickness)/2,0])
        cube([width+buffer*2+thickness*2, length+buffer+thickness, height], center=true);
        
        translate([0, length/2, 0])
        cube([width+buffer*2, length, height*2], center=true);
    }
    
    translate([0, -thickness/2 - 0.5, 0])
    cube([width+buffer*2+thickness*2, thickness, height], center=true);
    
}

module make_rim(d, thickness, height, $fn=50){
    difference(){
        // outer rim
        cylinder(d=d, h=height, center=true, $fn=$fn);
        
        // inner rim
        cylinder(d=d-thickness*2, h=height*2, center=true, $fn=$fn);
        
        // cut rim in half
        translate([d,0,0])
        cube([d*2, d*2, d*2], center=true);
    }
}

module make_flat_spring(d=5, thickness=1, height=1, width=10, length=50, $fn=50){
    /*
    Parameters:
        
        d := diameter of bend
        thickness := horizontal thickness of "squiggle"
        height := vertical thickness
        width := horizontal width
        length := horizontal length
    */
    
    if(d-1 <= thickness){
        echo("d must be more than twice the thickness");
    }else{
        
        for(i=[0:length/(d-thickness*.99)]){
            
            echo((i%2)*2-1);
            
            translate([0, (d-thickness)*i, 0])
            mirror([(i%2), 0, 0]){
            
                for(j=[0:1:1]) mirror([j,0,0])
                translate([-width/2+d/2, 0 + j*(d*1 - thickness), 0])
                make_rim(d=d, thickness=thickness, height=height, $fn=$fn);
                
                // cross beam
                translate([0,d/2-thickness/2,0])
                cube([width-d, thickness, height], center=true);
                
            }
            
        }
    }
    
}

module make_contained_flat_spring(d=5, thickness=1, height=1, width=10, length=50, rim=5, $fn=50){
    
    make_flat_spring(d=d, width=width, length=length, thickness=thickness);
        
    color("blue")
    make_spring_container(width=width, length=length, thickness=rim);
}

module make_spiral_spring(r=1, thickness=2, height=1, loops=3){
    linear_extrude(height=height) polygon(points=concat(
        [for(t = [90:360*loops]) 
            [(r-thickness+t/90)*sin(t),(r-thickness+t/90)*cos(t)]],
        [for(t = [360*loops:-1:90]) 
            [(r+t/90)*sin(t),(r+t/90)*cos(t)]]
            ));
}

module make_contained_spiral_spring(r=1, thickness=2, height=5, loop=3){
    box_w = 30;
    
    // outer rim
    difference(){
        cube([box_w,box_w,height], center=true);
        cube([box_w-2,box_w-2,height*2], center=true);
    }
   
    translate([0,box_w/2-1,0])
    cylinder(d=5, h=height, center=true, $fn=50);
    
    difference(){
        union(){
            translate([0,0,-height/2])
            make_spiral_spring(r=r, thickness=thickness, height=height, loops=loops);
            cylinder(d=6, h=height, center=true, $fn=50);
        }
        cube([2.5,2.5,height*2], center=true);
    }
    
}

// Spiral samples.

translate([0,0,0])
make_contained_spiral_spring(r=.5, thickness=1, loops=3);

translate([-31,0,0])
make_contained_spiral_spring(r=1.5, thickness=1, loops=3);

translate([-31-31,0,0])
make_contained_spiral_spring(r=2.5, thickness=1, loops=3);

translate([0,-32,0])
make_contained_spiral_spring(r=.5, thickness=2, loops=3);

translate([-31,-32,0])
make_contained_spiral_spring(r=1.5, thickness=2, loops=3);

translate([-31-31,-32,0])
make_contained_spiral_spring(r=2.5, thickness=2, loops=3);

translate([0,-32-32,0])
make_contained_spiral_spring(r=.5, thickness=3, loops=3);

translate([-31,-32-32,0])
make_contained_spiral_spring(r=1.5, thickness=3, loops=3);

translate([-31-31,-32-32,0])
make_contained_spiral_spring(r=2.5, thickness=3, loops=3);

//translate([0,0,0])
//make_contained_spiral_spring(r=2.5, thickness=2, loops=3);

// Generate samples.
/*
//1
make_contained_flat_spring(d=3, thickness=1, width=20, length=20, rim=5, $fn=50);

//2
translate([-35,0,0])
make_contained_flat_spring(d=2.5, thickness=1, width=20, length=20, rim=5, $fn=50);

//3
translate([35,0,0])
make_contained_flat_spring(d=4.25, thickness=1, width=20, length=20, rim=5, $fn=50);

//4
translate([35,-35,0]) make_contained_flat_spring(d=4.25, thickness=1.5, width=20, length=20, rim=5, $fn=50);

//5
translate([0,-35,0]) make_contained_flat_spring(d=5, thickness=1.5, width=20, length=20, rim=5, $fn=50);

//6
translate([-35,-35,0])
make_contained_flat_spring(d=5, thickness=2, width=20, length=20, rim=5, $fn=50);
*/
