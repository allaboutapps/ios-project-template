import ReactiveSwift
import Result
import UIKit
import ExampleKit
import Firebase
import Crashlytics

struct Foo: Decodable {
    let foo: String
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Appearance.setup()
        
        // TODO: setup new Firebase project and replace GoogleService-Info.plist
        FirebaseApp.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        AppCoordinator.shared.start(window: window!)
        
        return true
    }
    
    func testRequest() {
        APIClient.request(.postLogin(username: "max", password: "test"), type: Foo.self)
            .startWithResult { result in
                if let error = result.error {
                    print("error: \(error.localizedDescription)")
                } else if let foo = result.value {
                    print("value: \(foo)")
                }
        }
    }

    func applicationWillResignActive(_: UIApplication) {
    }

    func applicationDidEnterBackground(_: UIApplication) {
    }

    func applicationWillEnterForeground(_: UIApplication) {
    }

    func applicationDidBecomeActive(_: UIApplication) {
    }

    func applicationWillTerminate(_: UIApplication) {
    }
}
