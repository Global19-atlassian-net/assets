require_relative 'assets'
require_relative 'config'
require_relative 'middleware'
require_relative 'version'

require_relative 'preprocessors/css-preprocessor'
require_relative 'preprocessors/image-preprocessor'
require_relative 'preprocessors/javascript-preprocessor'
require_relative 'preprocessors/sass-preprocessor'

Pakyow::App.after :configure do
  config.assets.stores.each_pair do |name, path|
    Pakyow::Assets.register_path_with_name(path, name)
  end

  if config.assets.compile_on_startup
    Pakyow::App.processor :html do |content|
      Pakyow::Assets.mixin_fingerprints(content)
    end

    Pakyow.logger.debug 'Precompiling assets...'
    Pakyow::Assets.precompile
    Pakyow.logger.debug 'Finished precompiling!'
  end
end

# make sure this middleware executes first
# FIXME: need an api for this on Pakyow::App
Pakyow::App.middleware.unshift(lambda  { |builder|
  builder.use Pakyow::Assets::Middleware
})
