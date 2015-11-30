require 'fileutils'

module Pakyow
  module Assets
    def self.register_path_with_name(path, name)
      stores[name] = {
        path: path,
        assets: assets_at_path(path)
      }
    end

    def self.assets_at_path(path)
      Dir.glob(File.join(path, '**/[!_]*.[a-z]*')).map { |asset|
        String.normalize_path(asset[path.length..-1])
      }
    end

    def self.stores
      @stores ||= {}
    end

    def self.preprocessors
      @preprocessors ||= {}
    end

    def self.dependents
      @dependents ||= {}
    end

    def self.compiled_asset_path_for_request_path(path)
      path = String.normalize_path(path)
      ext = File.extname(path)

      return unless path =~ /\.(.*)$/
      return unless preprocessor?(ext)

      path_regex = /#{path.gsub(ext, '')}\.(#{alias_exts(ext).map(&:to_s).join('|')})/

      @stores.each_pair do |name, info|
        if asset = info[:assets].find { |asset| asset =~ path_regex }
          return compile_asset_at_path(asset, info[:path])
        end
      end

      nil
    end

    def self.normalize_ext(ext)
      ext.gsub(/[^a-z]/, '').to_sym
    end

    def self.alias_exts(ext)
      preprocessors.select { |_, info|
        info[:output_ext] == normalize_ext(ext)
      }.keys
    end

    def self.output_ext(ext)
      ".#{preprocessor_for_ext(ext)[:output_ext]}"
    end

    def self.preprocessor?(ext)
      preprocessors.values.map { |info| info[:output_ext] }.flatten.include?(normalize_ext(ext))
    end

    def self.preprocessor_for_ext(ext)
      ext = normalize_ext(ext)

      preprocessors[ext] || {
        block: nil,
        output_ext: ext,
        fingerprint_contents: false,
        finterprint: false
      }
    end

    def self.compile_asset_at_path(asset, path)
      absolute_path = File.join(path, asset)

      asset_dir = File.dirname(asset)
      asset_ext = output_ext(File.extname(asset))
      asset_file = File.basename(asset, '.*')

      if fingerprinted?(asset_ext)
        compiled_asset = "#{asset_file + '-' + asset_hash(absolute_path) + asset_ext}"
      else
        compiled_asset = "#{asset_file + asset_ext}"
      end

      compiled_path = File.join(
        Pakyow::Config.app.root,
        Pakyow::Config.assets.compiled_asset_path,
        asset_dir,
        compiled_asset
      )

      unless File.exists?(compiled_path)
        FileUtils.mkdir_p(File.dirname(compiled_path))

        if fingerprinted?(asset_ext)
          glob_path = File.join(Pakyow::Config.app.root, Pakyow::Config.assets.compiled_asset_path, asset_dir, "#{asset_file}-*#{asset_ext}")
        else
          glob_path = File.join(Pakyow::Config.app.root, Pakyow::Config.assets.compiled_asset_path, asset_dir, asset_file + asset_ext)
        end

        FileUtils.rm(Dir.glob(glob_path))
        File.open(compiled_path, 'wb+') { |fp| fp.write(preprocess(absolute_path)) }
      end

      compiled_path
    end

    def self.preprocessor(*exts, output: nil, fingerprint: false, fingerprint_contents: false, &block)
      exts.each do |ext|
        preprocessors[ext] = {
          block: block,
          output_ext: output || ext,
          fingerprint_contents: fingerprint_contents,
          fingerprint: fingerprint
        }
      end
    end

    def self.dependencies(*exts, &block)
      exts.each do |ext|
        dependents[ext] = block
      end
    end

    def self.preprocess(path)
      preprocessor = preprocessor_for_ext(File.extname(path))
      block = preprocessor[:block]

      block.nil? ? File.read(path) : block.call(path)
    end

    def self.precompile
      if File.exists?(Pakyow::Config.assets.compiled_asset_path)
        FileUtils.rm_r(Pakyow::Config.assets.compiled_asset_path)
      end

      stores.each do |_, info|
        info[:assets].each do |asset|
          compile_asset_at_path(asset, info[:path])
          absolute_path = File.join(info[:path], asset)

          fingerprint = asset_hash(absolute_path)

          if fingerprinted?(File.extname(asset))
            fingerprinted_asset = File.join(
              File.dirname(asset),
              "#{File.basename(asset, '.*')}-#{fingerprint + output_ext(File.extname(asset))}",
            )
          else
            fingerprinted_asset = File.join(
              File.dirname(asset),
              File.basename(asset, '.*') + output_ext(File.extname(asset)),
            )
          end

          replaceable_asset = File.join(
            File.dirname(asset),
            File.basename(asset, '.*') + output_ext(File.extname(asset)),
          )

          manifest[replaceable_asset] = {
            original_ext: File.extname(asset),
            fingerprinted_asset: fingerprinted_asset
          }
        end
      end

      base = File.join(Pakyow::Config.app.root, Pakyow::Config.assets.compiled_asset_path)

      manifest.each do |replaceable_asset, info|
        next unless fingerprint_contents?(info[:original_ext])

        path = File.join(base, info[:fingerprinted_asset])

        content = File.read(path)
        File.open(path, 'wb') { |file|
          file.write(mixin_fingerprints(content))
        }
      end
    end

    def self.manifest
      @manifest ||= {}
    end

    def self.mixin_fingerprints(content)
      return content if content.nil? || content.empty?

      manifest.each do |asset, info|
        content = content.gsub(asset, info[:fingerprinted_asset])
      end

      content
    end

    def self.asset_hash(absolute_path)
      Digest::MD5.hexdigest(dependencies_for(absolute_path).concat([absolute_path]).map { |filename|
        Digest::MD5.file(filename).hexdigest
      }.flatten.join)
    end

    def self.dependencies_for(absolute_path)
      block = dependents[normalize_ext(File.extname(absolute_path))]
      return [] if block.nil?
      block.call(absolute_path)
    end

    def self.fingerprinted?(ext)
      preprocessor_for_ext(ext)[:fingerprint]
    end

    def self.fingerprint_contents?(ext)
      preprocessor_for_ext(ext)[:fingerprint_contents]
    end
  end
end
