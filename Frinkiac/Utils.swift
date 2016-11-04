#if os(iOS)
import UIKit
    
extension UICollectionView {
    enum LayoutError: Error {
        case NotFlowLayout(UICollectionViewLayout)
    }
    
    func allowableWidth(itemsPerRow: CGFloat) throws -> CGFloat {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            throw LayoutError.NotFlowLayout(collectionViewLayout)
        }
        
        return bounds.width
            .divided(by: itemsPerRow)
            .subtracting(flowLayout.sectionInset.left)
            .subtracting(flowLayout.sectionInset.right)
            .subtracting(contentInset.left)
            .subtracting(contentInset.right)
    }
}
#endif
