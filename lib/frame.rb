#!/usr/env ruby

require 'fileutils'
#require 'liblicense'
require 'optparse' 
require 'ostruct'
require 'rdoc/usage'
require 'yaml'

class Frame
  VERSION = "0.0.2"
  
  def initialize (arguments)    
    @arguments = arguments
    # Here __FILE__ is the absolute path to this installed script
    @lib_dir = File.dirname(__FILE__)
    @source_dir = File.dirname(@lib_dir)
    @template_dir = @source_dir + '/templates'
    
    initialize_project_details
  end
  
  def run
    if parsed_options? && arguments_valid? 
      process_arguments            
      process_command
    else
      output_usage
    end
  end
  
  protected
  
  def initialize_project_details
    @project = OpenStruct.new
    @project.name = ''
    @project.unix_name = ''
    @project.artist = ''
    @project.remote_repository = nil
    @project.use_git = false
    @project.use_svn = :no
    @project.license_uri = ''
    
    # Don't save to the yaml in case the directory is moved by the user
    @project_dir = ''
    @version_control_dir = ''
  end
  
  def parsed_options?
    opts = OptionParser.new       
    opts.on('-v', '--version')  { output_version ; exit 0 }
    opts.on('-h', '--help')     { output_help }
    opts.on("-g", "--git URI")  do |uri| 
      @project.use_git = true
      @project.remote_repository = uri
    end
    opts.on("-r", "--svn-rep URI")  do |uri|
      @project.use_svn = :repository
      @project.remote_repository = uri
    end 
    opts.on("-d", "--svn-dir")  { @project.use_svn = :subdirectory }
    #opts.on('-l LICENSE', '--license URI')  do |license|
    #  @project.license_id << license
    #end 
    opts.on('-a', '--artist')  { |artist| @project.artist << artist }
    opts.on("-d DATE", "--date DATE") {|date| @project.date << date}
    # This consumes matched arguments from @arguments
    opts.parse!(@arguments) rescue return false
    process_options
    true      
  end
  
  def process_options
  end
  
  def output_options
    puts "Options:\\n"
    @options.marshal_dump.each do |name, val|        
      puts "  #{name} = #{val}"
    end
  end
  
  def arguments_valid?
    if @arguments.length != 1
      puts "No project name specified."
      return false
    end
    if @project.use_git && (@project.use_svn != :no)
      puts "Both git and svn specified. Please specify one or the other, not both."
      return false
    end
    if @project.use_git
      if File.extname(@project.remote_repository) != '.git'
        puts "git uri must be of the format: ssh://git.com/var/git/project.git"
        return false
      end
    end
    if @project.use_svn == :repository
      if @project.remote_repository.rindex(@project.unix_name) == nil
        puts "svn uri must end with project name"
        return false
      end
    end
    #TODO Check the licence id is valid
    true
  end
  
  def process_arguments
    @project.name = @arguments[0] # nil if unsupplied
    # Make a safe UNIX filename
    #TODO: Improve this
    @project.unix_name = @project.name.downcase.gsub(/ \//, '_')        
    @version_control_dir = Dir.pwd + '/' + @project.unix_name
    @project_dir = @version_control_dir
    if @project.use_svn == :repository
      @project_dir += '/trunk'
    end  
  end
  
  def output_help
    output_version
    RDoc::usage() # exits application
  end
  
  def output_usage
    RDoc::usage()
  end
  
  def output_version
    puts "#{File.basename(__FILE__)} version #{VERSION}"
  end
  
  def get_license_details
    #TODO Get the RDF metadata
    #TODO Get the full text of the license (or the non-web text?)
  end
  
  def make_directories
    if File.exists? @project_dir
      puts "Cannot create project. Directory named #{@project_dir} already exists. Please rename or move the existing directory."
      exit 1
    end
    
    FileUtils.mkdir_p @project_dir
    
    if @project.use_svn == :repository
      FileUtils.mkdir_p @version_control_dir + '/branches'
      FileUtils.mkdir_p @version_control_dir + '/tags'
    end
    
    FileUtils.mkdir_p @project_dir + "/discard"
    FileUtils.mkdir_p @project_dir + "/final"
    FileUtils.mkdir_p @project_dir + "/preparatory"
    FileUtils.mkdir_p @project_dir + "/releases"
    FileUtils.mkdir_p @project_dir + "/resources"
    FileUtils.mkdir_p @project_dir + "/script"
    FileUtils.mkdir_p @project_dir + "/web"
  end
  
  def make_script_link(name)
    script="#{@project_dir}/script/#{name}"
    File.open(script, 'w') {|f| 
      f.puts("#!/usr/bin/env ruby")
      f.puts("$project_dir=File.dirname(File.dirname(File.expand_path(__FILE__)))")
      f.puts("require '#{@lib_dir}/#{name}.rb'")
      f.puts("app = #{name.capitalize}.new(ARGV)")
      f.puts("app.run")
      File.chmod(0700, script)}
  end
  
  def make_script_links
    make_script_link("move")
    make_script_link("release")
    make_script_link("web")
    make_script_link("work")
  end
  
  def make_files
    #File.open("#{@project_dir}/resources/license.xml", 'w') {|f| 
    #  f.write(@project.license_metadata) }
    File.open("#{@project_dir}/COPYING", 'w') do |f| 
      f.write("See: ")
      f.write(@project.license_uri)
    end
    File.open("#{@project_dir}/README", 'w') do |f| 
      f.write("#{@project.name}")
      if @project.artist != ''
        f.write("by #{@project.artist}\name")
      end
      f.write("\nSee COPYING for license.\n")
    end
    FileUtils.cp("#{@template_dir}/template.svg", "#{@project_dir}/resources")
    File.open("#{@project_dir}/resources/configuration.yaml", 'w') do |f|
      f.write(@project.marshal_dump.to_yaml)
    end
  end
  
  def initialize_version_control
    if @project.use_git
      # Need to make sure we cd .. if something fails
      File.cd(@version_Control_dir)
      Kernel.system('git', 'init')
      Kernel.system('git', 'add', '.')
      Kernel.system('git', 'commit')
      Kernel.system('git', 'remote', 'add', 'origin', 
                    @project.remote_repository)
      Kernel.system('git', 'push', 'origin', 'master')
      file.cd('..')
     elsif @project.use_svn == :repository
       Kernel.system('svn', 'import', @version_control_dir, 
                     @project.remote_repository,
                     "-m", "Checkin of generated project directory structure.")
       FileUtils.remove_entry_secure(@version_control_dir)
       Kernel.system('svn', 'checkout', "#{@project.remote_repository}/trunk",
                     @project.name)
    elsif @project.use_svn == :directory
      Kernel.system('svn', 'add', @version_control_dir,
                     "-m", "Checkin of generated project directory structure.")
     end
  end
  
  def process_command
    #get_license_details
    make_directories
    make_script_links
    make_files
    initialize_version_control
  end
end
