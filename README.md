# fluent-plugin-latency

[![Build Status](https://secure.travis-ci.org/sonots/fluent-plugin-latency.png?branch=master)](http://travis-ci.org/sonots/fluent-plugin-latency)

Fluentd plugin to measure latency until receiving the messages. 

## What is this for?

This plugin is to investigate the network latency, in addition, the blocking situation of input plugins.

In the Fluentd mechanism, input plugins usually blocks and will not receive a new data until the previous data processing finishes.

By seeing the latency, you can easily find how long the blocking situation is occuring.

## How this works

Fluentd messages include the time attribute which expresses the time of when the message is created, or when it is written in application logs.

This plugin takes the difference between the current time and the time attribute to obtain the latency. 

## Installation

Use RubyGems:

    gem install fluent-plugin-latency

## Configuration

Following example measures the max and average latency until receiving messages. 
Note that this example uses [fluent-plugin-reemit](https://github.com/sonots/fluent-plugin-reemit) to capture all messages once, measure latencies, and then re-emit. 

```apache
<source>
  type forward
  port 24224
</source>

# Latency plugin output comes here
<match latency>
  type stdout
</match>

# All messages come here once. Measure latencies and re-emit
<match **>
  type copy
  <store>
    type latency
    tag latency
    interval 60
  </store>
  <store>
    type reemit
  </store>
</match>

# Whatever you want to do
<match **>
  type stdout
</match>
```

Output will be like

```
latency: {"max":1.011,"avg":0.002","num":10}
```

where `max` and `avg` are the maximum and average latency, and `num` is the number of messages.

## Option Parameters

* interval

    The time interval to emit measurement results

* tag

    The output tag name. Default is `latency`

## ChangeLog

See [CHANGELOG.md](CHANGELOG.md) for details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2014 Naotoshi Seo. See [LICENSE](LICENSE) for details.
