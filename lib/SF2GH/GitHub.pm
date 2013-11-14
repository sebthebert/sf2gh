=head1 NAME

SF2GH::GitHub - SourceForge 2 GitHub GitHub module

This module uses GitHub API.

http://developer.github.com/v3/issues/
http://developer.github.com/v3/issues/comments/

=cut

package SF2GH::GitHub;

use Data::Dumper;
use JSON;
use LWP::UserAgent 6;

my $URL_GH_REPOS = 'https://api.github.com/repos';

my $ua = LWP::UserAgent->new;
$ua->agent("sf2gh/$SF2GH::VERSION");
$ua->ssl_opts(verify_hostname => 0);

=head1 SUBROUTINES/METHODS

=head2 Close_Issue($token, $user, $project, $id_issue)

Closes GitHub Issue

=cut

sub Close_Issue
{
    my ($token, $user, $project, $id_issue) = @_;
    
    my $url = "$URL_GH_REPOS/$user/$project/issues/${id_issue}?access_token=$token";
    
    my $req = HTTP::Request->new(PATCH => $url);
    $req->header( 'Content-Type' => 'application/json' );

    $req->content(to_json({ state => 'closed' }));
    my $res = $ua->request($req);
    
    if ($res->is_success) 
    {
        my $data = from_json($res->content);
        
        return ($data->{number});
    }
    else 
    {
        printf "%s %s\n", $url, $res->status_line;
      
        return (undef);
    }
}

=head2 Create_Issue($token, $user, $project, $json)

Creates GitHub Issue

=cut

sub Create_Issue
{
    my ($token, $user, $project, $data) = @_;
    
    my $url = "$URL_GH_REPOS/$user/$project/issues?access_token=$token";
    
    my $req = HTTP::Request->new(POST => $url);
    $req->header( 'Content-Type' => 'application/json' );
	
	$data->{assignee} = $data->{assignee} || $user;

    $req->content(to_json($data));
    my $res = $ua->request($req);
  
    if ($res->is_success) 
    {
        my $data = from_json($res->content);
        
        return ($data->{number});
    }
    else 
    {
        printf "%s %s\n", $url, $res->status_line;
      
        return (undef);
    }
}

=head2 Update_Issue($token, $user, $project, $id_issue, $data)

Updates GitHub Issue

=cut

sub Update_Issue
{
    my ($token, $user, $project, $id_issue, $data) = @_;
    
    my $url = "$URL_GH_REPOS/$user/$project/issues/$id_issue/comments?access_token=$token";
    
    my $req = HTTP::Request->new(POST => $url);
    $req->header( 'Content-Type' => 'application/json' );
    $req->content(to_json($data));
    my $res = $ua->request($req);
    
    if ($res->is_success) 
    {
        my $data = from_json($res->content);
        
        return ($data->{number});
    }
    else 
    {
        printf "%s %s\n", $url, $res->status_line;
        
        return (undef);
    }
}  

1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut
