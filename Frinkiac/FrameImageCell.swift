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
        
        // Shadow
        //----------------------------------------------------------------------
        let radius: CGFloat = 4.0
        let pathRect = bounds.insetBy(dx: -radius, dy: -radius)
        let path = UIBezierPath(roundedRect: pathRect
            , byRoundingCorners: .allCorners
            , cornerRadii: CGSize(width: radius, height: radius)
        )
        layer.shadowPath = path.cgPath
        layer.shadowRadius = radius.multiplied(by: 2.0)
        layer.shadowOpacity = 0.333
        layer.shadowOffset = .zero

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
