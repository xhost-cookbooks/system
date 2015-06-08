
actions [:configure]
default_action :configure

attribute :filename, name_attribute: true, kind_of: String, default: '/etc/profile'

attribute :template, kind_of: Hash, default: nil

attribute :path, kind_of: Array, default: []

attribute :append_scripts, kind_of: Array, default: []
