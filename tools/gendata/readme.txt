I've written the same functionality in C and in Perl to compare runtimes.

Result:
If it takes 5 seconds with the compiled version, it takes 1min25sec with the
Perl (5.16.2) version.
Version 5.18 of Perl seem to have increased performance significantly. If it takes 2.75 seconds with the compiled version, it takes 13 seconds with the Perl version.
Or 2m13.271sec compared to 27.26sec.

I’m not sure, where this performance boost comes from.
