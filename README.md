# housebuild
A collection of tools and documentations for the House software suite

## Overview

The House software suite is a collection of web services designed to help with building a distributed home automation system.

Each web service is its own git repository, as the goal is to allow each module to be developped as independently as possible. Instead of modfying the applications to add one more driver for some specific hardware, just write a web service, and let the applications discover it.

This suite is designed to run under Linux, most specifically the Debian distribution, either on a PC or on a Raspberry Pi. The major dependencies are OpenSSL and, for some services, the Linux GPIO subsystem (gpiod).

## The House Suite

The following web services are currently part of the suite:

* [HousePortal](https://github.com/pascal-fb-martin/houseportal): the discovery and proxy service for the House suite.

* [HouseClock](https://github.com/pascal-fb-martin/houseclock): a time synchronization server designed for minimal installation effort and to be as independent from the Internet as possible. This was an answer to a deadly combination of the Raspberry Pi not having a backup clock and one too many power outage. This is also a reaction to ntpd, the high maintenance time synchronization for scientists, not home owners.

* [HouseSensor](https://github.com/pascal-fb-martin/housesensor): instrument your home with 1-Wire temperature sensors. This module depends on gpiod.

* [HouseRelays](https://github.com/pascal-fb-martin/houserelays): control your home through relays (or triacs). This module depends on gpiod.

* [Orvibo](https://github.com/pascal-fb-martin/orvibo): control the Orvibo S20 smart plugs. Too bad this model has been discontinued..

* [HouseWiz](https://github.com/pascal-fb-martin/housewiz): control the Philips Wiz Connected smart bulbs and plugs.

* [HouseKasa](https://github.com/pascal-fb-martin/housekasa): control the TP-Link Kasa bulbs and plugs.

* [WaterWise](https://github.com/pascal-fb-martin/waterwise): get the watering index from the South California Water District. This is for people in the Los Angeles area.

* [HouseSprinkler](https://github.com/pascal-fb-martin/housesprinkler): an irrigation system that schedules your sprinklers. Combine it with [WaterWise](https://github.com/pascal-fb-martin/waterwise) and [HouseRelays](https://github.com/pascal-fb-martin/houserelays) and you get your very own smart irrigation system.

* [HouseLights](https://github.com/pascal-fb-martin/houselights): schedule your home lights when you are on travel, or anything attached to a (smart) plug.

* [HouseDepot](https://github.com/pascal-fb-martin/housedepot): a centralized and versioned store for applications configuration.

All the web services above are based on [echttp](https://github.com/pascal-fb-martin/echttp), a HTTP environment to be embedded in C applications. Provides both a HTTP server, a HTTP client and JSON, XML decoding libraries.

The services typically follow one of these web interfaces:

* Event: collect and access application events. I always want to know if the actions that I scheduled got executed.

* Control: locate and operate digital controls.

* Sensor: locate and read digital and analog sensors.

* Waterindex: locate and get a watering index to adjust sprinkler times according to the current weather.

## Installation Tool

The houseinstall script simplifies building a complete system by automating the installation of all required components.

The user must have sudo privilege.

The tool must be run from the directory where the git repositories are to be created (including itself). If it is used for update later on, it must be run from the same directory.

As a bootstrap step, it must itself be installed manually:
```
git clone https://github.com/pascal-fb-martin/housebuild.git
pushd housebuild
sudo make install
popd
```

On Debian, the tool will automatically install external dependencies beforehand, such as Git, OpenSSL (i.e. libssl-dev), icotool (icoutils) and (possibly) or gpiod (i.e libgpiod-dev). On other Linux distributions these dependencies must be installed manually.

The script automatically installs mandatory, or common, dependencies from other House suite modules. It can also be used to update components that were already installed. If nothing needs to be done, no action is performed.

The following commands installs the sprinkler control, the lights control, and all their dependent services:
```
houseinstall sprinkler
houseinstall lights
```

Multiple names may be provided on the same command, which is a way to install optional components. For example:
```
houseinstall clock sprinkler
```

The following services names are supported: clock, sensor, relays, sprinkler, lights, orvibo, wiz, waterwise.

Note that all components of the House software suite follow the same standard installation steps:

* Install all dependencies.

* Clone the git repository.

* Change to the repository directory.

* Execute `make rebuild`

* Execute `sudo make install`

Each component typically run as its own systemd service.

## Software Update

All installed software can be updated later using the keyword `update`:
```
houseinstall update
```
A similar command, `housedev` can be used to recompile a project and its dependencies. This command does _not_ install. The same options are supported, including `update`.

