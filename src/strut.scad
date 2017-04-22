
module make_cross_beams_1(w, h, t, $fn=50){

    //sohcahtoa
    angle = atan((h-t)/(w-t));

    //c^2 = a^2 + b^2
    diagonal = sqrt(pow(w-t, 2) + pow(h-t, 2));

	    for(i=[0:1]){
	        mirror([0,0,i])
	        translate([0, -w/2+t/2, -h/2+t/2])
	        rotate([angle, 0, 0])
	        translate([-t/2, 0, -t/2])
	        cube([t, diagonal, t], center=false);
	    }
}

module make_cross_beams_2(w, h, t, $fn=50){

    //sohcahtoa
    angle = atan((h-t)/(w-t));

    //c^2 = a^2 + b^2
    diagonal = sqrt(pow(w-t, 2) + pow(h-t, 2));

	    for(i=[-1:2:1]){
			intersection(){
				translate([0, 0, -h/2*i])
				scale([1, 1, (h+t/2)/w])
				rotate([0, 90, 0])
				difference(){
					cylinder(d=w, h=t, center=true, $fn=$fn);
					cylinder(d=w-t*2, h=t, center=true, $fn=$fn);
				}
				cube([t, w, h], center=true);
			}
		}
}

module make_cross_plate(w, h, t, hub_d=0, cross_type=1, $fn=50){

    //sohcahtoa
    angle = atan((h-t)/(w-t));

    //c^2 = a^2 + b^2
    diagonal = sqrt(pow(w-t, 2) + pow(h-t, 2));

    // border
    difference(){
        cube([t,w,h], center=true);
        cube([t*2,w-t*2,h-t*2], center=true);
    }

    // cross beam
	if(cross_type==1){
		make_cross_beams_1(w=w, h=h, t=t);
	}
	if(cross_type==2){
		make_cross_beams_2(w=w, h=h, t=t);
	}
    
	if(hub_d){
	    rotate([0,90,0])
	    cylinder(d=hub_d, h=t, center=true, $fn=$fn);
	}

}

u = 5;

make_cross_plate(
	w=u*20,
	h=u*10,
	hub_d=0,//u*4,
	t=u,
	cross_type=1
);
