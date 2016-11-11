import Cocoa
import Frinkiac

@NSApplicationMain

// MARK: - App Delegate -
//------------------------------------------------------------------------------
class AppDelegate: NSObject, NSApplicationDelegate, NSTextFieldDelegate {
    // MARK: - Private -
    //--------------------------------------------------------------------------
    fileprivate var frameImage: FrameImage<Frinkiac>? = nil {
        didSet {
            frameImage?.caption { [weak self] in
                if let image = try? $0()?.image {
                    self?.setImage(image)
                }
            }
        }
    }
    fileprivate let memeGenerator = Frinkiac()
    fileprivate var searchProvider: FrameSearchProvider<Frinkiac>!

    // MARK: - Outlets -
    //--------------------------------------------------------------------------
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var searchTextField: NSSearchField!
    @IBOutlet weak var textField: NSTextField!
}

// MARK: - Extension, Initialization -
//------------------------------------------------------------------------------
extension AppDelegate {
    override func awakeFromNib() {
        super.awakeFromNib()
        //----------------------------------------------------------------------
        searchProvider = FrameSearchProvider(memeGenerator) { [weak self] in
            self?.frameImage = $0.first
        }
    }
}

// MARK: - Extension, Actions -
//------------------------------------------------------------------------------
extension AppDelegate {
    @IBAction func search(_ sender: Any?) {
        searchProvider.find(searchTextField.stringValue)
    }

    @IBAction func random(_ sender: Any?) {
        searchProvider.random { [weak self] in
            if let caption = try? $0().caption
             , let memeGenerator = self?.memeGenerator {
                self?.frameImage = FrameImage(memeGenerator, frame: caption.frame)
            }
        }
    }
    
    @IBAction func update(_ sender: Any?) {
        setImage(frameImage?.image, text: textField.stringValue)
    }
}

// MARK: - Extension, Set Image -
//------------------------------------------------------------------------------
extension AppDelegate {
    // MARK: - Private -
    //--------------------------------------------------------------------------
    fileprivate func setImage(_ image: ImageType?, text: String = "") {
        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = image
            self?.textField.stringValue = text
        }
    }
}

// MARK: - Extension, Control Callbacks -
// https://developer.apple.com/library/content/qa/qa1454/_index.html
//------------------------------------------------------------------------------
extension AppDelegate {
    /// Sent when the text in the receiving control changes.
    override func controlTextDidChange(_ obj: Notification) {
        switch obj.object {
        case let searchField as NSSearchField where searchField.isEqual(searchTextField):
            search(obj.object)
        case let textField as NSTextField where textField.isEqual(textField):
            setImage(frameImage?.image, text: textField.stringValue)
        default: ()
        }
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            textView.insertNewlineIgnoringFieldEditor(self)
            return true
        }
        return false
    }
}
