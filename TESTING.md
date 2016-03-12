Testing
=======

Preparation
-----------

Install Chef DK by following https://docs.chef.io/install_dk.html.

Ensure both bin dirs from chefdk take precedence in your `$PATH`:

    $ export PATH="/opt/chefdk/bin:/opt/chefdk/embedded/bin:$PATH"

List the rake tasks available:

    $ rake -T

Install the gem dependencies and cookbooks:

    $ rake prepare

All
---

Run all tests, write a symphony while you wait:

    $ rake test

Style
-----

Rubocop and Foodcritic:

    $ rake style

Unit
----

Currently ChefSpec only:

    $ rake unit

Integration
-----------

    $ rake kitchen:all

See `.kitchen.yml` and `test/` directory for details.

Additional Information
----------------------

Rake is used as a wrapper, providing quick commands to do key tests. Feel free
to use all the different methods provided by Chef DK and the development files
included in the cookbook.

These testing methods are also supported, although appear outdated at this time:

https://github.com/chef-cookbooks/community_cookbook_documentation/blob/master/TESTING.MD
