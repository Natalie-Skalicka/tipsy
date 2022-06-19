use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Routes;
use Tipsy;

my $tipsy = Tipsy.new;
my $application = routes($tipsy);

my Cro::Service $http = Cro::HTTP::Server.new(
    http => <1.1>,
    host => %*ENV<HTTP_HOST> ||
        die("Missing HTTP_HOST in environment"),
    port => %*ENV<HTTP_PORT> ||
        die("Missing HTTP_PORT in environment"),
    :$application,
    after => [
        Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
    ]
);
$http.start;
say "Listening at http://%*ENV<HTTP_HOST>:%*ENV<HTTP_PORT>";
react {
    whenever signal(SIGINT) {
        say "Shutting down...";
        $http.stop;
        done;
    }
}
