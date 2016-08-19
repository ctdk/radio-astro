A collection of utilities I've written for amateur radio astronomy. Currently they include:

* **simple-ra-processing** - Perl scripts to convert [simple_ra](https://github.com/patchvonbraun/simple_ra) data to a format suitable to feed into graphite.

These scripts aren't especially complex, but they don't need to be. To use them, run the script with a list of simple_ra data files and direct the output to a file or directly to a graphite server like so:

`tp-proc.pl ~/simple_ra_data/tp-20160805* > 2016-08-05-total-power.grph`

- or -

`tp-proc.pl ~/simple_ra_data/tp-20160805* | nc graphite-host 2003`

**NB:** Be careful using `spec-proc.pl` right now. It's very much a moving target. Currently it spits out an average of the spectral data for all the bandwidth slots, but that's less useful. A separate metric for each slot, though, quickly becomes a ridiculous amount of data.

* **jupiter-grapher** - A golang program to take WAV files of recorded Jupiter noise (or, strictly speaking, any radio noise) and feed that data into OpenTSDB. A work in progress, not entirely ready yet.

To install `jupiter-grapher`, run:

```
go get github.com/ctdk/radio-astronomy/jupiter-grapher
go install github.com/ctdk/radio-astronomy/jupiter-grapher
```

----------

More utilities like these should come along later. Not in this repository but potentially useful is the [jovian-noise](https://github.com/ctdk/jovian-noise) Jupiter decameter storm forcaster.

## COPYRIGHT

Copyright 2016, Jeremy Bingham

## LICENSE

This software is licensed under the terms of the Apache License, Version 2.0.
