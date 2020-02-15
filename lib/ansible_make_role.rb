require "ansible_make_role/version"

require "fileutils"

module AnsibleMakeRole
  def make_role(source_dir, verbose: false, force: false)
    source = "#{source_dir}/make.yml"
    target_dir = source_dir
    File.file?(source) or ShellOpts::error "Can't read file #{source.inspect}"
    File.directory?(target_dir) or ShellOpts::error "Can't find directory #{target_dir}"

    meta_yml = "#{target}/meta/main.yml"
    if force || !File.exist?(meta_yml) || File.mtime(source) > File.mtime(meta_yml)
      compile_role(source, target, verbose: verbose)
    else
      puts "#{target} is up to date" if verbose
    end
  end

private
  # source is a file, target is a directory. Target can be nil and defaults to
  # dirname of source
  def compile_role(source, target, verbose: false)
    sections = {
      "meta" => [],
      "defaults" => [],
      "vars" => [],
      "tasks" => [],
      "handlers" => []
    }
    lines = sections["meta"]

    puts "Parsing #{source}" if verbose
    File.readlines(source).each { |line|
      line.chomp!
      next if line =~ /^---\s*$/
      if line =~ /^(\w+)\s*:/
        section = $1
        if sections.key?(section) # Built-in section?
          lines = sections[section]
        else # Everything else goes to the meta file incl. section header
          lines = sections["meta"]
          lines << line
        end
      else
        lines << line
      end
    }

    sections.each { |section, lines|
      next if lines.empty? && section != "meta"
      dir = "#{target}/#{section}"
      file = "#{dir}/main.yml"

      puts "Create #{file}" if verbose
      FileUtils.mkdir_p(dir)
      File.open("#{dir}/main.yml", "w") { |f|
        f.puts "---" if section != "meta"
        unindent(lines).each { |l| f.puts l }
      }
    }
  end

  # Unindent lines by the indentation of the first non-comment and non-blank
  # line
  def unindent(lines)
    line = lines.find { |l| l !~ /^\s*#/ && l !~ /^\s*$/ }
    return lines if line.nil?
    line =~ /^(\s*)/
    prefix = $1.dup
    lines.map { |l| l.sub(/^#{prefix}/, "") }
  end  
end
