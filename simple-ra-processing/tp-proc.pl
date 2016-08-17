#!/usr/bin/perl

use strict;
use DateTime::Format::Epoch::JD;

my $decln;
my $base_ra;
my $cf;
my $bw;
my $jdate;
my $ra_start_time;

my $min_ra = 1 / 60;

my $SID_SEC = 1.00278;

foreach my $f (@ARGV) {
	open(FH, "<$f") or die "Couldn't open $f: $!\n";
	while (<FH>) {
		my @fields = split /\s+/, $_;
		if ($fields[0] eq "PARAMS") {
			$cf = $fields[1];
			$bw = $fields[2];
			$decln = $fields[3];
			$jdate = $fields[4];
			my $ra_tmp = $fields[5];
			if ($ra_tmp != $base_ra) {
				$base_ra = $ra_tmp;
				$ra_start_time = undef;
			}
			
			next;
		}
		$fields[0] =~ s/\.0$//;
		$fields[0] =~ /(\d+):(\d+):(\d+)/;
		my $hour = $1;
		my $minute = $2;
		my $second = $3;
		my $njd = $jdate;
		if ($hour < 12) {
			$njd += 0.5;
		} else {
			$njd -= 0.5;
		}
		my $dt = DateTime::Format::Epoch::JD->parse_datetime($njd);
		$dt->add(hours => $hour, minutes => $minute, seconds => $second);
		my $time = $dt->epoch();

		next if ($time < 0);

		my $y1 = $fields[2];
		my $y2 = $fields[3];
		my $y3 = $fields[4];
		if (!$ra_start_time) {
			$ra_start_time = $time;
		}
		my $ra_offset = (($time - $ra_start_time) * $SID_SEC) / 3600;
		my $cur_ra = $base_ra + $ra_offset;
		if ($cur_ra > 24) {
			my $xtra = $cur_ra - int($cur_ra);
			$cur_ra %= 24;
			$cur_ra += $xtra;
		}
		#$time *= 1000;
		
		# opentsdb
		#printf "radio.sky.total_power %d %.7f center_freq=$cf bw=$bw dec=%.3f ra=%.3f ra_hour=%d\n", $time, $y1, $decln, $cur_ra, int($cur_ra);
		#printf "radio.sky.ra %d %.3f center_freq=$cf bw=$bw dec=%.3f ra_hour=%d\n", $time, $cur_ra, $decln, int($cur_ra);
		#printf "radio.sky.dec %d %.3f center_freq=$cf bw=$bw ra=%.3f ra_hour=%d\n", $time, $decln, $cur_ra, int($cur_ra);

		# graphite
		my $key_freq = int($cf / 1000000);
		printf "radio.sky.$key_freq.total_power %.7f $time\n", $y1;
		printf "radio.sky.$key_freq.dec %.3f $time\n", $decln;
		printf "radio.sky.$key_freq.ra %.3f $time\n", $cur_ra;
	}
	close FH;
}
# <metric> <timestamp> <value> <tagk=tagv> [<tagkN=tagvN>]
