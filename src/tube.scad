$fn = 100;

module tube(d, t, h, center=false){
    difference(){
        cylinder(d=d, h=h, center=center);
        translate([0,0,-1])
        cylinder(d=d-t*2, h=h*2+2, center=center);
    }
}

module tube_cone(d1, d2, t, h, center=false){
    difference(){
        cylinder(d1=d1, d2=d2, h=h, center=center);
        cylinder(d1=d1-t*2, d2=d2-t*2, h=h+0.01, center=center);
    }
}

color("blue")
translate([-1+.1/2,0,0])
cylinder(d=0.1, h=6, center=false);

tube(d=2, t=0.1, h=5);

translate([5,0,0])
tube(d=2, t=0.1, h=5, center=true);

translate([-5,0,0])
tube_cone(d1=3, d2=1, t=0.1, h=5, center=true);
