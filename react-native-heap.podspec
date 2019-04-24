require "json"

json = File.read(File.join(__dir__, "package.json"))
package = JSON.parse(json).deep_symbolize_keys

# This function creates a `HeapSettings` plist file that the Obj-C library
# uses for initialization. This is a bit of a hack, but I couldn't find a better way:
#
#    - Client apps couldn't directly access .xcconfig files from a static library.
#    - Ditto for Info.plist files, which are stripped since this library is statically linked.
#
# Instead, simply declare a new "resource bundle" containing just a single plist file with the
# settings, and load it from Obj-C.
#
# TODO: What happens if `HEAP_APP_ID` is missing?
# KLUDGE: Cocoapods loads this file in a way that doesn't allow direct method calls, so we use a Proc here instead.
write_heap_settings = Proc.new do
  # `pwd` is <client_app>/node_modules/@heap/react-native-heap, so we
  # go up three levels to fetch `HEAP_APP_ID` from the client app's root
  # directory.
  heap_app_id = File.read(File.expand_path('../../../HEAP_APP_ID')).strip

  template = File.read(File.join(__dir__, 'ios', 'HeapSettings', 'HeapSettings.plist.template'))
  output_path = File.join(__dir__, 'ios', 'HeapSettings', 'HeapSettings.plist')

  IO.write(output_path, template.gsub('__HEAP_APP_ID__', heap_app_id))
end

write_heap_settings.call

Pod::Spec.new do |s|
  s.name = "react-native-heap"
  s.version = package[:version]
  s.summary = package[:description]
  s.license = { type: "MIT" }
  s.author = package[:author]
  s.homepage = package[:homepage]
  s.source = { git: package[:repository] }
  s.source_files = "ios/**/*.{h,m}"
  s.platform = :ios, "8.0"
  s.preserve_paths = "ios/Vendor"
  s.vendored_libraries = "ios/Vendor/libHeap.a"

  # This declaration rebuilds the `HeapSettings` bundle when the `HEAP_APP_ID` file is changed.
  s.resources = 'ios/HeapSettings/HeapSettings.plist'

  s.resource_bundles = {HeapSettings: ['ios/HeapSettings/HeapSettings.plist']}

  s.dependency "React"
end
