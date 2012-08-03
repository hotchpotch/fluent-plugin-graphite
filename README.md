# Fluent event to Graphite plugin (like statsd ).

# Installation

```
$ fluent-gem install fluent-plugin-graphite
```

# Usage

```
<match graphite>
  type graphite
  host localhost # optional
  port 2003 # optional
</match>
```

```ruby
fluent_logger.post('graphite',
  :key => 'mycounter',
  :count => 1
)

fluent_logger.post('graphite',
  :key => 'myrenderingtime',
  :count => 1,
  :sampling => 0.1
)

fluent_logger.post('graphite',
  :key => 'gaugor',
  :gauge => 333
)

# not work now...
fluent_logger.post('graphite',
  :key => 'myrenderingtime',
  :timer => 320
)

```

# Copyright

Copyright (c) 2012- Yuichi Tateno

# License

Apache License, Version 2.0
