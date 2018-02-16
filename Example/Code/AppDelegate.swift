import ReactiveSwift
import Result
import UIKit

struct Foo: Decodable {
    let foo: String
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Appearance.setup()

        APIClient.request(.postLogin(username: "max", password: "test"), type: Foo.self)
            .startWithResult { result in
                if let error = result.error {
                    print("error: \(error.localizedDescription)")
                } else if let foo = result.value {
                    print("value: \(foo)")
                }
            }

        return true
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
