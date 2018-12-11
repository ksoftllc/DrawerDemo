//
//  DrawerViewController.swift
//

import UIKit

private enum DrawerPosition {
    case open, closed
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
    private var drawerFrame: CGRect!
    private var drawerTopY: CGFloat!
    private var drawerMiddleY: CGFloat!
    private var drawerBottomY: CGFloat!
    private var drawerBottomPositionOffset: CGFloat!
    private var drawerPosition: DrawerPosition = .open //choose inital position of the sheet
    
    //tableview variables
    var listItems: [Any] = []
    var headerItems: [Any] = []
    
    func configureDrawer(containerView: UIView, overlaidView: UIView) {
        self.drawerParentView = containerView
        self.overlaidByDrawerView = overlaidView
        self.drawerFrame = overlaidView.frame
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard self.drawerParentView != nil else {
            fatalError("must call configureDrawer before view loads")
        }
        
        configurePanGestures()
    }
    
    override func viewDidLayoutSubviews() {
        self.drawerFrame = overlaidByDrawerView.frame
        self.drawerTopY = drawerFrame.origin.y
        self.drawerMiddleY = drawerTopY + drawerFrame.height * 0.5
        self.drawerBottomY = drawerTopY + (drawerFrame.height - searchBar.frame.height)
        self.currentDrawerY = drawerBottomY
    }
    
    fileprivate func configurePanGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.drawerView.addGestureRecognizer(panGesture)
        self.tableView.panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        drawerParentView.frame = drawerFrame.offsetBy(dx: 0, dy: 0)
    }
    

    @objc func handlePan(_ recognizer: UIPanGestureRecognizer){
        
        let dy = recognizer.translation(in: self.drawerParentView).y
        switch recognizer.state {
        case .changed:
            if self.tableView.contentOffset.y > 0 { //in table
                return
            }
            
            if self.tableView.contentOffset.y <= 0 { //top of table
                switch self.drawerPosition {
                case .open:
                    drawerParentView.frame = drawerFrame.offsetBy(dx: 0, dy: dy)
                case .closed:
                    let offset = drawerBottomY - drawerTopY + dy
                    drawerParentView.frame = drawerFrame.offsetBy(dx: 0, dy: offset)
                }
            }
            
            if self.drawerParentView.frame.minY > drawerTopY {
                self.tableView.contentOffset.y = 0
            }
        case .failed, .ended, .cancelled:
            if (self.tableView.contentOffset.y > 0) {//inside the table
                return
            }
            
            self.currentDrawerY = self.drawerParentView.frame.minY
            self.drawerView.isUserInteractionEnabled = false
            self.drawerPosition = self.nextLevel(recognizer: recognizer)

            UIView.animate(withDuration: DrawerConstants.animationDuration,
                           delay: 0,
                           usingSpringWithDamping: DrawerConstants.dampingRatio,
                           initialSpringVelocity: DrawerConstants.initialSpringVelocity,
                           options: .curveEaseInOut,
                           animations: {
                switch self.drawerPosition {
                case .open:
                    self.drawerParentView.frame = self.drawerFrame
                case .closed:
                    self.drawerParentView.frame =
                        CGRect(x: 0, y: self.drawerBottomY, width: self.drawerFrame.width, height: self.drawerFrame.height)
                }
            }) { (_) in //upon completion
                self.drawerView.isUserInteractionEnabled = true
                self.currentDrawerY = self.drawerParentView.frame.minY
            }
        default:
            break
        }
    }
    
    fileprivate func atTopOfTable() -> Bool {
        return tableView.contentOffset.y == 0
    }
    
    fileprivate func nextLevel(recognizer: UIPanGestureRecognizer) -> DrawerPosition {
        let velY = recognizer.velocity(in: self.view).y
        if velY < -DrawerConstants.snapVelocity {
            return .open
        } else if velY > DrawerConstants.snapVelocity {
            return atTopOfTable() ? .closed : .open
        } else {
            if currentDrawerY > drawerMiddleY {
                return .closed
            } else {
                return .open
            }
        }
    }
}

extension DrawerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleTableCell", for: indexPath) as! SimpleTableCell
        let model = SimpleTableCellViewModel(image: UIImage(named: "bandcamp_icon"), title: "Title \(indexPath.row)", subtitle: "Subtitle \(indexPath.row)")
        cell.configure(model: model)
        return cell
    }
}

