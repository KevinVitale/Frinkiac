#if os(iOS)
import UIKit

// MARK: - Frame Search Controller -
//------------------------------------------------------------------------------
public final class FrameSearchController<S: MemeGenerator>: FrameMemeCollection, UISearchResultsUpdating, UISearchControllerDelegate {
    // MARK: - Private -
    //--------------------------------------------------------------------------
    fileprivate var searchProvider: FrameSearchProvider<S>! = nil
    fileprivate var footerCollection: FrameCollectionViewController? = nil
    private var searchResultsCollection: FrameCollectionViewController? {
        return searchController.searchResultsController as? FrameCollectionViewController
    }

    // MARK: - Search Provider -
    //--------------------------------------------------------------------------
    private func initializeSearchProvider(_ resultsController: FrameCollectionViewController?) {
        searchProvider = FrameSearchProvider(delegate: resultsController) {
            resultsController?.images = $0
        }

        // Binds *selection*
        //----------------------------------------------------------------------
        resultsController?.delegate = self
    }

    // MARK: - Search Controller -
    //--------------------------------------------------------------------------
    fileprivate func initializeSearchController(_ controller: FrameCollectionViewController = FrameCollectionViewController()) {
        searchController = UISearchController(searchResultsController: controller)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        controller.collectionView?.keyboardDismissMode = .onDrag
    }

    fileprivate func initializeFooterCollection() {
        footerCollection = FrameFooterCollection()
        footerCollection?.delegate = self
        footerCollection?.flowLayout.scrollDirection = .horizontal
        footerCollection?.collectionView?.showsHorizontalScrollIndicator = false
        footerCollection?.preferredFrameImageRatio = .`default`
    }

    // MARK: - Public -
    //--------------------------------------------------------------------------
    public private(set) var searchController: UISearchController! = nil
    public var searchDelegate: FrameSearchControllerDelegate? = nil
    public var searchBar: UISearchBar! {
        return searchController.searchBar
    }

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    private func initialize() {
        initializeFooterCollection()
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

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let shouldActivate = searchDelegate?.frameSearchShouldActivate(self), shouldActivate == true {
            searchController.isActive = true
        }
    }

    // MARK: - Extension, Data Source -
    //------------------------------------------------------------------------------
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

    // MARK: - Extension, Search Results Updating -
    //------------------------------------------------------------------------------
    public func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            searchProvider.find(text)
        }
    }

    // MARK: - Collection Flow Layout Delegate -
    //--------------------------------------------------------------------------
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: searchBar.frame.height)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        // Return `.zero` if we don't have any images
        guard let footerCollection = footerCollection, footerCollection.hasImages else {
            return .zero
        }

        let selectedImageSize = imageSize(for: images.first, in: collectionView)
        var height = searchBar.frame.height
            .adding(selectedImageSize.height)
            .adding(flowLayout.sectionInset.top)
            .adding(flowLayout.sectionInset.bottom)

        height = max(
            collectionView.frame.height.subtracting(height),
            footerCollection.imageSize(for: footerCollection.images.first,
                                       in: footerCollection.collectionView!)
                .height
                .adding(footerCollection.flowLayout.sectionInset.top)
                .adding(footerCollection.flowLayout.sectionInset.bottom)
        )

        let size = CGSize(width: collectionView.frame.width, height: height)
        return size
    }

    // MARK: - Dequeue Cell -
    //--------------------------------------------------------------------------
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

    // MARK: - Search Controller Delegate -
    //--------------------------------------------------------------------------
    public final func didPresentSearchController(_ searchController: UISearchController) {
        searchBar.becomeFirstResponder()
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
        footerCollection?.scroll(to: frameImage)

        // Disable search
        //----------------------------------------------------------------------
        searchController.isActive = false
    }
}

public protocol FrameSearchControllerDelegate {
    func frameSearchShouldActivate<S: MemeGenerator>(_ frameSearchController: FrameSearchController<S>) -> Bool
}

// MARK: - Frame Footer Collection -
//------------------------------------------------------------------------------
fileprivate final class FrameFooterCollection: FrameMemeCollection {
    public override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return imageSize(for: images[indexPath.row], in: collectionView, itemWidthMultiplier: 1.5)
    }
}
#endif
