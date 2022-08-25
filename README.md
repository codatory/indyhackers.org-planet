# WARNING
[Heroku has announced sudden revocation of their free dynos](https://blog.heroku.com/next-chapter). If you're still using this service I recommend exporting the OPML feed and moving to native subscription before Salesforce finishes their rug-yanking.

# What is this?

This is a simple RSS Aggregator for the IndyHackers.org community. It collects feeds from all over the blogosphere and puts them in one simple to collect place.

# How do I get on?

You can either open an issue with your web or feed address, message me on Twitter or Slack, or fork the repo and run
the add_user.rb file. The syntax is as follows:

```shell
bundle && ruby add_user.rb http://mydomain.com
```

This will verify your feed works and add your feed URL to the config.yml file.

# Where does it live?

- rss: http://indyhackers-planet.herokuapp.com/posts.rss
- opml: http://indyhackers-planet.herokuapp.com/feeds.opml

# I just posted something and it hasn't shown up

To be nice to servers, I'm only updating the JSON and RSS every 15 minutes, with the feed set to a one hour expiration. If your new stuff isn't showing up after an hour, let me know and I'll look into it.

# More notes

I've started proactively validating feeds are working and active. If you don't post for over a year, or your feed stops working I'll get notified. If there's some sort of papertrail to a new feed, I'll probably pick it up, but if you change your domain or feed URL and don't want to wait for a year for someone to notice let me know.

Also, thanks to Heroku's change in Dyno policies... forever ago, the dyno for this service only runs about half the time since the dyno never otherwise idles. Consumers of the service should properly handle the HTTP503 from Heroku.
