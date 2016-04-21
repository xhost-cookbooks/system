# rubocop:disable Style/AccessorMethodName
if defined?(ChefSpec)
  ChefSpec.define_matcher :system_timezone

  def set_system_timezone(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:system_timezone, :set, resource_name)
  end

  ChefSpec.define_matcher :system_environment

  def configure_system_environment(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:system_environment, :configure, resource_name)
  end

  ChefSpec.define_matcher :system_hostname

  def set_system_hostname(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:system_hostname, :set, resource_name)
  end

  ChefSpec.define_matcher :system_packages

  def install_system_packages(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:system_packages, :install, resource_name)
  end

  def uninstall_system_packages(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:system_packages, :uninstall, resource_name)
  end

  ChefSpec.define_matcher :system_profile

  def configure_system_profile(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:system_profile, :configure, resource_name)
  end
end
