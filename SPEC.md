# ansible-make-role

## Moles Directory Structure

The moles/ directory contains role definitions. A role definition is either a
.yml file, or a directory with a make.yml file and optionally other files and
sub-directories. The make.yml file can be replaced with a file with the name of
the directory plus an .yml extension

Example:

```yaml
moles/
  a-single-file-role.yml

  a-directory-role/
    make.yml
    some-file
    some-template.j2
    some-subdirectory/
      ...

  a-named-role/
    a-named-role.yml
    ...
```

