// main
// Copyright (C) Henrik & Alexander Björkman www.eit.se/hb
// Created by Henrik & Alexander Björkman 2013-05-15
// Gnu public license v3
//
// History
// Created 2013-05-22




include<henriks_generic_modules.scad>



// x out towards outer frame
// y out towards outside of door
// z uppwards

// Origo is center of mount in YZ and its level with door end in X.


/*
12V VÄXELMOTOR 62:1
conrad:234352
modelcraft: IG160062-20402R
price: 200

MOTORDREVSMODUL 0,8 3,2 MM 10
conrad:219207 
price:32

MOTORDREVSMODUL 0,5 3,2 MM 10
conrad:219371  
price:32

*/


//factor=0.5; // How far extended the block is. 0=fully retracted, 1=fully extended.
// This uses the animate feature of openscad
factor=0.5+0.5*sin($t*360);

motor_length=45;
motor_diam=16+0.3;
motor_axle_diam=3;
motor_axle_len=11.6;
motor_gear_len=9;
motor_gear_diam=10;
motor_gear_n_teath=10;
motor_screw_pos=5; // How far from the center the screw holes for mounting motor are
motor_screw_diam=3; // diameter of the screw holes for mounting motor
motor_axle_without_gear=motor_axle_len-motor_gear_len; // how much between motor and gear, can be made bigger, the gear can be mounted a little further out than the tip of axle if needed.

between_mounting_holes=200;  // befintliga var 124 men behöver mer plats.
mounting_hole_diam=5;
mounting_hole_pos=12; // calculated from edge
mount_x=3;
mount_y=25;
mount_z=between_mounting_holes+2*mounting_hole_pos;

housing_thicknes=2;
housing_y=16;
housing_z=between_mounting_holes-4*mounting_hole_pos;
housing_screw_hole_diam=5;

block_y=11;
block_z=17;
block_move=22;  // slaglängd för lås cylindern (som inte är rund utan rektangulär)
block_gear_margin=motor_axle_diam;
block_gear_len=block_move+2*block_gear_margin;
block_gear_height=motor_axle_len;
block_x=block_gear_len+2*block_move+2*mount_x;
block_house_margin=0.3;


housing_x=block_x+housing_thicknes;


motor_pos_x=-(mount_x+block_move/2+block_gear_len/2);
motor_pos_z=-(block_z/2 + block_gear_height+motor_axle_without_gear); // position where the axis of the motor goes out from the motor.


// front plate
module mounting_plate()
{
  translate([-mount_x/2, 0, 0])
  difference()
  {
    cube([mount_x,mount_y,mount_z], center=true);

    translate([0, 0, between_mounting_holes/2])
    rotate([0,90,0])
    h_cylinder(mounting_hole_diam/2, mount_x*2);

    translate([0, 0, -between_mounting_holes/2])
    rotate([0,90,0])
    h_cylinder(mounting_hole_diam/2, mount_x*2);

    cube([mount_x*2,block_y+block_house_margin*2,block_z+block_house_margin*2], center=true);


  }
}

// nästan plattan längst in, den som "cylindern" går igenom där bak
module rear_block_mount()
{
  translate([-block_x+mount_x+block_move, 0, 0])
  difference()
  {
    translate([-mount_x/2, 0, 0])
    cube([mount_x,housing_y,block_z*4], center=true);

    cube([mount_x*2,block_y+block_house_margin,block_z+block_house_margin], center=true);
  }


}


module housing()
{
  rear_block_mount();


  // outer plate
  difference()
  {
    //translate([-(housing_x)/2, block_y/2+block_house_margin+housing_thicknes/2, 0])
    translate([-(housing_x)/2, housing_y/2-housing_thicknes/2, 0])
    cube([block_x+housing_thicknes,housing_thicknes,housing_z], center=true);

    motor();

    // In case the gears are to big to fit inside housing, uncomment this
    translate([motor_pos_x, housing_y/2, -(block_gear_height+block_z/2)/2])
    cube([block_gear_len+block_move,housing_thicknes*2,block_gear_height+block_z/2], center=true);

/*
    // screw holes
    translate([-(housing_x-mounting_hole_pos), 0, -housing_z/2+mounting_hole_pos])
    rotate([90,0,0])
    h_cylinder(housing_screw_hole_diam/2, housing_y*2);

    // screw holes
    translate([-(housing_x-mounting_hole_pos), 0, (housing_z/2-mounting_hole_pos)])
    rotate([90,0,0])
    h_cylinder(housing_screw_hole_diam/2, housing_y*2);

    // screw holes
    translate([-(mounting_hole_pos), 0, -(housing_z/2-mounting_hole_pos)])
    rotate([90,0,0])
    h_cylinder(housing_screw_hole_diam/2, housing_y*2);

    // screw holes
    translate([-(mounting_hole_pos), 0, (housing_z/2-mounting_hole_pos)])
    rotate([90,0,0])
    h_cylinder(housing_screw_hole_diam/2, housing_y*2);
*/
  }

/*
  // screw holes
  translate([-(housing_x-mounting_hole_pos), 0, -(housing_z/2-mounting_hole_pos)])
  rotate([90,0,0])
  h_holow_cylinder(housing_screw_hole_diam/2+housing_thicknes, housing_screw_hole_diam/2, housing_y);


  // screw holes
  translate([-(housing_x-mounting_hole_pos), 0, (housing_z/2-mounting_hole_pos)])
  rotate([90,0,0])
  h_holow_cylinder(housing_screw_hole_diam/2+housing_thicknes, housing_screw_hole_diam/2, housing_y);

  // screw holes
  translate([-(mounting_hole_pos), 0, -(housing_z/2-mounting_hole_pos)])
  rotate([90,0,0])
  h_holow_cylinder(housing_screw_hole_diam/2+housing_thicknes, housing_screw_hole_diam/2, housing_y);

  // screw holes
  translate([-(mounting_hole_pos), 0, (housing_z/2-mounting_hole_pos)])
  rotate([90,0,0])
  h_holow_cylinder(housing_screw_hole_diam/2+housing_thicknes, housing_screw_hole_diam/2, housing_y);
*/



  // support behind block gear
  translate([motor_pos_x, block_y/2+housing_thicknes/2+block_house_margin, -(block_gear_height+block_z/2)/2])
  cube([block_gear_len+block_move,housing_thicknes,block_gear_height+block_z/2+2*housing_thicknes], center=true);



  // rear plate
  translate([-housing_x+housing_thicknes/2, 0, 0])
  cube([housing_thicknes,housing_y,housing_z], center=true);



  // motor mount
  difference()
  {
    translate([motor_pos_x, 0, motor_pos_z+housing_thicknes/2])
    cube([50,housing_y,housing_thicknes], center=true);

    // screw holes for motor
    translate([motor_pos_x-motor_screw_pos, 0, motor_pos_z])
    h_cylinder(motor_screw_diam/2, housing_thicknes*2);

    translate([motor_pos_x+motor_screw_pos, 0, motor_pos_z])
    h_cylinder(motor_screw_diam/2, housing_thicknes*2);


    // hole for axis
    translate([motor_pos_x, 0, motor_pos_z])
    h_cylinder(motor_axis_diam/2+block_house_margin, housing_thicknes*2);
  }

  // upper plate
  translate([-housing_x/2, 0, housing_z/2-housing_thicknes/2])
  cube([housing_x,housing_y,housing_thicknes], center=true);

  // lower plate
  translate([-housing_x/2, 0, -housing_z/2+housing_thicknes/2])
  cube([housing_x,housing_y,housing_thicknes], center=true);


}


module moving_block()
{
  translate([0, 0, 0])
  {

    // main part
    translate([-block_x/2, 0, 0])
    cube([block_x,block_y,block_z], center=true);

    // part on which "kuggarna sitter"

    translate([-(mount_x+block_move+block_gear_len/2), block_y/2-1, -( block_z/2 + motor_axle_len/2)])
    {
      cube([block_gear_len,2,block_gear_height], center=true);

      translate([0,0,0])
      {
         for (n=[-7 : 7])
        {
           translate([n*2,-2,0])
           cube([1,2,motor_axle_len], center=true);
        }
      }
    }
  }
}

module gear(nTeath, outer_diam, inner_diam, height)
{
      h_holow_cylinder(outer_diam/3,inner_diam/2, height);

         for (i=[0 : (nTeath-1)])
         {
           rotate([0,0,((360/nTeath)*i)])
           {
             translate([outer_diam/2-  (outer_diam/4)/2 ,0,0])
             cube([outer_diam/4,outer_diam/nTeath,height], center=true);
           }
         }

}


module motor()
{
  color("Blue",0.5)
  translate([motor_pos_x, 0, motor_pos_z])
  {
    translate([0, 0, -motor_length/2])
   {
      h_cylinder(motor_diam/2,motor_length);

      translate([0, 0, motor_axle_len/2+motor_length/2])
      h_cylinder(motor_axle_diam/2,motor_axle_len);

      translate([0, 0, motor_axle_len/2+motor_length/2+(motor_axle_len-motor_gear_len)/2])
      gear(motor_gear_n_teath, motor_gear_diam, motor_axle_diam, motor_gear_len);
    }
  }
}


  // x
  //translate([50, 0, 0])
  //cube([2,2,2], center=true);


color("Green",0.5)
translate([block_move*factor, 0,0])
moving_block();

mounting_plate();

housing();

motor();



//      gear(10, 10, motor_axle_diam, motor_gear_len);
