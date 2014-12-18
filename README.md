# Net::TNS for Ruby [![Build Status](https://travis-ci.org/SpiderLabs/net-tns.svg?branch=master)](https://travis-ci.org/SpiderLabs/net-tns)

Library for connecting to Oracle databases.

## Description

Net::TNS for Ruby is a partial implementation of the TNS (Transparent Network Substrate) and TTI (Two-Task Interface, a.k.a. TTC) protocols used by Oracle Database. It allows users to connect and authenticate to databases; functionality beyond that point is limited. The library implements two protocols, and although TTI is the higher-level one, the library is named for TNS, which is more well-known.

## Requirements

Net::TNS was written for and has been most tested with Ruby 2. The specs pass on 1.9.3, although their coverage is incomplete. It may be able to work with previous versions.

## Installation

```gem install net-tns```

## Use

Because TNS and TTI are highly related (and not very useful without the other), they are both implemented in this library, although in separate namespaces (```Net::TNS``` and ```Net::TTI```).  ```require "net/tti"``` is sufficient to load both protocols (```require "net/tns"``` will only load the TNS implementation).

Each namespace includes a Client class, which provides access to the essential functionality for that protocol. There are several scripts in bin that demonstrate basic use.

#### Get the version of an Oracle DB server

```ruby
Net::TNS::Client.get_version(:host => "10.0.0.10") # => "11.2.0.2.0"
```

#### Try authenticating to a server

```ruby
tti_client = Net::TTI::Client.new
tti_client.connect( :host => "10.0.0.10", :sid => "ORCL" )
tti_client.authenticate( "jsmith", "bananas" ) # => true/false
```

## Contribute

Pull requests welcome! Once you've forked and cloned the project, you can ```bundle install``` to take care of the dependencies; after that, you're ready to code.

You can also create issues for any bugs or feature requests, but they may take longer to get done, of course.

## Resources on TNS and TTI

* http://www.csee.umbc.edu/portal/help/oracle8/network.815/a67440/ch2.htm#1007271
* http://www.pythian.com/blog/repost-oracle-protocol/
* http://www.nyoug.org/Presentations/2008/Sep/Harris_Listening%20In.pdf
* https://community.oracle.com/thread/555302?start=0&tstart=0 (for naming of high-level components)
* http://ckng62.blogspot.com/2014/02/tns-data-packet-structure.html
* https://www.thesprawl.org/research/oracle-tns-protocol/
* The Oracle Hacker's Handbook by David Litchfield
