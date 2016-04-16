require 'thor'
require 'fileutils'

module Rubygb
  class CLI < Thor
    desc 'build FILENAME', 'attempt to assemble, link + fix FILENAME and create a gb rom from it'
    option :no_fix, type: :boolean, desc: 'skip header fixing'
    option :output, desc: 'dir to put all build files'
    def build filename
      Rubygb.build filename, options
    end

    desc 'init PROJECT_NAME', 'create a new gameboy project at the location'
    def init project_name
      puts "Creating new project at #{File.expand_path project_name}"
      raise "Project already exists at #{File.expand_path project_name}!"if Dir.exists? project_name

      Dir.mkdir project_name
      galp_dest = File.join(project_name,"lib")
      Dir.mkdir galp_dest
      galp_lib = File.expand_path(File.join(File.dirname(__FILE__),"..","galp"))

      Dir.glob(File.join(galp_lib,"*")) do |file|
        puts "Copying #{File.basename(file)}..."
        FileUtils.copy file, galp_dest
      end

      template = Template.basic(project_name)
      filename = File.join(project_name,"#{project_name}.s")
      puts "Generating #{filename}..."
      File.open(filename,"w") {|f| f << template}

      puts "Done!"
    end

    desc "convert FILE", "convert a png file to gameboy format"
    option :output, :desc => "filename of converted file"
    def convert image_file
      filename = options[:output]
      filename ||= "#{image_file}.inc"

      img = Image.convert image_file
      file = ImageTemplates.image img

      File.open(filename,"w") { |f| f << file}
    end
  end
end
