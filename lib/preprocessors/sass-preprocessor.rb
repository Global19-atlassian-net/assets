require 'sass'
require 'yui/compressor'

Pakyow::Assets.preprocessor :scss, :sass, output: :css, fingerprint_contents: true do |path|
  content = Sass::Engine.for_file(path, {}).render

  if Pakyow::Config.assets.minify
    begin
      YUI::CssCompressor.new.compress(content)
    rescue YUI::Compressor::RuntimeError
      Pakyow.logger.warn "Unable to minify #{path}; using raw content"
      content
    end
  else
    content
  end
end

Pakyow::Assets.dependencies :scss, :sass do |path|
  Sass::Engine.for_file(path, {}).dependencies.map { |dependency|
    dependency.options[:filename]
  }
end
