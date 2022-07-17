# frozen_string_literal: true

require 'fileutils'
require_relative "rbs_prototyper/version"

module RbsPrototyper
  class Error < StandardError; end
  # Your code goes here...

  def self.generate(target_path:, output_dir: 'sig', command: 'rbs')
    raise Error, 'The specified file or directory does not exist.' if !File.file?(target_path) && !File::directory?(target_path)
    raise Error, 'Specify the .rb file' if File.file?(target_path) && !target_path.end_with?('.rb')
    raise Error, 'Invalid command.' unless PROTOTYPE_COMMANDS.include?(command)

    if File::directory?(target_path)
      generate_rbs_recursively(target_path, output_dir, command)
    else
      generate_rbs(target_path, output_dir, command)
    end
  end

  private

  PROTOTYPE_COMMANDS = {
    'rbs' => 'rbs prototype rb',
    'typeprof' => 'typeprof'
  }

  def self.generate_rbs_recursively(target_path, output_dir, command)
    Dir.glob('**/*', File::FNM_DOTMATCH, base: target_path).each do |file|
      if file.end_with?('.rb')
        file_path = File.join(target_path, file)
        generate_rbs_path = "#{output_dir}/#{file}"
        FileUtils.mkdir_p(File.dirname(generate_rbs_path)) if file.include?('/')
        `#{PROTOTYPE_COMMANDS[command]} #{file_path} > #{generate_rbs_path}s`
      end
    end
  end

  def self.generate_rbs(target_path, output_dir, command)
    generate_rbs_path = "#{output_dir}/#{File.basename(target_path)}"
    FileUtils.mkdir_p(File.dirname(generate_rbs_path))
    `#{PROTOTYPE_COMMANDS[command]} #{target_path} > #{generate_rbs_path}s`
  end
end
