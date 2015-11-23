require 'yui/compressor'

Pakyow::Assets.preprocessor :css, fingerprint_contents: true do |path|
  content = File.open(path).read

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
