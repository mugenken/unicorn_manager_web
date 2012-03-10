package Unicorn::Manager::Web::Site;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub index {
    my $self = shift;

    $self->stash(message => 'Welcome to Unicorn::Manager::Web');
    $self->render('index');
}

sub login {
    my $self = shift;

    $self->stash( message => 'help yourself in' );
    $self->render('login');
}

sub auth {
    my $self = shift;

    if ($self->authenticate($self->param('username'), $self->param('password'))){
        $self->session->{authenticated} = 1;
    }

    $self->redirect_to('/');
}

sub leave {
    my $self = shift;

    $self->logout();
    delete $self->session->{authenticated};
    $self->redirect_to('/');
}

1;
