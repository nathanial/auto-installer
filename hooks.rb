require 'package'
include Logging

add_guard :command => :install do |package|
  not package.installed?
end

add_before_hook :command => :install do |package|
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

add_after_hook :command => :remove do |package|
  package.remove_directories
end

add_after_hook :command => :install do |package|
  debug "#{package.name} installs_service? #{package.installs_service?}"
  package.install_service if package.installs_service?
end

add_after_hook :command => :remove do |package|
  debug "#{package.name} installs_service? #{package.installs_service?}"
  package.remove_service if package.installs_service?
end

add_before_hook :command => :install do |package|
  debug "#{package.name} has_repository? #{package.has_repository?}"
  package.download_repository if package.has_repository?
end

add_before_hook :command => :install do |package|
  package.create_directories
end
