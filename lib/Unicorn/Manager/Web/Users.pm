package Unicorn::Manager::Web::Users;
use Mojo::Base 'Mojolicious::Controller';

has user_config => sub {
    my $self = shift;

    return {
        Rails => {
            skel => '/etc/skel_rails',
            database => 'postgres',
        },
        Wordpress => {
            skel => '/etc/skel_php',
            database => 'mysql',
        },
    };
};


sub index {
    my $self = shift;

    $self->redirect_to( controller => 'users', action => 'list');
}

sub list {
    my $self = shift;

    open my $fh, '<', '/etc/passwd';
    my @list = <$fh>;
    close $fh;

    my @users = ();

    for (@list){
        my ($username, undef, $uid, $gid, $comment, $home, $shell) = split ':', $_;
        push @users, {
            username => $username,
            uid => $uid,
            gid => $gid,
            comment => $comment,
            home => $home,
            shell => $shell,
        } if $uid > 500 && $username ne 'nobody';
    }

    $self->render('list', userlist => [@users]);
}

sub add {
    my $self = shift;

    my $config = [];
    for (keys %{$self->user_config}){
        push @$config, $_;
    }

    $self->render('add', config => $config);
}

sub create {
    my $self = shift;

    my $username = $self->param('username');
    my $type = $self->param('type');

    if (!$type or !$username){
        $self->flash( message => 'Username missing!');
        $self->redirect_to('/users/add');
    }

    my $useradd = 'useradd -m -s /bin/bash -k ' . $self->user_config->{$type}->{skel} . ' ' . $username;

    $self->render('create', useradd => $useradd);

}

1;

