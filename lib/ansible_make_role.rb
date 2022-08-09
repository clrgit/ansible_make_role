require "ansible_make_role/version"

require "fileutils"

module AnsibleMakeRole
  ROLE_FILE_NAME = "role.yml"

  DEFAULT_FORCE_FLAG = false
  DEFAULT_GIT_FLAG = false

  class Error < StandardError; end

  @force = DEFAULT_FORCE_FLAG
  def self.force() @force end
  def self.force=(value) @force = value end

  @git = DEFAULT_GIT_FLAG
  def self.git() @git end
  def self.git=(value) @git = value end

  def self.make(role_dir)
    changed = false
    wrap_system_call_error {
      role_file = "#{role_dir}/#{ROLE_FILE_NAME}"
      meta_file = "#{role_dir}/meta/main.yml"
      git_file = "#{role_dir}/.gitignore"
      if force || !File.exist?(meta_file) || File.mtime(role_file) > File.mtime(meta_file)
        if !compile_role(role_file, role_dir).empty?
          IO.write(git_file, "*/main.yml\n") if git
          changed = true
        end
      end
    }
    return changed
  end

  def self.clean(role_dir)
    changed = false
    wrap_system_call_error {
      File.exists?("#{role_dir}/#{ROLE_FILE_NAME}") or raise Error.new("Not a role directory: #{role_dir}")
      for file in Dir["#{role_dir}/*/main.yml"]
        FileUtils.rm(file)
        dir = File.dirname(file)
        FileUtils.rmdir(dir) if File.empty?(dir)
        changed = true
      end
      git_file = "#{role_dir}/.gitignore"
      if git && File.exist?(git_file)
        FileUtils.rm(git_file)
        changed = true
      end
    }
    return changed
  end

private
  # Turn a SystemCallError into a AnsibleMakeRole::Error exception and remove
  # Ruby reference from message (eg. the "@ rb_sysopen" part)
  def self.wrap_system_call_error(&block)
    begin
      yield
    rescue SystemCallError => ex
      raise Error.new(ex.message.sub(/ @ \w+/, ""))
    end
  end

  # source is a single-file role and target is the role directory. Returns list
  # of generated files
  def self.compile_role(source, target)
    meta = []
    sections = {
      "defaults" => [],
      "vars" => [],
      "tasks" => [],
      "handlers" => []
    }
    current_section = meta

    File.readlines(source).each { |line|
      line.chomp!
      next if line =~ /^---\s*$/
      if line =~ /^(\w+)\s*:/
        section = $1
        if sections.key?(section) # Built-in section?
          current_section = sections[section]
        else # Everything else goes to the meta file incl. section header
          current_section = meta
          current_section << line
        end
      else
        current_section << line
      end
    }

    if meta.all? { |l| l =~ /^\s*$/ }
      meta = ["dependencies: []"]
    end

    (sections.to_a + [["meta", meta]]).map { |section, lines|
      dir = "#{target}/#{section}"
      file = "#{dir}/main.yml"
      if lines.all? { |l| l =~ /^\s*$/ }
        FileUtils.rm_f(file)
        FileUtils.rmdir(dir) if Dir.exist?(dir)
        nil
      else
        FileUtils.mkdir_p(dir)
        File.open(file, "w") { |f|
          f.puts "---" if section != "meta"
          unindent(lines).each { |l| f.puts l }
        }
        file
      end
    }.compact
  end

  # Unindent lines by the indentation of the first non-comment and non-blank
  # line
  def self.unindent(lines)
    line = lines.find { |l| l !~ /^\s*#/ && l !~ /^\s*$/ }
    return lines if line.nil?
    line =~ /^(\s*)/
    prefix = $1.dup
    lines.map { |l| l.sub(/^#{prefix}/, "") }
  end  
end



