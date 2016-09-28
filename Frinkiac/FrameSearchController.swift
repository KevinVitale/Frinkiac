#if os(iOS)
import UIKit

// MARK: - Frame Search Controller -
//------------------------------------------------------------------------------
public final class FrameSearchController: UIViewController {
    // MARK: - Private -
    //--------------------------------------------------------------------------
    private var searchController: UISearchController! = nil
    private var searchBar: UISearchBar! {
        return searchController.searchBar
    }

    
    // MARK: - Public -
    //--------------------------------------------------------------------------
    public private(set) var searchProvider: FrameSearchProvider!
    
    // MARK: - View Lifecycle -
    //--------------------------------------------------------------------------
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .simpsonsYellow

        // Search Controller
        //----------------------------------------------------------------------
        let frameController = FrameCollectionViewController()
        searchController = UISearchController(searchResultsController: frameController)
        searchController.searchResultsUpdater = self
        searchController.delegate = self

        // Search Bar
        //----------------------------------------------------------------------
        view.addSubview(searchController.searchBar)

        // Search Provider
        //----------------------------------------------------------------------
        searchProvider = FrameSearchProvider {
            let images = $0.map { FrameImage($0, delegate: frameController) }
            frameController.images = images
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
