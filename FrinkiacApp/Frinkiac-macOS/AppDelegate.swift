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
                set(frame: caption.frame, text: caption.caption)
            }
        }
    }
    private func set(frame: Frame, text: String) {
        frame.memeLink(text).download { [weak self] in
            if let image = try? $0() {
                DispatchQueue.main.async {
                    self?.imageView.image = image
                    self?.textField.stringValue = text
                }
            }
        }.resume()
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
        set(frame: caption!.frame, text: textField.stringValue)
    }
}
