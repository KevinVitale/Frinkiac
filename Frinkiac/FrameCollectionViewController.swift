#if os(iOS)
import UIKit

// MARK: - Frame Collection View Controller -
//------------------------------------------------------------------------------
public class FrameCollectionViewController: UICollectionViewController, FrameImageDelegate {
    public enum FrameImageRatio {
        case square
        case `default`
    }

    // MARK: - Public -
    //--------------------------------------------------------------------------
    public weak var delegate: FrameCollectionDelegate? = nil
    public var images: [FrameImage] = [] {
        didSet {
            reload()
        }
    }
    public final var hasImages: Bool {
        return !images.isEmpty
    }
    public var preferredFrameImageRatio: FrameImageRatio = .square

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

    // MARK: - Item Size -
    //--------------------------------------------------------------------------
    public final func imageSize(for frameImage: FrameImage?, `in` collectionView: UICollectionView) -> CGSize {
        let maxWidth = collectionView.maxWidth(for: itemsPerRow)

        guard let frameImage = frameImage
            , let image = frameImage.image
            , preferredFrameImageRatio == .`default` else {
                let itemWidth = (maxWidth / CGFloat(itemsPerRow))
                return CGSize(width: itemWidth, height: itemWidth)
        }

        let imageRatio = maxWidth / image.size.width / max(1.0, CGFloat(itemsPerRow))
        let imageWidth = image.size.width * imageRatio
        let imageHeight = image.size.height * imageRatio

        return CGSize(width: imageWidth, height: imageHeight)
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
    public func frame(_ frame: FrameImage, didUpdateImage image: UIImage) {
        reload()
    }

    public func frame(_ frame: FrameImage, didUpdateMeme meme: UIImage) {
    }
}

// MARK: - Extension, Data Source -
//------------------------------------------------------------------------------
extension FrameCollectionViewController {
    public final override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public final override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    public var itemsPerRow: Int {
        return 3
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return imageSize(for: images[indexPath.row], in: collectionView)
    }
}

// MARK: - Frame Collection Delegate -
//------------------------------------------------------------------------------
public protocol FrameCollectionDelegate: class {
    func frameCollection(_ : FrameCollectionViewController, didSelect frameImage: FrameImage)
}

// MARK: - Extension, Collection View
//------------------------------------------------------------------------------
extension UICollectionView {
    public final func maxWidth(for itemCount: Int) -> CGFloat {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("Layout must be an instance of \(UICollectionViewFlowLayout.self)")
        }
        return frame.width
            .subtracting(flowLayout.sectionInset.left)
            .subtracting(flowLayout.sectionInset.right)
            .subtracting(flowLayout.minimumInteritemSpacing * (max(1.0, CGFloat(itemCount).subtracting(1.0))))
    }

    public final func numberOfItems(in section: Int = 0) -> Int {
        return dataSource?.collectionView(self, numberOfItemsInSection: section) ?? 0
    }
}


// MARK: - Frame Meme Collection -
//------------------------------------------------------------------------------
/**
 A frame collection view controller that will reload when a frame image `meme`
 is downloaded.
*/
public class FrameMemeCollection: FrameCollectionViewController {
    public override func dequeue(frameCellAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: FrameImageCell.cellIdentifier, for: indexPath) as! FrameImageCell

        // Sets the image depending on the state of `meme`
        //----------------------------------------------------------------------
        let frame = images[indexPath.row]
        cell.imageView.image = frame.meme ?? frame.image

        return cell
    }

    public override func frame(_: FrameImage, didUpdateMeme meme: ImageType) {
        reload()
    }
}
#endif
