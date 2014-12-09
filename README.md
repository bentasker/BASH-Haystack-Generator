BASH Haystack generator
==========================


**Note: This codebase should currently be considered unusable as it's in an early PoC stage!**


About
--------

BASH Haystack generator is a small set of BASH scripts (server-side and client-side) to generate random data for requesting/sending via Tor/VPN at random intervals to increase the level of irrelevant traffic which may be observed by a monitoring adversary and reduce the effectiveness of recording traffic patterns over encrypted tunnels.

The server-side scripts generate a file of a fixed size (default 1GB) containing random(ish) data from /dev/urandom (by default).

The client scripts request bits of that data (with the option to use a random generator to decide whether to request anything on this run or not). The number of requests made (and the size of the ranges) are also randomly generated (whether per-run or per-request)

The client script currently supports the following

* Downloading of random byte ranges
* Randomise the number of requests per run
* Randomise the delay between requests
* Also send random amounts of data upstream
* Can be disabled via logfile
* User-agent can be customised for easy identification in server logs


The server side script is much, much simpler. Both are designed to be run by cron (though you may want to redirect the client script's stdout to /dev/null)  



Requirements
--------------

The base requirements for the client are

* Curl
* tr
* dd
* fold

The requirements for the server are

* dd
* Some kind of HTTP(s) server to serve the generated file

Note: It's up to the network administrator to ensure that the relevant traffic is routed over their VPN (or Tor) connection.  



HTTP Server Specific Notes
-------------------------------

If the remote server is using NGinx and the client has been configured with SEND_DATA=y then a default install of NGinx will not return the requested data, instead giving a HTTP 405 (Method not allowed).

The fix (unpleasant as it is) is to add the following to the relevant server block

	error_page 405 = $uri;

  



Notes on Atomicity
---------------------

The client script was deliberately designed with no atomicity, if one run takes a while then the next may quite possibly start before it's completed. Given that the aim is to render measurements of traffic meaningless this is a good thing as it helps reduce the likelihood of your scheduled traffic run being quite so identifiable.  




Suggested Run Interval
-------------------------

The most appropriate run interval will differ by each users situation, but common sense should be applied. There's not a huge amount of point in attempting to mask your traffic if the script doing the masking runs once every 12 hours for 5 minutes a time.

There may also be situations where it's better to run the script in a while loop than to add it to crontab.  



Client - Multiple Config Files
----------------------------------

Although the default config file is called 'config' you can pass the filename of an alternative config file if you wish to maintain multiple configurations

	./request_generator -c foo.config

The filename passed can either be an absolute path, or the name of a config file in the same directory as the request_generator script.


---------------------------------------


Issue Tracking
---------------

Development is managed within a private JIRA instance, a static HTML mirror of the project can be found at http://projects.bentasker.co.uk/jira_projects/browse/BHAYSTACKG.html




License
--------

Copyright (C) 2014 B Tasker
Released under the [GNU GPL V2](http://www.gnu.org/licenses/gpl-2.0.html)
