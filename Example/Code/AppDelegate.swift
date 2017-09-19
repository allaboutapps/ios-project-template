import UIKit

struct Foo: Decodable {
    let foo: String
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Appearance.setup()
        
        APIClient.request(.postLogin(username: "Max", password: "Test"))
            .parseAPIResponseType(Foo.self)
            .startWithResult { (result) in
                if let error = result.error {
                    print("error: \(error.localizedDescription)")
                } else if let foo = result.value {
                    print("value: \(foo)")
                }
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}
