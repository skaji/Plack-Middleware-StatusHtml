use strict;
use warnings;
use utf8;
use Test::More;
use Plack::Test;
use Plack::Builder;
use HTTP::Request::Common;

my $app = sub { [200,[],["ok"]] };

{
    eval { builder { enable 'StatusHtml'; $app }; };
    ok $@;
}

test_psgi
    app => builder {
        enable 'StatusHtml', status => 500;
        $app;
    },
    client => sub {
        my $cb = shift;
        my $res;
        $res = $cb->( GET "/" );
        is $res->code, 200;
        $res = $cb->( GET "/status.html" );
        is $res->code, 500;
        is $res->content_type, "text/html";

        $res = $cb->( GET "/a/status.html" );
        is $res->code, 200;
        $res = $cb->( GET "/status.html?hoge=foo" );
        is $res->code, 500;
        is $res->content_type, "text/html";

        note $res->content;
    };

test_psgi
    app => builder {
        enable 'StatusHtml', status => sub { 500 };
        $app;
    },
    client => sub {
        my $cb = shift;
        my $res;
        $res = $cb->( GET "/" );
        is $res->code, 200;
        $res = $cb->( GET "/status.html" );
        is $res->code, 500;
        is $res->content_type, "text/html";

        $res = $cb->( GET "/a/status.html" );
        is $res->code, 200;
        $res = $cb->( GET "/status.html?hoge=foo" );
        is $res->code, 500;
        is $res->content_type, "text/html";

        note $res->content;
    };

test_psgi
    app => builder {
        enable 'StatusHtml', status => sub {
            my $env = shift;
            $env->{HTTP_X_FOO} ? 500 : 501;
        };
        $app;
    },
    client => sub {
        my $cb = shift;
        my $res;
        $res = $cb->( GET "/" );
        is $res->code, 200;
        $res = $cb->( GET "/status.html" );
        is $res->code, 501;

        $res = $cb->( GET "/status.html", "x-foo" => 1 );
        is $res->code, 500;
        is $res->content_type, "text/html";
        $res = $cb->( GET "/status.html?hoge=foo", "x-foo" => 1 );
        is $res->code, 500;
        is $res->content_type, "text/html";
    };



done_testing;

