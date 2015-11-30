require 'yui/compressor'

Pakyow::Assets.preprocessor :js, fingerprint: true, fingerprint_contents: true do |path|
  content = File.read(path)

  if Pakyow::Config.assets.minify
    begin
      YUI::JavaScriptCompressor.new(munge: true).compress(content)
    rescue YUI::Compressor::RuntimeError
      Pakyow.logger.warn "Unable to minify #{path}; using raw content"
      content
    end
  else
    content
  end
end
