
$fn = 30;
ouverture = ((2 * ($t < 0.5 ? $t : 1 - $t) * 100) % 120) + 40;
angle=22.5;

l=54.19;
L=67.46;
delta=1.19;

m=53;
M=66.25;
mM=116.98;

epaisseur=6;
jepaisseur=10;

dec=sin(angle)*M;

/*
 * Calcul du rayon.
 */
ci = cos(ouverture/2) * M + 2 * epaisseur;
cy = cos(ouverture/2) * m;
/* Théorème d'Al-Kashi */
iy = sqrt(ci*ci + cy*cy - 2 * ci * cy * cos(180 - angle));
r=(iy / 2) / sin(angle / 2);
r_ex=r+sin(ouverture/2) * M - jepaisseur / 2;
r_in=r-sin(ouverture/2) * M - jepaisseur / 2;
echo (r);
echo (iy, mM);

module master2d() {
    translate([-1.19, 6])
    difference() {
        union() {
            difference() {
                union() {
                    translate([0, -12]) square([l, 12]);
                    translate([l, -6]) circle(d=12);
                }
                
                translate([l, -6]) circle(d=4);
            }
            
            rotate(angle) {
                difference() {
                    union() {
                        translate([-L, -12]) square([L, 12]);
                        translate([-L, -6]) circle(d=12);
                    }
                
                    translate([-L, -6]) circle(d=4);
                }
            }
        }
        
        translate([delta, -6]) circle(d=4);
    }
}

module master3d() {
    linear_extrude(height=epaisseur) master2d();
}

module master3d_op() {
    translate([0, 0, epaisseur]) rotate([0, 180, 0]) master3d();
}

module jonction4() {
    rotate([90, 0, 0])
    translate([0,0,-jepaisseur/2])
    difference() {
        union() {
            cube([3*epaisseur, epaisseur, jepaisseur]);
            
            translate([0, -2*epaisseur, 0])
                cube([3*epaisseur, epaisseur, jepaisseur]);
            translate([-3*epaisseur, -epaisseur, 0])
                cube([4*epaisseur, epaisseur, jepaisseur]);
            translate([-3*epaisseur,  epaisseur, 0])
                cube([3*epaisseur, epaisseur, jepaisseur]);

            translate([-epaisseur, 0,0])
                cube([epaisseur,3*epaisseur,jepaisseur]);
            translate([epaisseur, 0,0])
                cube([epaisseur,3*epaisseur,jepaisseur]);
            translate([-2*epaisseur, -3*epaisseur,0])
                cube([epaisseur,3*epaisseur,jepaisseur]);
            translate([0, -3*epaisseur,0])
                cube([epaisseur,3*epaisseur,jepaisseur]);
        }
        
        translate([2*epaisseur,epaisseur/2, jepaisseur/2]) rotate([90,0,0])
            cylinder(h=20, r=2);
        translate([-2*epaisseur,20-epaisseur/2, jepaisseur/2]) rotate([90,0,0])
            cylinder(h=20, r=2);
        
        translate([-epaisseur/2,2*epaisseur, jepaisseur/2]) rotate([0,90,0])
            cylinder(h=20, r=2);
        translate([-20+epaisseur/2,-2*epaisseur, jepaisseur/2]) rotate([0,90,0])
            cylinder(h=20, r=2);
    }
}

module jonction3() {
    intersection() {
        difference() {
            cube([6*epaisseur, jepaisseur, 6*epaisseur], center=true);
            
            translate([epaisseur, -jepaisseur, 0])
                cube([4*epaisseur, 2*jepaisseur, epaisseur]);
            rotate([0, 120, 0]) 
            
            translate([epaisseur, -jepaisseur, 0])
                cube([4*epaisseur, 2*jepaisseur, epaisseur]);
            
            rotate([0, 240, 0]) 
            translate([epaisseur, -jepaisseur, 0])
                cube([4*epaisseur, 2*jepaisseur, epaisseur]);
            
            translate([2*epaisseur, 0, -epaisseur/2])
            cylinder(r=2, h=20);
            
            rotate([0, 120, 0])
            translate([2*epaisseur, 0, -epaisseur/2])
                cylinder(r=2, h=20);
            
            rotate([0, 240, 0])
            translate([2*epaisseur, 0, -epaisseur/2])
                cylinder(r=2, h=20);
        }

        sphere(r=3*epaisseur);
    }
}

module segment() {
    t=cos(ouverture/2)*(l-delta);
    
    translate([-t, 0, -epaisseur])
    rotate([0,0,-ouverture/2])
    {
        master3d();
        
        rotate([0, 0, ouverture])
        translate([0,0,epaisseur])
            master3d();
    }
    
    translate([t, 0, -epaisseur])
    rotate([0, 0, ouverture/2])
    {
        translate([0, 0, epaisseur]) master3d_op();
        translate([0, 0, 0]) rotate([0,0,-ouverture]) master3d_op();
    }
}

module expcircle(level=1) {
    for (i = [0:7]) {
        rotate([0,0,i*2*angle+angle]) translate([0,r, 0]) segment();
    }
    
    jonctions = (level == 1 ? [0:7] : (level == 2 ? [0,1,3,4,5,7] : [1:2:7]));
    
    for (i = jonctions) {
        rotate([0,0,i*2*angle]) translate([0,r_ex, 0]) jonction4();
        rotate([0,0,i*2*angle]) translate([0,r_in, 0]) rotate([0, 0, 180]) jonction4();
    }
    
    /*for (i = [0:7])
        #rotate([0,0,i*2*angle+angle]) translate([0, -1, 5]) cube([r, 2, 2]);
    %translate([0, 0, 6]) circle(r=r);*/
}

jonction3();

module expsphere() {
    expcircle();
    rotate([90,0,0]) expcircle(level=2);
    rotate([0,90,0]) expcircle(level=3);
}

//expsphere();