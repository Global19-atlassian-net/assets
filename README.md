# pakyow-assets

Asset handling for [Pakyow](http://pakyow.com). It's intended to be lightweight
and fast in development while providing powerful fingerprinting and caching
features for production environments.

In development, assets are compiled on demand. They're recompiled again only if
the source changes.

When starting up in production, Pakyow will compile, minify, and fingerprint
every asset file. Fingerprinted filenames are automatically handled.

Bundled preprocessors include: js, css, png, gif, jpg, favicon, and sass.

# Installation

Place inside your Gemfile

```ruby
gem 'pakyow-assets'
```

Run `bundle install` and restart your app server.

# Usage

Place all assets in a `app/assets` directory. When compiled, assets will mimic
the directory structure. During development, all assets will be compiled to a
`.assets` directory. Pakyow will serve requests to all assets when running in a
development environment. All assets should be in their original, non-minified
state; this makes debugging easier in development.

*It's recommended that `.assets` be excluded from version control.*

In production, assets will automatically be minified and fingerprinted when the
app boots up. As a developer you don't have to worry about fingerprinting assets
or setting cache headers; Pakyow does that for you.

Here are the cache headers that Pakyow sets for fingerprinted assets (`mtime` is
the last modified timestamp of the asset):

```ruby
headers['Age'] = (Time.now - mtime).to_i
headers['Cache-Control'] = 'public, max-age=31536000'
headers['Vary'] = 'Accept-Encoding'
headers['Last-Modified'] = mtime.httpdate
```

Non-fingerprinted assets will be served, but without cache headers.

## Configuration

Take a look at `lib/config.rb` for all available options.

## Custom Preprocessors

Pakyow Assets can easily be extended to support new asset types. Take a look at
the existing preprocessors in `lib/preprocessors` for examples on how to write
your own. Eventually all bundled preprocessors will be moved into their own gem,
following the `pakyow-{preprocessor-name}` convention (e.g. `pakyow-sass`).

## External Asset Stores

Any number of asset stores can be registered:

```ruby
Pakyow::Config.assets.stores[:store_name] = 'absolute_path_to_store'
```

Assets from all stores will be compiled together into the app. This is intended
to be used when including assets in external libraries.

# License

pakyow-assets is released under the [MIT License](http://opensource.org/licenses/MIT).
