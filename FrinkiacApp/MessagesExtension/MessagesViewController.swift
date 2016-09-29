import UIKit
import Messages
import Frinkiac

class MessagesViewController: MSMessagesAppViewController {
    override func willBecomeActive(with conversation: MSConversation) {
        print(#function)
        super.willBecomeActive(with: conversation)
        presentSearchController(for: activeConversation, with: presentationStyle)
    }

    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        print(#function)
        super.didTransition(to: presentationStyle)
        presentSearchController(for: activeConversation, with: presentationStyle)
    }

}

// MARK: - Extension, Frame Collection Delegate -
//------------------------------------------------------------------------------
extension MSMessagesAppViewController: FrameCollectionDelegate {
    public func frameCollection(_ frameCollection: FrameCollectionViewController, didSelect frameImage: FrameImage) {
        requestPresentationStyle(.compact)

        // 1) Download: 'Caption'
        //----------------------------------------------------------------------
        Frinkiac.caption(with: frameImage.frame) { [weak self] in
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
                        DispatchQueue.main.async {
                            conversation.insert(message) { _ in
                                
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
        embed(child: FrameSearchController.searchController(with: self))
    }
}


// MARK: - Extension, Search Bar Delegate
//------------------------------------------------------------------------------
extension MessagesViewController: UISearchBarDelegate {
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        var beginEditing = false
        //----------------------------------------------------------------------
        switch  presentationStyle {
        case .compact:
            requestPresentationStyle(.expanded)
        default:
            beginEditing = true
        }
        //----------------------------------------------------------------------
        print("\t", #function, beginEditing)
        return beginEditing
    }
}

// MARK: - Extension, Frame Search Controller
//------------------------------------------------------------------------------
extension FrameSearchController {
    /**
     A convienence class method for generating a search controller with a given
     `FrameControllerDelegate` assigned to `frameController.delegate`, and a given
     'UISearchBarDelegate' assigned to `searchBar.delegate`.
     
     - parameter delegate: An optional delegate instance.
     - returns: A new instance of `FrameSearchController`.
     */
    fileprivate class func searchController(with delegate: (FrameCollectionDelegate & UISearchBarDelegate)?) -> FrameSearchController {
        let searchController = FrameSearchController()
        searchController.frameController.delegate = delegate
        searchController.searchBar.delegate = delegate
        return searchController
    }
}
