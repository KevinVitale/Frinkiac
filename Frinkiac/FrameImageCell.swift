#if os(iOS)
import UIKit

// MARK: - Frame Image Cell -
//------------------------------------------------------------------------------
class FrameImageCell: UICollectionViewCell {
    // MARK: - Public -
    //--------------------------------------------------------------------------
    /// - parameter imageView: The image view.
    var imageView: UIImageView = UIImageView(frame: .zero)

    // MARK: - Reuse Lifecycle -
    //--------------------------------------------------------------------------
    override func layoutSubviews() {
        super.layoutSubviews()

        // Content View
        //----------------------------------------------------------------------
        contentView.backgroundColor = .simpsonsFleshy
        contentView.addSubview(imageView)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 4.0
        contentView.layer.borderWidth = 2.0
        contentView.layer.borderColor = UIColor.white.cgColor
        
        // Image View
        //----------------------------------------------------------------------
        imageView.frame = contentView.frame
        imageView.contentMode = .scaleAspectFill
        imageView.autoresizingMask = [
              .flexibleWidth
            , .flexibleHeight
        ]
    }

    // MARK: - Identifier -
    //--------------------------------------------------------------------------
    static let cellIdentifier: String = "\(FrameImageCell.self)"
}
#endif
