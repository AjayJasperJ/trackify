import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    NSLog("[Trackify] AppDelegate didFinishLaunchingWithOptions START")
    if let launchOptions = launchOptions {
      for (key, value) in launchOptions {
        NSLog("[Trackify] launchOption key=\(key.rawValue) value=\(value)")
      }
    } else {
      NSLog("[Trackify] launchOptions=nil")
    }

    do {
      GeneratedPluginRegistrant.register(with: self)
      NSLog("[Trackify] GeneratedPluginRegistrant.register DONE")
    } catch {
      NSLog("[Trackify] ERROR GeneratedPluginRegistrant.register FAILED: \(error.localizedDescription)")
    }

    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    NSLog("[Trackify] super.application didFinishLaunchingWithOptions END result=\(result)")
    return result
  }
}