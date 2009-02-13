# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby-terminfo}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tanaka Akira"]
  s.date = %q{2009-02-13}
  s.description = %q{terminfo binding for Ruby}
  s.email = %q{akr@fsij.org}
  s.extensions = ["extconf.rb"]
  s.extra_rdoc_files = ["README", "ChangeLog"]
  s.files = ["README", "ChangeLog", "Rakefile", "lib/terminfo.rb", "terminfo.c", "extconf.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://ruby-terminfo.rubyforge.org}
  s.rdoc_options = ["--title", "ruby-terminfo documentation", "--charset", "utf-8", "--opname", "index.html", "--line-numbers", "--main", "README", "--inline-source", "--exclude", "^(examples|extras)/"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ruby-terminfo}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{terminfo binding for Ruby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
