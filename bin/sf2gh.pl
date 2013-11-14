#!/usr/bin/perl

=head1 NAME

sf2gh.pl - SourceForge to GitHub migration tool

=head1 DESCRIPTION

This program is useful to migrate your project from SourceForge to GitHub

You need to export your project data from SourceForge first.
(https://sourceforge.net/p/<project>/admin/export)

You also need to have a GitHub Token.

=head1 SYNOPSIS

	sf2gh.pl --project <sf_project_name> 
	   --tracker <bugs|feature-requests|support-requests>
	   --ghtoken <github_token> --ghuser <github_user> --ghrepo <github_repository>
	   [ --exclude <list_of_ids_to_exclude> ]
	   
	sf2gh.pl --help
	
	sf2gh.pl --version

=head1 OPTIONS

=over 4

=item B<-h>, B<-?>, B<--help>

Prints a brief help message and exits.

=item B<-p>, B<--project>

Sets the Project to migrate

=item B<-t>, B<--tracker>

Sets the Tracker to migrate (bugs, feature-requests or support-requests)

=item B<-V>, B<--verbose>

Sets verbose mode.

=item B<-v>, B<--version>

Prints program version an exits.

=item B<-x>, B<--exclude>

Sets a list of ids to exclude from the migration

=back

=cut

use strict;
use warnings;

use FindBin;
use Getopt::Long;

use lib "$FindBin::Bin/../lib/";
use SF2GH;
use SF2GH::GitHub;
use SF2GH::SourceForge;

our $PROGRAM = 'sf2gh.pl';
our $VERSION = $SF2GH::VERSION;

=head1 SUBROUTINES/METHODS

=head2 POD2Usage($n)

Prints program usage from the POD 

n=0 -> only SYNOPSIS
n=1 -> only SYNOPSIS, OPTIONS, ARGUMENTS, OPTIONS AND ARGUMENTS
n=2 -> Entire manpage

=cut

sub POD2Usage
{
	my $n = shift;  

    require Pod::Usage;

    Pod::Usage::pod2usage({ -exitval => 0, -verbose => $n, -noperldoc => 1 });  
}

#
# MAIN
#

my %opt = ();
GetOptions(\%opt,
        'ghrepo|r=s',
		'ghtoken|k=s',
		'ghuser|u=s',
        'help|h|?', 
        'man',
		'project|p=s',
		'tracker|t=s@',
		'verbose|V',
        'version|v',
        'exclude|x'     
        ) or POD2Usage(2);

$opt{man}       and POD2Usage(2);
$opt{help}      and POD2Usage(1);
$opt{version}   and print "$PROGRAM $VERSION\n" and exit;

# Prints Help if no project, tracker, ghtoken, ghuser, ghrepository defined
($opt{project} && $opt{tracker} 
    && $opt{ghtoken} && $opt{ghuser} && $opt{ghrepo}) 
        or POD2Usage(1);

$opt{verbose} and $SF2GH::VERBOSE = 1;

foreach my $tracker (@{$opt{tracker}})
{
    if ($tracker =~ /^(bugs|feature-requests|support-requests)$/)
	{
	   my @ids = SF2GH::SourceForge::Tracker_Items($opt{project}, $tracker);
	   foreach my $id (sort {$a <=> $b} @ids)
	   {
	       printf "----------------------------------------\n";
		   printf "Item %d:\n", $id;
		   my $item = SF2GH::SourceForge::Tracker_Item($opt{project}, $tracker, $id);
            if ($item)
			{
			    printf "%s\n", $item->{summary};
			    my $body = $item->{description};
			    if (scalar @{$item->{attachments}})
                {
                    $body .= "\n\n";
                    foreach my $a (@{$item->{attachments}})
                    {
                        $body .= sprintf "**Attachment:** %s\n", $a->{url};
                    }
                }
			    my $gh_id = SF2GH::GitHub::Create_Issue(
			         $opt{ghtoken}, $opt{ghuser}, $opt{ghrepo},
                        { title => $item->{summary}, body => $body,
                            labels => ["SF2GH-$tracker"], assignee => 'sebthebert' } );

            	my @sorted_posts = sort { $a->{timestamp} cmp $b->{timestamp} } 
                	@{$item->{discussion_thread}->{posts}};
            	foreach my $p (@sorted_posts)
            	{
            	    my $body = sprintf "**Date:** %s\n**Author:** %s\n\n%s\n",
            	       $p->{timestamp}, $p->{author}, $p->{text};
                if (scalar @{$p->{attachments}})
                {
                    $body .= "\n\n";
                    foreach my $a (@{$p->{attachments}})
                    {
                        $body .= sprintf "**Attachment:** %s\n", $a->{url};
                    }
                }
            	    SF2GH::GitHub::Update_Issue(
            	       $opt{ghtoken}, $opt{ghuser}, $opt{ghrepo}, $gh_id,
                        { body => $body });
                    
            	}
            SF2GH::GitHub::Close_Issue($opt{ghtoken}, $opt{ghuser}, $opt{ghrepository}, $gh_id)
                if ($item->{status} eq "closed");	
			}
		}
	}
}

#SF2GH::SourceForge::Feature_Requests($project);
#SF2GH::SourceForge::Feature_Request($project, 30);
#SF2GH::SourceForge::Support_Requests($project);

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut
