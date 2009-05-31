#! /usr/bin/env ruby

template = <<-__
  NAME
    options.rb

  DESCRIPTION
    options.rb simplifies the common idiom of dealing with keyword options in
    ruby functions.  it also deals correctly with symbol vs string keywords and
    prevents many subtle programming errors that can arise from doing so
    incorrectly.  options.rb doesn't hack ruby's core with one exception: the
    method Array#options.

  SYNOPSIS
    require 'options'

    def method(*args, &block)
      args, options = Options.parse(args)

      a = args.shift
      b = args.shift

      force = options.getopt(:force, default = false)
      verbose = options.getopt([:verbose, :VERBOSE])
      foo, bar = options.getopt(:foo, :bar)
    end

  INSTALL
    gem install options

  SAMPLES
    <%= samples %>
__


require 'erb'
require 'pathname'

$VERBOSE=nil

def indent(s, n = 2)
  s = unindent(s)
  ws = ' ' * n
  s.gsub(%r/^/, ws)
end

def unindent(s)
  indent = nil
  s.each do |line|
    next if line =~ %r/^\s*$/
    indent = line[%r/^\s*/] and break
  end
  indent ? s.gsub(%r/^#{ indent }/, "") : s
end

samples = ''
prompt = '~ > '

Dir.chdir(File.dirname(__FILE__))

Dir['sample*/*'].sort.each do |sample|
  samples << "\n" << "  <========< #{ sample } >========>" << "\n\n"

  cmd = "cat #{ sample }" 
  samples << indent(prompt + cmd, 2) << "\n\n" 
  samples << indent(`#{ cmd }`, 4) << "\n" 

  cmd = "ruby #{ sample }" 
  samples << indent(prompt + cmd, 2) << "\n\n" 

  cmd = "ruby -e'STDOUT.sync=true; exec %(ruby -Ilib #{ sample })'" 
  #cmd = "ruby -Ilib #{ sample }" 
  samples << indent(`#{ cmd } 2>&1`, 4) << "\n" 
end

erb = ERB.new(unindent(template))
result = erb.result(binding)
#open('README', 'w'){|fd| fd.write result}
#puts unindent(result)
puts result
