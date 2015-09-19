# Sonarflow - Music Discovery App for iOS

## Introduction

The Sonarflow iOS App is a fun, simple and interactive way to discover new music on  iPhone and iPad. It allows to visually browse one’s music collection on the device and discover new music online.

The app targets iOS 5 and 6 and was available in the Apple App Store from 2010 until 2014. It has been downloaded over 150,000 times.

Sonarflow is published under the MIT license (see LICENSE file in the same directory for the complete terms).

Main features of Sonarflow iOS App:

* One-touch access to your world of music
* Discover new bands and artists in iTunes
* Sleek user interface
* Download songs and albums from iTunes
* Watch band videos through YouTube
* Read artist biographies

### Spectralmind

Spectralmind was an innovative media technology company founded 2008 by a group of music enthusiasts and semantic audio analysis experts in Vienna, Austria:

Thomas Lidy, Ewald Peiszer, Johann Waldherr and Wolfgang Jochum

Spectralmind’s audio analysis and music discovery applications allow computers to hear music in a similar way as humans do and consequently to find and recommend music by its mere content. This technology is an enabler for solutions in media search, categorization and recommendation.

In addition to Sonarflow iOS App, Spectralmind also created Sonarflow Android App and SEARCH by Sound Platform for audio content analysis (see below).

Spectralmind ceased operations as of September 2015 and published its software stack as open source software under the MIT license.

### Available software

Spectralmind's open source software is comprised of four repositories:

* [SEARCH by Sound Platform a.k.a. Smafe](https://www.github.com/spectralmind/smafe)
* [SEARCH by Sound Web Application a.k.a. Smint](https://www.github.com/spectralmind/smint)
* [Sonarflow iOS App](https://www.github.com/spectralmind/sonarflow-ios)
* [Sonarflow Android App](https://www.github.com/spectralmind/sonarflow-android)

## Build

The source code is organised as an XCode project.

It has a number of dependencies that are included as git submodules.

After cloning this project, execute

`git submodule update --init --recursive`

It will pull the additional dependencies from further git repositories and place them in the according subdirectories.

Then open sonarflow.xcworkspace in Xcode.

### Known issues

Note that the app has been built for iOS 5 and 6 and has not yet been ported to iOS 7 or above.

## Support

As Spectralmind ceased operation, no support can be given by the company. Please contact any active members on github, or otherwise you can still try technology@spectralmind.com .

## Acknowledgement

We wish to thank all the contributors to this software, with a special thank you to all former employees and freelancers of Spectralmind.

September 2015
The Founders of Spectralmind: Thomas Lidy, Ewald Peiszer, Johann Waldherr 
