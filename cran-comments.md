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
      Stockfish (2:37, 10:30)
      UCI (9:39)
  
  * CRAN repository db overrides:
      X-CRAN-Comment: Archived on 2020-12-19 for policy violation.
      On cross-platform portable code.

* Checking installed package size ... NOTE

  * Installed size is 6.9Mb

## Justification for installed size

* This package compiles and installs a binary for the Stockfish engine according
to the recommendations outlined at
[Writing R Extensions](https://cran.r-project.org/doc/manuals/R-exts.html#Package-subdirectories).
Since we shouldn't use any extra flags, the final size of the binary is going to
be a few Mb.
