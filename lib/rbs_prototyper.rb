# frozen_string_literal: true

require 'fileutils'
require_relative "rbs_prototyper/version"

module RbsPrototyper
  class Error < StandardError; end
  # Your code goes here...

  def self.generate(target_path:, output_dir: 'sig')
    raise Error, '指定したファイルまたはディレクトリが存在しません' if !File.file?(target_path) && !File::directory?(target_path)
    raise Error, '.rb ファイルを指定してください' if File.file?(target_path) && !target_path.end_with?('.rb')

    if File::directory?(target_path)
      generate_rbs_recursively(target_path, output_dir)
    else
      generate_rbs(target_path, output_dir)
    end
  end

  private

  def self.generate_rbs_recursively(target_path, output_dir)
    Dir.glob('**/*', File::FNM_DOTMATCH, base: target_path).each do |file|
      if file.end_with?('.rb')
        file_path = File.join(target_path, file)
        generate_rbs_path = "#{output_dir}/#{file}"
        FileUtils.mkdir_p(File.dirname(generate_rbs_path)) if file.include?('/')
        `typeprof #{file_path} > #{generate_rbs_path}s`
      end
    end
  end

  def self.generate_rbs(target_path, output_dir)
    generate_rbs_path = "#{output_dir}/#{File.basename(target_path)}"
    `typeprof #{target_path} > #{generate_rbs_path}s`
  end
end
