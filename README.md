# Net::TNS for Ruby
[![Build Status](https://travis-ci.org/SpiderLabs/net-tns.svg?branch=master)](https://travis-ci.org/SpiderLabs/net-tns)

Library for connecting to Oracle databases.

## Description

Net::TNS for Ruby is a partial implementation of the TNS (Transparent Network Substrate) and TTI (Two-Task Interface, a.k.a. TTC) protocols used by Oracle Database. It allows users to connect and authenticate to databases; functionality beyond that point is limited. The library implements two protocols, and although TTI is the higher-level one, the library is named for TNS, which is more well-known.

## Requirements

Net::TNS was written for and tested with Ruby 2, but it may be able to run on earlier versions. Net::TNS requires the Bindata gem.

## Installation

```gem install net-tns```

## Use

Because TNS and TTI are highly related (and not very useful without the other), they are both implemented in this library, although in separate namespaces (```Net::TNS``` and ```Net::TTI```).  ```require "net/tti"``` is sufficient to load both protocols (```require "net/tns"``` will only load the TNS implementation).

Each namespace includes a Client class, which provides access to the essential functionality for that protocol. There are several scripts in bin that demonstrate basic use.

## Resources on TNS and TTI

* http://www.csee.umbc.edu/portal/help/oracle8/network.815/a67440/ch2.htm#1007271
* http://www.pythian.com/blog/repost-oracle-protocol/
* http://www.nyoug.org/Presentations/2008/Sep/Harris_Listening%20In.pdf
* https://community.oracle.com/thread/555302?start=0&tstart=0 (for naming of high-level components)
* http://ckng62.blogspot.com/2014/02/tns-data-packet-structure.html
* https://www.thesprawl.org/research/oracle-tns-protocol/
* The Oracle Hacker's Handbook by David Litchfield
