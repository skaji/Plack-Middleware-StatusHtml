package Plack::Middleware::StatusHtml;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use parent 'Plack::Middleware';
use Plack::Util::Accessor qw(status);

use HTTP::Status qw(status_message);

sub prepare_app {
    my $self   = shift;
    my $status = $self->status or die "ERROR missing 'status' configuration";
    $self->status( ref $status ? $status : sub { $status } );
}

sub call {
    my ($self, $env) = @_;

    if ($env->{PATH_INFO} eq '/status.html') {
        my $status  = $self->status->($env);
        my $message = status_message $status;

        # taken from Amon2::Web::create_simple_status_page
        my $html = <<"...";
<!doctype html>
<html>
    <head>
        <meta charset=utf-8 />
        <title>$status $message</title>
        <style type="text/css">
            body {
                text-align: center;
                font-family: 'Menlo', 'Monaco', Courier, monospace;
                background-color: whitesmoke;
                padding-top: 10%;
            }
            .number {
                font-size: 800%;
                font-weight: bold;
                margin-bottom: 40px;
            }
            .message {
                font-size: 400%;
            }
        </style>
    </head>
    <body>
        <div class="number">$status</div>
        <div class="message">$message</div>
    </body>
</html>
...
        return [
            $status,
            [
                'Content-Type' => 'text/html; charset=utf-8',
                'Content-Length' => length($html),
            ],
            [$html],
        ];
    } else {
        return $self->app->($env);
    }
}


1;
__END__

=encoding utf-8

=head1 NAME

Plack::Middleware::StatusHtml - health check by /status.html

=head1 SYNOPSIS

    use Plack::Builder;

    builder {
        enable 'StatusHtml', status => sub {
            my $env = shift;
            if (...) { 200 } else { 503 };
        };
        $app;
    };

=head1 DESCRIPTION

It is common to check whether a web application is alive or not
by accessing /status.html.
This middleware serves /status.html with your desired http status code.

=head1 CONFIGURATION

=over 4

=item status

A callback function that returns http status code,
or just a http status code.

The callback function will get the PSGI env as the first variable.


=back

=head1 LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Shoichi Kaji E<lt>skaji@cpan.orgE<gt>

=cut

