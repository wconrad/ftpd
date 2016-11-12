# encoding: utf-8

if Gem::Specification::find_all_by_name("jeweler").any?

  require 'jeweler'

  README_PATH = File.expand_path('../README.md', File.dirname(__FILE__))

  def remove_markdown_link(description)
    regex = %r{
    \[
      ([^\]]+)
    \]
    (
      \[\d+\] |
      \([^)]+\)
    )
  }x
    description = description.gsub(regex, '\1')
  end

  def remove_badges(description)
    description.gsub(/^\[!.*\n/, '')
  end

  def join_lines(description)
    description.gsub(/\n/, ' ').strip
  end

  def extract_description_from_readme
    readme = File.open(README_PATH, 'r', &:read)
    description = readme[/^# FTPD.*\n+((?:.*\n)+?)\n*##/i, 1]
    unless description
      raise 'Unable to extract description from readme'
    end
    description = remove_badges(description)
    description = remove_markdown_link(description)
    description = join_lines(description)
    description
  end

  Jeweler::Tasks.new do |gem|
    # gem is a Gem::Specification... see
    # http://docs.rubygems.org/read/chapter/20 for more options
    gem.name = 'ftpd'
    gem.homepage = 'http://github.com/wconrad/ftpd'
    gem.license = 'MIT'
    gem.summary = %Q{Pure Ruby FTP server library}
    gem.description = extract_description_from_readme
    gem.email = 'wconrad@yagni.com'
    gem.authors = ['Wayne Conrad']
    # dependencies defined in Gemfile
  end

  Jeweler::RubygemsDotOrgTasks.new

end
