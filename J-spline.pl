#!/usr/bin/perl
use warnings;
use strict;
use Glib qw/TRUE FALSE/;
use Gtk2 -init;

my $xsize             = 400;
my $ysize             = 400;
my $subdivision_level = 5;

my @points =
  ( '120', '350', '100', '350', '80', '350', '80', '210', '120', '100'
+, '260', '50', '220', '210', '220', '350', '200', '350', '180', '350'
+ ); 
my $area;

my %allocated_colors;
my ( $x0, $y0, $x1, $y1, $width, ) = ( 0, 0, 0, 0 );

my $window = new Gtk2::Window("toplevel");
$window->signal_connect( "delete_event", sub { Gtk2->main_quit; } );
$window->set_border_width(10);
$window->set_size_request( 640, 480 );
$window->set_position('center');

my $vbox = Gtk2::VBox->new( 0, 0 );
$window->add($vbox);
$vbox->set_border_width(2);

my $hbox = Gtk2::HBox->new( 0, 0 );
$vbox->pack_start( $hbox, 1, 1, 0 );
$hbox->set_size_request( 320, 240 );
$hbox->set_border_width(2);

my $hbox1 = Gtk2::HBox->new( 0, 0 );
$vbox->pack_start( $hbox1, 0, 0, 0 );
$hbox1->set_border_width(2);

my $button1 = Gtk2::Button->new('Generate');
$hbox1->pack_start( $button1, FALSE, FALSE, 2 );
$button1->signal_connect( clicked => sub { start_drawing($area) } );

my $button2 = Gtk2::Button->new('Exit');
$hbox1->pack_start( $button2, FALSE, FALSE, 2 );
$button2->signal_connect( clicked => sub { exit; } );

my $scwin = Gtk2::ScrolledWindow->new();
my $ha1   = $scwin->get_hadjustment;
$scwin->set_policy( 'always', 'never' );

my $vp = Gtk2::Viewport->new( undef, undef );
$scwin->add($vp);
$hbox->pack_start( $scwin, 1, 1, 0 );

$area = new Gtk2::DrawingArea;
$area->size( $xsize, $ysize );
$vp->add($area);

$area->set_events(
    [
        qw/exposure-mask
          leave-notify-mask
          button-press-mask
          pointer-motion-mask
          pointer-motion-hint-mask/
    ]
);

$area->signal_connect( button_press_event => \&button_press_event );

$window->show_all;

Gtk2->main;

sub get_color {
    my ( $colormap, $name ) = @_;
    my $ret;

    if ( $ret = $allocated_colors{$name} ) {
        return $ret;
    }

    my $color = Gtk2::Gdk::Color->parse($name);
    $colormap->alloc_color( $color, TRUE, TRUE );

    $allocated_colors{$name} = $color;

    return $color;
}

sub draw_line {
    my ( $widget, $line, $color ) = @_;

    my $colormap = $widget->window->get_colormap;

    my $gc = $widget->{gc} || new Gtk2::Gdk::GC $widget->window;
    $gc->set_foreground( get_color( $colormap, $color ) );

    $widget->window->draw_lines( $gc, @$line );
    $gc->set_foreground( get_color( $colormap, 'black' ) );
    $widget->window->draw_points( $gc, @$line );
}

sub start_drawing {
    my $area = shift;

    &draw_line( $area, [@points], 'blue' );

    my $a;
    my $b;
    my $k = 0;
    while ( $k++ < $subdivision_level ) {
        my $j = 0;
        my @tmp;
        while ( $j < $#points ) {
            $a = $b = 0.5;
            if ( $j == 0 ) {

                push( @tmp, $points[$j] );
                push( @tmp, $points[ $j + 1 ] );
            }
            elsif ( $j + 3 <= $#points ) {
                my ( $pt1, $pt2 );

                #push( @tmp, $points[$j] );
                #push( @tmp, $points[ $j + 1 ] );

                $pt1 =
                  ( $a * $points[ $j - 2 ] +
                      ( 8 - 2 * $a ) * $points[$j] +
                      $a * $points[ $j + 2 ] ) / 8;
                $pt2 =
                  ( $a * $points[ $j - 1 ] +
                      ( 8 - 2 * $a ) * $points[ $j + 1 ] +
                      $a * $points[ $j + 3 ] ) / 8;
                push( @tmp, int($pt1) );
                push( @tmp, int($pt2) );
            }
            if ( $j + 5 <= $#points && $j > 0) {
                my ( $pt1, $pt2 );

                #push( @tmp, $points[ $j + 2 ] );
                #push( @tmp, $points[ $j + 3 ] );

                $pt1 =
                  ( ( $b - 1 ) * $points[$j -2] +
                      ( 9 - $b ) * $points[ $j ] +
                      ( 9 - $b ) * $points[ $j + 2 ] +
                      ( $b - 1 ) * $points[ $j + 4 ] ) / 16;
                $pt2 =
                  ( ( $b - 1 ) * $points[ $j -1 ] +
                      ( 9 - $b ) * $points[ $j + 1 ] +
                      ( 9 - $b ) * $points[ $j + 3 ] +
                      ( $b - 1 ) * $points[ $j + 5 ] ) / 16;
                push( @tmp, int($pt1) );
                push( @tmp, int($pt2) );
            }
            $j += 2;
        }
        push( @tmp, $points[ $#points - 1 ] );
        push( @tmp, $points[$#points] );
        @points = ();
        @points = @tmp;
        print "@points\n";
    }

    &draw_line( $area, [@points], 'green' );
    print "@points";
}
