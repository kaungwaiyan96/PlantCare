require 'xcodeproj'

project_path = 'PlantCare.xcodeproj'

# Remove existing project if any
if File.exist?(project_path)
  FileUtils.rm_rf(project_path)
end

project = Xcodeproj::Project.new(project_path)

# Main App Target
app_target = project.new_target(:application, 'PlantCare', :ios, '17.0')
app_target.build_configurations.each do |config|
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['PRODUCT_NAME'] = 'PlantCare'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.plantcare.PlantCare'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  config.build_settings['INFOPLIST_KEY_NSCameraUsageDescription'] = 'PlantCare needs camera access to photograph and identify plants.'
  config.build_settings['INFOPLIST_KEY_NSPhotoLibraryUsageDescription'] = 'PlantCare needs photo library access to select plant pictures for identification.'
  config.build_settings['INFOPLIST_KEY_UILaunchScreen_Generation'] = 'YES'
  config.build_settings['CURRENT_PROJECT_VERSION'] = '1'
  config.build_settings['MARKETING_VERSION'] = '1.0'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1'
  config.build_settings['ENABLE_PREVIEWS'] = 'YES'
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  config.build_settings['SWIFT_EMIT_LOC_STRINGS'] = 'YES'
end

# Tests Target
test_target = project.new_target(:unit_test_bundle, 'PlantCareTests', :ios, '17.0')
test_target.add_dependency(app_target)
test_target.build_configurations.each do |config|
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['PRODUCT_NAME'] = 'PlantCareTests'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.plantcare.PlantCareTests'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  config.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/PlantCare.app/PlantCare'
  config.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
end

# Add source files
app_group = project.main_group.find_subpath('PlantCare', true)
test_group = project.main_group.find_subpath('PlantCareTests', true)

Dir.glob('PlantCare/**/*.swift').each do |file_path|
  file_ref = app_group.new_file(File.expand_path(file_path))
  app_target.add_file_references([file_ref])
end

Dir.glob('PlantCare/**/*.{png,jpg,jpeg,xcassets}').each do |file_path|
  file_ref = app_group.new_file(File.expand_path(file_path))
  app_target.resources_build_phase.add_file_reference(file_ref)
end

Dir.glob('PlantCareTests/**/*.swift').each do |file_path|
  file_ref = test_group.new_file(File.expand_path(file_path))
  test_target.add_file_references([file_ref])
end

# Recreate schemes
project.recreate_user_schemes

project.save
puts "Successfully generated PlantCare.xcodeproj with #{app_target.source_build_phase.files.count} app files and #{test_target.source_build_phase.files.count} test files!"
