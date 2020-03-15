require 'fileutils'
require 'yaml'

TMPDIR = "spec/tmp"
$ANSIBLE_DEBUG = false # Set to true to keep role directory
#$ANSIBLE_DEBUG = true

def mktemp
  FileUtils.rm_rf(TMPDIR)
  FileUtils.mkdir(TMPDIR)
end

def rmtemp
  FileUtils.rm_rf(TMPDIR) if !$ANSIBLE_DEBUG
end

def role_file_path()
  "#{TMPDIR}/role.yml"
end

def make_role_file(s)
  IO.write(role_file_path, s)
end

def make_role(s)
  make_role_file(s)
  AnsibleMakeRole.make(TMPDIR)
end

def section_path(section_name)
  "#{TMPDIR}/#{section_name}/main.yml"
end

def section_hash(section_name)
  YAML.load(IO.read(section_path(section_name)))
end

def section_file(section_name)
  IO.read(section_path(section_name))
end

def meta_yml() section_hash("meta") end
def defaults_yml() section_hash("defaults") end
def vars_yml() section_hash("vars") end
def tasks_yml() section_hash("tasks") end
def handlers_yml() section_hash("handlers") end

def meta_file() section_file("meta") end
def defaults_file() section_file("defaults") end
def vars_file() section_file("vars") end
def tasks_file() section_file("tasks") end
def handlers_file() section_file("handlers") end


