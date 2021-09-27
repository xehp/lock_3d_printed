// These are some generic modules for openscad.
// Copyright (C) 2013 Henrik Björkman, www.eit.se, 
// May be distributed as under Gnu public license version 3.
//
// History
// Created 2012-09-25 By Henrik
// 2013-05-29 Added h_spur_gear and h_rack_gear. Henrik
// 2013-11-03 Added h_cube_rounded_corners. /Henrik


// A holow centered cylinder
module h_holow_cylinder(outer_radius, inner_radius, hight)
{
  difference() 
  {
    cylinder(hight,outer_radius,outer_radius,$fn=90, center=true);
    cylinder(hight*2,inner_radius,inner_radius,$fn=90, center=true);
  }
}


// A simple centered cylinder
module h_cylinder(radius, hight)
{
  //cylinder(hight,radius,radius,$fn=90, center=true);
  cylinder(hight,radius,radius,$fs=0.5, center=true);
}


// Internal module used by h_triangle_with_screw_holes
module h_rounded_triangle(width, depth)
{
    hull() 
    {
       translate([width/2,0,0]) h_cylinder(h_screw_hole_radius*2,h_wall_thicknes);

       translate([-width/2,0,0]) h_cylinder(h_screw_hole_radius*2,h_wall_thicknes);
    }

    hull() 
    {
       translate([width/2,0,0]) h_cylinder(h_screw_hole_radius*2,h_wall_thicknes);

       translate([0,depth,0]) h_cylinder(h_screw_hole_radius*2,h_wall_thicknes);
    }

    hull() 
    {
       translate([-width/2,0,0]) h_cylinder(h_screw_hole_radius*2,h_wall_thicknes);

       translate([0,depth,0]) h_cylinder(h_screw_hole_radius*2,h_wall_thicknes);
    }
}


// Use this if screw holes are needed at specified positions.
// The material is extended to go around the screw holes.
module h_triangle_with_screw_holes(width, depth, wall_thicknes,screw_hole_radius)
{
    difference() 
    {
      // En triangel
      h_rounded_triangle(width, depth);

      // med skruvhål i varje hörn

      translate([width/2,0,0])
      h_cylinder(screw_hole_radius,wall_thicknes);

      translate([-width/2,0,0])
      h_cylinder(screw_hole_radius,wall_thicknes);

      translate([0,depth,0])
      h_cylinder(screw_hole_radius,wall_thicknes);

    }


}

// Internal module used by h_trapetsoid_with_screw_holes
module h_rounded_trapetsoid(base_width, top_width, depth)
{
    hull() 
    {
       translate([base_width/2,0,0]) h_cylinder(h_screw_hole_radius*2,h_wall_thicknes);
       translate([-base_width/2,0,0]) h_cylinder(h_screw_hole_radius*2,h_wall_thicknes);
    }

    hull() 
    {
       translate([base_width/2,0,0]) h_cylinder(h_screw_hole_radius*2,h_wall_thicknes);
       translate([top_width/2,depth,0]) h_cylinder(h_screw_hole_radius*2,h_wall_thicknes);
    }

    hull() 
    {
       translate([-base_width/2,0,0]) h_cylinder(h_screw_hole_radius*2,h_wall_thicknes);
       translate([-top_width/2,depth,0]) h_cylinder(h_screw_hole_radius*2,h_wall_thicknes);
    }

    hull() 
    {
       translate([top_width/2,depth,0]) h_cylinder(h_screw_hole_radius*2,h_wall_thicknes);
       translate([-top_width/2,depth,0]) h_cylinder(h_screw_hole_radius*2,h_wall_thicknes);
    }

}


// To be used when position of screw holes are to be at given positions. 
// Material is placed around those positions.
module h_trapetsoid_with_screw_holes(base_width, top_width, depth)
{
    translate([0,-depth/2,0])

    difference() 
    {
      h_rounded_trapetsoid(base_width, top_width, depth);

      // med skruvhål i varje hörn

      translate([base_width/2,0,0])
      h_cylinder(h_screw_hole_radius,h_wall_thicknes);

      translate([-base_width/2,0,0])
      h_cylinder(h_screw_hole_radius,h_wall_thicknes);

      translate([top_width/2,h_depth,0])
      h_cylinder(h_screw_hole_radius,h_wall_thicknes);

      translate([-top_width/2,h_depth,0])
      h_cylinder(h_screw_hole_radius,h_wall_thicknes);
    }
}


function h_distance2d(x1,y1,x2,y2) = sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2));


// Places a cylinder inside the tip of a triangle sort of.
module h_cylinder_inside(x0,y0,x1,y1,x2,y2,radius,height)
{
  //translate([x0,y0,0]) h_cylinder(1, height*2);//
  //translate([x1,y1,0]) h_cylinder(1, height*2);//
  //translate([x2,y2,0]) h_cylinder(1, height*2);//

  d01=h_distance2d(x0,y0,x1,y1);
  d02=h_distance2d(x0,y0,x2,y2);

  xn=x0-(x0-x2)*d01/d02;
  yn=y0-(y0-y2)*d01/d02;

  //translate([xn,yn,0]) h_cylinder(0.25, height*8);//

  xm=(x1+xn)/2;
  ym=(y1+yn)/2;

  //translate([xm,ym,0]) h_cylinder(0.5, height*4);//

  d1m=sqrt((xm-x1)*(xm-x1) + (ym-y1)*(ym-y1));
  d0m=sqrt((xm-x0)*(xm-x0) + (ym-y0)*(ym-y0));

  xc=x0+(xm-x0)*radius*d01/(d1m*d0m);
  yc=y0+(ym-y0)*radius*d01/(d1m*d0m);
  
  translate([xc,yc,0]) h_cylinder(radius, height);
}

// Places a smaller cylinder inside the tip of a triangle at the position where a larger one would fit.
module h_cylinder_inside_screw_hole(x0,y0,x1,y1,x2,y2,radius,height, hole_radius)
{
  //translate([x0,y0,0]) h_cylinder(1, height*2);
  //translate([x1,y1,0]) h_cylinder(1, height*2);
  //translate([x2,y2,0]) h_cylinder(1, height*2);

  d01=h_distance2d(x0,y0,x1,y1);
  d02=h_distance2d(x0,y0,x2,y2);

  xn=x0-(x0-x2)*d01/d02;
  yn=y0-(y0-y2)*d01/d02;

  //translate([xn,yn,0]) h_cylinder(0.25, height*8);

  xm=(x1+xn)/2;
  ym=(y1+yn)/2;

  //translate([xm,ym,0]) h_cylinder(0.5, height*4);

  d1m=sqrt((xm-x1)*(xm-x1) + (ym-y1)*(ym-y1));
  d0m=sqrt((xm-x0)*(xm-x0) + (ym-y0)*(ym-y0));

  xc=x0+(xm-x0)*radius*d01/(d1m*d0m);
  yc=y0+(ym-y0)*radius*d01/(d1m*d0m);
  
  translate([xc,yc,0]) h_cylinder(hole_radius, height);
}





// A triangle with rounded corners
// Use this if the outer rim of the triangle is known.
module h_rounded_3_corners(x1,y1,x2,y2,x3,y3,radius,height)
{
   // Place 3 circles and fill the area between them.

  hull() 
  {
    h_cylinder_inside(x1,y1,x2,y2,x3,y3,radius,height);
    h_cylinder_inside(x2,y2,x1,y1,x3,y3,radius,height);
    h_cylinder_inside(x3,y3,x2,y2,x1,y1,radius,height);
  }
}


// A triangle with rounded corners
// Use this if the outer rim of the triangle is known.
// Screw holes are placed near the corners.
module h_rounded_3_corners_screw_holes(x1,y1,x2,y2,x3,y3,radius,height, hole_radius)
{
   // Place 3 circles and fill the area between them.

  difference() 
  {
    h_cylinder_inside(x1,y1,x2,y2,x3,y3,radius,height);
    h_cylinder_inside_screw_hole(x1,y1,x2,y2,x3,y3,radius,height,hole_radius);
    h_cylinder_inside_screw_hole(x2,y2,x1,y1,x3,y3,radius,height,hole_radius);
    h_cylinder_inside_screw_hole(x3,y3,x2,y2,x1,y1,radius,height,hole_radius);    
  }
}



// 4 corners with rounded corners
// The corners must be in order 1,2,3,4 so 
// that 1 is opposite 3 and 2 is opposite 4.
//
//   1------4
//   |      |
//   |      |
//   2------3
//
// If not it will not be correctly dimensioned. It will be too small!
//
module h_rounded_4_corners(x1,y1,x2,y2,x3,y3,x4,y4,radius,height)
{

  hull() 
  {
    h_cylinder_inside(x1,y1,x2,y2,x4,y4,radius,height);
    h_cylinder_inside(x2,y2,x1,y1,x3,y3,radius,height);
    h_cylinder_inside(x3,y3,x2,y2,x4,y4,radius,height);
    h_cylinder_inside(x4,y4,x1,y1,x3,y3,radius,height);
  }
}


// 4 corners with rounded corners and screw holes
// The corners must be in order 1,2,3,4 so 
// that 1 is opposite 3 and 2 is opposite 4.
//
//   1------4
//   |      |
//   |      |
//   2------3
//
module h_rounded_4_corners_screw_holes(x1,y1,x2,y2,x3,y3,x4,y4,radius,height, hole_radius)
{

  difference() 
  {
    h_rounded_4_corners(x1,y1,x2,y2,x3,y3,x4,y4,radius,height);
    h_cylinder_inside_screw_hole(x1,y1,x2,y2,x4,y4,radius,height,hole_radius);
    h_cylinder_inside_screw_hole(x2,y2,x1,y1,x3,y3,radius,height,hole_radius);
    h_cylinder_inside_screw_hole(x3,y3,x2,y2,x4,y4,radius,height,hole_radius);
    h_cylinder_inside_screw_hole(x4,y4,x1,y1,x3,y3,radius,height,hole_radius);
    
  }
}




// Internal module used by h_frame_with_4_rounded_corners
module h_rounded_4_corners_inner_frame(x1,y1,x2,y2,x3,y3,x4,y4,radius,height, hole_radius)
{
   // Place 3 circles and fill the area between them.

  hull() 
  {
    h_cylinder_inside_screw_hole(x1,y1,x2,y2,x4,y4,radius,height,hole_radius);
    h_cylinder_inside_screw_hole(x2,y2,x1,y1,x3,y3,radius,height,hole_radius);
    h_cylinder_inside_screw_hole(x3,y3,x2,y2,x4,y4,radius,height,hole_radius);
    h_cylinder_inside_screw_hole(x4,y4,x1,y1,x3,y3,radius,height,hole_radius);
  }
}


// 4 corners with rounded corners
// The corners must be in order 1,2,3,4 so 
// that 1 is opposite 3 and 2 is opposite 4.
// If not it will not be correctly dimensioned. It will be too small!
//
// It shall be like this:
//
//   1------4
//   |      |
//   |      |
//   2------3
//
// That is NOT like this:
//
//   1------3
//   |      |   This will be interpreted as a "time glass" shape.
//   |      |
//   2------4
//
//
module h_frame_with_4_rounded_corners(x1,y1,x2,y2,x3,y3,x4,y4,radius,height)
{
  difference() 
  {
    h_rounded_4_corners(x1,y1,x2,y2,x3,y3,x4,y4,radius,height);
    h_rounded_4_corners_inner_frame(x1,y1,x2,y2,x3,y3,x4,y4,radius*2,height,radius);
  }
}


// more like a cuboid, 4 edges are rounded, upper and lower are not.
module h_cube_rounded_corners(sizeX, sizeY, radius, height)
{
  h_rounded_4_corners(sizeX/2,sizeY/2 ,sizeX/2, -sizeY/2, -sizeX/2, -sizeY/2, -sizeX/2, sizeY/2, radius, height);
}



//http://en.wikibooks.org/wiki/OpenSCAD_User_Manual/2D_to_3D_Extrusion
module h_torus(torus_radius, circle_radius)
{
  rotate_extrude(convexity = 10, $fn = 36)
  translate([torus_radius, 0, 0])
  circle(r = circle_radius, $fn = 36, center=true);
}


module h_torus_low_res(torus_radius, circle_radius)
{
  rotate_extrude(convexity = 10, $fn = 12)
  translate([torus_radius, 0, 0])
  circle(r = circle_radius, $fn = 12, center=true);
}

// Total hight will be 2*circle_radius+additional_hight
module h_streched_torus(torus_radius, circle_radius, additional_hight)
{
  if (additional_hight>0)
  {
   union()
   {
    h_holow_cylinder(torus_radius+circle_radius, torus_radius-circle_radius, additional_hight);

    translate([0, 0, additional_hight/2])
    h_torus(torus_radius, circle_radius);

    translate([0, 0, -additional_hight/2])
    h_torus(torus_radius, circle_radius);
   }
  }
  else
  {
    h_torus(torus_radius, circle_radius);
  }
}


module h_torus_half(torus_radius, circle_radius, angle)
{
  difference()
  {
    h_torus_low_res(torus_radius, circle_radius);
    translate([0, -torus_radius*2, -torus_radius/2])
    cube([torus_radius*2,torus_radius*4,torus_radius]);
  }
  translate([0, -torus_radius, 0])
  sphere(circle_radius, $fn = 12);
  translate([0, torus_radius, 0])
  sphere(circle_radius, $fn = 12);
}



// Use this to mask out everything below the xy plane
module h_mask_lower_z()
{
  translate([-100,-100,-100])
  cube([200,200,100]);
}


// Rounded plate
// Total hight will be 2*circle_radius+additional_hight
module h_rounded_plate(torus_radius, circle_radius, additional_hight)
{
  hull()
  {
    h_streched_torus(torus_radius, circle_radius, additional_hight);
  }
}


// Rounded plate
// Total hight will be 2*circle_radius+additional_hight
module h_rounded_plate_with_cone(torus_radius, circle_radius, additional_hight)
{
  hull()
  {
    h_streched_torus(torus_radius, circle_radius, additional_hight);
    cylinder(additional_hight/2+circle_radius*2, torus_radius, 0);
  }
}


module h_rod_rounded_ends(hight, radius)
{
  hull()
  {
    sphere(radius, $fn = 12);
    translate([0,hight,0])
    sphere(radius, $fn = 12);
  }
}



// Radius is distance from center to one corner (or half the distance between two opposite corners).
// Key size will be 2*r*cos(30)
// If Key size is known r=keySize/(2*cos(30))
module h_hexagon(radius, height)
{
  linear_extrude(height = height, center = true/*, convexity = 10*/)
  polygon([[radius*cos(30),radius*sin(30)], [radius*cos(90),radius*sin(90)], [radius*cos(150),radius*sin(150)], [radius*cos(210),radius*sin(210)], [radius*cos(270),radius*sin(270)], [radius*cos(330),radius*sin(330)]]);
}


// 3d printer is not super accurate so 
h_gear_dedendum_margin=1.10; // increase the dedendum a little.
h_gear_addendum_margin=0.99; // decrease the addendum a little.


// Origo här är där mitt i tandens bas
module h_gear_tooth(face_width, gear_module, n_teeth)
{
    assign(pitch_diam=n_teeth*gear_module, circular_pitch=3.14159*gear_module, addendum=gear_module*h_gear_addendum_margin, dedendum=gear_module*h_gear_dedendum_margin)
    {
        hull()
        {
            //translate([0,0,0])
            cube([0.48*circular_pitch,face_width, dedendum*2], center=true);

            translate([0,0,dedendum+addendum/2])
            cube([0.16*circular_pitch,face_width,addendum], center=true);
        }
    }
}


// kuggstång
// Origo för denna är mitt i pitch (pitch är mitt i tänderna)
// heigth är från pitch till kuggstångens botten
module h_rack_gear(length, face_width, height, n_teeth, gear_module)
{
  assign(pitch_diam=n_teeth*gear_module, circular_pitch=3.14159*gear_module, dedendum=gear_module*h_gear_dedendum_margin)
  {

      // part on which the teeth sits 
      translate([0,0,-(dedendum+(height-dedendum)/2)])
      cube([length,face_width,height-dedendum], center=true);

        translate([0,0,-height/2-dedendum])
        for (n=[0 : (n_teeth-1)])
        {
           assign (pitch_len=3.14159*gear_module)
           {
             assign(offset=n*pitch_len-((n_teeth-1)/2)*pitch_len)
             {
               translate([offset,0,height/2])
               h_gear_tooth(face_width, gear_module, n_teeth);

             }
        }
      }
  }
}


// vanligt kugghjul
// origo är mitt i kugghjulet, ska ändra det sen...
module h_spur_gear(axle_diam, tot_length, face_width, n_teeth, gear_module)
{
  //https://en.wikipedia.org/wiki/Gear
 assign(pitch_diam=n_teeth*gear_module, circular_pitch=3.14159*gear_module, addendum=gear_module*h_gear_addendum_margin, dedendum=gear_module*h_gear_dedendum_margin)  // just guessing factor 0.95 & 1.05 for Addendum and Dedendum, at least Addendum needs to be smaller than Dedendum
 {
   assign(root_diam=pitch_diam-2*dedendum)
   {

      h_holow_cylinder(root_diam/2,axle_diam/2, tot_length);

      //translate([0,0,tot_length/2-face_width/2])
      //h_holow_cylinder(1.2*pitch_diam/2,axle_diam/2, face_width);

      translate([0,0,tot_length/2-face_width/2])
      for (i=[0 : (n_teeth-1)])
      {
         rotate([0,0,((360/n_teeth)*i)])
         {
  //        h_gear_tooth(root_diam, dedendum, addendum, face_width, gear_module);

           hull()
          {
             translate([pitch_diam/2 ,0,0])
             cube([addendum*2,0.16*circular_pitch,face_width], center=true);

             translate([root_diam/2 ,0,0])
             cube([dedendum*2,0.48*circular_pitch,face_width], center=true);
           }

         }
       }
   }
  }
}





module letter_E(size)
{
  h_rod_rounded_ends(size,size/8);

  rotate([0,0,-90])
  h_rod_rounded_ends(size/2,size/8);

  translate([0,size/2, 0]) 
  rotate([0,0,-90])
  h_rod_rounded_ends(size/2,size/8);

  translate([0,size, 0]) 
  rotate([0,0,-90])
  h_rod_rounded_ends(size/2,size/8);
}

module letter_I(size)
{
  translate([size*0.25, 0, 0]) 
  h_rod_rounded_ends(size,size/8);
}

module letter_S(size)
{
  translate([-size*0.1, size*0.1, 0]) 
  rotate([0,0,-15])
  {
  translate([size*0.25, size*0.75, 0]) 
  h_torus_half(size/4, size/8, 180);

  translate([size*0.25, size*0.25, 0]) 
  rotate([0,0,180])
  h_torus_half(size/4, size/8, 180);
  }
}


module letter_T(size)
{
  translate([size*0.5, 0, 0]) 

  h_rod_rounded_ends(size,size/8);

  translate([size*0.1,size, 0]) 
  rotate([0,0,-90])
  h_rod_rounded_ends(size*0.8,size/8);

}

module letter_W(size)
{
  translate([size*0.3, 0, 0]) 
  rotate([0,0,15])
  h_rod_rounded_ends(size,size/7);

  translate([size*0.3, 0, 0]) 
  rotate([0,0,-15])
  h_rod_rounded_ends(size,size/7);

  translate([size*0.7, 0, 0]) 
  rotate([0,0,15])
  h_rod_rounded_ends(size,size/7);

  translate([size*0.7, 0, 0]) 
  rotate([0,0,-15])
  h_rod_rounded_ends(size,size/7);

}

module dot(size)
{
  translate([size*0.25, 0, 0]) 
  h_rod_rounded_ends(size/8,size/8);
}

