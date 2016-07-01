# Bitbond Ruby

## Usages

### Configure

Once you have your API keys then you can configure the client as

```ruby
Bitbond.configure do |config|
  config.app_id = "YOUR_APP_ID"
  config.secret_key = "SECRET_KEY"
end
```

Or

```ruby
Bitbond.configuration.app_id = "YOUR_APP_ID"
Bitbond.configuration.secret_key = "SECRET_KEY"
```
