
import UIKit

class CommentsViewController: UIViewController, StoryboardInitialViewController {
    
    weak var coordinator: Coordinator?
    var viewModel: DetailViewModel!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var draggerView: UIView!
    private var heightConstraint: NSLayoutConstraint!
    private weak var hostingViewController: UIViewController?
    private lazy var currentHeight: CGFloat = draggerView.bounds.height

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.reloadData()
        
        let _ = viewModel.comments.observeNext { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(detectPan(sender:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        draggerView.addGestureRecognizer(panGesture)
    }
    
    func embed(in viewController: UIViewController) {
        self.hostingViewController = viewController
        viewController.view.addSubview(view)
        viewController.addChild(self)
        view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        let left = view.leftAnchor.constraint(equalTo: viewController.view.leftAnchor)
        let right = view.rightAnchor.constraint(equalTo: viewController.view.rightAnchor)
        let bottom = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        heightConstraint = view.heightAnchor.constraint(equalToConstant: draggerView.bounds.height)
        NSLayoutConstraint.activate([left, right, bottom, heightConstraint])
        didMove(toParent: viewController)
    }
    
    func show(from view: UIView) {
        self.heightConstraint.constant = view.bounds.height
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.2,
                       options: [],
                       animations: {
                        self.view.layoutIfNeeded()
        })
    }
    

    @objc
    func detectPan(sender: UIPanGestureRecognizer) {
        
        guard let hostingViewController = self.hostingViewController else { return }
        
        if sender.state == .began  {
            currentHeight = heightConstraint.constant
        }

        if sender.state == .changed {
            let drag = sender.location(in: hostingViewController.view)
            var newHeight = hostingViewController.view.bounds.height - drag.y
            
            if newHeight < draggerView.bounds.height + 20 {
                newHeight = draggerView.bounds.height
            }
            
            if newHeight > hostingViewController.view.bounds.height - 20 {
                newHeight = hostingViewController.view.bounds.height
            }
            
            heightConstraint.constant = newHeight
            
            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
        }

        if sender.state == .ended || sender.state == .cancelled {
            currentHeight = heightConstraint.constant
        }
    }
}

extension CommentsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.comments.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentCell
        cell.detailViewModel = viewModel
        cell.comment = viewModel.comments.value?[indexPath.row]
        cell.delegate = self
        return cell
    }
}

extension CommentsViewController: CommentCellDelegate {
    func requestedReply(for comment: Comment) {
        coordinator?.showReply(for: comment, viewModel: viewModel, from: self)
    }
}
