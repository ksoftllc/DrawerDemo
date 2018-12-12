//
//  DrawerViewController.swift
//

import UIKit

private enum DrawerPosition {
    case open, closed
}

protocol DrawerView {
    func configureDrawer(containerView: UIView, overlaidView: UIView)
}

private enum DrawerConstants {
    static let snapVelocity:CGFloat = 900
    static let animationDuration: TimeInterval = 0.5
    static let initialSpringVelocity: CGFloat = 0.5
    static let dampingRatio: CGFloat = 0.8
}

class DrawerViewController: UIViewController {

    @IBOutlet var drawerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var currentDrawerY: CGFloat = 0
    
    private var drawerParentView: UIView!
    private var overlaidByDrawerView: UIView!
    private var drawerAtTopFrame: CGRect!
    private var drawerAtBottomFrame: CGRect!
    private var drawerTopY: CGFloat!
    private var drawerMiddleY: CGFloat!
    private var drawerBottomY: CGFloat!
    private var drawerBottomPositionOffset: CGFloat!
    private var drawerPosition: DrawerPosition = .closed //choose inital position of the sheet
    
    //tableview variables
    var listItems: [Any] = []
    var headerItems: [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard self.drawerParentView != nil else {
            fatalError("must call configureDrawer before view loads")
        }
        
        configurePanGestures()
    }
    
    override func viewDidLayoutSubviews() {
        drawerAtTopFrame = overlaidByDrawerView.frame
        view.frame = CGRect(x: 0, y: 0, width: drawerAtTopFrame.width, height: drawerAtTopFrame.height)
        drawerTopY = drawerAtTopFrame.origin.y
        drawerMiddleY = drawerTopY + drawerAtTopFrame.height * 0.5
        drawerBottomY = drawerTopY + (drawerAtTopFrame.height - searchBar.frame.height)
        drawerAtBottomFrame = CGRect(x: drawerAtTopFrame.minX, y: drawerBottomY, width: drawerAtTopFrame.width, height: drawerAtTopFrame.height)
        
        switch drawerPosition {
        case .open:
            self.currentDrawerY = drawerTopY
        case .closed:
            self.currentDrawerY = drawerBottomY
        }
        moveDrawerTo(position: drawerPosition)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch self.drawerPosition {
        case .open:
            drawerParentView.frame = drawerAtTopFrame
        case .closed:
            drawerParentView.frame = drawerAtBottomFrame
        }
    }
    
}

extension DrawerViewController: DrawerView {
    
    func configureDrawer(containerView: UIView, overlaidView: UIView) {
        self.drawerParentView = containerView
        self.overlaidByDrawerView = overlaidView
        self.drawerAtTopFrame = overlaidView.frame
    }
    
}

private extension DrawerViewController {
    
    func adjustDrawerFrame(_ yOffset: CGFloat) {
        let offset: CGFloat
        switch self.drawerPosition {
        case .open:
            offset = yOffset
        case .closed:
            offset = drawerBottomY - drawerTopY + yOffset
        }
        //don't offset past zero to stay within container view
        drawerParentView.frame = drawerAtTopFrame.offsetBy(dx: 0, dy: max(0, offset))
    }
    
    func animateToNextPosition(_ position: DrawerPosition) {
        drawerPosition = position
        drawerView.isUserInteractionEnabled = false
        let animations = {
            self.moveDrawerTo(position: position)
        }
        
        let onCompletion = { (_: Bool) in
            self.drawerView.isUserInteractionEnabled = true
            self.currentDrawerY = self.drawerParentView.frame.minY
        }
        
        UIView.animate(withDuration: DrawerConstants.animationDuration,
                       delay: 0,
                       usingSpringWithDamping: DrawerConstants.dampingRatio,
                       initialSpringVelocity: DrawerConstants.initialSpringVelocity,
                       options: .curveEaseInOut,
                       animations: animations,
                       completion: onCompletion)
    }
    
    func configurePanGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDrawerPan(_:)))
        self.drawerView.addGestureRecognizer(panGesture)
        self.tableView.panGestureRecognizer.addTarget(self, action: #selector(handleTableViewPan(_:)))
    }
    
    @objc func handleDrawerPan(_ recognizer: UIPanGestureRecognizer) {
        let dy = recognizer.translation(in: self.drawerParentView).y
        switch recognizer.state {
        case .changed:
            adjustDrawerFrame(dy)
        case .failed, .ended, .cancelled:
            currentDrawerY = drawerParentView.frame.minY
            animateToNextPosition(nextPosition(recognizer: recognizer))
        default:
            break
        }
    }
    
    @objc func handleTableViewPan(_ recognizer: UIPanGestureRecognizer){
        if tableView.atTop {
            handleDrawerPan(recognizer)
        }
        //else allow table to scroll
    }
    
    func moveDrawerTo(position: DrawerPosition) {
        switch position {
        case .open:
            self.drawerParentView.frame = self.drawerAtTopFrame
        case .closed:
            self.drawerParentView.frame = self.drawerAtBottomFrame
        }
    }
    
    func nextPosition(recognizer: UIPanGestureRecognizer) -> DrawerPosition {
        let velY = recognizer.velocity(in: self.view).y
        let belowMidpoint = currentDrawerY > drawerMiddleY
        
        switch (velY, belowMidpoint) {
        case (let vel, _) where vel < -DrawerConstants.snapVelocity:
            return .open
        case (let vel, _) where vel > DrawerConstants.snapVelocity:
            return .closed
        case (_, false):
            return .open
        case (_, true):
            return .closed
        }
    }
    
}

extension DrawerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleTableCell", for: indexPath) as! SimpleTableCell
        let model = SimpleTableCellViewModel(image: UIImage(named: "bandcamp_icon"), title: "Title \(indexPath.row)", subtitle: "Subtitle \(indexPath.row)")
        cell.configure(model: model)
        return cell
    }
    
}

fileprivate extension UITableView {
    
    var atTop: Bool {
        return self.contentOffset.y <= 0
    }
    
}
