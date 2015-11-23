# pakyow-assets

Asset handling for [Pakyow](http://pakyow.com). It's intended to be lightweight
and fast in development while providing powerful fingerprinting and caching
support for production environments.

In development, assets are compiled on demand rather than up-front. They'll only
be recompiled again when the source changes.

When starting up in production, Pakyow will compile, minify, and fingerprint
every asset file. Fingerprinted filenames are automatically handled.

Bundled preprocessors include: js, css, png, gif, jpg, favicon, and sass.

# Installation

Place inside your Gemfile

    gem 'pakyow-assets'

Run `bundle install` and restart your app server.

# Usage

Place all assets in a `app/assets` directory. When compiled, assets will mimic
the directory structure. During development, all assets will be compiled to a
`.assets` directory by default. Pakyow will serve requests to all assets when
running in a development environment. The idea in production is for all assets
to be in a non-minified state, making debugging easy.

*Note that all compiled assets should be excluded from version control as they
will be compiled and fingerprinted when deployed to a production environment.*

In production, assets will automatically be minified and fingerprinted. As a
developer you don't have to worry about caching or fingerprints; Pakyow takes
care of all of that for you.

## Configuration

There are many configuration options available. Take a look at `lib/config.rb`
for all the available options.

## Custom Preprocessor

Pakyow Assets can easily be extended. Take a look at the existing preprocessors
in `lib/preprocessors` for examples.

## External Asset Store

Any number of asset stores can be registered:

```ruby
Pakyow::Config.assets.stores[:store_name] = 'absolute_path_to_store'
```

# License

pakyow-assets is released under the [MIT License](http://opensource.org/licenses/MIT).
