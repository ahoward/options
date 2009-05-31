### gemspec: options-1.0.1

  Gem::Specification::new do |spec|
    spec.name = "options"
    spec.version = "1.0.1"
    spec.platform = Gem::Platform::RUBY
    spec.summary = "options"

    spec.files = ["gemspec.rb", "lib", "lib/options.rb", "options.gemspec", "README", "README.rb", "samples", "samples/a.rb", "samples/b.rb", "samples/c.rb"]
    spec.executables = []
    
    spec.require_path = "lib"

    spec.has_rdoc = true
    spec.test_files = nil
    #spec.add_dependency 'lib', '>= version'
    #spec.add_dependency 'fattr'

    spec.extensions.push(*[])

    spec.rubyforge_project = 'codeforpeople'
    spec.author = "Ara T. Howard"
    spec.email = "ara.t.howard@gmail.com"
    spec.homepage = "http://github.com/ahoward/options/tree/master"
  end

