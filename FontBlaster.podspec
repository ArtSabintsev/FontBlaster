Pod::Spec.new do |s|
# Version
s.version       = "5.2.0"
s.swift_version = "5.3"

# Meta
s.name         = "FontBlaster"
s.summary      = "Programmatically load custom fonts into your iOS app."
s.homepage     = "https://github.com/ArtSabintsev/FontBlaster"
s.license      = "MIT"
s.authors      = { "Arthur Ariel Sabintsev" => "arthur@sabintsev.com"}
s.description  = <<-DESC
Say goodbye to importing custom fonts via property lists as **FontBlaster** automatically imports and loads all  fonts in your app's Bundle/NSBundle with one line of code.
                 DESC

# Deployment Targets
s.ios.deployment_target = "11.0"
s.osx.deployment_target = "10.10"
s.tvos.deployment_target = "11.0"

# Sources
s.source       = { :git => "https://github.com/ArtSabintsev/FontBlaster.git", :tag => s.version.to_s }
s.source_files = 'Sources/'
s.requires_arc = true

end
