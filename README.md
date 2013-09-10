Simple Puppet Forge
===================

A simple Puppet forge implementation which requires no database backend and will just read the metadata from the modules from disk instead.

Installation
------------

It requires Sinatra (at least version 1.3+). Can be run as a regular Rack application under for example Passenger.
There is a sample apache vhost configuration in the archive.

It also requires GNU tar (hopefully other variants can be supported in the future).

By default modules should be stored under `/var/lib/simple-puppet-forge/modules`. It expects the directory structure to be `user/module/user-module-version.tar.gz`.

Usage
-----

Set the `module_repository` setting in Puppet to point to your simple puppet forge instance, for example `module_repository=http://forge.example.com/`.

After that you should be able to install modules using `puppet module install` provided they exist on disk.
