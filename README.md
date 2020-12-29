# housebuild
A collection of tools and documentations for the House software suite

## Overview

The House software suite is a collection of web services designed to help with building a distributed home automation system.

Each web service is its own git repository, as the goal is to allow each module to be developped as independently as possible. Instead of modfying the applications to add one more driver for some specific hardware, just write a web service, and let the applications discover it.

This suite is designed to run under Linux, most specifically the Debian distribution, either on a PC or on a Raspberry Pi. One major requirement for some services is to have access to the Linux GPIO subsystem (libgpiod).

## The House Suite

The following web services are currently part of the suite:
* [HousePortal](https://github.com/pascal-fb-martin/houseportal): the discovery and proxy service for the House suite.
* [HouseClock](https://github.com/pascal-fb-martin/houseclock): a time synchronization server designed for minimal installation effort and to be as independent from the Internet as possible. This was an answer to a deadly combination of the Raspberry Pi not having a backup clock and one too many power outage. This is also a reaction to ntpd, the high maintenance time synchronization for scientists, not home owners.
* [HouseSensor](https://github.com/pascal-fb-martin/housesensor): instrument your home with 1-Wire temperature sensors.
* [HouseRelays](https://github.com/pascal-fb-martin/houserelays): control your home through relays (or triacs).
* [Orvibo](https://github.com/pascal-fb-martin/orvibo): control the Orvibo S20 smart plugs. Too bad this model has been discontinued..
* [WaterWise](https://github.com/pascal-fb-martin/waterwise): get the watering index from the South California Water District. This is for people in the Los Angeles area.
* [HouseSprinkler](https://github.com/pascal-fb-martin/housesprinkler): an irrigation system that schedules your sprinklers. Combine it with [WaterWise](https://github.com/pascal-fb-martin/waterwise) and [HouseRelays](https://github.com/pascal-fb-martin/houserelays) and you get your very own smart irrigation system.
* [HouseLight](https://github.com/pascal-fb-martin/houselights): schedule your home lights when you are on travel, or anything attached to a (smart) plug.

All the web services above are based on [echttp](https://github.com/pascal-fb-martin/echttp), a HTTP environment to be embedded in C applications. Provides both a HTTP server, a HTTP client and JSON, XML decoding libraries.

The services typically follow one of these web interfaces:

* Event: how to collect and access application events. I always want to know if the actions that I scheduled got executed.

* Control: how to locate and operate digital controls.

* Sensor: locate and read digital and analog sensors.

* Waterindex: locate and get a watering index to adjust sprinkler times to the current weather.

## Installation Tool

The houseinstall script simplifies building a complete sprinkler or lights control system by automating the installation of all required components.

For example:
```
houseinstall sprinkler
houseinstall lights
```

Otherwise, all components of the House software suite follow the same standard installation steps:
* Install all dependencies.
* Clone the git repository.
* Execute `make rebuild`
* Execute `sudo make install`

Each component typically run as its own systemd or System V service.

