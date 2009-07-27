require 'package'

add_guard :command => :install do |package|
  not package.installed?
end

add_before_hook :command => :install do |package|
  debug "class = #{package.class}"
  debug "dependencies = #{package.class.dependency_names.join(', ')}"
  for dependency in package.class.dependency_names
    Packages.install(dependency)
  end
end
  
add_guard :command => :remove do |package|
  package.installed?
end

add_before_hook :command => :install do |package|
  package.process_support_files
end

add_before_hook :command => :install do |package|
  package.create_directories
end

add_after_hook :command => :remove do |package|
  package.remove_directories
end

