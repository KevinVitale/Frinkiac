#if os(iOS)
import UIKit

// MARK: - Frame Search Controller -
//------------------------------------------------------------------------------
public final class FrameSearchController<M: MemeGenerator>: FrameMemeController<M>, UISearchResultsUpdating, UISearchControllerDelegate {
    // MARK: - Private -
    //--------------------------------------------------------------------------
    private var footerCollection: FrameMemeController<M>! = nil
    private var searchController: UISearchController! = nil
    private var searchProvider: FrameSearchProvider<M>! = nil

    // MARK: - Public -
    //--------------------------------------------------------------------------
    public var searchDelegate: FrameSearchControllerDelegate? = nil
    public var searchBar: UISearchBar! {
        return searchController.searchBar
    }
    public var isActive: Bool = false {
        didSet {
            searchController.isActive = isActive
        }
    }

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public required init(_ selectionCallback: SelectionCallback? = nil) {
        super.init(selectionCallback)

        func set(frameImage: FrameImage<M>) {
            searchController.isActive = false
            images = [frameImage]
        }

        // Footer Collection
        //----------------------------------------------------------------------
        footerCollection = FrameFooterController {
            set(frameImage: $0.1)
        }
        footerCollection.itemsPerRow = 1.25
        footerCollection.flowLayout.scrollDirection = .horizontal
        footerCollection.collectionView?.showsHorizontalScrollIndicator = false
        footerCollection.preferredFrameImageRatio = .`default`

        // If 'FrameImageCell' has a shadow, this `clear` background helps.
        footerCollection.collectionView?.backgroundColor = .clear

        // Search Controller
        //----------------------------------------------------------------------
        let searchResultsController = FrameCollectionViewController<M> { [weak self] in
            self?.footerCollection.images = $0.0?.images ?? []
            set(frameImage: $0.1)
        }
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.delegate = self
        searchController.searchResultsUpdater = self

        // Search Provider
        //----------------------------------------------------------------------
        searchProvider = FrameSearchProvider() {
            searchResultsController.images = $0
        }

        // Section Inset 
        //----------------------------------------------------------------------
        let sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        flowLayout.sectionInset = sectionInset
        footerCollection.flowLayout.sectionInset = sectionInset
        searchResultsController.flowLayout.sectionInset = sectionInset
    }

    // MARK: - View Lifecyle -
    //--------------------------------------------------------------------------
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Items
        //----------------------------------------------------------------------
        preferredFrameImageRatio = .default
        itemsPerRow = 1.0

        // Flow layout
        //----------------------------------------------------------------------
        flowLayout.sectionHeadersPinToVisibleBounds = true

        // Cell Types
        //----------------------------------------------------------------------
        collectionView?.register(FrameSearchCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: FrameSearchCell.cellIdentifier)
        collectionView?.register(FrameResultsCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: FrameResultsCell.cellIdentifier)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isActive = searchDelegate?.searchShouldActivate(searchController) ?? false
    }

    // MARK: - Search Results, Updating -
    //------------------------------------------------------------------------------
    public func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            searchProvider.find(text)
        }
    }

    // MARK: - Collection View, Data Source
    //--------------------------------------------------------------------------
    public override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            return dequeueSearchCell(ofKind: kind, at: indexPath)
        default:
            return dequeueResultsCell(ofKind: kind, at: indexPath)
        }
    }

    // MARK: - Collection Flow Layout Delegate -
    //--------------------------------------------------------------------------
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: searchBar.frame.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height.multiplied(by: 0.333))
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
        cell.collectionView = footerCollection.collectionView
        return cell
    }

    // MARK: - Search Controller Delegate -
    //--------------------------------------------------------------------------
    public final func didPresentSearchController(_ searchController: UISearchController) {
        searchBar.becomeFirstResponder()
    }
}

public protocol FrameSearchControllerDelegate {
    func searchShouldActivate(_ searchController: UISearchController) -> Bool
}

// MARK: - Frame Footer Controller -
//------------------------------------------------------------------------------
fileprivate final class FrameFooterController<M: MemeGenerator>: FrameMemeController<M> {
    fileprivate override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didSelectItemAt: indexPath)
        scroll(to: frameImage(at: indexPath))
    }
}
#endif
