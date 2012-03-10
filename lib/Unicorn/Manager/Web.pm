package Unicorn::Manager::Web;
use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin::Authentication;
use String::Random;
use YAML;

has passwd => sub {
    my $self = shift;
    # YAML file like this
    #
    #---
    #  login_name:
    #    name: username
    #    password: secret
    #  john:
    #    name: John Doe
    #    password: password
    #
    my $passwd = $ENV{HOME} . '/passfile';

    my $users = YAML::LoadFile($passwd);

    return $users;
};

# This method will run once at server start
sub startup {
    my $self = shift;

    # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer');

    # Router
    my $r = $self->routes;
    my $random = String::Random->new;
    my $session_key = $random->randpattern('.' x 40);

    $self->plugin(
        'authentication' => {
            'session_key' => $session_key,
            'load_user' => sub {
                my $self = shift;
                my $uid = shift;

                my $users = Unicorn::Manager::Web->passwd;

                return $users->{$uid} || undef;
            },
            'validate_user' => sub {
                my $self = shift;
                my $uid  = shift;
                my $pass = shift;

                my $users = Unicorn::Manager::Web->passwd;

                return $uid if exists $users->{$uid} && $pass eq $users->{$uid}->{password};
            },
        }
    );

    # Normal route to controller
    $r->route('/')->to('site#index');
    $r->route('/auth')->to('site#auth');
    $r->route('/login')->to('site#login');
    $r->route('/logout')->to('site#leave');

    $r->route('/users/:action')->over(authenticated => 1)->to( controller => 'users' );
}

1;
