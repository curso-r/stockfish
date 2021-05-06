## Test environments

* GitHub Actions (ubuntu-16.04): devel, release, oldrel
* GitHub Actions (windows): release, oldrel
* GitHub Actions (macOS): release, oldrel
* win-builder: devel

## R CMD check results

0 errors | 0 warnings | 2 notes

* Checking CRAN incoming feasibility ... NOTE
  
  * New submission
  
  * Package was archived on CRAN
  
  * Possibly mis-spelled words in DESCRIPTION:
      UCI (9:39)
  
  * CRAN repository db overrides:
      X-CRAN-Comment: Archived on 2021-04-04 for policy violation.
      Uses platform-dependent code to skip failing checks instead of
      correcting them as asked.

* Checking installed package size ... NOTE

  * Installed size is 6.9Mb

## Other comments

* Regarding the installed size: this package compiles and installs a binary for
Stockfish according to the recommendations outlined at Writing R Extensions.
Since we shouldn't use any extra flags, the final size of the binary is going to
be a few Mb, exceeding CRAN's recommended size.

* Regarding copyrights: in order to better preserve authorship of the C++ code,
all of Stockfish's main authors are now listed as contributors in the
DESCRIPTION file. Additionally, a "Copyright Notice" section has been added to
the README.

* Regarding the archival: the last time this package was accepted to CRAN, I was
notified that it was not passing its checks on M1 Mac. Since I was required to
fix the problems within two weeks and had no access to an M1 Mac, my only
possible course of action was skipping the checks on that platform (which is a
policy violation). This has been fixed and the checks should now pass on M1 Mac.
