
action :configure do
  template new_resource.filename do
    variables profile: {
      path: new_resource.path,
      append_scripts: new_resource.append_scripts
    }

    if new_resource.template
      new_resource.template.each do |attr, value|
        send attr, value
      end
    else
      source 'profile.erb'
    end
  end
end
