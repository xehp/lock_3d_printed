// main
// Copyright (C) Henrik & Alexander Björkman www.eit.se/hb
// Created by Henrik & Alexander Björkman 2013-05-15
//
// History
// Created 2013-05-22




include<henriks_generic_modules.scad>










housing_thicknes=2;
housing_x=52;    // measured inside, inner size of box
housing_y=65.5;  // -"-
housing_z=10;    // Outer size of box

screw_hole_diam=3+1; // Door screw hole diameter, shall be 3 but to print it we need an extra mm.
distBetweenScrewHoles = 30; // Door screw holes

mount_size_xy = 8;
keypad_z = 2;
keypad_screw_hole_diam=2+1; // It shall be 2 mm, but it gets to small when printing so add some 0.5 mm or 1 mm.
cable_hole_diam=12;

slits_y=3;
slitz_x=5;

keypadScrewX = 44;
keypadScrewY = 55;


// This needs to be adjusted to fit actual bolts.  hexagon_radius=keySize/(2*cos(30))
housing_nut_size=2.6; // key 4 mm -> hexagon_radius=2.4

mount_x=45.5/2; // how far from center to put screw hole
mount_y=59/2;



/*
module hole_for_countersunkscrew()
{
    h_cylinder(mounting_hole_diam/2, mount_x*10);
    cylinder(mount_x/2,mounting_hole_diam/2, mounting_hole_diam*3/4);
}
*/


/*
module screw_holes_mounting_plate_and_box()
{
    translate([0, 0, between_mounting_holes/4])
    rotate([0,90,0])
    {
      hole_for_countersunkscrew();
      translate([0, 0, -(housing_thicknes+mount_x+mount_x/2)])
      h_hexagon(mounting_plate_and_box_nut_size, mount_x);
    }

    translate([0, 0, -between_mounting_holes/4])
    rotate([0,90,0])
    {
      hole_for_countersunkscrew();
      translate([0, 0, -(housing_thicknes+mount_x+mount_x/2)])
      h_hexagon(mounting_plate_and_box_nut_size, mount_x);
    }
}
*/




module h_cube_rounded_corners(sizeX, sizeY, radius, height)
{
  h_rounded_4_corners(sizeX/2,sizeY/2 ,sizeX/2, -sizeY/2, -sizeX/2, -sizeY/2, -sizeX/2, sizeY/2, radius, height);
}









module nut_mount(radius, height)
{
    difference()
    {
       h_cylinder(radius*4/3, height);
       h_hexagon(radius, height*2);
    }
}







module doorScrewHoles()
{
  translate([distBetweenScrewHoles/2, 0, 0])
  h_cylinder(screw_hole_diam/2, housing_z*2);

  translate([-distBetweenScrewHoles/2, 0, 0])
  h_cylinder(screw_hole_diam/2, housing_z*2);
}

module mountingScrewHoles()
{

  translate([mount_x, mount_y, 0])
  {
    h_cylinder(keypad_screw_hole_diam/2,housing_z*2, center=true);
    h_hexagon(housing_nut_size, housing_z);
    h_cylinder(housing_nut_size*1.2,housing_z/2, center=true);
  }

  translate([-mount_x, mount_y, 0])
  {
    h_cylinder(keypad_screw_hole_diam/2,housing_z*2, center=true);
    h_hexagon(housing_nut_size, housing_z);
    h_cylinder(housing_nut_size*1.2,housing_z/2, center=true);
  }

  translate([mount_x, -mount_y, 0])
  {
    h_cylinder(keypad_screw_hole_diam/2,housing_z*2, center=true);
    h_hexagon(housing_nut_size, housing_z);
    h_cylinder(housing_nut_size*1.2,housing_z/2, center=true);
  }

  translate([-mount_x, -mount_y, 0])
  {
    h_cylinder(keypad_screw_hole_diam/2,housing_z*2, center=true);
    h_hexagon(housing_nut_size, housing_z);
    h_cylinder(housing_nut_size*1.2,housing_z/2, center=true);
  }

}



module plate()
{
  //cube([housing_x,housing_y,housing_thicknes], center=true);

  difference()
  {
    translate([0, 0, housing_z/2])
    h_cube_rounded_corners(housing_x+2*housing_thicknes, housing_y+2*housing_thicknes, housing_thicknes, housing_z);

    translate([0, 0, housing_z])
    translate([0, 0, -housing_thicknes/2])
    h_cube_rounded_corners(housing_x, housing_y, housing_thicknes, housing_thicknes);

    translate([0, 0, housing_z/2])
    translate([0, 0, housing_thicknes])   
    h_cube_rounded_corners(housing_x-housing_thicknes, housing_y-housing_thicknes, housing_thicknes, housing_z);

  }
}



// housing_box without screw holes
module housing_box_base()
{
  plate();

  translate([(housing_x/2-mount_size_xy/2), (housing_y/2-mount_size_xy/2), (housing_z-keypad_z)/2])
  cube([mount_size_xy,mount_size_xy,housing_z-keypad_z], center=true);

  translate([-(housing_x/2-mount_size_xy/2), (housing_y/2-mount_size_xy/2), (housing_z-keypad_z)/2])
  cube([mount_size_xy,mount_size_xy,housing_z-keypad_z], center=true);

  translate([(housing_x/2-mount_size_xy/2), -(housing_y/2-mount_size_xy/2), (housing_z-keypad_z)/2])
  cube([mount_size_xy,mount_size_xy,housing_z-keypad_z], center=true);

  translate([-(housing_x/2-mount_size_xy/2), -(housing_y/2-mount_size_xy/2), (housing_z-keypad_z)/2])
  cube([mount_size_xy,mount_size_xy,housing_z-keypad_z], center=true);
 
  translate([0, (housing_y/2)-slits_y/2, housing_z/2])
  cube([slitz_x,slits_y,housing_z], center=true);

}


module cableOpening()
{
    translate([0, 20, 0])
    h_cube_rounded_corners(20,20, 2, 10);

    translate([0, 10, 0])
    cube([cable_hole_diam,20,10], center=true);

    h_cylinder(cable_hole_diam/2, housing_z*2);

}

// These hoes are not needed but reduses amount of material used.
module materialReduction()
{
    translate([0, -22, 0])
    h_cube_rounded_corners(20,15, 2, 10);

    translate([20, 16, 0])
    h_cube_rounded_corners(10,15, 2, 10);

    translate([-20, 16, 0])
    h_cube_rounded_corners(10,15, 2, 10);

    translate([20, -16, 0])
    h_cube_rounded_corners(10,15, 2, 10);

    translate([-20, -16, 0])
    h_cube_rounded_corners(10,15, 2, 10);

}


module keypadScrews()
{
  translate([0, 0, 10])
  cube([keypadScrewX,keypadScrewY,6], center=true);
}

module housing_box()
{


  difference()
  {
    housing_box_base();

    doorScrewHoles();
    cableOpening();
    mountingScrewHoles();
    keypadScrews();
    materialReduction();

    translate([0, (housing_y/2)-slits_y/2, housing_z/2])
    cube([3,slits_y,housing_z], center=true);
  }
}







// This was used to adust the size of nut mounts.
module size_of_nut_mounts_example()
{
  intersection()
  {
    translate([20,-20,housing_y/2]) rotate([90,0,0]) housing_box();
    h_cylinder(25,40);
  }
}



module all()
{
  //color("Green",0.5)

  //color("Purple",0.5)

  color("Red",0.5)
  housing_box();

  //color("Orange",0.5)

  //color("Magenta",0.5)

  //color("Blue",0.5)


  //color("Black",0.5)



}





// Uncomment one of the lines below

all();
//translate([40,0,housing_y/2]) rotate([90,0,0]) housing_box();
//size_of_nut_mounts_example();



