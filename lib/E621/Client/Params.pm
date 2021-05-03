package E621::Client::Params;
use Modern::Perl;
use experimental qw/smartmatch/;

use Carp qw/ croak /;
use Clone qw/ clone /;
use Function::Parameters;
use List::Util qw/ reduce /;
use List::MoreUtils qw/ uniq /;

use constant MAX_TAGS_PER_REQUEST => 1000;
use constant MAX_POSTS_PER_REQUEST => 320;

fun merge_rules_and_args(:$rules, :$args) {
	my @merged = map {
		my $config_val = clone $_;
		$config_val->{value} = $args->{$config_val->{argument}};
		if (! defined $config_val->{key}) {
			$config_val->{key} = $config_val->{argument};
		}

		$config_val;
	} @{$rules};

	return \@merged;
}

fun generate_content(:$rules) {
	my %content;

	for my $param (@{collate_params(rules => $rules)}) {
		$content{$_->{key}} = $_->{value};
	}

	return \%content;
}

fun generate_query(:$rules) {
	my @query_string_components = map {
		sprintf('%s=%s', $_->{key}, $_->{value});
	} @{collate_params(rules => $rules)};

	return \@query_string_components;
}

fun collate_params(:$rules) {
	my @params = sort {
		$a->{key} cmp $b->{key};
	} map {
		my $qsc = clone $_;

		if (defined $qsc->{preformat}) {
			$qsc->{value} = $qsc->{preformat}->($qsc->{value});
		}

		$qsc;
	} grep {
		$_->{is_query};
	} @{$rules};

	return \@params;
}

fun validate_required_params(:$rules) {
	my @errors = map {
		$_->{argument};
	} grep {
		!defined $_->{value} && defined $_->{required} && 1 eq $_->{required};
	}  @{$rules};

	if (scalar @errors > 0) {
		croak(
			sprintf('Generating URL failed. Must provide: %s.', join(', ', @errors))
		);
	}

	return 1;
}

fun validate_conflicts(:$rules) {
	my $not_allowed = reduce {
		[@{$a}, @{$b}];
	} map {
		$_->{conflicts} || [];
	} grep {
		defined $_->{value};
	} @{$rules};

	my @conflicts = map {
		$_->{argument};
	} grep {
		defined $_->{value} && $_->{argument} ~~ @{$not_allowed};
	} @{$rules};

	if (scalar @conflicts > 0) {
		croak(
			sprintf('Supplied conflicting arguments: %s', join(', ', @conflicts))
		);
	}

	return 1;
}

fun validate_predicates(:$rules) {
	my @errors = grep {
		defined $_->{predicate} && ! $_->{predicate}->($_->{value});
	} @{$rules};

	if (scalar @errors > 0) {
		croak(
			sprintf('Didn\'t meet requirements: %s', join(', ', @errors))
		);
	}

	return 1;
}

1;
