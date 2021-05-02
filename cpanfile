requires 'perl', '5.03';

requires 'Carp', '>= 1.50, < 2.0';
requires 'Clone', '>= 0.45, < 1.0';
requires 'Function::Parameters', '>= 2.001003, < 3.0';
requires 'List::MoreUtils', '>= 0.430, < 1.0';
requires 'LWP::Protocol::https', '>= 6.10, < 7.0';
requires 'LWP::UserAgent', '>= 6.53, < 7.0';
requires 'Modern::Perl', '>= 1.20200211';
requires 'Mozilla::CA', '>= 20200520';
requires 'Net::SSLeay', '>= 1.49, < 2.0';
requires 'Readonly', '>= 2.05, < 3.0';

# requires 'Some::Module', 'VERSION';

on test => sub {
    requires 'Test::More', '0.96';
    requires 'Test::Exception', '>= 0.43, < 0.5';
};
