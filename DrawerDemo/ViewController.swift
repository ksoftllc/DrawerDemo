
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var overlaidView: UIView!
    @IBOutlet weak var drawerContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DrawerViewController") as! DrawerViewController
        addChildViewController(vc)
        let drawerView = vc as DrawerView
        drawerView.configureDrawer(containerView: drawerContainer, overlaidView: overlaidView)
        drawerContainer.addSubview(vc.view)
        drawerContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            drawerContainer.topAnchor.constraint(equalTo: vc.view.topAnchor),
            drawerContainer.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
            drawerContainer.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            drawerContainer.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),

            ])
        vc.didMove(toParentViewController: self)
    }
    
    
}

