NLP-Bash
========

Do a bag of words analysis of English classics like Jane Eyre and Wuthering Heights in Bash!

See a fully commented script in: `frequency_report.sh`. A parallel version is in `frequency_report_parallel.sh`

```bash
$ ./frequency_report.sh
$ ./frequency_report_parallel.sh
```

License
=======

MIT

Output
======

```bash
$ time ./frequency_report.sh

Top 10 words by frequency for JaneEyre
======================================
the,7947,0.0421426
i,7020,0.0372268
and,6610,0.0350526
to,5178,0.0274587
of,4462,0.0236618
a,4436,0.0235239
you,2974,0.015771
in,2802,0.0148589
was,2506,0.0132892
it,2358,0.0125044

Top 10 words by frequency for WutheringHeights
==============================================
and,4762,0.0400319
the,4727,0.0397377
to,3556,0.0298937
i,3535,0.0297171
a,2359,0.019831
of,2336,0.0196377
he,1924,0.0161742
you,1781,0.014972
her,1545,0.0129881
in,1516,0.0127443

DistinctiveWords for JaneEyre
=============================
jane
me
had
in
my
the
a
was
of
i

Distinctive words for WutheringHeights
======================================
he
his
and
him
her
heathcliff
she
linton
catherine
to

real    0m8.202s
user    0m9.347s
sys    0m0.120s
```

The time for the parallel version is:

```bash
real    0m6.767s
user    0m9.652s
sys    0m0.137s
```

which uses about 3% more CPU but gets work done 1.2x faster. Most of the time is spent in the expensive preprocessing and sorting of large files.
