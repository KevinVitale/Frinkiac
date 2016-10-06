import UIKit
import Messages
import Frinkiac

class MessagesViewController: MSMessagesAppViewController, FrameSearchControllerDelegate {
    /// - parameter MemeGenerator: Pick your poison.
    fileprivate typealias MemeGenerator = Frinkiac
    
    // MARK: - Search Controller -
    //--------------------------------------------------------------------------
    // TODO: Fix me; this is a smell (☠️)
    //--------------------------------------------------------------------------
    fileprivate weak var searchController: FrameSearchController<MemeGenerator>? = nil
    fileprivate func setSearch(active: Bool) {
        searchController?.searchController?.isActive = active
    }
    func frameSearchShouldActivate<S : ServiceHost>(_ frameSearchController: FrameSearchController<S>) -> Bool {
        return presentationStyle == .expanded
    }
    //--------------------------------------------------------------------------

    // MARK: - Message Lifecycle -
    //--------------------------------------------------------------------------
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        presentSearchController(for: conversation, with: presentationStyle)
    }

    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransition(to: presentationStyle)
        if presentationStyle == .compact {
            setSearch(active: false)
        }
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.didTransition(to: presentationStyle)
        presentSearchController(for: activeConversation, with: presentationStyle)
    }

}

// MARK: - Extension, Frame Collection Delegate -
//------------------------------------------------------------------------------
extension MessagesViewController: FrameCollectionDelegate {
    public func frameCollection(_ frameCollection: FrameCollectionViewController, didSelect frameImage: FrameImage) {
        // 1) Download: 'Caption'
        //----------------------------------------------------------------------
        MemeGenerator.caption(with: frameImage.frame) { [weak self] in
            if let caption = try? $0().0
             , let conversation = self?.activeConversation {
                // 2) Download: 'Image'
                //--------------------------------------------------------------
                caption.memeLink.download {
                    if let image = try? $0() {
                        // 3) Create: 'Template Layout'
                        //------------------------------------------------------
                        let layout = MSMessageTemplateLayout()
                        layout.image = image
                        layout.caption = caption.subtitle
                        
                        // 4) Create: 'Message'
                        //------------------------------------------------------
                        let message = MSMessage(session: conversation.selectedMessage?.session ?? MSSession())
                        message.url = caption.memeLink.url
                        message.layout = layout
                        
                        // 5) Insert: 'Message'
                        //------------------------------------------------------
                        conversation.insert(message) { _ in
                            DispatchQueue.main.async {
                                self?.requestPresentationStyle(.compact)
                                self?.setSearch(active: false)
                            }
                        }
                    }
                }.resume()
            }
        }.resume()
    }
}

// MARK: - Extension, Message View Controller -
//------------------------------------------------------------------------------
extension MessagesViewController {
    // MARK: - Remove All Children -
    //--------------------------------------------------------------------------
    private func removeAllChildren() {
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
    }

    private func embed(child controller: UIViewController) {
        addChildViewController(controller)

        view.addSubview(controller.view)

        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false

        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true

        controller.didMove(toParentViewController: self)
    }

    // MARK: - Present View Controller
    //--------------------------------------------------------------------------
    fileprivate func presentSearchController(for conversation: MSConversation?, with presentationStyle: MSMessagesAppPresentationStyle) {
        // Rebuild controller hierarchy
        //----------------------------------------------------------------------
        removeAllChildren()

        // Create embedded controller
        //----------------------------------------------------------------------
        let searchController = FrameSearchController<MemeGenerator>()
        searchController.delegate = self
        searchController.searchDelegate = self
        searchController.searchBar.delegate = self

        // Install search controller
        //----------------------------------------------------------------------
        embed(child: searchController)
        self.searchController = searchController
    }
}

// MARK: - Extension, Search Bar Delegate -
//------------------------------------------------------------------------------
extension MSMessagesAppViewController: UISearchBarDelegate {
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if presentationStyle == .compact {
            requestPresentationStyle(.expanded)
        }
        //----------------------------------------------------------------------
        return presentationStyle == .compact ? false : true
    }
}
