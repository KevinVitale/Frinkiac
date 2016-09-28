#if os(iOS)
import UIKit

// MARK: - Frame Collection View Controller -
//------------------------------------------------------------------------------
public final class FrameCollectionViewController: UICollectionViewController, FrameImageDelegate {
    // MARK: - Public -
    //--------------------------------------------------------------------------
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

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Layout Guide Insets
        //----------------------------------------------------------------------
        let layoutGuideInsets = UIEdgeInsets(top: topLayoutGuide.length, left: 0.0, bottom: bottomLayoutGuide.length, right: 0.0)
        collectionView?.contentInset = layoutGuideInsets
        collectionView?.scrollIndicatorInsets = layoutGuideInsets
    }

    // MARK: - Reload -
    //--------------------------------------------------------------------------
    private func reload() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }

    // MARK: - Dequeue Cell -
    //--------------------------------------------------------------------------
    fileprivate func dequeue(frameCellAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: FrameImageCell.cellIdentifier, for: indexPath) as! FrameImageCell

        let image = images[indexPath.row].image
        cell.imageView.image = image
        return cell
    }

    // MARK: - Frame Image Delegate -
    //--------------------------------------------------------------------------
    public func frame(_ frame: FrameImage, didUpdate image: UIImage) {
        if let index = images.index(where: { $0 == frame }) {
            collectionView?.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }
}

// MARK: - Extension, Data Source -
//------------------------------------------------------------------------------
extension FrameCollectionViewController {
    public override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dequeue(frameCellAt: indexPath)
    }
}

// MARK: - Extension, Flow Layout Delegate -
//------------------------------------------------------------------------------
extension FrameCollectionViewController: UICollectionViewDelegateFlowLayout {
    private class var itemsPerRow: Int {
        return 3
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = max(CGFloat(FrameCollectionViewController.itemsPerRow), 2.0)
        let viewWidth = collectionView.frame.width
            .subtracting(flowLayout.sectionInset.left)
            .subtracting(flowLayout.sectionInset.right)
            .subtracting(flowLayout.minimumInteritemSpacing * (itemsPerRow.subtracting(1.0)))

        let itemWidth = (viewWidth / itemsPerRow)

        return CGSize(width: itemWidth, height: itemWidth)
    }
}
    
// MARK: - Extension, Simpsons Yellow -
//------------------------------------------------------------------------------
extension UIColor {
    public class var simpsonsYellow: UIColor {
        return UIColor(red: 1.0, green: (217.0/255.0), blue: (15.0/255.0), alpha: 1.0)
    }

    public class var simpsonsBlue: UIColor {
        return UIColor(red: (23.0/255.0), green: (145.0/255.0), blue: 1.0, alpha: 1.0)
    }

    public class var simpsonsPaleBlue: UIColor {
        return UIColor(red: (112.0/255.0), green: (209.0/255.0), blue: 1.0, alpha: 1.0)
    }

    public class var simpsonsPastelGreen: UIColor {
        return UIColor(red: (209.0/255.0), green: 1.0, blue: (135.0/255.0), alpha: 1.0)
    }

    public class var simpsonsFleshy: UIColor {
        return UIColor(red: (209.0/255.0), green: (178.0/255.0), blue: (112.0/255.0), alpha: 1.0)
    }
}
#endif
