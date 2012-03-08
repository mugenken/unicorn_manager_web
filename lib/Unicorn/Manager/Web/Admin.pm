package Unicorn::Manager::Web::Admin;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub welcome {
    my $self = shift;

    $self->redirect_to('/login') and return 0 unless( $self->user_exists );

    # Render template "example/welcome.html.ep" with message
    $self->render(
        message => 'Welcome to the Mojolicious real-time web framework!'
    );
}

sub login {
    my $self = shift;

    $self->stash( message => 'help yourself in' );
    $self->render('login');
}

sub auth {
    my $self = shift;

    $self->authenticate($self->param('username'), $self->param('password'));

    my $redirect = $self->session->{coming_from};
    delete $self->session->{coming_from};
    $self->redirect_to( $redirect || '/welcome');
}

sub leave {
    my $self = shift;

    $self->logout();
    $self->render( text => 'logout' );
}

1;
