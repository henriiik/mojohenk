use Mojolicious::Lite;
use Mojo::mysql;

use 5.20.2;
use experimental 'signatures';

helper mysql => sub { 
    state $mysql = Mojo::mysql->new('mysql://root:so_secret_password@mysql/mojohenk')
};

sub handleUsers {
    my ($c, $db, $err, $results) = @_;
    
    if ($err) {
        $c->render(text => qq|
        <p>ERROR: $err</p>
        |);
    } else {
        my $users = $results->hashes;
        my $HTML = '<h1>Users</h1>';
        foreach my $u (@$users) {
            $HTML .= "<p>id: $u->{id}, email: $u->{email}</p>";
        }
        $c->render(text => $HTML);
    }
}

sub queryThen($c, $db, $query, $callback) {
    $db->query($query => sub {
        $callback->($c, @_);
    });
}

sub main {
    my ($c, $page, $section) = @_;
    
    $page = "Frontpage" unless $page;
    $section = "default" unless $section;

    if ($page eq 'users') {
        my $db = $c->mysql->db;
        queryThen($c, $db, 'select * from user', \&handleUsers);
    } else {
        $c->render(text => qq|
        <h1>$page</h1>
        <p>section: $section</p>
        |);
    }
}

get '/' => sub {
    my $c = shift;
    $c->redirect_to('index.pl');
};

get '/index.pl' => sub {
    my $c  = shift;
    my $params = $c->req->params->to_hash;
    main($c, $params->{'page'}, $params->{'section'});
};

get '/:page/:section' => sub {
    my $c = shift;
    main($c, $c->stash('page'), $c->stash('section'));
};

get '/:page' => sub {
    my $c = shift;
    main($c, $c->stash('page'), '');
};

app->start;
