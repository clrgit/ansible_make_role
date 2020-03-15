require 'shellopts'

require 'helpers/role_helper.rb'

describe "AnsibleMakeRole" do
  it 'has a version number' do
    expect(AnsibleMakeRole::VERSION).not_to be_nil
  end

  describe ".force" do
    it "returns the value of the force flag" do
      expect(AnsibleMakeRole.force).to eq AnsibleMakeRole::DEFAULT_FORCE_FLAG
    end
  end

  describe ".force=" do
    it "sets the force flag" do
      AnsibleMakeRole.force = false
      expect(AnsibleMakeRole.force).to eq false
      AnsibleMakeRole.force = true
      expect(AnsibleMakeRole.force).to eq true
    end
  end

  describe ".git" do
    it "returns the value of the git flag" do
      expect(AnsibleMakeRole.git).to eq AnsibleMakeRole::DEFAULT_GIT_FLAG
    end
  end

  describe ".git=" do
    it "sets the git flag" do
      AnsibleMakeRole.git = false
      expect(AnsibleMakeRole.git).to eq false
      AnsibleMakeRole.git = true
      expect(AnsibleMakeRole.git).to eq true
    end
  end

  describe ".clean" do
    it "removes auto-generated files"
    it "returns true if any file was removed"
  end

  describe ".make" do
    around(:each) { |example|
      mktemp
      example.run
      rmtemp
    }

    def make_section_example
      make_role <<~HERE
        ---
        defaults:
          value: defaults
        vars:
          value: vars
        tasks:
          value: tasks
        handlers:
          value: handlers
        meta:
          value: meta
        anything:
          value: anything
      HERE
    end

    it "ignores up-to-date roles unless .force is true"

    it "generates a .gitignore file if .git is true"

    it "returns true if any file was generated"

    it "generates a main.yml file for each section in the make.yml file" do
      make_section_example
      expect(defaults_yml).to eq({ "value" => "defaults" })
      expect(vars_yml).to eq({ "value" => "vars" })
      expect(tasks_yml).to eq({ "value" => "tasks" })
      expect(handlers_yml).to eq({ "value" => "handlers" })
    end

    it "puts everything else into meta/main.yml" do
      make_section_example
      expect(meta_yml).to eq({ "meta" => { "value" => "meta" }, "anything" => { "value" => "anything" } })
    end

    it "preserves in-section comments" do
      make_role <<~HERE
        ---
        defaults:
          # This comment goes to defaults/main.yml
          value: defaults
        # This comment goes to defaults/main.yml
      HERE
      expect(defaults_file).to eq <<~HERE
        ---
        # This comment goes to defaults/main.yml
        value: defaults
        # This comment goes to defaults/main.yml
      HERE
    end

    it "puts all other comments in the meta file" do
      make_role <<~HERE
        ---
        # This comment goes to meta/main.yml
        defaults:
          # This goes to defaults/main.yml
          value: defaults

        anything:
          # This comment goes to meta/main.yml
          value: anything
      HERE
      expect(meta_file).to eq <<~HERE
        # This comment goes to meta/main.yml
        anything:
          # This comment goes to meta/main.yml
          value: anything
      HERE
    end

    it "preserves blank lines" do
      make_role <<~HERE
        ---
        # Before
        
        # After
      HERE
      expect(meta_file).to eq <<~HERE
        # Before
        
        # After
      HERE
    end
  end
end

