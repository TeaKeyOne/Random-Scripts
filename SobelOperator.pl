#!/usr/local/bin/perl
use strict;
use warnings;
use Image::Magick;

sub sobelEdgeDetection($);

my $inputImage  = 'input.jpg';
my $outputImage = 'output.jpg';
my $Img         = new Image::Magick;
my $warn        = $Img->Read($inputImage);
print "$warn";

my $foo = sobelEdgeDetection($Img);
$warn = $foo->Write($outputImage);
print "$warn";

sub sobelEdgeDetection($) {
    my $imSrcImg  = shift;
    my $buf       = $imSrcImg->Clone();
    my @GX        = ( [ -1, 0, 1 ], [ -2, 0, 2 ], [ -1, 0, 1 ] );
    my @GY        = ( [ 1, 2, 1 ], [ 0, 0, 0 ], [ -1, -2, -1 ] );
    my $tolerance = 90;

    my $sumRx     = 0;
    my $sumGx     = 0;
    my $sumBx     = 0;
    my $sumRy     = 0;
    my $sumGy     = 0;
    my $sumBy     = 0;
    my $finalSumR = 0;
    my $finalSumG = 0;
    my $finalSumB = 0;
    my $gray      = 0;
    my ( $width, $height ) = $imSrcImg->Get( 'width', 'height' );

    # Iterate over every pixel in the image and change
    for my $y ( 1 .. ( $height - 2 ) ) {
        for my $x ( 1 .. ( $width - 2 ) ) {
            for ( my $i = -1 ; $i <= 1 ; $i++ ) {
                for ( my $j = -1 ; $j <= 1 ; $j++ ) {
                    my @pixel =
                      $imSrcImg->GetPixel( x => $x + $i, y => $y + $j 
+);
                    #GetPixel method returns normalized floated colors
+ 0..1 so they need to be converted
                    my $r = int( $pixel[0] * 255 );
                    my $g = int( $pixel[1] * 255 );
                    my $b = int( $pixel[2] * 255 );

                    $sumRx += $r * $GX[ $i + 1 ][ $j + 1 ];
                    $sumGx += $g * $GX[ $i + 1 ][ $j + 1 ];
                    $sumBx += $b * $GX[ $i + 1 ][ $j + 1 ];

                    $sumRy += $r * $GY[ $i + 1 ][ $j + 1 ];
                    $sumGy += $g * $GY[ $i + 1 ][ $j + 1 ];
                    $sumBy += $b * $GY[ $i + 1 ][ $j + 1 ];
                }
            }
            $finalSumR = abs($sumRx) + abs($sumRy);
            $finalSumG = abs($sumGx) + abs($sumGy);
            $finalSumB = abs($sumBx) + abs($sumBy);

            $gray = ( $finalSumR + $finalSumG + $finalSumB ) / 3;

            if ( $gray > $tolerance ) {
                $buf->Set( "pixel[$x,$y]" => "white" );
            }
            else {
                $buf->Set( "pixel[$x,$y]" => "black" );
            }

            $sumRx = 0;
            $sumGx = 0;
            $sumBx = 0;
            $sumRy = 0;
            $sumGy = 0;
            $sumBy = 0;
            $gray  = 0;
        }
    }
    return $buf;
}
