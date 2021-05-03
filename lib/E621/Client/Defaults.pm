package E621::Client::Defaults;
use Modern::Perl;

use constant VERSION => '0.01';
use constant REQUEST_RATE_LIMIT => 0.5;

use constant PROTOCOL => 'https:';
use constant E621_BASE_URL => 'e621.net';
use constant E926_BASE_URL => 'e926.net';

use constant USER_AGENT => sprintf(
	'E621::Client/%s (perl module by Frosku)',
	VERSION
);

1;
