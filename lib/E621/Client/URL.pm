package E621::Client::URL;
use Modern::Perl;
use experimental qw/smartmatch/;

use E621::Client::Params;
use Function::Parameters;

=pod

In order to prevent ourselves from having to repeat the same logic over and
over again, we generalize URL generation to the following tasks:

- Ensure required fields exist;
- Ensure conflicting fields don't exist;
- Check other predicates;
- Preformat arguments;
- Format query string components;
- Build base URL;
- Attach query string.

The data structure we use to perform all of these operations is as follows:

    (
        {
            argument  => "tags",
            is_query  => 1,
            conflicts => \(),
            key       => "search[tags]",
            preformat => \sub { join("+", @{shift}) },
            predicate => \sub { scalar @{shift} < 100 },
            required  => 0,
            value     => \("first", "second", "third"),
        },
        ...
    )

=cut

fun generate_url(:$url_generator, :$rules, :$args) {
	my $generation_rules = merge_rules_and_args(
		rules => $rules,
		args => $args
	);

	validate_required_params(rules => $generation_rules);
	validate_conflicts(rules => $generation_rules);
	validate_predicates(rules => $generation_rules);

	my $query_string_components = generate_query(rules => $generation_rules);

	return sprintf(
		"%s%s%s",
		$url_generator->($args),
		scalar @{$query_string_components} > 0 ? '?' : '',
		join('&', @{$query_string_components})
	);
}

fun generate_query(:$rules) {
	return E621::Client::Params::generate_query(rules => $rules);
}

fun merge_rules_and_args(:$rules, :$args) {
  return E621::Client::Params::merge_rules_and_args(
		rules => $rules,
		args => $args
	);
}

fun validate_required_params(:$rules) {
	return E621::Client::Params::validate_required_params(rules => $rules);
}

fun validate_conflicts(:$rules) {
	return E621::Client::Params::validate_conflicts(rules => $rules);
}

fun validate_predicates(:$rules) {
	return E621::Client::Params::validate_predicates(rules => $rules);
}

1;
