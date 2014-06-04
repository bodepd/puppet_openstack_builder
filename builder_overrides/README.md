This builder overrides directory is intended to store
things that can override core files out of the openstack
builder.

This currently includes two thigns:

- Vagrantfile - provide additional roles needed by vagrant here
- Puppetfile  - use this to specify new modules or override existing
                modules.
