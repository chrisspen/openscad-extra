
use <wedge.scad>;

module torus(r1=1, r2=2, angle=360, endstops=0, $fn=50){
    if(angle < 360){
        intersection(){
            rotate_extrude(convexity=10, $fn=$fn)
            translate([r2, 0, 0])
            circle(r=r1, $fn=$fn);
            
            color("blue")
            wedge(h=r1*3, r=r2*2, a=angle);
        }
    }else{
        rotate_extrude(convexity=10, $fn=$fn)
        translate([r2, 0, 0])
        circle(r=r1, $fn=$fn);
    }
    
    if(endstops && angle < 360){
        rotate([0,0,angle/2])
        translate([0,r2,0])
        sphere(r=r1);
        
        rotate([0,0,-angle/2])
        translate([0,r2,0])
        sphere(r=r1);
    }
}

module rounded_cylinder(d=1, h=1, r=0.1, center=true, $fn=100){
    translate([0,0,(center==true)?-h/2:0]){
        // bottom edge
        translate([0,0,r])torus(r1=r, r2=(d-r*2)/2, $fn=$fn);
        // top edge
        translate([0,0,h-r])torus(r1=r, r2=(d-r*2)/2, $fn=$fn);
        // main cylinder outer
        translate([0,0,r])cylinder(d=d, h=h-r*2, center=false, $fn=$fn);
        // main cylinder inner
        translate([0,0,0])cylinder(d=d-r*2, h=h, center=false, $fn=$fn);
    }
}

rotate([0,0,180])
torus(r1=0.5, angle=90, endstops=1);

torus(r1=0.5, r2=4);

translate([-1,0,0])
rounded_cylinder(r=0.25, center=true);

translate([1,0,0])
cylinder(d=1, h=1, $fn=50);