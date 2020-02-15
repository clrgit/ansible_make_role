require 'open3'

require 'helpers/role_helper.rb'

class Exe
  attr_reader :command
  attr_accessor :stdin
  attr_reader :stdout, :stderr, :status

  def initialize(command = nil)
    @command = command
  end

  def call(args = nil, stdin: @stdin) # args is a string. Like '-v -q -r')
    stdout_str, stderr_str, status_obj = Open3.capture3([command, args].compact.join(' '), stdin_data: stdin)
    @stdout = stdout_str.split("\n")
    @stderr = stderr_str.split("\n")
    @status = status_obj.exitstatus
    return self
  end
end

describe "ansible-make-role command" do
  let(:stdin) { "" }
  let(:stdout) { exe.stdout }
  let(:stderr) { exe.stderr }
  let(:status) { exe.status }
  let(:exe) { Exe.new("exe/ansible-make-role") }

  around(:each) { |example|
    mktemp
    make_make_yml <<~HERE
      dependencies:
        - somerole
    HERE
    example.run
    rmtemp
  }

  context "options" do
    context "--version" do
      it "prints name and version" do
        exe.call("--version")
        expect(stdout).to eq ["ansible-make-role #{AnsibleMakeRole::VERSION}"]
      end
    end

    context "--verbose" do
      it "reports progress for updated roles" do
        exe.call("--verbose #{TMPDIR}")
        expect(stdout).to eq ["Parsing #{TMPDIR}/make.yml", "Create #{TMPDIR}/meta/main.yml"]
      end

      it "reports no change for up to date roles" do
        exe.call("#{TMPDIR}")
        exe.call("--verbose #{TMPDIR}")
        expect(stdout).to eq ["#{TMPDIR} is up to date"]
      end
    end

    context "--force" do
      it "also recompile up to date roles" do
        exe.call("--force --verbose #{TMPDIR}")
        expect(stdout).to eq ["Parsing #{TMPDIR}/make.yml", "Create #{TMPDIR}/meta/main.yml"]
      end
    end
  end

  it "fails if directory is not writable" do
    FileUtils.rm_rf(TMPDIR)
    exe.call(TMPDIR)
    expect(status).to eq 1
    expect(stderr).to include("ansible-make-role: Can't write to directory #{TMPDIR}")
  end

  it "fails if make.yml is not readable" do
    FileUtils.rm(make_yml_path)
    exe.call(TMPDIR)
    expect(status).to eq 1
    expect(stderr).to include("ansible-make-role: Can't read file #{TMPDIR}/make.yml")
  end

  it "accepts multiple directory arguments" do
    exe.call("--verbose #{TMPDIR} #{TMPDIR}")
    expect(stdout).to include("Parsing #{TMPDIR}/make.yml", "#{TMPDIR} is up to date")
  end

  it "only compiles out of date roles" do
    exe.call("--verbose #{TMPDIR} #{TMPDIR}")
    expect(stdout).to include("Parsing #{TMPDIR}/make.yml", "#{TMPDIR} is up to date")
  end
end

