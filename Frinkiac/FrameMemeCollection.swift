#if os(iOS)
import UIKit
    
// MARK: - Frame Meme Collection -
//------------------------------------------------------------------------------
/**
 A frame collection view controller that will reload when a frame image `meme`
 is downloaded.
*/
public class FrameMemeCollection: FrameCollectionViewController {
    public override func dequeue(frameCellAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: FrameImageCell.cellIdentifier, for: indexPath) as! FrameImageCell

        // Sets the image depending on the state of `meme`
        //----------------------------------------------------------------------
        let frame = images[indexPath.row]
        cell.imageView.image = frame.meme ?? frame.image

        return cell
    }

    public override func frame(_: FrameImage, didUpdateMeme meme: ImageType) {
        reload()
    }
}
#endif
