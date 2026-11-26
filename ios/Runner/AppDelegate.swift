import AVFoundation
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "vide/camera_permissions",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "status":
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
          result("granted")
        case .notDetermined:
          result("notDetermined")
        case .denied:
          result("permanentlyDenied")
        case .restricted:
          result("restricted")
        @unknown default:
          result(FlutterError(
            code: "CameraPermissionStatusUnavailable",
            message: "The camera permission state is unknown.",
            details: nil
          ))
        }
      case "preparePermissionRequest":
        result(nil)
      case "openSettings":
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
          result(false)
          return
        }
        UIApplication.shared.open(settingsUrl) { result($0) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
