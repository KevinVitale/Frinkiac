#if os(iOS)
import UIKit

// MARK: - Frame Search Controller -
//------------------------------------------------------------------------------
public final class FrameSearchController: UICollectionViewController {
    // MARK: - Private -
    //--------------------------------------------------------------------------
    private var searchController: UISearchController! = nil
    private var searchBar: UISearchBar! {
        return searchController.searchBar
    }

    // MARK: - Search Provider -
    //----------------------------------------------------------------------
    private func initializeSearchProvider() {
        searchProvider = FrameSearchProvider { [weak self] in
            let images = $0.map { FrameImage($0, delegate: self?.frameController) }
            self?.frameController.images = images
        }
    }

    // MARK: - Public -
    //--------------------------------------------------------------------------
    public private(set) var searchProvider: FrameSearchProvider! = nil
    public private(set) lazy var frameController = FrameCollectionViewController()

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSearchProvider()
    }
    public required init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        initializeSearchProvider()
    }
    
    // MARK: - View Lifecycle -
    //--------------------------------------------------------------------------
    public override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true

        // Collection View
        //--------------------------------------------------------------------------
        collectionView?.backgroundColor = .simpsonsYellow
        collectionView?.alwaysBounceHorizontal = false

        // Cell Types
        //----------------------------------------------------------------------
        collectionView?.register(FrameSearchCell.self, forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: FrameSearchCell.cellIdentifier)

        // Search Controller
        //----------------------------------------------------------------------
        searchController = UISearchController(searchResultsController: frameController)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Layout Guide Insets
        //----------------------------------------------------------------------
        let layoutGuideInsets = UIEdgeInsets(top: topLayoutGuide.length, left: 0.0, bottom: bottomLayoutGuide.length, right: 0.0)
        collectionView?.contentInset = layoutGuideInsets
        collectionView?.scrollIndicatorInsets = layoutGuideInsets

        frameController.collectionView?.contentInset = layoutGuideInsets
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

extension FrameSearchController: UISearchControllerDelegate {
    public func willPresentSearchController(_ searchController: UISearchController) {
        print(#function)
    }

    public func didPresentSearchController(_ searchController: UISearchController) {
        print(#function)
    }

    public func willDismissSearchController(_ searchController: UISearchController) {
        print(#function)
    }

    public func didDismissSearchController(_ searchController: UISearchController) {
        print(#function)
        searchProvider.reset()
    }
}
#endif
