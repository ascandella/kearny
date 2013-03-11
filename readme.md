Kearny
======

A lightweight Sinatra / D3 application suited for wall-mounted stats
visualizations. Developed for use at [Causes](http://www.causes.com), where we
love graphs and numbers.

### Screenshot

![screenshot](https://raw.github.com/sectioneight/kearny/master/screenshot.png)

### About

Metrics-driven development is great, but having to manually check disparate data
sources to get a feeling for the various ways we're constantly trying to
improve.

Kearny provides a way to hook up various backends such as
[Graphite](http://graphite.wikidot.com),
[Google Analytics](http://www.google.com/analytics),
and [Mixpanel](https://mixpanel.com).

### Installation

1. Clone the repo:

        git clone git://github.com/sectioneight/kearny.git

2. Configure your Kearny instance with your desired components. For example, to
   configure the Graphite backend:

        cp config/graphite.yml{.sample,}

    Then, open `config/graphite.yml` in your favorite editor and configure your
    `graphite_host`. Note that Kearny is written to support multiple
    environments, so each configuration file with credentials is broken into
    `development` and `production`. If you omit an environment, and instead
    specify top-level keys, that'll work too (and the settings will apply to all
        environments).

    See: `config/kearny.yml` for an example.

3. Run Kearny in your favorite Rack container. I provide a (barebones)
   `config/unicorn.erb` file that is suitable for internal deployment. A
   `config.ru` file is provided for compatibility with the likes of `rackup` and
   `shotgun`.

                unicorn -c config/unicorn.rb

Note that I opted to omit the `unicorn` gem from the Gemfile to keep things
lean. This assumes you already have it installed. If not, you'll want to `gem
install unicorn`.

### Usage

Now that you have a server up, you'll want to make some pretty graphs. I've
provided some sample configurations, but you'll undoubtedly want to make them
your own.

The rest of this section is _pending_ while I hook up client-side editing.
Presently it's all done by hand-editing JSON.

### Contributing

Pull requests and issues are welcome. There currently no automated tests
(ghasp!) since much of the code is simply plumbing together various services.
Once I have a better feeling for the feature set, I'll revise this section.

### License

Copyright 2013 Aiden Scandella. Released under the MIT license.
