use Mojolicious::Lite;
use Mojo::mysql;
use 5.20.2;
use experimental 'signatures';

helper mysql => sub { 
    state $mysql = Mojo::mysql->new('mysql://root:so_secret_password@mysql/mojohenk')
};

sub handleUsers {
    my ($delay, $err, $results) = @_;
    return $results->hashes;
}

sub queryThen($c, $mysql, $query, $cb) {
    $mysql->query($query => sub {
        my $json = $cb->(@_);
        $c->render(json => $json);
    });
}

get '/' => sub {
    my $c  = shift;
    my $db = $c->mysql->db;
    queryThen($c, $db, 'select * from user', \&handleUsers);
};

app->start;
