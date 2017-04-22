$fn = 100;

module tube(d, t, h, center=false){
    difference(){
        cylinder(d=d, h=h, center=center);
        translate([0,0,-1])
        cylinder(d=d-t, h=h*2+2, center=center);
    }
}

tube(d=2, t=0.1, h=5);

translate([5,0,0])
tube(d=2, t=0.1, h=5, center=true);
