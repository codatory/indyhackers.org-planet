[![Build Status](https://cloud.drone.io/api/badges/codatory/indyhackers.org-planet/status.svg)](https://cloud.drone.io/codatory/indyhackers.org-planet)

# What is this?

This is a simple RSS Aggregator for the IndyHackers.org community. It collects feeds from all over the blogosphere and puts them in one simple to collect place.

# How do I get on?

You can either open an issue with your web or feed address, or fork the repo and run
the add_user.rb file. The syntax is as follows:

```shell
bundle && ruby add_user.rb http://mydomain.com
```

This will verify your feed works and add your domain to the config.yml file.

# Where does it live?

- json: http://indyhackers-planet.herokuapp.com/posts.json
- rss: http://indyhackers-planet.herokuapp.com/posts.rss
- opml: http://indyhackers-planet.herokuapp.com/feeds.opml

# I just posted something and it hasn't shown up

To be nice to servers, I'm only updating the JSON and RSS every 1 hour. If your new stuff isn't showing up after an hour, open an issue and I'll look into it.
