require 'yaml'
require 'shellopts'

require 'helpers/role_helper.rb'

describe "AnsibleMakeRole" do
  it 'has a version number' do
    expect(AnsibleMakeRole::VERSION).not_to be_nil
  end

  describe ".make_role" do
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
        # This before
        
        # After
      HERE
      expect(meta_file).to eq <<~HERE
        # This before
        
        # After
      HERE
    end
  end
end

