package Unicorn::Manager::Web;
use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin::Authentication;
use String::Random;

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

                my $users = {
                    admin => {
                        username => 'Admin',
                        password => 'test123',
                        name     => 'Mak Simal',
                    },
                };

                return $users->{$uid} || undef;
            },
            'validate_user' => sub {
                my $self = shift;
                my $uid  = shift;
                my $pass = shift;

                return 'admin' if $uid eq 'Admin' && $pass eq 'test123';
            },
        }
    );

    # Normal route to controller
    $r->route('/welcome')->to('admin#welcome');
    $r->route('/auth')->to('admin#auth');
    $r->route('/login')->to('admin#login');
    $r->route('/logout')->to('admin#leave');

    $r->route('/users/:action')->over(authenticated => 1)->to( controller => 'users' );
}

1;
