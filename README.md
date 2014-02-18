# NAME

Plack::Middleware::StatusHtml - health check by /status.html

# SYNOPSIS

    use Plack::Builder;

    builder {
        enable 'StatusHtml', status => sub {
            my $env = shift;
            if (...) { 200 } else { 503 };
        };
        $app;
    };

# DESCRIPTION

It is common to check whether a web application is alive or not
by accessing /status.html.
This middleware serves /status.html with your desired http status code.

# CONFIGURATION

- status

    A callback function that returns http status code,
    or just a http status code.

    The callback function will get the PSGI env as the first variable.

# LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Shoichi Kaji <skaji@cpan.org>
