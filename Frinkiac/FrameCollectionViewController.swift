#if os(iOS)
import UIKit

// MARK: - Frame Collection View Controller -
//------------------------------------------------------------------------------
public final class FrameCollectionViewController: UIViewController, FrameImageDelegate {
    // MARK: - Public -
    //--------------------------------------------------------------------------
    public var images: [FrameImage] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }

    // MARK: - Outlets -
    //--------------------------------------------------------------------------
    @IBOutlet var collectionView: UICollectionView! = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    // MARK: - Computed -
    //--------------------------------------------------------------------------
    var flowLayout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }

    // MARK: - View Lifecycle -
    //--------------------------------------------------------------------------
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Root View
        //----------------------------------------------------------------------
        view.addSubview(collectionView)
        collectionView.frame = view.frame
        collectionView.backgroundColor = .simpsonsYellow

        // Collection View
        //----------------------------------------------------------------------
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.autoresizingMask = [
              .flexibleWidth
            , .flexibleHeight
        ]

        // Collection Layout
        //----------------------------------------------------------------------
        let inset: CGFloat = 8.0
        let spacing: CGFloat = 8.0
        flowLayout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = spacing

        // Cell Types
        //----------------------------------------------------------------------
        collectionView.register(FrameImageCell.self, forCellWithReuseIdentifier: FrameImageCell.cellIdentifier)
    }

    // MARK: - Dequeue Cell -
    //--------------------------------------------------------------------------
    fileprivate func dequeue(frameCellAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FrameImageCell.cellIdentifier, for: indexPath) as! FrameImageCell

        let image = images[indexPath.row].image
        cell.imageView.image = image
        return cell
    }

    // MARK: - Frame Image Delegate -
    //--------------------------------------------------------------------------
    public func frame(_ frame: FrameImage, didUpdate image: UIImage) {
        if let index = images.index(where: { $0 == frame }) {
            collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }
}

// MARK: - Extension, Data Source -
//------------------------------------------------------------------------------
extension FrameCollectionViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        return UIColor(red: 10, green: (217.0/255.0), blue: (15.0/255.0), alpha: 1.0)
    }
}
#endif
