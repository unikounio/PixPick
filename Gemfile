source "https://rubygems.org"

gem "rails", "~> 7.2.1"
gem "rails-i18n"
gem "sprockets-rails"
gem "sqlite3", ">= 1.4"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem "slim-rails", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "i18n_generators", require: false
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-fjord", require: false
  gem "rubocop-performance", require: false
  gem "slim_lint", require: false
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
