import UIKit
import {{cookiecutter.projectName}}Kit

class LoginViewController: UIViewController {
    
    var onLogin: (() -> Void)?
    
    // MARK: Setup
    
    static func create() -> Self {
        return UIStoryboard(.auth).instantiateViewController(self)
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Login"
    }
    
    // MARK: Actions
    
    @IBAction func login(_ sender: Any) {
        Credentials.currentCredentials = Credentials(accessToken: "testToken", refreshToken: nil, expiresIn: nil)
        self.onLogin?()
    }
    
    deinit {
        print("deinit view controller: \(self)")
    }
    
}
