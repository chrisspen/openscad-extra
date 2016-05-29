
module rounded_cube(size, r=0, center=false, $fn=20){
    translate([(center)?0:r, (center)?0:r, (center)?0:r])
    minkowski(){
        cube([size[0]-r*2, size[1]-r*2, size[2]-r*2], center=center);
        sphere(r, $fn=$fn);
    }
}

module rounded_cube_2d(size, r=0, center=false, $fn=20){
    translate([(center)?0:r, (center)?0:r, 0])
    minkowski(){
        cube([size[0]-r*2, size[1]-r*2, size[2]/2], center=center);
        cylinder(d=r*2, h=size[2]/2, $fn=$fn);
    }
}

module pie_slice(r=3.0, height=1, angle=30, fn=100){
    $fn = fn;
    intersection() {
        cylinder(r=r, h=height, $fn=fn);
        linear_extrude(height=height) square(r);
        rotate(angle-90) linear_extrude(height=height) square(r);
    }
}

//pie_slice(r=1, angle=15);

module rounded_pie(length, height, r, angle=30, fn=100){
    
    $fn = fn;
    
    a_minus = atan(r/length);
    
    wedge_x = r/tan(angle/2);
    
    translate([wedge_x, r, 0])
    rotate([0, 0, -.1/2])
    pie_slice(r=length - wedge_x, height=height, angle=angle+.1, fn=fn);
    
    difference(){
        union(){
            //front rounded edge
            rotate([0, 0, 0])
            translate([0, r, 0])
            hull(){
                translate([0, 0, r])
                rotate([0, 90, 0])
                cylinder(r=r, h=length, $fn=fn);
                
                translate([0, 0, height-r])
                rotate([0, 90, 0])
                cylinder(r=r, h=length, $fn=fn);
            }
            
            //back rounded edge
            rotate([0, 0, angle])
            translate([0, -r, 0])
            hull(){
                translate([0, 0, r])
                rotate([0, 90, 0])
                cylinder(r=r, h=length, $fn=fn);
                
                translate([0, 0, height-r])
                rotate([0, 90, 0])
                cylinder(r=r, h=length, $fn=fn);
            }
        }
    
        translate([wedge_x, r, -1/2])
        rotate([0, 0, 0])
        pie_slice(r=length-r+1, height=height+1, angle=angle, fn=fn);

        
    }//end diff
    
}

rounded_cube([1,2,1], r=.25, $fn=100, center=false);

translate([2, 0, 0])
rounded_cube_2d([1,2,1], r=.25, $fn=100, center=false);

translate([4, 0, 0])
rounded_pie(length=3, height=1, r=.1, angle=65, fn=100);
