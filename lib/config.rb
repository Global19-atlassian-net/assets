Pakyow::Config.register(:assets) { |config|

  # registered asset stores
  config.opt :stores, lambda {
    @stores ||= {
      default: File.join(Pakyow::Config.app.root, 'app', 'assets')
    }
  }

  # whether or not pakyow should host assets
  config.opt :compile_on_request

  # whether pakyow should compile assets on startup
  config.opt :compile_on_startup

  # where assets should be compiled to
  config.opt :compiled_asset_path

  # whether or not to cache the assets
  config.opt :cache

  # whether or not to minify the assets
  config.opt :minify

  # the prefix to add to asset names (useful for cdn)
  config.opt :prefix, '/'

}.env(:development) { |opts|
  opts.cache = false
  opts.compile_on_request = true
  opts.compile_on_startup = false
  opts.compiled_asset_path = '.assets'
  opts.minify = false
}.env(:production) { |opts|
  opts.cache = true
  opts.compile_on_request = false
  opts.compile_on_startup = true
  opts.compiled_asset_path = 'public'
  opts.minify = true
}
