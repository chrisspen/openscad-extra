
module make_screw(length, head_height=1.5, d=2.5){
    difference(){
        union(){
            cylinder(d=d, h=length, center=true, $fn=100);
            translate([0,0,length/2-head_height/2])
            cylinder(r1=d/2, r2=d, h=head_height, center=true, $fn=100);
        }
                
        for(i=[0:1])
        translate([0,0,length*.5+1.5])
        rotate([90,0,90*i])
        cylinder(d=5, h=.5, center=true, $fn=100);
    }
}

module make_screw_10(){
    make_screw(length=10);
}

module make_screw_15(){
    make_screw(length=15);
}

module make_screw_20(){
    make_screw(length=20);
}

//make_screw_10();

//make_screw_15();

make_screw_20();
