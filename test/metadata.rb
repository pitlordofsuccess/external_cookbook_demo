name 'test'
maintainer 'Nathan Cerny'
maintainer_email 'ncerny@gmail.com'
license 'Apache-2.0'
description 'Installs/Configures test'
long_description 'Installs/Configures test'
version '0.1.1'
chef_version '>= 12.1' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/test/issues'

# The `source_url` points to the development reposiory for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/test'

depends 'chef_client_updater'
