import UIKit
import Flutter
import native_state

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"Notification"]) {
      [[UIApplication sharedApplication] cancelAllLocalNotifications]
      [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"Notification"]
    }
    if (@available(iOS 10.0, *)) {
      [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication, didDecodeRestorableStateWith coder: NSCoder) {
    StateStorage.instance.restore(coder: coder)
  }

  override func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder) {
    StateStorage.instance.save(coder: coder)
  }

  override func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
    return true
  }

  override func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
    return true
  }
}
