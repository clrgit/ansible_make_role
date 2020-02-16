require "ansible_make_role/version"

require "fileutils"

module AnsibleMakeRole
  class Error < StandardError; end
  class CantReadFile < Error; end
  class CantWriteDir < Error; end

  def self.make(source, target_dir = File.dirname(source), verbose: false, force: false)
    # tests require directory to be checked before file
    File.directory?(target_dir) && File.writable?(target_dir) or raise CantWriteDir.new(target_dir)
    File.file?(source) && File.readable?(source) or raise CantReadFile.new(source)

    meta_yml = "#{target_dir}/meta/main.yml"
    if force || !File.exist?(meta_yml) || File.mtime(source) > File.mtime(meta_yml)
      compile_role(source, target_dir, verbose: verbose)
    else
      puts "#{target_dir} is up to date" if verbose
    end
  end

private
  # source is a file, target is a directory. Target can be nil and defaults to
  # dirname of source
  def self.compile_role(source, target, verbose: false)
    meta = []
    sections = {
      "defaults" => [],
      "vars" => [],
      "tasks" => [],
      "handlers" => []
    }
    current_section = meta

    puts "Parsing #{source}" if verbose
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
  def self.unindent(lines)
    line = lines.find { |l| l !~ /^\s*#/ && l !~ /^\s*$/ }
    return lines if line.nil?
    line =~ /^(\s*)/
    prefix = $1.dup
    lines.map { |l| l.sub(/^#{prefix}/, "") }
  end  
end



