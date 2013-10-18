default["system"]["timezone"] = 'UTC'
default["system"]["short_hostname"] = 'localhost'
default["system"]["domain"] = 'localdomain'
default["system"]["static_hosts"] = Hash.new
default["system"]["upgrade_packages"] = true

default["system"]["packages"]["install"] = []
default["system"]["packages"]["install_compile_time"] = []