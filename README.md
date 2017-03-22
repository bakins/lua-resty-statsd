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
