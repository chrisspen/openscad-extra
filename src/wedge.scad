// Copyright 2013 Jonathan Hulka
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
// MA 02110-1301, USA.


//Creates a wedge-shaped section of a cylinder
//The result is centered with the open part of the wedge facing in the positive y direction
//h - height
//r - radius
//a - angle
//$fn=100;
module wedge(h, r, a, $fn=50)
{
    th=(a%360)/2;
    difference()
    {
        cylinder(h=h,r=r,center=true, $fn=$fn);
        if(th<90)
        {
            for(n=[-1,1])rotate(-th*n)translate([(r+0.5)*n,0,0])
                cube(size=[r*2+1,r*2+1,h+1],center=true);
        }
        else
        {
            intersection()
            {
                rotate(-th)translate([(r+0.5),(r+0.5),0])
                    cube(size=[r*2+1,r*2+1,h+1],center=true);
                rotate(th)translate([-(r+0.5),(r+0.5),0])
                    cube(size=[r*2+1,r*2+1,h+1],center=true);
            }
        }
    }
}

wedge(h=1, r=1, a=270);
