require 'xcodeproj'
project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the Runner target
target = project.targets.find { |t| t.name == 'Runner' }

# Find the Runner group
runner_group = project.main_group.find_subpath('Runner', false)

# Add file reference
file_path = 'GoogleService-Info.plist'
file_ref = runner_group.files.find { |f| f.path == file_path }
if file_ref.nil?
  file_ref = runner_group.new_file(file_path)
end

# Add to Resources Build Phase
resources_build_phase = target.resources_build_phase
unless resources_build_phase.files_references.include?(file_ref)
  build_file = resources_build_phase.add_file_reference(file_ref, true)
  puts "Added #{file_path} to Resources Build Phase"
else
  puts "#{file_path} already in Resources Build Phase"
end

project.save
puts "Saved project.pbxproj"
