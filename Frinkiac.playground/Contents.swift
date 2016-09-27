import PlaygroundSupport
import UIKit
import Frinkiac

PlaygroundPage.current.needsIndefiniteExecution = true

typealias Callback<T> = ((() throws -> T?) -> ())

// MARK: - Extension, Simpsons Yellow -
//------------------------------------------------------------------------------
extension UIColor {
    class var simpsonsYellow: UIColor {
        return UIColor(red: 10, green: (217.0/255.0), blue: (15.0/255.0), alpha: 1.0)
    }
}

// MARK: - Extension, Download Image -
//------------------------------------------------------------------------------
extension Frame {
    /**
     Downloads the image located at `self.imageLink`.

     - parameter callback: A callback that can receive another function
                           which will return the image when executed.
     */
    fileprivate func downloadImage(_ callback: @escaping Callback<UIImage>) {
        DispatchQueue.global(qos: .userInitiated).async {
            callback {
                let url = URL(string: self.imageLink)!
                let data = try Data(contentsOf: url)
                return UIImage(data: data)
            }
        }
    }
}

// MARK: - Frame Model Delegate -
//------------------------------------------------------------------------------
protocol FrameModelDelegate: class {
    func frame(_ model: FrameModel, didUpdate image: UIImage)
}

// MARK: - Frame Model -
//------------------------------------------------------------------------------
final class FrameModel: Equatable {
    // MARK: - Private -
    //--------------------------------------------------------------------------
    private let frameID: Int
    
    // MARK: - Public -
    //--------------------------------------------------------------------------
    private(set) var image: UIImage? = nil

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    init(_ frame: Frame, delegate: FrameModelDelegate? = nil) {
        frameID = frame.id
        //----------------------------------------------------------------------
        frame.downloadImage {
            if let image = try? $0() {
                self.image = image

                DispatchQueue.main.async {
                    delegate?.frame(self, didUpdate: image!)
                }
            }
        }
    }

    // MARK: - Equatable -
    //--------------------------------------------------------------------------
    static func ==(lhs: FrameModel, rhs: FrameModel) -> Bool {
        return lhs.frameID == rhs.frameID
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
class FrameCollectionViewController: UIViewController, FrameModelDelegate {
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

    // MARK: - Frame Model Delegate -
    //--------------------------------------------------------------------------
    func frame(_ model: FrameModel, didUpdate image: UIImage) {
        if let index = items.index(where: { $0 == model }) {
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

// MARK: - Frame Search Provider -
//------------------------------------------------------------------------------
final class FrameSearchProvider {
    // MARK: - Private -
    //--------------------------------------------------------------------------
    /// - parameter callback: The callback provided during initialization.
    private var callback: (([Frame]) -> ()) = { _ in }

    /// - parameter searchTask: The task which performs the search.
    private var searchTask: URLSessionTask? = nil

    /// - parameter results: The frames returned by searching for `searchText`.
    /// - note: Updating this value invokes `callback`, iff: `newValue` isn't `nil`.
    private var results: [Frame]? = nil {
        didSet {
            if let results = results {
                callback(results)
            }
        }
    }

    /// - parameter searchText: The search query.
    /// - note: Before updating this value, any in-flight `searchTask` is cancelled,
    ///         and `searchTask` is reassigneld with a new task. After this value is
    ///         updated, `searchTask` is started.
    private var searchText: String = "" {
        willSet {
            searchTask?.cancel()
            searchTask = find(newValue) { [weak self] in
                if let results = try? $0() {
                    self?.results = results
                }
            }
        }
        didSet {
            searchTask?.resume()
        }
    }

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    init(_ callback: @escaping (([Frame]) -> ())) {
        self.callback = callback
    }
    
    // MARK: - Find -
    //--------------------------------------------------------------------------
    /**
     Searches for those frames containg `text`.

     - parameter text: The text being searched for.
     - parameter callback: A callback that can receive another function
                           which will return the frames when executed.
     
     - returns: A session task that, when started, performs a search
                and executes `callback`.
     */
    private func find(_ text: String, callback: @escaping Callback<[Frame]>) -> URLSessionTask {
        return Frinkiac.search(for: text) { result in
            callback {
                try? result().0
            }
        }
    }

    /**
     Search for frames containing `text`.

     - parameter text: The query to search for. 
     */
    func find(_ text: String) {
        searchText = text
    }
}

// MARK: - Collection View =
//------------------------------------------------------------------------------
let viewController = FrameCollectionViewController()
PlaygroundPage.current.liveView = viewController

let searchProvider = FrameSearchProvider {
    let items = $0.map { FrameModel($0, delegate: viewController) }
    viewController.items = items
}

searchProvider.find("Mr. Sparkle")
searchProvider.find("Apple Computers")

