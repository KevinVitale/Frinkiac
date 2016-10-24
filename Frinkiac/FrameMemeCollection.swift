#if os(iOS)
import UIKit
    
// MARK: - Frame Meme Controller -
//------------------------------------------------------------------------------
/**
 A frame collection view controller that updates each frame image's caption when
 `images` is set.
*/
public class FrameMemeController<M: MemeGenerator>: FrameCollectionViewController<M> {
    public override var images: [FrameImage<M>] {
        didSet {
            images.forEach {
                $0.caption { [weak self] _ in
                    self?.reload()
                }
            }
        }
    }
}
#endif
