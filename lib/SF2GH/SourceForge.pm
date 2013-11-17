
=head1 NAME

SF2GH::SourceForge - SourceForge 2 GitHub SourceForge module

=DESCRIPTION

This module extracts information from json files exported from SourceForge.
(https://sourceforge.net/p/<project>/admin/export)

=cut

package SF2GH::SourceForge;

use strict;
use warnings;

use Data::Dumper;
use File::Slurp;
use JSON;

=head1 SUBROUTINES/METHODS

=head2 Tracker_Item($project, $tracker_type, $id)

=cut

sub Tracker_Item
{
    my ($project, $tracker_type, $id) = @_;

    my $file = "${project}-backup/${tracker_type}.json";
    (-r $file)  or die "[ERROR] Unable to find tracker file $file !";
    my $data = from_json(read_file($file));

    foreach my $ticket (@{$data->{tickets}})
    {
        return ($ticket) if ($ticket->{ticket_num} == $id);
    }

    return (undef);
}

=head2 Tracker_Items($project, $tracker_type)

=cut

sub Tracker_Items
{
    my ($project, $tracker_type) = @_;

    my @ids  = ();
    my $file = "${project}-backup/${tracker_type}.json";
    (-r $file)  or die "[ERROR] Unable to find tracker file $file !";
    my $data = from_json(read_file($file));
    foreach my $item (@{$data->{tickets}})
    {
        if ($SF2GH::VERBOSE)
        {
            printf "%s: %s [%s]\n",
                $item->{ticket_num}, $item->{summary}, $item->{status};
        }
        push @ids, $item->{ticket_num};
    }

    return (@ids);
}

1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut
