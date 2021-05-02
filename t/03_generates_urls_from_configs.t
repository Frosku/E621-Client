#!/usr/bin/env perl
use Function::Parameters;
use Modern::Perl;
use Test::Exception;
use Test::More;
use E621::Client::URL;

my %protocol    = ( argument => "protocol", required => 1 );
my %base_url    = ( argument => "base_url", required => 1 );
my %limit       = (
	argument => "limit",
	predicate => sub { return shift() < 100; },
	is_query => 1
);
my %page        = (
	argument => "page",
	is_query => 1,
	conflicts => ["page_before", "page_after"]
);
my %page_before = (
	argument => "page_before",
	is_query => 1,
	conflicts => ["page", "page_after"],
	preformat => sub { return sprintf("b%s", shift); },
	key => "page"
);
my %tags = (
	argument => "tags",
	is_query => 1,
	preformat => sub { return join("+", sort @{shift()}); }
);

sub url_generator {
	my $args = shift->{args};

	return sprintf("%s%s", $args->{protocol}, $args->{base_url});
}

my @set_one_rules = (
	\%protocol,
	\%base_url,
	\%limit,
	\%page,
	\%page_before,
	\%tags
);

my %set_one_args = (
	protocol => 'https://',
	base_url => 'e621.net'
);

my $set_one_merged = E621::Client::URL::merge_rules_and_args(
	rules => \@set_one_rules,
	args => \%set_one_args
);

subtest 'testing merge_rules_and_args', sub {
	ok(scalar @{$set_one_merged} == scalar @set_one_rules, 'we get the number of merged entries which we expect');

	for my $rule (@{$set_one_merged}) {
		ok(
			(! defined $rule->{value} && ! defined $set_one_args{$rule->{argument}})
			|| $rule->{value} eq $set_one_args{$rule->{argument}},
			sprintf(
				'actual value "%s" matches expected value "%s" - merge worked',
				$rule->{value} || 'undef',
				$set_one_args{$rule->{argument}} || 'undef'
			)
		);
	}
};

subtest 'testing validate_required_params', sub {
	ok(
		E621::Client::URL::validate_required_params(rules => $set_one_merged),
		'validation correctly succeeds when all required parameters are truthy'
	);

	my %set_two_args = (protocol => 'https://');
	my $set_two_merged = E621::Client::URL::merge_rules_and_args(
		rules => \@set_one_rules,
		args => \%set_two_args
	);

	dies_ok(
		sub {
			E621::Client::URL::validate_required_params(rules => $set_two_merged)
		},
		'validation correctly croaks when one or more required parameters is falsey'
	);
};

subtest 'testing validate_predicates', sub {
	my %set_three_args = (limit => 99);
	my $set_three_merged = E621::Client::URL::merge_rules_and_args(
		rules => \@set_one_rules,
		args => \%set_three_args
	);

	ok(
		E621::Client::URL::validate_predicates(rules => $set_three_merged),
		'validation successfully passes when all predicates are met'
	);

	my %set_four_args = (limit => 100);
	my $set_four_merged = E621::Client::URL::merge_rules_and_args(
		rules => \@set_one_rules,
		args => \%set_four_args
	);

	dies_ok(
		sub {
			E621::Client::URL::validate_predicates(rules => $set_four_merged)
			},
		'validation correctly croaks when predicates fail'
	);
};

subtest 'testing validate_conflicts', sub {
	my %set_five_args = (page => 2);
	my $set_five_merged = E621::Client::URL::merge_rules_and_args(
		rules => \@set_one_rules,
		args => \%set_five_args
	);

	ok(
		E621::Client::URL::validate_conflicts(rules => $set_five_merged),
		'validation succeeds when page is passed in without page_before'
	);

	my %set_six_args = (page_before => 2);
	my $set_six_merged = E621::Client::URL::merge_rules_and_args(
		rules => \@set_one_rules,
		args => \%set_six_args
	);

	ok(
		E621::Client::URL::validate_conflicts(rules => $set_six_merged),
		'validation succeeds when page_before is passed in without page'
	);

	my %set_seven_args = (page => 2, page_before => 2);
	my $set_seven_merged = E621::Client::URL::merge_rules_and_args(
		rules => \@set_one_rules,
		args => \%set_seven_args
	);

	dies_ok(
		sub { E621::Client::URL::validate_conflicts(rules => $set_seven_merged) },
		'validation correctly croaks when there are conflicts'
	);
};

subtest 'testing generate_url', sub {
	my @generate_base_url_rules = (\%protocol, \%base_url);
	my %generate_base_url_args = (protocol => 'https://', base_url => 'e621.net');

	ok(
		E621::Client::URL::generate_url(
			url_generator => sub {
				my $args = shift();
				return sprintf('%s%s', $args->{protocol}, $args->{base_url});
			},
			rules => \@generate_base_url_rules,
			args => \%generate_base_url_args
		) eq 'https://e621.net',
		'successfully generates base URL'
	);

	my @generate_qsa_url_rules = (\%protocol, \%base_url, \%tags, \%page_before);
	my %generate_qsa_url_args = (
		protocol => 'https://',
		base_url => 'e621.net',
		tags => ['cute', 'vaporeon', 'artist:unknown', 'test_tag'],
		page_before => 505
	);

	ok(
		E621::Client::URL::generate_url(
			url_generator => sub {
				my $args = shift();
				return sprintf('%s%s/posts.json', $args->{protocol}, $args->{base_url});
			},
			rules => \@generate_qsa_url_rules,
			args => \%generate_qsa_url_args
		) eq
		'https://e621.net/posts.json?page=b505&tags=artist:unknown+cute+test_tag+vaporeon',
		'successfully generates URL with query string'
	);
};

done_testing();
