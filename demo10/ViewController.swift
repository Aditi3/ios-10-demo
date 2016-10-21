
import UIKit
import SharedManager

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    private lazy var sharedManager: SharedManager = {
        let appGroupName = Bundle.main.infoDictionary?["appGroupName"] as! String
        return SharedManager(forAppGroup: appGroupName)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let image = sharedManager.image(forName: "logo.png") {
            self.imageView.image = image
            let gestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(tap))
            self.imageView.addGestureRecognizer(gestureRecognizer);
            self.imageView.isUserInteractionEnabled = true;
        }
    }

    @objc func tap() {
        CleverTap.sharedInstance().recordEvent("testEvent");
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

