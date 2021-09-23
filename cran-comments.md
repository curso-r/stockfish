## Test environments

* GitHub Actions (ubuntu-18.04): devel, release, oldrel
* GitHub Actions (windows): release, oldrel
* GitHub Actions (macos): release, oldrel
* Vagrant VM (windows 2022 preview): devel
* win-builder: devel
* mac-builder: release

## R CMD check results

0 errors | 0 warnings | 1 note

* Checking installed package size ... NOTE

  * Installed size is 7.6Mb

## Other comments

* Regarding the installed size: this package compiles and installs a binary for
Stockfish according to the recommendations outlined at Writing R Extensions.
Since we shouldn't use any extra flags, the final size of the binary is going to
be a few Mb, exceeding CRAN's recommended size.
