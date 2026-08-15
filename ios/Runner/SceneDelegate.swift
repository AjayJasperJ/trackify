import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

  private func log(_ message: String) {
    NSLog("[Trackify] %@", message)
  }

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    log("scene willConnectTo session=\(session.persistentIdentifier)")
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    log("scene willConnectTo END")
  }
}