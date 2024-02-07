# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require File.join(File.dirname(__FILE__), "lib/ftpd/release")

class Readme

  def description
    readme = File.open(README_PATH, "r", &:read)
    description = readme[/^# FTPD.*\n+((?:.*\n)+?)\n*##/i, 1]
    unless description
      raise "Unable to extract description from readme"
    end
    description = remove_badges(description)
    description = remove_markdown_link(description)
    description = join_lines(description)
    description
  end

  private

  README_PATH = File.expand_path("README.md", File.dirname(__FILE__))
  private_constant :README_PATH

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
    description.gsub(/^\[!.*\n/, "")
  end

  def join_lines(description)
    description.gsub(/\n/, " ").strip
  end

end

Gem::Specification.new do |s|
  s.name = "ftpd"
  s.version = Ftpd::Release::VERSION
  s.required_rubygems_version = Gem::Requirement.new(">= 0")
  s.require_paths = ["lib"]
  s.authors = ["Wayne Conrad"]
  s.date = Ftpd::Release::DATE
  s.description = Readme.new.description
  s.email = "kf7qga@gmail.com"
  s.executables = ["ftpdrb"]
  s.extra_rdoc_files = [
    "LICENSE.md",
    "README.md"
  ]
  s.files = [
    ".yardopts",
    "Changelog.md",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.md",
    "README.md",
    "Rakefile",
    "bin/ftpdrb",
    "ftpd.gemspec",
    "insecure-test-cert.pem",
  ]
  s.files += Dir["doc/**/*.md"]
  s.files += Dir["examples/**/*.rb"]
  s.files += Dir["lib/**/*.rb"]
  s.homepage = "http://github.com/wconrad/ftpd"
  s.licenses = ["MIT"]
  s.required_ruby_version = ">= 2.7.8"
  s.rubygems_version = "2.5.1"
  s.summary = "Pure Ruby FTP server library"
  s.add_runtime_dependency("memoizer", "~> 1.0")
  s.add_development_dependency("net-ftp", "~> 0.3")
  s.add_development_dependency("cucumber", "~> 9.1")
  s.add_development_dependency("rake", "~> 13.1")
  s.add_development_dependency("redcarpet", "~> 3.6")
  s.add_development_dependency("rspec", "~> 3.1")
  s.add_development_dependency("rspec-its", "~> 1.0")
  s.add_development_dependency("timecop", "~> 0.9")
  s.add_development_dependency("yard", "~> 0.9")
end
