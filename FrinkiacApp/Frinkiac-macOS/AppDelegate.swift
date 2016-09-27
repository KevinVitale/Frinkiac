import Cocoa
import Frinkiac

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Outlets -
    //--------------------------------------------------------------------------
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var searchTextField: NSSearchField!
    @IBOutlet weak var textField: NSTextField!

    // MARK: - Private -
    //--------------------------------------------------------------------------
    private var searchProvider: FrameSearchProvider!
    private var caption: Caption? {
        didSet {
            if let caption = caption {
                set(meme: caption.frame, text: caption.caption)
            }
        }
    }
    private func set(meme frame: Frame, text caption: String) {
        let link = Frinkiac.memeLink(frame: frame, text: caption)
        let image = NSImage(contentsOf: URL(string: link)!)
        //----------------------------------------------------------------------
        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = image
            self?.textField.stringValue = caption
        }
    }

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    override func awakeFromNib() {
        super.awakeFromNib()
        //----------------------------------------------------------------------
        searchProvider = FrameSearchProvider { [weak self] in
            if let frame = $0.first {
                Frinkiac.caption(with: frame) {
                    self?.caption = try? $0().0
                }.resume()
            }
        }
    }
    
    // MARK: - Actions -
    //--------------------------------------------------------------------------
    @IBAction func search(sender: AnyObject?) {
        searchProvider.find(searchTextField.stringValue)
    }
    @IBAction func random(sender: AnyObject?) {
        Frinkiac.random { [weak self] in
            self?.caption = try? $0().0
            }.resume()
    }
    @IBAction func update(sender: AnyObject?) {
        set(meme: caption!.frame, text: textField.stringValue)
    }
}
