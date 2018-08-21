lua-resty-statsd
================

Statsd client for [OpenResty](https://openresty.org/en/) that supports the
extended/[datadog](http://docs.datadoghq.com/guides/dogstatsd/) protocol.

Status
======
This library is considered production ready.

Usage
=====

Example openresty/nginx config usage.
```
init_worker_by_lua_block {
  statsd = require("resty.statsd").new({namespace="nginx"})
}

server {
  log_by_lua_block{
    statsd.count("requests", 1, 1.0, {someLabel="someValue"})
  }
}
```

Methods
=======

new
---

`statsd = require("resty.statsd").new(options)`

Create a new statsd client. You should create one of these and [reuse](https://github.com/openresty/lua-nginx-module#data-sharing-within-an-nginx-worker) it. The client uses a simple queue internally and pushes stats periodically.

An optional Lua table can be specified:
* `host` - statsd host. default: _127.0.0.1_
* `port` - statsd port. default: _8125_
* `namespace` - this will be prefixed to every metric emitted. A namespace of "foo" and a metric name of "bar" would emit a metric named "foo.bar". There is no default.
* `tags` -  a table of key=value lables that will be added to every metric.
* `timeout` - socket timeout in miliseconds for send.default: _250_
* `delay` - how often to send flush the metrics queue in miliseconds. default: _250_


gauge
-----

`statsd:gauge(key, value, sample_rate, tags)`

Set a gauge value. Value should be an integer.  

If sample_rate is nil, it defaults to 1.0 - ie, no sampling.

Tags is a table of key=value that will be merged with those passed to `new` - if any.

count
-----

`statsd:count(key, value, sample_rate, tags)`

Increment a counter by value. To decrement,  use a negative integer.

If sample_rate is nil, it defaults to 1.0 - ie, no sampling.

Tags is a table of key=value that will be merged with those passed to `new` - if any.

timing
-----

`statsd:timing(key, value, sample_rate, tags)`

Record a timing. Value should be an integer in milliseconds.

If sample_rate is nil, it defaults to 1.0 - ie, no sampling.

Tags is a table of key=value that will be merged with those passed to `new` - if any.

## LICENSE


This module is licensed under the BSD license.

Copyright (C) 2016-2017, by Brian Akins

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
