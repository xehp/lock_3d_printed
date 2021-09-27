// main
// Copyright (C) Henrik & Alexander Björkman www.eit.se/hb
// Created by Henrik & Alexander Björkman 2013-05-15
//
// History
// Created 2013-05-22




include<henriks_generic_modules.scad>



// x out towards outer frame
// y out towards outside of door
// z uppwards

// Origo is center of mount in YZ and its level with door end in X.




//factor=0.5; // How far extended the block is. 0=fully retracted, 1=fully extended.
// This uses the animate feature of openscad
factor=0.5+0.5*sin($t*360);

housing_thicknes=1;
housing_x=72;
housing_y=12;  // outer size of house
housing_z=72;  // outer size of house
housing_screw_hole_diam=2.9;

housing_lower_cable_passage=4;
housing_lower_z=housing_z/2-housing_lower_cable_passage;
housing_front_housing_thickness=4;
housing_support_size=8;

block_house_margin=0.4; // Margin between cylinder block and house. 
block_y=housing_y - 2*housing_thicknes - 3*block_house_margin;

motor_length=26;
motor_diam=13;
motor_axle_diam=3;
motor_axle_len=11.6;

motor_spur_gear_length=block_y + housing_thicknes; // This is the total length of the motor pinions module
motor_spur_gear_face_width=motor_spur_gear_length-(housing_thicknes+1); // usable part of pinions with teeth
motor_spur_gear_n_teeth=10;
motor_spur_gear_module=1.0;
motor_gear_flens_length=motor_spur_gear_length;

motor_gear_reference_diam=motor_spur_gear_module*motor_spur_gear_n_teeth;
motor_gear_diam=motor_gear_reference_diam+2;
motor_screw_pos=5; // How far from the center the screw holes for mounting motor are
motor_screw_diam=1.6; // diameter of the screw holes for mounting motor
motor_axle_without_gear=motor_axle_len-motor_spur_gear_length; // how much between motor and gear, can be made bigger, the gear can be mounted a little further out than the tip of axle if needed.
motor_house_opening=6.5;


between_mounting_holes=125;
mounting_hole_diam=5;
mounting_hole_pos=12; // calculated from edge
mount_x=3;
mount_y=25;
mount_z=between_mounting_holes+2*mounting_hole_pos;


motor_mount_x=26;
motor_mount_y=1;
motor_mount_z=14;
motor_mount_screw_pos=10;
motor_mount_screw_diam=housing_screw_hole_diam;
motor_mount_margin=0.2;
motor_mount_tube=10;


// actually position of motor_mount.
motor_pos_x=-45;
motor_pos_y=-(housing_y/2);
motor_pos_z=-24; // position where the axis of the motor goes out from the motor.

motor_tube_len=motor_length+5;
motor_tube_thicknes=0;
motor_tube_ring_thicknes=2;
motor_tube_snapp_len=motor_mount_tube+6;


block_z=24;
block_move=22;  // slaglängd för lås cylindern (som inte är rund utan rektangulär)
block_move_margin=2;
block_gear_margin=(16+0.3)/2;
block_gear_len=block_move+2*block_gear_margin;
block_gear_height=motor_axle_len;
block_gear_offset_z=2.6;
block_teeth_base_z=16 - block_z/2;  // 2
block_teeth_base_offset_x=motor_pos_x-block_gear_len/2+block_gear_margin;
block_x=-block_teeth_base_offset_x+block_gear_len/2+block_move+mount_x/*+block_house_margin*/;
//block_x=105;   //block_gear_len+2*block_move+2*mount_x
block_len=75;//block_x;
block_vertical_x = 1.75; // 1 is to week, 2 is too hard, With 1.5 it did not fill it,
block_vertical_z=housing_z*0.32;
block_mount_thickness=10;
block_mount_thickness_z=12;

block_mount_front_x=(motor_pos_x+block_gear_len/2+block_move/2+block_move_margin+block_mount_thickness/2);
block_mount_rear_x=-(housing_x+6);
block_center_z=10;




manuellt_vred_pos_x=-45;
manuellt_vred_pos_y=-housing_y/2;
manuellt_vred_pos_z=-24;


motor_axle_diam_margin=0.9;
motor_mount_axle_diam=4.0+motor_axle_diam_margin;



distance_from_block_to_motor_axle_z=-motor_pos_z-block_z/2;



// assumed dimensions of microswitch
microswitch_len=20.1;
microswitch_height=10.2;
microswitch_diam=2.5;
microswitch_width=6.4;
microswitch_dist_between_holes=9.5; // perhaps it shall be 10?
microswitch_dist_base_to_holes=2.9;
microswitch_terminal_len_from_holes=6.4;
microswitch_terminal_len=microswitch_terminal_len_from_holes-microswitch_dist_base_to_holes;
microswitch_terminal_width=3.2;
microswitch_lever_width=3.2;

// just guessing these (could not read it on the drawing)
microswitch_lever_len=0; // 0 if there is no lever
microswitch_lever_base=microswitch_len*0.45;
microswitch_lever_thickness=0.25;
microswitch_from_holes_to_top=microswitch_height-microswitch_dist_base_to_holes;
microswitch_offset_x=2;
microswitch_mount_offset=block_vertical_x/2+block_move/2 + 7.1; // determines how far appart the two microswitches will sit. Was ...+7.5 on version printer 2013-11-08. Will try ...+7.1
microswitch_inner_x=motor_pos_x + microswitch_offset_x - microswitch_mount_offset; 
microswitch_outer_x=motor_pos_x + microswitch_offset_x + microswitch_mount_offset;
microswitch_z=housing_z/2 - housing_thicknes - microswitch_len/2 - 0.5; 


upper_plate_cable_hole_x=6; // offset from microswitch


outer_plate_rear_screw_offset=block_z/2+block_mount_thickness_z/2+block_teeth_base_z+2.5;
outer_plate_front_screw_offset=block_z/2+block_mount_thickness/2;
outer_plate_rear_lower_screw_x=block_mount_rear_x;
outer_plate_rear_lower_screw_z=-outer_plate_rear_screw_offset;
outer_plate_rear_upper_screw_x=block_mount_rear_x;
outer_plate_rear_upper_screw_z=outer_plate_rear_screw_offset;
outer_plate_front_lower_screw_x=block_mount_front_x;
outer_plate_front_lower_screw_z=-outer_plate_front_screw_offset;
outer_plate_front_upper_screw_x=block_mount_front_x;
outer_plate_front_upper_screw_z=outer_plate_front_screw_offset;


cable_hole_diam=3;

// This needs to be adjusted to fit actual bolts.  hexagon_radius=keySize/(2*cos(30))
mounting_plate_and_box_nut_size=4.4; // key 7 mm -> hexagon_radius=4.1
motor_mount_nut_size=2.6; // key 4 mm -> hexagon_radius=2.4
housing_nut_size=2.6; // key 4 mm -> hexagon_radius=2.4

screw_holes_mounting_plate_and_box_dist=27; // measured from center

housing_extension_rear_z=block_z+2*(block_mount_thickness_z+block_teeth_base_z);


mount_dist_x=motor_mount_x - motor_mount_z;
//mount_diam=motor_mount_x - motor_mount_z;
//mount_diam=motor_mount_z/2;
mount_diam=motor_diam+housing_thicknes*2++motor_tube_thicknes*2;
motor_mount_track=motor_tube_ring_thicknes+motor_mount_margin;
motor_mount_thicknes=housing_thicknes+motor_mount_track+motor_mount_margin;

motor_mount_cyl_radius=(motor_diam+motor_mount_margin)/2+housing_thicknes+motor_tube_thicknes;



module hole_for_countersunkscrew()
{
    h_cylinder(mounting_hole_diam/2, mount_x*10);

    translate([0,0,-0.3])
    cylinder(mount_x/2+0.31,mounting_hole_diam/2, mounting_hole_diam*0.8);
}



module screw_holes_mounting_plate_and_box()
{
    translate([0, 0, screw_holes_mounting_plate_and_box_dist])
    rotate([0,90,0])
    {
      hole_for_countersunkscrew();
      translate([0, 0, -(housing_thicknes+mount_x+mount_x*2)])
      //rotate([0,0,30])
      h_hexagon(mounting_plate_and_box_nut_size, mount_x*3);
    }

    translate([0, 0, -screw_holes_mounting_plate_and_box_dist])
    rotate([0,90,0])
    {
      hole_for_countersunkscrew();
      translate([0, 0, -(housing_thicknes+mount_x+mount_x*2)])
      //rotate([0,0,30])
      h_hexagon(mounting_plate_and_box_nut_size, mount_x*3);

    }


    // For injection moulding we need a way for the tools to move out.
    translate([-(housing_thicknes+mount_x+mount_x*2), 5, -screw_holes_mounting_plate_and_box_dist])
    cube([mount_x*3,10,1.7*mounting_plate_and_box_nut_size], center=true);

    translate([-(housing_thicknes+mount_x+mount_x*2), 5, screw_holes_mounting_plate_and_box_dist])
    cube([mount_x*3,10,1.7*mounting_plate_and_box_nut_size], center=true);

}



module nut_mounts_mounting_plate_and_box()
{
/*
    translate([-(mount_x+housing_thicknes), 0, between_mounting_holes/4])
    rotate([0,90,0])
    {
      nut_mount(mounting_plate_and_box_nut_size, mount_x*2);
    }

    translate([-(mount_x+housing_thicknes), 0, -between_mounting_holes/4])
    rotate([0,90,0])
    {
      nut_mount(mounting_plate_and_box_nut_size, mount_x*2);
    }
*/
}




// front plate, The big part on which the other parts are mounted, this part is to be mounted in door.
module mounting_plate()
{
  translate([-mount_x/2, 0, 0])
  difference()
  {
    cube([mount_x,mount_y,mount_z], center=true);

    // screw holes for mounting mounting_plate to door

    translate([0, 0, between_mounting_holes/2])
    rotate([0,90,0])
    hole_for_countersunkscrew();

    translate([0, 0, -between_mounting_holes/2])
    rotate([0,90,0])
    hole_for_countersunkscrew();


    // Opening for block cylinder
    cube([mount_x*2,block_y+block_house_margin*2,block_z+block_house_margin*2], center=true);

    screw_holes_mounting_plate_and_box();

  }

}


module block_supports()
{
   block_supports_z=block_z/2+block_house_margin+block_mount_thickness/2;

   // upper
   translate([0,0,block_supports_z])
   cube([block_mount_thickness,housing_y-2*housing_thicknes,block_mount_thickness], center=true);

   // lower
   translate([0,0,-block_supports_z])
   cube([block_mount_thickness,housing_y-2*housing_thicknes,block_mount_thickness], center=true);
}




// plattan narmast mot mounting plate
module front_plate()
{
  translate([-(mount_x+housing_front_housing_thickness/2), 0, 0])
  {
    difference()
    {
      cube([housing_front_housing_thickness,housing_y-2*housing_thicknes,housing_z /*block_z*4*/], center=true);

    cube([housing_front_housing_thickness*2,3*housing_thicknes+block_y+block_house_margin,block_z+block_house_margin*2], center=true);
    }

  }
}

// plattan langst in
module rear_plate()
{
  translate([-(mount_x+housing_x-housing_thicknes/2), 0, 0])
  {
    difference()
    {
      cube([housing_thicknes,housing_y-2*housing_thicknes,housing_z /*block_z*4*/], center=true);

      cube([housing_thicknes*2,3*housing_thicknes+block_y+block_house_margin,block_z+block_house_margin+18], center=true);
    }
  }
}



// holes for motor axle and screws
module screw_holes_for_motor()
{
    // screw holes for motor
    translate([motor_screw_pos, housing_thicknes/2, 0])
    rotate([-90,0,0])
    h_cylinder(motor_screw_diam/2, housing_thicknes*10);

    translate([-motor_screw_pos, housing_thicknes/2, 0])
    rotate([-90,0,0])
    h_cylinder(motor_screw_diam/2, housing_thicknes*10);

    // hole for motor axle
    translate([0, housing_thicknes/2, 0])
    rotate([-90,0,0])
    h_cylinder((motor_mount_axle_diam)/2, housing_thicknes*10);
}


// origo for denna ar i mitten pa ytan dar forsankningen finns.
// hole extends along negative z axle
module screw_hole_for_countersunkscrew(diameter)
{
    screw_dia=diameter*1.6;

    translate([0,0,-diameter*5])
    h_cylinder(diameter/2, diameter*10);


    translate([0,0,-diameter/2])
    cylinder(screw_dia/2,diameter/2, diameter);


    translate([0,0,diameter*2])
    h_cylinder(screw_dia/2, diameter*4.01);

}


module screw_holes_for_motor_mount()
{
    // screw holes

    translate([motor_mount_screw_pos, 0, 0])
    rotate([-90,0,0])
    //h_cylinder(motor_mount_screw_diam/2, housing_thicknes*10);
    screw_hole_for_countersunkscrew(motor_mount_screw_diam);

    translate([-motor_mount_screw_pos, 0, 0])
    rotate([-90,0,0])
    //h_cylinder(motor_mount_screw_diam/2, housing_thicknes*10);
    screw_hole_for_countersunkscrew(motor_mount_screw_diam);
}

module nut_mount(radius, height)
{
    difference()
    {
       h_cylinder(radius*4/3, height);
       h_hexagon(radius, height*2);
    }
}


module nut_holes_for_motor_mount()
{
    // nut holes

    mount_len=housing_thicknes*5;

    translate([motor_pos_x+motor_mount_screw_pos, motor_pos_y+mount_len/2, motor_pos_z])
    rotate([-90,0,0])
    nut_mount(motor_mount_nut_size, mount_len);

    translate([motor_pos_x-motor_mount_screw_pos, motor_pos_y+mount_len/2, motor_pos_z])
    rotate([-90,0,0])
    nut_mount(motor_mount_nut_size, mount_len);

}


module holes_for_motor_mount()
{
    translate([motor_pos_x, motor_pos_y, motor_pos_z])
    screw_holes_for_motor_mount();

    // hole for motor axle
    translate([motor_pos_x, motor_pos_y+housing_thicknes/2, motor_pos_z])
    rotate([-90,0,0])
    h_cylinder(motor_house_opening, housing_thicknes*10);
}


module reinforcementsMotorMount()
{
  housing_reinforce=28;
  translate([-(mount_x+housing_x/2), -(housing_y/2-housing_thicknes*2/2), -housing_reinforce])
  cube([housing_x,housing_thicknes*2,housing_reinforce/2], center=true);
  translate([motor_pos_x-3, -(housing_y/2-housing_thicknes*3/2), -housing_reinforce])
  cube([(housing_x+motor_pos_x)*2,housing_thicknes*3,housing_reinforce/2], center=true);
  translate([motor_pos_x+14, 0, -housing_reinforce])
  cube([housing_thicknes,housing_y-2*housing_thicknes,housing_reinforce/2], center=true);
  translate([motor_pos_x-14, 0, -housing_reinforce])
  cube([housing_thicknes,housing_y-2*housing_thicknes,housing_reinforce/2], center=true);

  intersection()
  {
    translate([motor_pos_x, 0, motor_pos_z]) rotate([-90,0,0]) h_holow_cylinder(motor_house_opening+1,motor_house_opening,(housing_y-housing_thicknes*2));
    translate([motor_pos_x, 0, -housing_reinforce]) cube([(housing_x+motor_pos_x)*2,(housing_y-housing_thicknes*2),housing_reinforce/2], center=true);
  }

}


module holes_for_mounting_the_microswitches()
{
    translate([microswitch_inner_x, 0, microswitch_z+microswitch_dist_between_holes/2])
    rotate([90,0,0])
    h_cylinder(microswitch_diam/2, housing_y*20);

    translate([microswitch_inner_x, 0, microswitch_z-microswitch_dist_between_holes/2])
    rotate([90,0,0])
    h_cylinder(microswitch_diam/2, housing_y*20);


    translate([microswitch_outer_x, 0, microswitch_z+microswitch_dist_between_holes/2])
    rotate([90,0,0])
    h_cylinder(microswitch_diam/2, housing_y*20);

    translate([microswitch_outer_x, 0, microswitch_z-microswitch_dist_between_holes/2])
    rotate([90,0,0])
    h_cylinder(microswitch_diam/2, housing_y*20);
}





module pins_for_mounting_the_microswitch()
{
    msl=4;
    mst=1;
    msh=housing_y*2/3;

    translate([0, 0, microswitch_dist_between_holes/2])
    rotate([90,0,0])
    h_cylinder(0.7*microswitch_diam/2, housing_y);

    translate([0, 0, -microswitch_dist_between_holes/2])
    rotate([90,0,0])
    h_cylinder(0.7*microswitch_diam/2, housing_y);


    translate([msl/2 + (microswitch_dist_base_to_holes+0.2), -(housing_y/2-msh/2), microswitch_dist_between_holes/2])
    cube([msl, msh, 2],  center=true);

    translate([msl/2 + (microswitch_dist_base_to_holes+0.2), -(housing_y/2-msh/2), -microswitch_dist_between_holes/2])
    cube([msl, msh, 2],  center=true);


    translate([-1.75, -(housing_y/2-msh/2), - (microswitch_len/2 + mst/2 + 0.2)])
    cube([microswitch_height, msh, mst],  center=true);

    translate([-1.75, -(housing_y/2-msh/2),  (microswitch_len/2 + mst/2 + 0.2)])
    cube([microswitch_height*1.2, msh, mst],  center=true);


    translate([-(msl/2 + (microswitch_from_holes_to_top + 0.2)), -(housing_y/2-msh/2), microswitch_len/2 - mst/2])
    cube([msl, msh, 2],  center=true);

}


module pins_for_mounting_the_microswitches()
{
    translate([microswitch_inner_x, 0, microswitch_z])
    mirror([1,0,0])
    pins_for_mounting_the_microswitch();

    translate([microswitch_outer_x, 0, microswitch_z])
    pins_for_mounting_the_microswitch();
}



// hole for countersunk screws
module hole_outer_plate()
{
    rotate([90,0,0])
    {
      h_cylinder(housing_screw_hole_diam/2, housing_y*10);

      
      translate([0,0,housing_y/2])
      h_hexagon(housing_nut_size, housing_y);

      //translate([0,0,-(housing_y/2+housing_thicknes*1.2)])
      translate([0,0,housing_y*0.8])
      h_cylinder(housing_nut_size*1.2, housing_y);
    }
}



module holes_for_mounting_the_outer_plate()
{
    // screw holes

    // rear lower
    translate([outer_plate_rear_lower_screw_x, 0, outer_plate_rear_lower_screw_z])
    hole_outer_plate();

    // rear upper
    translate([outer_plate_rear_upper_screw_x, 0, outer_plate_rear_upper_screw_z])
    hole_outer_plate();

    // front lower
    translate([outer_plate_front_lower_screw_x, 0, outer_plate_front_lower_screw_z])
    hole_outer_plate();

    // front upper
    translate([outer_plate_front_upper_screw_x, 0, outer_plate_front_upper_screw_z])
    hole_outer_plate();

    // center
    translate([motor_pos_x, 0, 0])
    hole_outer_plate();
}


module supports_for_mounting_the_outer_plate()
{


    // rear lower
    translate([outer_plate_rear_lower_screw_x, 0, outer_plate_rear_lower_screw_z])
    cube([housing_support_size, housing_y-housing_thicknes*2,8],  center=true);

    // rear upper
    translate([outer_plate_rear_upper_screw_x, 0, outer_plate_rear_upper_screw_z])
    cube([housing_support_size, housing_y-housing_thicknes*2,8],  center=true);

/*
    // front lower
    translate([outer_plate_front_lower_screw_x, 0, outer_plate_front_lower_screw_z])
    rotate([90,0,0])
    h_cylinder(housing_screw_hole_diam*3/2, housing_y-housing_thicknes*2);

    // front upper
    translate([outer_plate_front_upper_screw_x, 0, outer_plate_front_upper_screw_z])
    rotate([90,0,0])
    h_cylinder(housing_screw_hole_diam*3/2, housing_y-housing_thicknes*2);
*/
}


module outer_plate_screw_hole_supports()
{
  hull()
  {
    // rear lower
    translate([outer_plate_rear_lower_screw_x, (housing_y-housing_thicknes)/2, outer_plate_rear_lower_screw_z])
    rotate([90,0,0])
    h_cylinder(housing_screw_hole_diam*3/2, housing_thicknes);

    // rear upper
    translate([outer_plate_rear_upper_screw_x, (housing_y-housing_thicknes)/2, outer_plate_rear_upper_screw_z])
    rotate([90,0,0])
    h_cylinder(housing_screw_hole_diam*3/2, housing_thicknes);

    // front lower
    translate([outer_plate_front_lower_screw_x, (housing_y-housing_thicknes)/2, outer_plate_front_lower_screw_z])
    rotate([90,0,0])
    h_cylinder(housing_screw_hole_diam*3/2, housing_thicknes);

    // front upper
    translate([outer_plate_front_upper_screw_x, (housing_y-housing_thicknes)/2, outer_plate_front_upper_screw_z])
    rotate([90,0,0])
    h_cylinder(housing_screw_hole_diam*3/2, housing_thicknes);
  }
}


module fuse_pin()
{
  translate([0, -6, 0])
  rotate([0,-45,0])
  h_cylinder(1, 20);

}



module motor_mount()
{

  // motor mount
  difference()
  {
    translate([0,0,0])
    {
      // plattan
      translate([0, -(motor_mount_thicknes/2), 0])
      hull()
      {
        translate([mount_dist_x/2, 0, 0])
        rotate([90,0,0])
        h_cylinder(mount_diam/2, motor_mount_thicknes);

        translate([-mount_dist_x/2, 0, 0])
        rotate([90,0,0])
        h_cylinder(mount_diam/2, motor_mount_thicknes);
      }

      // ett ror
      translate([0, -(motor_mount_tube/2), 0])
      rotate([90,0,0])
      h_cylinder(motor_mount_cyl_radius, motor_mount_tube);

      // en liten pinne som hindrar handtaget fran att rotera.
      translate([0, -((motor_mount_tube+1)/2), 0])
      cube([motor_mount_cyl_radius*2,(motor_mount_tube+1),1], center=true);
    }

    // holes for motor axle and screws
    //screw_holes_for_motor();

    translate([0, -motor_mount_thicknes, 0])
    rotate([0,0,180])
    screw_holes_for_motor_mount();

    // sparet som slitsen pa roret roterar i.
    rotate([90,0,0])
    h_cylinder((motor_diam+motor_mount_margin)/2+housing_thicknes+motor_tube_thicknes, motor_mount_track*2);

    // opening for the tube 
    rotate([90,0,0])
    h_cylinder((motor_diam+motor_mount_margin)/2+motor_tube_thicknes, motor_mount_track*20);

    if (motor_tube_thicknes!=0)
    {
      // opening for fuse pin
      fuse_pin();
    }
  }

  // två små pinnar som hindrar motorn fran att rotera i fästet.
  rotate([0,45,0])
  {
    translate([motor_mount_cyl_radius, -1/2, 0])
    cube([2,1,1], center=true);
    translate([-motor_mount_cyl_radius, -1/2, 0])
    cube([2,1,1], center=true);
  }
}


module motor_tube_snapp()
{
    translate([0, -motor_tube_snapp_len/2, 0])
    cube([2,motor_tube_snapp_len,0.8], center=true);

    hull()
    {
      translate([0, -motor_tube_snapp_len, 0])
      cube([2,0.11,housing_thicknes], center=true);

      translate([0, -(motor_tube_snapp_len-3), 0+0.5])
      cube([2,0.11,housing_thicknes], center=true);
    }

}


module motor_tube()
{

  mount_dist_x=motor_mount_x - motor_mount_z;
  mount_diam=motor_mount_x - motor_mount_z;


  // motor mount
  difference()
  {
    rotate([90,0,0])
    {
      if (motor_tube_thicknes!=0)
      {
        translate([0, 0, (motor_tube_len)/2])
        h_holow_cylinder(motor_diam/2+housing_thicknes,motor_diam/2, motor_tube_len);
      }

      // plattan man skruvar fast motorn i
      translate([0, 0, housing_thicknes/2])
      h_cylinder(motor_diam/2+housing_thicknes+motor_tube_thicknes, housing_thicknes);

      // en ring som glider runt i motor_mount
      translate([0, 0, motor_tube_ring_thicknes/2])
      h_holow_cylinder(motor_diam/2+housing_thicknes+motor_tube_thicknes,motor_diam/2, motor_tube_ring_thicknes);

    }

    // holes for motor axle and screws
    screw_holes_for_motor();

    if (motor_tube_thicknes!=0)
    {
      // opening for fuse pin
      fuse_pin();

      // notch for handle
      translate([0, -motor_tube_len, 0])
      cube([3+motor_mount_margin,10,40], center=true);

      translate([0, -motor_tube_len, 0])
      cube([40,10,3+motor_mount_margin], center=true);
    }



    // två små pinnar som hindrar motorn fran att rotera i fästet.
    rotate([0,45,0])
    {
      translate([motor_mount_cyl_radius, -1/2, 0])
      cube([2+0.3,4,1+0.3], center=true);
      translate([-motor_mount_cyl_radius, -1/2, 0])
      cube([2+0.3,4,1+0.3], center=true);
    }
  }


  // fasten som ska halla kvar handtaget
  if (motor_tube_thicknes==0)
  {
    translate([0, 0, ((motor_diam-2)/2+housing_thicknes/2)])
    motor_tube_snapp();

    rotate([0,180,0])
    translate([0, 0, ((motor_diam-2)/2+housing_thicknes/2)])
    motor_tube_snapp();
  }
  
}


// origo for this module is where the tube ends on the inner end (not the handle end)
// It then extends in positive z.
module motor_handle()
{
  notch_pos=motor_tube_snapp_len-motor_mount_tube;
 
  difference()
  {

   translate([0, 0, (motor_tube_len)/2])
   h_holow_cylinder(motor_diam/2+housing_thicknes+0.2,motor_diam/2+0.2, motor_tube_len);

   // notch for sprints
   translate([0, 0, notch_pos])
   cube([3,40,7], center=true);


   // notch for breakable non rotation sprints
   translate([0, 0, 1/2])
   cube([40,1+0.3,1+0.3], center=true);
  }


  // the handle
  //translate([0, 0, motor_tube_len])
  //cube([16,40,4], center=true);

  // two guides so that when motor_handle is turned the motor will turn also.
  motor_handle_guide_len=(motor_tube_len)*0.7;
  difference()
  {
    translate([0, 0, (motor_tube_len)-motor_handle_guide_len/2])
    h_cylinder(motor_diam/2+housing_thicknes, motor_handle_guide_len);

    translate([0, 0, (motor_tube_len)-motor_handle_guide_len/2])
    cube([16,10+0.5,motor_handle_guide_len*1.01], center=true);
  }

}


module upper_plate()
{
  //difference()
  {
    translate([-(mount_x+housing_x/2), 0, housing_z/2-housing_thicknes/2])
    cube([housing_x,housing_y-housing_thicknes*2,housing_thicknes], center=true);
/*
    // cable hole rear
    translate([microswitch_inner_x-upper_plate_cable_hole_x,0,housing_z/2-housing_thicknes/2])
    h_cylinder(cable_hole_diam/2, housing_thicknes*10);

    // cable hole front
    translate([microswitch_outer_x+upper_plate_cable_hole_x,0,housing_z/2-housing_thicknes/2])
    h_cylinder(cable_hole_diam/2, housing_thicknes*10);
*/
  }

}

module lower_plate()
{
  translate([-(mount_x+housing_x/2), 0, -housing_lower_z+housing_thicknes/2])
  cube([housing_x,housing_y-housing_thicknes*2,housing_thicknes], center=true);
}



// housing_box without screw holes
module housing_box_base()
{

  front_plate();

  rear_plate();

  // upper plate
  upper_plate();


  // lower plate
  lower_plate();

  // rear_block_mount();
  //translate([block_mount_rear_x, 0, 0])
  //block_supports();

  // front_block_mount();
  translate([block_mount_front_x, 0, 0])
  block_supports();



  translate([-(mount_x+housing_x/2), motor_pos_y+housing_thicknes/2, 0])
  cube([housing_x,housing_thicknes,housing_z], center=true);

  supports_for_mounting_the_outer_plate();

  // Reinforce lower part of house since motor is mounted there
  reinforcementsMotorMount();


  nut_holes_for_motor_mount();

  nut_mounts_mounting_plate_and_box();


  // Support to keep block-cylinder in place
  translate([motor_pos_x, 0, 0])
  cube([block_gear_len-block_move-2*block_house_margin-2,housing_y-2*housing_thicknes,block_center_z-block_house_margin], center=true);



  // Extend the rear of the house
  translate([-(housing_x+5), -(housing_y/2-housing_thicknes/2), 0])
  cube([10,housing_thicknes,housing_extension_rear_z], center=true);
  translate([-(housing_x+10-housing_thicknes/2), 0, 0])
  cube([housing_thicknes,housing_y-2*housing_thicknes,housing_extension_rear_z], center=true);


  // 2 extra plates to keep microswitch cables away from moving cylinder block.
  slen=16+microswitch_height;
  translate([-(housing_x+10-slen/2), 0, block_z/2+housing_thicknes/2+block_house_margin*2])
  cube([slen,housing_y-2*housing_thicknes,housing_thicknes], center=true);
  translate([-(4+slen/2), 0, block_z/2+housing_thicknes/2+block_house_margin])
  cube([slen,housing_y-2*housing_thicknes,housing_thicknes], center=true);
  
  pins_for_mounting_the_microswitches();

}


module housing_box()
{


  difference()
  {

    housing_box_base();


    // holes for motor mount
    holes_for_motor_mount();


    // We need some holes for mounting the microswitches
    //holes_for_mounting_the_microswitches();


    // Screw holes for mounting outer plate.
    holes_for_mounting_the_outer_plate();



    // cable hole rear
    translate([microswitch_inner_x-upper_plate_cable_hole_x,0,microswitch_z])
    rotate([90,0,0])
    h_cylinder(cable_hole_diam/2, housing_y*2);

    // cable hole front
    translate([microswitch_outer_x+upper_plate_cable_hole_x,0,microswitch_z])
    rotate([90,0,0])
    h_cylinder(cable_hole_diam/2, housing_y*2);


    // To mount the big plate with box some screws are needed.
    // holes to mount the "mount plate" with the housing base.
    screw_holes_mounting_plate_and_box();



    // Remove some material in the lower part of house so that cables from keypad can pass there
    translate([-(housing_x/2+mount_x/*+housing_front_housing_thickness*/),0,-housing_z/2])
    cube([housing_x,housing_y*2,housing_lower_cable_passage*2], center=true);

    //translate([-(housing_x),0,-housing_z/2])
    //cube([housing_x/2,housing_y*2,housing_lower_cable_passage*5], center=true);

  }

}

module outer_plate_base()
{
    translate([-(mount_x+housing_x/2), housing_y/2-housing_thicknes/2, 0])
    cube([housing_x,housing_thicknes,housing_z], center=true);
    outer_plate_screw_hole_supports();
}

module outer_plate()
{
  difference()
  {
    outer_plate_base();
    holes_for_mounting_the_outer_plate();
    holes_for_mounting_the_microswitches();

    // Remove some material in the lower part of house so that cables from keypad can pass there
    translate([-(housing_x/2+mount_x/*+housing_front_housing_thickness*/),0,-housing_z/2])
    cube([housing_x,housing_y*2,housing_lower_cable_passage*2], center=true);
  }

}





module housing()
{

  housing_box();


}


// The moving part, origo is in the center of its outermost surface.
module block_cylinder_base()
{

    // main part
    translate([-block_len/2-block_house_margin-block_move_margin, 0, 0])
    hull()
    {
       cube([block_len,block_y,block_z], center=true);
       cube([block_len+2*block_move_margin,block_y-1,block_z-block_move_margin], center=true);
    }



    // vertical part to trigger microswitches
    translate([block_teeth_base_offset_x+microswitch_offset_x, 0, +( block_vertical_z- housing_thicknes -1)])
    cube([block_vertical_x,block_y,housing_z*0.3], center=true);

    // The linear gears
    translate([block_teeth_base_offset_x, 0, -( block_z/2 + block_teeth_base_z)])
    rotate([0,180,0])
    {
        translate([0, 0, block_gear_offset_z])
        h_rack_gear(block_gear_len, block_y, 3+block_teeth_base_z, 12, motor_spur_gear_module);
   }
}

module block_cylinder()
{
  difference()
  {
    block_cylinder_base();

    // An opening in the block cylinder for the support part that keep it in place.
    translate([block_teeth_base_offset_x, 0, 0])
    cube([block_gear_len+2*block_house_margin,block_y*2,block_center_z+block_house_margin], center=true);
  }
}

// This is used to check that the teeth don't go into each other.
module gear_animation(axle_diam, tot_length, face_width, n_teeth, gear_module)
{
 
        translate([-n_teeth*gear_module/2, 0,0])
        rotate([0,0,360*$t/n_teeth])
        h_spur_gear(axle_diam, tot_length, face_width, n_teeth, gear_module);

        translate([n_teeth*gear_module/2, 0,0])
        rotate([0,0,-360*$t/n_teeth+180/n_teeth])
        h_spur_gear(axle_diam, tot_length, face_width, n_teeth, gear_module);


        translate([0, 0,-20+n_teeth*gear_module/2])
        rotate([90,360*$t/n_teeth+180/n_teeth,0])
        h_spur_gear(axle_diam, tot_length, face_width, n_teeth, gear_module);

        //translate([sin($t*360)*3.14159*gear_module, 0,-20])
        translate([-$t*3.14159*gear_module, 0,-20])
        h_rack_gear(50, face_width, gear_module*2, 6, gear_module);
}

// Origo for this is in center of the base of gear (the end without teeth)
module motor_gear()
{
  translate([0, 0, motor_spur_gear_length/2])
  {

    h_spur_gear(motor_axle_diam+motor_axle_diam_margin, motor_spur_gear_length, motor_spur_gear_face_width, motor_spur_gear_n_teeth, motor_spur_gear_module);

    translate([(motor_axle_diam+motor_axle_diam_margin)*0.57, 0, (motor_spur_gear_length-motor_gear_flens_length)/2])
    cube([motor_axle_diam/2,motor_axle_diam,motor_gear_flens_length], center=true);
  }
}


// Origo here is where the axle exits the main body of motor.
// Motor body extends along negative y axle
module motor()
{
  rotate([-90,0,0])
  {
    translate([0, 0, -motor_length/2])
    {
      // Main body
      intersection()
      {
        h_cylinder(motor_diam/2,motor_length);
        cube([motor_diam+1,motor_diam-2,motor_length], center=true);
      }

      // motor axle
      translate([0, 0, motor_axle_len/2+motor_length/2])
      h_cylinder(motor_axle_diam/2,motor_axle_len);


      //translate([0, 0, motor_axle_len/2+motor_length/2+(motor_axle_len-motor_gear_len)/2])
      //h_gear(motor_axle_diam, motor_gear_len, motor_gear_teeth_len, motor_gear_n_teath, motor_gear_module);

    }


    translate([0, 0, motor_mount_y])
    rotate([0,0,factor*360*0.70])
    motor_gear();
  }
}


// Origo for this module is between the two mounting holes.
module microswitch()
{

    translate([0, 0, -microswitch_dist_base_to_holes])
    {

     difference()
     {
      translate([0, 0, microswitch_height/2])
      cube([microswitch_len,microswitch_width,microswitch_height], center=true);

      translate([microswitch_dist_between_holes/2, 0, microswitch_dist_base_to_holes])
      rotate([90,0,0])
      h_cylinder(microswitch_diam/2,microswitch_width*2);

      translate([-microswitch_dist_between_holes/2, 0, microswitch_dist_base_to_holes])
      rotate([90,0,0])
      h_cylinder(microswitch_diam/2,microswitch_width*2);
     }

     // lever
     translate([-microswitch_lever_base, 0, microswitch_height])
     rotate([0,-5,0])
     translate([microswitch_lever_len/2, 0, 0])
     cube([microswitch_lever_len,microswitch_lever_width,microswitch_lever_thickness], center=true);

     // terminals
     translate([-microswitch_len*0.40, 0, 0])
     cube([microswitch_lever_thickness,microswitch_terminal_width,microswitch_terminal_len], center=true);

     // terminals
     translate([microswitch_len*0.05, 0, 0])
     cube([microswitch_lever_thickness,microswitch_terminal_width,microswitch_terminal_len], center=true);

     // terminals
     translate([microswitch_len*0.40, 0, 0])
     cube([microswitch_lever_thickness,microswitch_terminal_width,microswitch_terminal_len], center=true);
    }
}


// This was used to adust the size of nut mounts.
module size_of_nut_mounts_example()
{
  intersection()
  {
    translate([20,-20,housing_y/2]) rotate([90,0,0]) housing();
    h_cylinder(25,40);
  }
}


  // x
  //translate([50, 0, 0])
  //cube([2,2,2], center=true);

module all()
{
  color("Green",0.5)
  translate([block_move*factor, 0,0])
  block_cylinder();

  color("Purple",0.5)
  mounting_plate();

  color("Red",0.5)
  housing();

  //color("Orange",0.5)
  //translate([0,40,0])
  //outer_plate();

  color("Magenta",0.5)
  translate([motor_pos_x, motor_pos_y, motor_pos_z])
  motor_mount();

  color("Yellow",0.5)
  translate([motor_pos_x, motor_pos_y, motor_pos_z])
  motor_tube();


  color("Blue",0.5)
  translate([motor_pos_x, motor_pos_y-motor_mount_y, motor_pos_z])
  motor();


  color("Black",0.5)
  translate([microswitch_inner_x, 0, microswitch_z])
  rotate([0,90,0])
  rotate([0,0,180])
  microswitch();


  color("Black",0.5)
  translate([microswitch_outer_x, 0, microswitch_z])
  rotate([0,-90,0])
  //rotate([0,0,180])
  microswitch();

}


// This frame is an experiment, the intention is to help prevent warping when printing the object.
module frame(x,y)
{
  t=2;
  z=3;
  translate([0,0,z/2])
  difference()
  {
    cube([x,y,z], center=true);
    cube([x-t,y-t,z*2], center=true);
    cube([2,y+2,z*2], center=true);
    cube([x+2,2,z*2], center=true);

    cube([x-40,y+2,z*2], center=true);
    cube([x+2,y-40,z*2], center=true);
  }
}


// To run gear animation, use "view" -> "animate", then in the bar that 
// appears enter something like FPS 10, Steps 100.

// Uncomment one of the lines below

all();
//microswitch();
//rotate([0,0,90]) {translate([block_len/2+3,-3.2,block_y/2]) rotate([90,0,0]) block_cylinder(); frame(87,40); translate([13,13,0]) cube([30, 1, 3]);}
//translate([0,0,mount_x]) rotate([0,-90,0]) mounting_plate(); //frame(155,33);
//translate([42,housing_lower_cable_passage/2,housing_y/2]) rotate([90,0,0]) housing(); frame(86,77);
//translate([42,housing_lower_cable_passage/2,housing_thicknes-housing_y/2]) rotate([90,0,0]) outer_plate(); frame(86,79);
//rotate([-90,0,0]) motor_mount();
//rotate([-90,0,0]) motor_tube();
//translate([0,0,motor_spur_gear_length]) rotate([180,0,0]) motor_gear();
//size_of_nut_mounts_example();
//translate([0,0,1.2]) rotate([-90,0,0]) motor();

//screw_hole_for_countersunkscrew(3);


//translate([0,0,motor_mount_tube]) motor_handle();


