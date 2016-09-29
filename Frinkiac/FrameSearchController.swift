#if os(iOS)
import UIKit

// MARK: - Frame Search Controller -
//------------------------------------------------------------------------------
public final class FrameSearchController: UICollectionViewController {
    // MARK: - Private -
    //--------------------------------------------------------------------------
    fileprivate var searchProvider: FrameSearchProvider! = nil

    // MARK: - Search Provider -
    //--------------------------------------------------------------------------
    private func initializeSearchProvider() {
        searchProvider = FrameSearchProvider { [weak self] in
            let images = $0.map { FrameImage($0, delegate: self?.frameController) }
            self?.frameController.images = images
        }
    }

    // MARK: - Search Controller -
    //--------------------------------------------------------------------------
    private func initializeSearchController() {
        searchController = UISearchController(searchResultsController: frameController)
        searchController.searchResultsUpdater = self
    }

    // MARK: - Public -
    //--------------------------------------------------------------------------
    public private(set) lazy var frameController = FrameCollectionViewController()
    public private(set) var searchController: UISearchController! = nil
    public var searchBar: UISearchBar! {
        return searchController.searchBar
    }

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    private func initialize() {
        initializeSearchProvider()
        initializeSearchController()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    public required init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
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
        collectionView?.register(FrameSearchCell.self, forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: FrameSearchCell.cellIdentifier)
    }

    // MARK: - Dequeue Cell -
    //--------------------------------------------------------------------------
    fileprivate func dequeueSearchCell(ofKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView?.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FrameSearchCell.cellIdentifier, for: indexPath) as! FrameSearchCell
        cell.searchBar = searchBar
        return cell
    }
}

// MARK: - Extension, Data Source -
//------------------------------------------------------------------------------
extension FrameSearchController {
    public override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return dequeueSearchCell(ofKind: kind, at: indexPath)
    }
}

// MARK: - Extension, Collection Flow Layout Delegate -
//--------------------------------------------------------------------------
extension FrameSearchController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: searchBar.frame.height)
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
#endif
