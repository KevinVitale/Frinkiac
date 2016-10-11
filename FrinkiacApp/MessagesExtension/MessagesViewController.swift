import UIKit
import Messages
import Frinkiac

class MessagesViewController: MSMessagesAppViewController, FrameSearchControllerDelegate {
    /// - parameter MemeService: Pick your poison.
    fileprivate typealias MemeService = Frinkiac
    
    // MARK: - Search Controller -
    //--------------------------------------------------------------------------
    // TODO: Fix me; this is a smell (☠️)
    //--------------------------------------------------------------------------
    fileprivate weak var searchController: FrameSearchController<MemeService>? = nil
    fileprivate func setSearch(active: Bool) {
        searchController?.isActive = active
    }
    func searchShouldActivate(_ searchController: UISearchController) -> Bool {
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
extension MessagesViewController {
    fileprivate func frameCollection(_ frameCollection: FrameCollectionViewController<MemeService>? = nil, didSelect frameImage: FrameImage<MemeService>) {
        // 1) Download: 'Caption'
        //----------------------------------------------------------------------
        if let image = frameImage.image
            , let url = frameImage.response?.url
            , let text = frameImage.memeText?.text
            , let conversation = activeConversation {
            
            // 3) Create: 'Template Layout'
            //------------------------------------------------------
            let layout = MSMessageTemplateLayout()
            layout.image = image
            layout.caption = text
            
            // 4) Create: 'Message'
            //------------------------------------------------------
            let message = MSMessage(session: conversation.selectedMessage?.session ?? MSSession())
            message.url = url
            message.layout = layout
            
            // 5) Insert: 'Message'
            //------------------------------------------------------
            conversation.insert(message) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.requestPresentationStyle(.compact)
                    self?.setSearch(active: false)
                }
            }
        }
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
        let searchController = FrameSearchController<MemeService>() { [weak self] in
            self?.frameCollection($0.0, didSelect: $0.1)
        }
        // FIXME: Check out 'transitionDelegate'?
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
