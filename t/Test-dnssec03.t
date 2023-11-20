use strict;
use warnings;

use Test::More;
use File::Basename;
use File::Spec::Functions qw( rel2abs );
use lib dirname( rel2abs( $0 ) );

BEGIN {
    use_ok( q{Zonemaster::Engine} );
    use_ok( q{Zonemaster::Engine::Nameserver} );
    use_ok( q{Zonemaster::Engine::Test::DNSSEC} );
    use_ok( q{TestUtil}, qw( perform_testcase_testing ) );
}

###########
# dnssec03 - https://github.com/zonemaster/zonemaster/blob/master/docs/public/specifications/test-zones/DNSSEC-TP/dnssec03.md
my $test_module = q{DNSSEC};
my $test_case = 'dnssec03';

# Common hint file (test-zone-data/COMMON/hintfile)
Zonemaster::Engine::Recursor->remove_fake_addresses( '.' );
Zonemaster::Engine::Recursor->add_fake_addresses( '.',
    { 'ns1' => [ '127.1.0.1', 'fda1:b2:c3::127:1:0:1' ],
      'ns2' => [ '127.1.0.2', 'fda1:b2:c3::127:1:0:2' ],
    }
);

# Test zone scenarios
# - Documentation: L<TestUtil/perform_testcase_testing()>
# - Format: { SCENARIO_NAME => [ zone_name, [ MANDATORY_MESSAGE_TAGS ], [ FORBIDDEN_MESSAGE_TAGS ], testable ] }
my %subtests = (
    'NO-DNSSEC-SUPPORT' => [
        q(no-dnssec-support.dnssec03.xa),
        [ qw(DS03_NO_DNSSEC_SUPPORT) ],
        [ qw(DS03_ERR_MULT_NSEC3 DS03_ILLEGAL_HASH_ALGO DS03_ILLEGAL_ITERATION_VALUE DS03_ILLEGAL_SALT_LENGTH DS03_INCONSISTENT_HASH_ALGO DS03_INCONSISTENT_ITERATION DS03_INCONSISTENT_NSEC3_FLAGS DS03_INCONSISTENT_SALT_LENGTH DS03_LEGAL_EMPTY_SALT DS03_LEGAL_HASH_ALGO DS03_LEGAL_ITERATION_VALUE DS03_NO_NSEC3 DS03_NSEC3_OPT_OUT_DISABLED DS03_NSEC3_OPT_OUT_ENABLED_NON_TLD DS03_NSEC3_OPT_OUT_ENABLED_TLD DS03_SERVER_NO_DNSSEC_SUPPORT DS03_SERVER_NO_NSEC3 DS03_UNASSIGNED_FLAG_USED) ],
        1
    ],
    'NO-NSEC3' => [
        q(no-nsec3.dnssec03.xa),
        [ qw(DS03_NO_NSEC3) ],
        [ qw(DS03_ERR_MULT_NSEC3 DS03_ILLEGAL_HASH_ALGO DS03_ILLEGAL_ITERATION_VALUE DS03_ILLEGAL_SALT_LENGTH DS03_INCONSISTENT_HASH_ALGO DS03_INCONSISTENT_ITERATION DS03_INCONSISTENT_NSEC3_FLAGS DS03_INCONSISTENT_SALT_LENGTH DS03_LEGAL_EMPTY_SALT DS03_LEGAL_HASH_ALGO DS03_LEGAL_ITERATION_VALUE DS03_NO_DNSSEC_SUPPORT DS03_NSEC3_OPT_OUT_DISABLED DS03_NSEC3_OPT_OUT_ENABLED_NON_TLD DS03_NSEC3_OPT_OUT_ENABLED_TLD DS03_SERVER_NO_DNSSEC_SUPPORT DS03_SERVER_NO_NSEC3 DS03_UNASSIGNED_FLAG_USED) ],
        1
    ],
    'GOOD-VALUES' => [
        q(good-values.dnssec03.xa),
        [ qw(DS03_LEGAL_EMPTY_SALT DS03_LEGAL_HASH_ALGO DS03_LEGAL_ITERATION_VALUE DS03_NSEC3_OPT_OUT_DISABLED) ],
        [ qw(DS03_ERR_MULT_NSEC3 DS03_ILLEGAL_HASH_ALGO DS03_ILLEGAL_ITERATION_VALUE DS03_ILLEGAL_SALT_LENGTH DS03_INCONSISTENT_HASH_ALGO DS03_INCONSISTENT_ITERATION DS03_INCONSISTENT_NSEC3_FLAGS DS03_INCONSISTENT_SALT_LENGTH DS03_NO_DNSSEC_SUPPORT DS03_NO_NSEC3 DS03_NSEC3_OPT_OUT_ENABLED_NON_TLD DS03_NSEC3_OPT_OUT_ENABLED_TLD DS03_SERVER_NO_DNSSEC_SUPPORT DS03_SERVER_NO_NSEC3 DS03_UNASSIGNED_FLAG_USED) ],
        1
    ],
    'ERR-MULT-NSEC3' => [
        q(err-mult-nsec3.dnssec03.xa),
        [ qw(DS03_ERR_MULT_NSEC3 DS03_LEGAL_EMPTY_SALT DS03_LEGAL_HASH_ALGO DS03_LEGAL_ITERATION_VALUE DS03_NSEC3_OPT_OUT_DISABLED) ],
        [ qw(DS03_ILLEGAL_HASH_ALGO DS03_ILLEGAL_ITERATION_VALUE DS03_ILLEGAL_SALT_LENGTH DS03_INCONSISTENT_HASH_ALGO DS03_INCONSISTENT_ITERATION DS03_INCONSISTENT_NSEC3_FLAGS DS03_INCONSISTENT_SALT_LENGTH DS03_NO_DNSSEC_SUPPORT DS03_NO_NSEC3 DS03_NSEC3_OPT_OUT_ENABLED_NON_TLD DS03_NSEC3_OPT_OUT_ENABLED_TLD DS03_SERVER_NO_DNSSEC_SUPPORT DS03_SERVER_NO_NSEC3 DS03_UNASSIGNED_FLAG_USED) ],
        1
    ],
    'BAD-VALUES' => [
        q(bad-values.dnssec03.xa),
        [ qw(DS03_ILLEGAL_HASH_ALGO DS03_ILLEGAL_ITERATION_VALUE DS03_ILLEGAL_SALT_LENGTH DS03_NSEC3_OPT_OUT_ENABLED_NON_TLD) ],
        [ qw(DS03_ERR_MULT_NSEC3 DS03_INCONSISTENT_HASH_ALGO DS03_INCONSISTENT_ITERATION DS03_INCONSISTENT_NSEC3_FLAGS DS03_INCONSISTENT_SALT_LENGTH DS03_LEGAL_EMPTY_SALT DS03_LEGAL_HASH_ALGO DS03_LEGAL_ITERATION_VALUE DS03_NO_DNSSEC_SUPPORT DS03_NO_NSEC3 DS03_NSEC3_OPT_OUT_DISABLED DS03_NSEC3_OPT_OUT_ENABLED_TLD DS03_SERVER_NO_DNSSEC_SUPPORT DS03_SERVER_NO_NSEC3 DS03_UNASSIGNED_FLAG_USED) ],
        1
    ],
    'INCONSISTENT-VALUES' => [
        q(inconsistent-values.dnssec03.xa),
        [ qw(DS03_ILLEGAL_HASH_ALGO DS03_ILLEGAL_ITERATION_VALUE DS03_ILLEGAL_SALT_LENGTH DS03_INCONSISTENT_HASH_ALGO DS03_INCONSISTENT_ITERATION DS03_INCONSISTENT_NSEC3_FLAGS DS03_INCONSISTENT_SALT_LENGTH DS03_LEGAL_EMPTY_SALT DS03_LEGAL_HASH_ALGO DS03_LEGAL_ITERATION_VALUE DS03_NSEC3_OPT_OUT_DISABLED DS03_NSEC3_OPT_OUT_ENABLED_NON_TLD) ],
        [ qw(DS03_ERR_MULT_NSEC3 DS03_NO_DNSSEC_SUPPORT DS03_NO_NSEC3 DS03_NSEC3_OPT_OUT_ENABLED_TLD DS03_SERVER_NO_DNSSEC_SUPPORT DS03_SERVER_NO_NSEC3 DS03_UNASSIGNED_FLAG_USED) ],
        1
    ],
    'NSEC3-OPT-OUT-ENABLED-TLD' => [
        q(nsec3-opt-out-enabled-tld-dnssec03),
        [ qw(DS03_NSEC3_OPT_OUT_ENABLED_TLD DS03_LEGAL_EMPTY_SALT DS03_LEGAL_HASH_ALGO DS03_LEGAL_ITERATION_VALUE) ],
        [ qw(DS03_ERR_MULT_NSEC3 DS03_ILLEGAL_HASH_ALGO DS03_ILLEGAL_ITERATION_VALUE DS03_ILLEGAL_SALT_LENGTH DS03_INCONSISTENT_HASH_ALGO DS03_INCONSISTENT_ITERATION DS03_INCONSISTENT_NSEC3_FLAGS DS03_INCONSISTENT_SALT_LENGTH DS03_NO_DNSSEC_SUPPORT DS03_NO_NSEC3 DS03_NSEC3_OPT_OUT_DISABLED DS03_NSEC3_OPT_OUT_ENABLED_NON_TLD DS03_SERVER_NO_DNSSEC_SUPPORT DS03_SERVER_NO_NSEC3 DS03_UNASSIGNED_FLAG_USED) ],
        1
    ],
    'SERVER-NO-DNSSEC-SUPPORT' => [
        q(server-no-dnssec-support.dnssec03.xa),
        [ qw(DS03_SERVER_NO_DNSSEC_SUPPORT DS03_LEGAL_EMPTY_SALT DS03_LEGAL_HASH_ALGO DS03_LEGAL_ITERATION_VALUE DS03_NSEC3_OPT_OUT_DISABLED) ],
        [ qw(DS03_ERR_MULT_NSEC3 DS03_ILLEGAL_HASH_ALGO DS03_ILLEGAL_ITERATION_VALUE DS03_ILLEGAL_SALT_LENGTH DS03_INCONSISTENT_HASH_ALGO DS03_INCONSISTENT_ITERATION DS03_INCONSISTENT_NSEC3_FLAGS DS03_INCONSISTENT_SALT_LENGTH DS03_NO_DNSSEC_SUPPORT DS03_NO_NSEC3 DS03_NSEC3_OPT_OUT_ENABLED_NON_TLD DS03_NSEC3_OPT_OUT_ENABLED_TLD DS03_SERVER_NO_NSEC3 DS03_UNASSIGNED_FLAG_USED) ],
        1
    ],
    'SERVER-NO-NSEC3' => [
        q(server-no-nsec3.dnssec03.xa),
        [ qw(DS03_SERVER_NO_NSEC3 DS03_LEGAL_EMPTY_SALT DS03_LEGAL_HASH_ALGO DS03_LEGAL_ITERATION_VALUE DS03_NSEC3_OPT_OUT_DISABLED) ],
        [ qw(DS03_ERR_MULT_NSEC3 DS03_ILLEGAL_HASH_ALGO DS03_ILLEGAL_ITERATION_VALUE DS03_ILLEGAL_SALT_LENGTH DS03_INCONSISTENT_HASH_ALGO DS03_INCONSISTENT_ITERATION DS03_INCONSISTENT_NSEC3_FLAGS DS03_INCONSISTENT_SALT_LENGTH DS03_NO_DNSSEC_SUPPORT DS03_NO_NSEC3 DS03_NSEC3_OPT_OUT_ENABLED_NON_TLD DS03_NSEC3_OPT_OUT_ENABLED_TLD DS03_SERVER_NO_DNSSEC_SUPPORT DS03_UNASSIGNED_FLAG_USED) ],
        1
    ],
    'UNASSIGNED-FLAG-USED' => [
        q(unassigned-flag-used.dnssec03.xa),
        [ qw(DS03_UNASSIGNED_FLAG_USED DS03_LEGAL_EMPTY_SALT DS03_LEGAL_HASH_ALGO DS03_LEGAL_ITERATION_VALUE DS03_NSEC3_OPT_OUT_DISABLED) ],
        [ qw(DS03_ERR_MULT_NSEC3 DS03_ILLEGAL_HASH_ALGO DS03_ILLEGAL_ITERATION_VALUE DS03_ILLEGAL_SALT_LENGTH DS03_INCONSISTENT_HASH_ALGO DS03_INCONSISTENT_ITERATION DS03_INCONSISTENT_NSEC3_FLAGS DS03_INCONSISTENT_SALT_LENGTH DS03_NO_DNSSEC_SUPPORT DS03_NO_NSEC3 DS03_NSEC3_OPT_OUT_ENABLED_NON_TLD DS03_NSEC3_OPT_OUT_ENABLED_TLD DS03_SERVER_NO_DNSSEC_SUPPORT DS03_SERVER_NO_NSEC3) ],
        1
    ]
);
###########

my $datafile = 't/' . basename ($0, '.t') . '.data';

if ( not $ENV{ZONEMASTER_RECORD} ) {
    die q{Stored data file missing} if not -r $datafile;
    Zonemaster::Engine::Nameserver->restore( $datafile );
    Zonemaster::Engine::Profile->effective->set( q{no_network}, 1 );
}

Zonemaster::Engine::Profile->effective->merge( Zonemaster::Engine::Profile->from_json( qq({ "test_cases": [ "$test_case" ] }) ) );

perform_testcase_testing( $test_case, $test_module, %subtests );

if ( $ENV{ZONEMASTER_RECORD} ) {
    Zonemaster::Engine::Nameserver->save( $datafile );
}

done_testing;