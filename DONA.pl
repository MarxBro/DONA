#!/usr/bin/perl
######################################################################
# DONAS (aka torus, toroide, gomon)
######################################################################

use Data::Dumper;
use strict;

my $theta_spacing = 0.06;
my $phi_spacing   = 0.02;

my $R1 = 1;
my $R2 = 2;
my $K2 = 5;

my $screen_width = 120;
my $screen_height = 80;

#// Calculate K1 based on screen size: the maximum x-distance occurs roughly at
#// the edge of the torus, which is at x=R1+R2, z=0.  we want that to be
#// displaced 3/8ths of the width of the screen, which is 3/4th of the way from
#// the center to the side of the screen.
#// screen_width*3/8 = K1*(R1+R2)/(K2+0)
#// screen_width*K2*3/(8*(R1+R2)) = K1

my $K1 = $screen_width*$K2*3/(8*($R1+$R2));

my @LUCESITAS = split (undef, '.,-~:;=!*#$@');

sub render_frame {
    my ( $A, $B ) = shift;
    my $cosA = cos($A);
    my $sinA = sin($A);
    my $cosB = cos($B);
    my $sinB = sin($B);

    my @aa      = ( 0 .. $screen_width );
    my @bb      = ( 0 .. $screen_height );
    my @output  = ();
    my @zbuffer = ();
    foreach my $index (@aa) {
        foreach my $index2 (@bb) {
            $output[$index][$index2]  = ' ';
            $zbuffer[$index][$index2] = '0';
        }
    }
    for ( my $th = 0 ; $th < 2 * 3.14 ; $th += $theta_spacing ) {
        my $costheta = cos($th);
        my $sintheta = sin($th);
        for ( my $phi = 0 ; $phi < 2 * 3.14 ; $phi += $phi_spacing ) {
            my $cosphi  = cos($phi);
            my $sinphi  = sin($phi);
            my $circleX = $R2 * $R1 * $costheta;
            my $circleY = $R1 * $sintheta;

            # X Y Z ahora
            my $x = $circleX * ( $cosB * $cosphi + $sinA * $sinB * $sinphi ) - $circleY * $cosA * $sinB;
            my $y = $circleX * ( $sinB * $cosphi - $sinA * $cosB * $sinphi ) + $circleY * $cosA * $cosB;
            my $z   = $K2 + $cosA * $circleX * $sinphi + $circleY * $sinA + 1;
            my $ooz = 1 / $z;

            #Proyeccion
            my $xp = int( $screen_width / 2 + $K1 * $ooz * $x );
            my $yp = int( $screen_height / 2 - $K1 * $ooz * $y );

            #LUZ
            my $L = $cosphi * $costheta * $sinB -
                    $cosA * $costheta * $sinphi -
                    $sinA * $sintheta +
                    $cosB * ( $cosA * $sintheta - $costheta * $sinA * $sinphi );
            if ( $L > 0 ) {
                if ( $ooz > $zbuffer[$xp][$yp] ) {
                    $zbuffer[$xp][$yp] = $ooz;
                    my $luminance_index = $L * 8 ; #// this brings L into the range 0..11 (8*sqrt(2) = 11.3)
                    $output[$xp][$yp] = $LUCESITAS[$luminance_index];
                }
            }
        }
    }
    #print "\x1b[H";
    for ( my $j = 0 ; $j < $screen_width ; $j++ ) {
        for ( my $k = 0 ; $k < $screen_height ; $k++ ) {
            next unless $output[$j][$k];
            print $output[$j][$k];
        }
        print "\n";
    }


}

for my $step (100 .. 150){
    render_frame($step, $step);
    #sleep(1);
    select undef,undef,undef,0.1;
}

