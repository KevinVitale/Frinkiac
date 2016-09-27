import PlaygroundSupport
import UIKit
import Frinkiac

PlaygroundPage.current.needsIndefiniteExecution = true


// MARK: - Simpsons Yellow -
//------------------------------------------------------------------------------
extension UIColor {
    class var simpsonsYellow: UIColor {
        return UIColor(red: 10, green: (217.0/255.0), blue: (15.0/255.0), alpha: 1.0)
    }
}

// MARK: - Extension, Download Image -
//------------------------------------------------------------------------------
extension Frame {
    typealias ImageCallback = ((() throws -> UIImage?) -> ())

    /**
     Downloads the image located at `self.imageLink`.

     - parameter callback: A callback that can receive another function
     which will return the image when executed.
     */
    fileprivate func downloadImage(_ callback: @escaping ImageCallback) {
        DispatchQueue.global().async {
            callback {
                let url = URL(string: self.imageLink)!
                let data = try Data(contentsOf: url)
                return UIImage(data: data)
            }
        }
    }
}

protocol ItemDelegate {
    associatedtype Item
    func item(_ item: Item, didUpdate image: UIImage)
}

// MARK: - Frame Model -
//------------------------------------------------------------------------------
class FrameModel: Equatable {
    // MARK: - Private -
    //--------------------------------------------------------------------------
    let frame: Frame
    
    // MARK: - Public -
    //--------------------------------------------------------------------------
    private(set) var image: UIImage? = nil

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    init<Delegate: ItemDelegate>(_ frame: Frame, delegate: Delegate) where Delegate.Item == FrameModel {
        self.frame = frame
        //----------------------------------------------------------------------
        frame.downloadImage {
            if let image = try? $0() {
                self.image = image
                DispatchQueue.main.async {
                    delegate.item(self, didUpdate: image!)
                }
            }
        }
    }

    static func ==(lhs: FrameModel, rhs: FrameModel) -> Bool {
        return lhs.frame.id == rhs.frame.id
    }
}

class FrameCell: UICollectionViewCell {
    // MARK: - Public -
    //--------------------------------------------------------------------------
    /// - parameter imageView: The image view.
    var imageView: UIImageView = UIImageView(frame: .zero)

    // MARK: - Reuse Lifecycle -
    //--------------------------------------------------------------------------
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        contentView.addSubview(imageView)

        // View
        //----------------------------------------------------------------------
        clipsToBounds = true
        layer.cornerRadius = 4.0
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.white.cgColor

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
    static let cellIdentifier: String = "\(FrameCell.self)"
}

// MARK: - Frame Collection View Controller -
//------------------------------------------------------------------------------
class FrameCollectionViewController: UIViewController, ItemDelegate {
    // MARK: - Aliases -
    //--------------------------------------------------------------------------
    typealias Item = FrameModel
    
    // MARK: - Public -
    //--------------------------------------------------------------------------
    var items: [Item] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }

    // MARK: - Outlets -
    //--------------------------------------------------------------------------
    @IBOutlet var collectionView: UICollectionView! = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    // MARK: - Computed -
    //--------------------------------------------------------------------------
    var flowLayout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }

    // MARK: - View Lifecycle -
    //--------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        // Root View
        //----------------------------------------------------------------------
        view.addSubview(collectionView)
        collectionView.frame = view.frame
        collectionView.backgroundColor = .simpsonsYellow

        // Collection View
        //----------------------------------------------------------------------
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.autoresizingMask = [
              .flexibleWidth
            , .flexibleHeight
        ]

        // Collection Layout
        //----------------------------------------------------------------------
        let inset: CGFloat = 8.0
        let spacing: CGFloat = 8.0
        flowLayout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = spacing

        // Cell Types
        //----------------------------------------------------------------------
        collectionView.register(FrameCell.self, forCellWithReuseIdentifier: FrameCell.cellIdentifier)
    }

    // MARK: - Dequeue Cell -
    //--------------------------------------------------------------------------
    fileprivate func dequeue(frameCellAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FrameCell.cellIdentifier, for: indexPath) as! FrameCell

        let image = items[indexPath.row].image
        cell.imageView.image = image
        return cell
    }

    // MARK: - Item Delegate -
    //--------------------------------------------------------------------------
    func item(_ item: Item, didUpdate image: UIImage) {
        if let index = items.index(where: { $0 == item }) {
            collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }

}

// MARK: - Extension, Data Source -
//------------------------------------------------------------------------------
extension FrameCollectionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dequeue(frameCellAt: indexPath)
    }
}

// MARK: - Extension, Delegate -
//------------------------------------------------------------------------------
extension FrameCollectionViewController: UICollectionViewDelegate {
}

// MARK: - Extension, Flow Layout Delegate -
//------------------------------------------------------------------------------
extension FrameCollectionViewController: UICollectionViewDelegateFlowLayout {
    private class var itemsPerRow: Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let itemsPerRow = max(CGFloat(FrameCollectionViewController.itemsPerRow), 2.0)
        let viewWidth = collectionView.frame.width
            .subtracting(flowLayout.sectionInset.left)
            .subtracting(flowLayout.sectionInset.right)
            .subtracting(flowLayout.minimumInteritemSpacing * (itemsPerRow.subtracting(1.0)))

        let itemWidth = (viewWidth / itemsPerRow)

        return CGSize(width: itemWidth, height: itemWidth)
    }
}

// MARK: - Collection View =
//------------------------------------------------------------------------------
let viewController = FrameCollectionViewController()
PlaygroundPage.current.liveView = viewController

// MARK: - Network =
//------------------------------------------------------------------------------
private func find(_ text: String, after time: DispatchTime = DispatchTime.now()) -> URLSessionTask {
    return Frinkiac.search(for: text) {
        guard let frames = try? $0().0 else { return }
        let items = frames.map { FrameModel($0, delegate: viewController) }

        // Update Items
        //----------------------------------------------------------------------
        DispatchQueue.main.asyncAfter(deadline: time) {
            viewController.items = items
        }
    }
}

// MARK: - Extension, Seconds
//------------------------------------------------------------------------------
extension Int {
    fileprivate func seconds(from time: inout DispatchTime) -> DispatchTime {
        time = time + DispatchTimeInterval.seconds(self)
        return time
    }
}

var time: DispatchTime = .now()
var task: URLSessionTask!

task = find("fish bulb")
task.resume()

task = find("Mr. Sparkle", after: 3.seconds(from: &time))
task.resume()

task = find("Super Bowl", after: 3.seconds(from: &time))
task.resume()

task = find("Everybody knows that rock achieved", after: 3.seconds(from: &time))
task.resume()
