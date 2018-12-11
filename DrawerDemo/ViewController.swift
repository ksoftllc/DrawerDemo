
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var overlaidView: UIView!
    @IBOutlet weak var drawerContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BottomSheetViewController") as! DrawerViewController
        vc.configureDrawer(containerView: drawerContainer, overlaidView: overlaidView)
        drawerContainer.addSubview(vc.view)
    }
    
    
}

