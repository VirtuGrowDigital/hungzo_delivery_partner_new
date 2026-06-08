import FirebaseAuth
import Flutter
import UIKit

@objc(SceneDelegate)
class SceneDelegate: FlutterSceneDelegate {
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    for urlContext in URLContexts {
      if Auth.auth().canHandle(urlContext.url) {
        return
      }
    }

    super.scene(scene, openURLContexts: URLContexts)
  }
}
