
import UIKit

class TagsCollectionViewController: UICollectionViewController, StoryboardInitialViewController {
    
    weak var coordinator: Coordinator?
    
    var tags: [Tags]? {
        didSet {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            collectionView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        }
    }
    
    private var sortedTags: [Tags]? {
        get {
            return tags?.sorted { $0.confidence! > $1.confidence! }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        let alignedFlowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        alignedFlowLayout.estimatedItemSize = CGSize(width: 100, height: 30)
        collectionView.collectionViewLayout = alignedFlowLayout
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedTags?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as! TagCollectionViewCell
        cell.tagLabel.text = sortedTags?[indexPath.row].tag
        cell.tagLabel.sizeToFit()
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TagCollectionViewCell
        guard let tag = cell.tagLabel.text else { return }
        coordinator?.pr0grammConnector.searchItems(for: [tag])
    }
}
