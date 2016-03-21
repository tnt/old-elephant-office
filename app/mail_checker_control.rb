#!/usr/local/bin/ruby

gem 'daemons', '= 1.0.10'
require 'daemons'

options = {
    #:ARGV       => ['start', '-f', '--', 'param_for_myscript']
    :dir_mode   => :script,
    :dir        => '../tmp/pids'
    #:multiple   => true,
    #:ontop      => true,
    #:mode       => :exec,
    #:backtrace  => true,
    #:monitor    => true
  }

Daemons.run(File.expand_path('../mail_checker.rb',  __FILE__), options)
