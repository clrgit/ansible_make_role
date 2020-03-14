require "ansible_make_role/version"

require "fileutils"

module AnsibleMakeRole
  class Error < StandardError; end

  @force = true
  def self.force=(value) @force = value end
  def self.force() @force end

  def self.make(mole_file, mole_dir, role_dir)
    File.mkdir(role_dir)
    meta_yml = "#{role_dir}/meta/main.yml"
    if force || !File.exist?(meta_yml) || File.mtime(mole_file) > File.mtime(meta_yml)
      compile_role(mole_file, role_dir)
      true
    end

    templates_dir = "#{target}/templates"
    files_dir = "#{target}/files"

    # FIXME: Check for overwrites of files from #make_file_role
    Dir["#{source}/*"].grep_v { |f| f == use_file }.each { |f|
      case f
        when File.file?(f)
          if f =~ /\.j2$/
            mkdir(templates_dir)
            cp(f, templates_dir)
          else
            mkdir_p(files_dir)
            cp(f, files_dir)
          end
        when File.directory?(f)
          cp(f, target)
      else
        raise Error, "Can't copy #{f}"
      end
    }

    true
  end

private
  # Wrapper methods
  def mkdir(d)
    FileUtils.mkdir_p(d) rescue SystemCallError raise Error.new("Can't create directory #{d}")
  end

  def cp(s,t)
    FileUtils.cp_r(s,t) rescue SystemCallError raise Error.new("Can't copy #{s}")
  end

  # source is a single-file role and target is the role directory
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

    (sections.to_a + [["meta", meta]]).each { |section, lines|
      next if lines.empty? && section != "meta"
      next if lines.all? { |l| l =~ /^\s*$/ }
      dir = "#{target}/#{section}"
      file = "#{dir}/main.yml"

      File.open("#{dir}/main.yml", "w") { |f|
        f.puts "---" if section != "meta"
        unindent(lines).each { |l| f.puts l }
      }
    }
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



