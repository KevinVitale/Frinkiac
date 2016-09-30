#if os(iOS)
import UIKit

// MARK: - Frame Results Cell -
//------------------------------------------------------------------------------
class FrameResultsCell: UICollectionViewCell {
    // MARK: - Public -
    //--------------------------------------------------------------------------
    public weak var collectionView: UICollectionView? = nil {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView?.reloadData()
            }
        }
    }

    // MARK: - View Lifecycle -
    //--------------------------------------------------------------------------
    override func layoutSubviews() {
        super.layoutSubviews()

        // Search Bar
        //----------------------------------------------------------------------
        if let collectionView = collectionView {
            contentView.addSubview(collectionView)
            collectionView.frame = contentView.frame
            collectionView.autoresizingMask = [
                .flexibleWidth
                , .flexibleHeight
            ]
            collectionView.sizeToFit()
        }
    }

    // MARK: - Identifier -
    //--------------------------------------------------------------------------
    static let cellIdentifier: String = "\(FrameResultsCell.self)"
}
#endif
