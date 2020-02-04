# ansible-make-role

Pre-compiler that turns `make.yml` files into Ansible roles

## Usage

```shell
    ansible-make-role -f|--force -t|--target-dir=DIR -v|--verbose DIR...
```

`ansible-make-role` expects a `make.yml` file in each of the given directories
and generate a Ansible role definitions. The generated files will reside in
subdirectories of the `make.yml` file, but the --target-dir option creates a
role directory in the given directory and role files in subdirectories of that
`ansible-make-role` only generates out-of-date files unless the --force option
is used. Use the `--verbose` option to get information about the process

## Description

The `make.yml` contains a section for each generated file so that eg. the `tasks` section becomes the `tasks/main.yml` file. Example:

```yaml
---
dependencies:
  - role: rails-server

defaults:
  appl_name: "myapp"
  appl_domain: "mydomain.com"
  appl_git_url: "https://github.com/..."
  appl_user: "myuser"
  appl_group: "myuser"
  appl_path: "/var/www/appl"

vars:
  appl_host: "{{ appl_name}}.{{ appl_domain }}"

tasks:
  - name: "Ensure MsSQL libraries"
    import_tasks: "tasks/mssql.yml"

  - name: "Find required ruby version"
    shell: "git archive --remote={{ appl_git_url }} HEAD .ruby-version | tar x -O"
    register: find_ruby_version
    delegate_to: localhost
    failed_when: find_ruby_version.rc != 0
    changed_when: false

  ...
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ansible_make_role'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ansible_make_role

