#!/usr/bin/env perl
use Modern::Perl;
use Test::More;
use E621::Client::Defaults;

ok(
	E621::Client::Defaults::REQUEST_RATE_LIMIT eq 0.5,
	"request rate limit set correctly"
);

ok(
	E621::Client::Defaults::E621_BASE_URL eq "e621.net",
	"e621 base url set correctly"
);

ok(
	E621::Client::Defaults::E926_BASE_URL eq "e926.net",
	"e926 base url set correctly"
);

ok(
	E621::Client::Defaults::PROTOCOL eq "https:",
	"protocol set correctly"
);

like(
	E621::Client::Defaults::USER_AGENT,
	qr/^E621\:\:Client\/\d+\.\d+ \(perl module by Frosku\)$/,
	"client user agent looks sane"
);

done_testing();
