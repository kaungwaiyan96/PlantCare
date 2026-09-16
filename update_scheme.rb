require 'xcodeproj'

project = Xcodeproj::Project.open('PlantCare.xcodeproj')
app_target = project.targets.find { |t| t.name == 'PlantCare' }
test_target = project.targets.find { |t| t.name == 'PlantCareTests' }

scheme = Xcodeproj::XCScheme.new
scheme.configure_with_targets(app_target, test_target)
scheme.save_as('PlantCare.xcodeproj', 'PlantCare', true)
puts "Successfully configured PlantCare scheme with Test action!"
