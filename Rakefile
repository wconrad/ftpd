# encoding: utf-8
require 'rubygems'
require 'bundler'

$:.unshift(File.dirname(__FILE__) + '/lib')
Dir['rake_tasks/**/*.rake'].each { |path| load path }

task :default => [:cucumber]
