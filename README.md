# ansible-make-role

Pre-compiler that turns `make.yml` files into Ansible roles

## Usage

```shell
    ansible-make-role -f|--force -v|--verbose --version DIR...
```

`ansible-make-role` expects a `make.yml` file in each of the given directories
and generate a Ansible role from each of them. The generated files will reside
in subdirectories of the directory of the `make.yml` file but it can be
overridden by the --target-dir option. `ansible-make-role` only generates
out-of-date files unless the --force option is used. Use the `--verbose` option
to get information about the process

## Description

The `make.yml` contains a section for each generated file so that eg. the
`tasks` section becomes the `tasks/main.yml` file. The supported sections are
`defaults`, `vars`, `tasks`, and `handlers`. Anything outside of those sections
(notably `dependencies`) goes to the `meta/main.yml` file

Example:

```yaml
---
dependencies: # Goes to meta/main.yml
  - role: rails-server

defaults: # Goes to defaults/main.yml
  appl_name: "myapp"
  appl_domain: "mydomain.com"

vars: # Goes to vars/main.yml
  appl_host: "{{ appl_name}}.{{ appl_domain }}"

tasks: # Goes to tasks/main.yml
  - name: "Ensure Apache"
    yum: name=httpd state=present
    notify: restart_httpd

  - name: "Ensure Apache is enabled"
    service: name=httpd enabled=yes

handlers: # Goes to handlers/main.yml"
  - name: restart_httpd
    servide name=httpd state=restarted

  ...
```

## Options


`-f, --force`
        Re-generate all files even if not needed

`-v, --verbose`
        Report progress

`--version`
        Print version


## Installation

Install it for the current ruby using:

    $ gem install ansible_make_role

