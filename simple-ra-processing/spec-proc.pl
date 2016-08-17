#!/usr/bin/perl

use strict;
use DateTime::Format::Epoch::JD;

my $decln;
my $base_ra;
my $cf;
my $bw;
my $jdate;
my $time;
my $ra_start_time;

my $min_ra = 1 / 60;

my $SID_SEC = 1.00278;
my $BW_SLOTS = 2048;

my @holding;

foreach my $f (@ARGV) {
	open(FH, "<$f") or die "Couldn't open $f: $!\n";
	my $done = undef;
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
		if ($fields[0] =~ /^\d+:/) {
			$fields[0] =~ s/\.0$//;
			$fields[0] =~ /^(\d+):(\d+):(\d+)/;
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
			$time = $dt->epoch();

			next;
		}

		my $done;
		if ($fields[$#fields] eq "]") {
			pop @fields;
			$done = 1;
		}
		push (@holding, @fields);

		if ($done) {
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
			my $metric_time = $time * 1000;
			my $step = $bw / $BW_SLOTS;
			my $freq = $cf - ($bw / 2);
			my $tot = 0;
			for (my $i = 0; $i < $BW_SLOTS; $i++) {
				#printf "radio.sky.spectral.%d.fft %d %.2f center_freq=$cf bw=$bw dec=%.3f ra=%.3f ra_hour=%d\n", int($freq), $metric_time, $holding[$i], $decln, $cur_ra, int($cur_ra);
				#printf "radio.sky.spectral.%d.fft %.2f $time\n", int($freq), $holding[$i];
				#printf "radio.sky.spectral.%d.dec %.3f $time\n", int($freq), $decln;
				#printf "radio.sky.spectral.%d.ra %.3f $time\n", int($freq), $cur_ra;
				$tot += $holding[$i];
				$freq += $step;
			}
			my $avg_db = $tot / $BW_SLOTS;
			printf "radio.sky.spectral.avg %.2f $time\n", $avg_db;
			@holding = ();
		}
	}
	close FH;
}
# <metric> <timestamp> <value> <tagk=tagv> [<tagkN=tagvN>]

