# -*- coding: utf-8 -*-
require 'optparse'
require 'fileutils'
require "hiki2yard/version"


module Hiki2yard
  class Command
    def self.run(argv=[])
      new(argv).execute
    end

    def initialize(argv=[])
      @argv = argv
      @source_path = File.expand_path('..', __FILE__)
      @target_path = Dir.pwd
      @base_name=File.basename(@target_path)
      print "source_path= \'#{@source_path}\'\n"
      print "target_path= \'#{@target_path}\'\n"
      @opts={}
    end

    def execute
      @argv << '--help' if @argv.size==0
      command_parser = OptionParser.new do |opt|
        opt.on('-v', 'show program Version.') { |v|
          opt.version = Hiki2yard::VERSION
          puts opt.ver
        }
        opt.on('-f','--force','force copy new Rakefile.') {
          @opts[:force]=true
        }
        opt.on('-i','--init','initialize hiki2yard directory.') { |v|
          init
          exit
        }
      end
      command_parser.banner = "Usage: hiki2yard [options] FILE"
      command_parser.parse!(@argv)
      exit
    end

    def init
      rev_rakefile2
      mk_yardopts
      create_dir_if_not_exists(File.join(@target_path,'hikis'))
      create_dir_if_not_exists(File.join(@target_path,"#{@base_name}.wiki"))
      create_dir_if_not_exists(File.join(@target_path,'latexes'))
      add_pre_in_latexes
      rev_gemspec
    end

    def add_pre_in_latexes
      source=File.join(@source_path,'hiki2yard','handout_pre.tex')
      target=File.join(@target_path,'latexes')
      p command = "cp #{source} #{target}"
      system command
    end

    def rev_rakefile2
      rev_rakefile
      source=File.join(@source_path,'hiki2yard','latex_task.rb')
      target=File.join(@target_path,'Rakefile')
      p command = "cat #{source} >> #{target}"
      system command
    end

    def rev_rakefile
      source=File.join(@source_path,'hiki2yard','new_rakefile')
      target=File.join(@target_path,'Rakefile')
      p @opts[:force] 
      if @opts[:force] then
        copy_file_even_if_exists(source, target)
      else
        copy_file_if_not_exists(source, target)
      end
    end

    def mk_yardopts
      cont = "-\n**/*.md\n"
      File.write(File.join(@target_path,'.yardopts'),cont)
    end

    def create_dir_if_not_exists(data_path)
      return if File::exists?(data_path)
      FileUtils.mkdir(data_path,:verbose=>true) # :noop=>true)
    end

    def copy_file_if_not_exists(source, target)
      if File::exists?(target)
        print "File #{target} exists, not copy.\n"
        return
      end
      FileUtils.cp(source,target,:verbose=>true) # :noop=>true)
    end

    def copy_file_even_if_exists(source, target)
      FileUtils.cp(source,target,:verbose=>true) # :noop=>true)
    end

    def rev_gemspec
      cont=<<"EOS"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "hiki2md"
  spec.add_development_dependency "mathjax-yard"
  spec.add_development_dependency "hiki2latex"
EOS
      print "add follows at the tail of #{@target_path}/#{@base_name}.gemspec\n"
      print cont
    end
  end
end




