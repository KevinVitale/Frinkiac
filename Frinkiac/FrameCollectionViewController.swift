#if os(iOS)
import UIKit

// MARK: - Frame Collection View Controller -
//------------------------------------------------------------------------------
public class FrameCollectionViewController: UICollectionViewController, FrameImageDelegate {
    // MARK: - Public -
    //--------------------------------------------------------------------------
    public weak var delegate: FrameCollectionDelegate? = nil
    public var images: [FrameImage] = [] {
        didSet {
            reload()
        }
    }

    // MARK: - Computed -
    //--------------------------------------------------------------------------
    var flowLayout: UICollectionViewFlowLayout {
        return collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
    }

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public required init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    // MARK: - View Lifecycle -
    //--------------------------------------------------------------------------
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Collection View
        //--------------------------------------------------------------------------
        collectionView?.backgroundColor = .simpsonsYellow
        collectionView?.alwaysBounceHorizontal = false

        // Cell Types
        //----------------------------------------------------------------------
        collectionView?.register(FrameImageCell.self, forCellWithReuseIdentifier: FrameImageCell.cellIdentifier)

        // Collection Layout
        //----------------------------------------------------------------------
        let inset: CGFloat = 4.0
        let spacing: CGFloat = 4.0
        flowLayout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = spacing
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        reload()
    }

    // MARK: - Reload -
    //--------------------------------------------------------------------------
    public func reload() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }

    // MARK: - Dequeue Cell -
    //--------------------------------------------------------------------------
    public func dequeue(frameCellAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: FrameImageCell.cellIdentifier, for: indexPath) as! FrameImageCell

        let image = images[indexPath.row].image
        cell.imageView.image = image
        return cell
    }

    // MARK: - Frame Image Delegate -
    //--------------------------------------------------------------------------
    public func frame(_ frame: FrameImage, didUpdate image: UIImage) {
        if let index = images.index(where: { $0 == frame }) {
            reload()
        }
    }
}

// MARK: - Extension, Data Source -
//------------------------------------------------------------------------------
extension FrameCollectionViewController {
    final public override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    final public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dequeue(frameCellAt: indexPath)
    }

    public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let frameImage = images[indexPath.row]
        delegate?.frameCollection(self, didSelect: frameImage)
    }
}

// MARK: - Extension, Flow Layout Delegate -
//------------------------------------------------------------------------------
extension FrameCollectionViewController: UICollectionViewDelegateFlowLayout {
    public class var itemsPerRow: Int {
        return 3
    }

    final public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = max(CGFloat(FrameCollectionViewController.itemsPerRow), 1.0)
        let viewWidth = collectionView.frame.width
            .subtracting(flowLayout.sectionInset.left)
            .subtracting(flowLayout.sectionInset.right)
            .subtracting(flowLayout.minimumInteritemSpacing * (itemsPerRow.subtracting(1.0)))

        let itemWidth = (viewWidth / itemsPerRow)

        return CGSize(width: itemWidth, height: itemWidth)
    }
}

// MARK: - Frame Collection Delegate -
//------------------------------------------------------------------------------
public protocol FrameCollectionDelegate: class {
    func frameCollection(_ : FrameCollectionViewController, didSelect frameImage: FrameImage)
}
#endif
