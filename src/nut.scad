$fn = 100;

module make_hex_nut(w, h, d=0){
    // d = inner diameter
    // w = width across the flats
    // h = height or thickness
    s = w/sqrt(3);
    difference(){
        union(){
            for(i=[0:1:2]){
                rotate([0,0,120*i])
                cube([w, s, h], center=true);
            }
        }
        if(d){
            cylinder(d=d, h=h+1, center=true);
        }
    }
}

//make_hex_nut(w=5, h=2, d=2.5);

module make_nut_2(d=2){
    make_hex_nut(w=4.8, h=2, d=d);
}

module make_nut_w4_h1p5(d=2){
    make_hex_nut(w=4, h=1.5, d=d);
}

module make_nut_2_5(d=2, h=3.5){
    make_hex_nut(w=5+0.5/2, h=h, d=d);
}

module make_nut_2_5_test(){
    difference(){
        translate([0,0,-.5])
        cube([10,10,2], center=true);
        make_nut_2_5(d=0);
    }
}

module make_nut_2_5_test_downward(){
    difference(){
        translate([0,0,1])
        cube([10,10,2*2.5], center=true);
        color("red")
        make_nut_2_5(d=0);
        color("blue")
        cylinder(d=2.5, h=10, center=true);
    }
}

module make_nut_2_5_test_punchout(){
    difference(){
        translate([0,0,1.5])
        cube([10,10,2*1.5], center=true);
        color("red")
        make_nut_2_5(d=0);
        color("blue")
        cylinder(d=2.5, h=10, center=true);
    }
    color("green")
    translate([0,0,1.8])
    cube([10,10,0.25], center=true);
}

//make_nut_2_5_test();
make_nut_w4_h1p5();
//make_nut_2_5_test_downward();
//make_nut_2_5_test_punchout();
