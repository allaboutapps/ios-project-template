import UIKit
import {{cookiecutter.projectName}}Kit

class MoreViewController: UIViewController {
    
    // MARK: Setup
    
    static func create() -> Self {
        return UIStoryboard(.more).instantiateViewController(self)
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "More"
    }
    
    // MARK: Actions
    
    @IBAction func logout(_ sender: Any) {
        Credentials.currentCredentials = nil
    }
    
    deinit {
        print("deinit view controller: \(self)")
    }
    
}
