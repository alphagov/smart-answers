# Checksums

## Updating checksums

Each smart answer flow has a corresponding checksums file at
`test/data/NAME-files.yml` for a smart answer called NAME. This file
contains a list of the files that relate to this smart answer, along
with a md5 hash of the file contents.

By tracking the related files, and their checksums, it is possible to
check if a smart answer would be affected by a change by checking the
checksums files that would be affected.

For example, if you make a code change, expecting to impact just one
smart answer, by updating all the checksum files and then checking
that the only one that has changed is for the relevant smart answer,
this can help to check that no unintended side effects have occurred.

### Updating all the checksum values

The following command will update all the checksum values for all
smart answer flows.

```bash
rake checksums:update
```

### Updating checksum values for specific smart answers

The update rake task can be given the names of the smart answers to
update, in which case only those will be updated.

```bash
rake checksums:update[marriage-abroad,check-uk-visa]
```

## Generating and altering checksum files

### For a new smart answer

To generate the checksum file for a new smart answer flow, run:

```bash
rake checksums:add_files[NAME]
```

If the smart answer has additional files that are not included by
default, these can be specified after the name. Glob patterns are
supported, e.g. you can use `foo/*` to select the files in a
directory.

```bash
rake checksums:add_files[NAME,foo,bar/*]
```

### Adding files for an existing smart answer

To add files to the checksums file for an existing smart answer flow,
run `checksums:add_files` specifying the name of the smart answer
flow, and the files you wish to add. Glob patterns are supported. For
example:

```bash
rake checksums:add_files[marriage-abroad,foo,bar/*]
```
