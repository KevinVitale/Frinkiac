#if os(iOS)
import UIKit

// MARK: - Frame Search Controller -
//------------------------------------------------------------------------------
public class FrameSearchController: FrameCollectionViewController {
    // MARK: - Private -
    //--------------------------------------------------------------------------
    fileprivate var searchProvider: FrameSearchProvider! = nil
    fileprivate var footerCollection: FrameCollectionViewController? = nil
    private var searchResultsCollection: FrameCollectionViewController? {
        return searchController.searchResultsController as? FrameCollectionViewController
    }

    // MARK: - Search Provider -
    //--------------------------------------------------------------------------
    private func initializeSearchProvider(_ resultsController: FrameCollectionViewController?) {
        searchProvider = FrameSearchProvider { [weak self] in
            let images = $0.map { FrameImage($0, delegate: resultsController) }
            resultsController?.images = images
        }

        // Binds *selection*
        //----------------------------------------------------------------------
        resultsController?.delegate = self
    }

    // MARK: - Search Controller -
    //--------------------------------------------------------------------------
    fileprivate func initializeSearchController() {
        searchController = UISearchController(searchResultsController: FrameCollectionViewController())
        searchController.searchResultsUpdater = self
    }

    fileprivate func initializeResultsController() {
        footerCollection = FrameCollectionViewController()
        footerCollection?.delegate = self
        footerCollection?.flowLayout.scrollDirection = .horizontal
        footerCollection?.collectionView?.showsHorizontalScrollIndicator = false
        footerCollection?.preferredFrameImageRatio = .`default`
    }

    // MARK: - Public -
    //--------------------------------------------------------------------------
    public private(set) var searchController: UISearchController! = nil
    public var searchBar: UISearchBar! {
        return searchController.searchBar
    }

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    private func initialize() {
        initializeResultsController()
        initializeSearchController()
        initializeSearchProvider(searchResultsCollection)
        preferredFrameImageRatio = .`default`
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    public required init() {
        super.init()
        initialize()
    }

    // MARK: - View Lifecycle -
    //--------------------------------------------------------------------------
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Collection View
        //----------------------------------------------------------------------
        collectionView?.backgroundColor = .simpsonsYellow
        collectionView?.alwaysBounceHorizontal = false

        // Cell Types
        //----------------------------------------------------------------------
        collectionView?.register(FrameSearchCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: FrameSearchCell.cellIdentifier)
        collectionView?.register(FrameResultsCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: FrameResultsCell.cellIdentifier)
    }

    // MARK: - Collection Flow Layout Delegate -
    //--------------------------------------------------------------------------
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: searchBar.frame.height)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let footerCollection = footerCollection, footerCollection.hasImages {
            // TODO: Fix this! It's a smell (☠️)
            // It's causing the auto-layout log spewage
            //------------------------------------------------------------------
            let iDontKnowWhyThisBuffer: CGFloat = {
                let buffer: CGFloat = 20.0
                let isWidthSmaller = collectionView.frame.width < collectionView.frame.height
                return buffer * (isWidthSmaller ? -1.0 : 1.0)
            }()
            //------------------------------------------------------------------
            // I hate view controller rotation
            //------------------------------------------------------------------
            let footerImageHeight = footerCollection.imageSize(for: footerCollection.images.first, in: footerCollection.collectionView!).height
            let remainingHeight = max(footerImageHeight, collectionView.frame.height
                .subtracting(searchBar.frame.height)
                .subtracting(imageSize(for: images.first, in: collectionView).height)
            //------------------------------------------------------------------
            ).adding(iDontKnowWhyThisBuffer)
            //------------------------------------------------------------------
            let itemCount = (footerCollection.images ?? []).count
            return CGSize(width: collectionView.maxWidth(for: itemCount), height: remainingHeight)
        }
        return .zero
    }

    // MARK: - Dequeue Cell -
    //--------------------------------------------------------------------------
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
    fileprivate func dequeueSearchCell(ofKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView?.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FrameSearchCell.cellIdentifier, for: indexPath) as! FrameSearchCell
        cell.searchBar = searchBar
        return cell
    }

    fileprivate func dequeueResultsCell(ofKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView?.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FrameResultsCell.cellIdentifier, for: indexPath) as! FrameResultsCell
        cell.collectionView = footerCollection?.collectionView
        return cell
    }
}

// MARK: - Extension, Data Source -
//------------------------------------------------------------------------------
extension FrameSearchController {
    public override var itemsPerRow: Int {
        return 1
    }
    
    public override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionFooter:
            return dequeueResultsCell(ofKind: kind, at: indexPath)
        default:
            return dequeueSearchCell(ofKind: kind, at: indexPath)
        }
    }
}

// MARK: - Extension, Search Results Updating -
//------------------------------------------------------------------------------
extension FrameSearchController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            searchProvider.find(text)
        }
    }
}

// MARK: - Extension, Frame Collection Delegate
//------------------------------------------------------------------------------
extension FrameSearchController: FrameCollectionDelegate {
    public func frameCollection(_ frameController: FrameCollectionViewController, didSelect frameImage: FrameImage) {
        if frameController != footerCollection {
            footerCollection?.images = frameController.images
        }

        // Update the frame image delegate
        //----------------------------------------------------------------------
        frameImage.delegate = self
        images = [frameImage]

        // Disable search
        //----------------------------------------------------------------------
        searchController.isActive = false
    }
}
#endif
