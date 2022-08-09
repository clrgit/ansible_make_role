
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ansible_make_role/version"

Gem::Specification.new do |spec|
  spec.name          = "ansible_make_role"
  spec.version       = AnsibleMakeRole::VERSION
  spec.authors       = ["Claus Rasmussen"]
  spec.email         = ["claus.l.rasmussen@gmail.com"]

  spec.summary       = %q{Make Ansible role from make.yml file}
  spec.description   = %q{
                          ansible-make-role process a single-file role
                          definition file and generate an Ansible role from it.
                          The role is defined in the role.yml file and contain
                          a section for each Ansible main.yml file: 'defaults',
                          'vars', 'tasks', and 'handlers'. Definitions outside
                          of those sections (notably 'dependencies') are going
                          to the meta/main.yml file
                       }
  spec.homepage      = "http://github.com/clrgit/ansible_make_role"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes"
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

# spec.add_development_dependency "bundler", "~> 2.2.10" 
# spec.add_development_dependency "rake", ">= 12.3.3"
# spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "shellopts", "0.9.3"
  spec.add_dependency "indented_io"
end
