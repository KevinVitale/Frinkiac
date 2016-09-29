#if os(iOS)
import UIKit

// MARK: - Frame Search Cell -
//------------------------------------------------------------------------------
class FrameSearchCell: UICollectionViewCell {
    // MARK: - Public -
    //--------------------------------------------------------------------------
    public weak var searchBar: UISearchBar? = nil

    // MARK: - View Lifecycle -
    //--------------------------------------------------------------------------
    override func layoutSubviews() {
        super.layoutSubviews()

        // Search Bar
        //----------------------------------------------------------------------
        if let searchBar = searchBar {
            contentView.addSubview(searchBar)
            searchBar.frame = contentView.frame
            searchBar.autoresizingMask = [
                .flexibleWidth
                , .flexibleHeight
            ]
            searchBar.sizeToFit()
        }
    }
    
    // MARK: - Identifier -
    //--------------------------------------------------------------------------
    static let cellIdentifier: String = "\(FrameSearchCell.self)"
}
#endif
