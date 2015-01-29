# Embulk plugin for Twitter Stream input

This [Embulk](https://github.com/embulk/embulk) plugin read records from Twitter Stream!

## Configuration

```yaml
exec: {}
in:
  type: twitterstream
  consumer_key:        XXXXXXXXXXXXXXXXXXXXXX
  consumer_secret:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  access_token:        XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  access_token_secret: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  count: 3
  column:
    - id_str
    - name
    - user.screen_name
out: {type: stdout}
```

