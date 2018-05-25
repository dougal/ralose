= RaLoSe - Rails Log Search

Search Rails logs for a string - get all the log lines for matching requests.

RaLoSe uses Rails request IDs to group lines from the same request. Make sure you have these configured in your environment. For example, ensure `config/env/production.rb` has the line:

```
config.log_tags = [ :request_id ]
```

== Install

Either install the Gem:

```
gem install ralose
```

Or add to your Gemfile if using as part of a project:

```
gem "ralose"
```

Then `bundle install`.


== Usage

You can either pass a file:

```
ralose foobar log/production.log
```

or pipe a file to STDIN:

```
tail -f log/production.log | ralose foobar
```

In both cases `ralose` will output requests which match the search string `foobar`.

For additional options, run `ralose -h`.


== Contributing to RaLoSe

Source is available on Github at https://github.com/dougal/ralose.

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2018 Douglas F Shearer. See LICENSE.txt for
further details.

