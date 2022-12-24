# -*- encoding: utf-8 -*-
# stub: ruby-terminfo 0.1.1 ruby lib
# stub: extconf.rb

Gem::Specification.new do |s|
  s.name = "ruby-terminfo".freeze
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tanaka Akira".freeze]
  s.date = "2022-12-24"
  s.description = "terminfo binding for Ruby".freeze
  s.email = "akr@fsij.org".freeze
  s.extensions = ["extconf.rb".freeze]
  s.extra_rdoc_files = ["README".freeze, "ChangeLog".freeze]
  s.files = ["ChangeLog".freeze, "README".freeze, "Rakefile".freeze, "extconf.rb".freeze, "lib/terminfo.rb".freeze, "terminfo.c".freeze, "test/test_winsize.rb".freeze]
  s.homepage = "http://ruby-terminfo.rubyforge.org".freeze
  s.rdoc_options = ["--title".freeze, "ruby-terminfo documentation".freeze, "--charset".freeze, "utf-8".freeze, "--opname".freeze, "index.html".freeze, "--line-numbers".freeze, "--main".freeze, "README".freeze, "--inline-source".freeze, "--exclude".freeze, "^(examples|extras)/".freeze]
  s.rubygems_version = "3.3.7".freeze
  s.summary = "terminfo binding for Ruby".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  else
    s.add_dependency(%q<rake>.freeze, ["~> 13.0"])
  end
end
