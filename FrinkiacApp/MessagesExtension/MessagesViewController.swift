import UIKit
import Messages
import Frinkiac

class MessagesViewController: MSMessagesAppViewController {
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        presentSearchController(for: activeConversation!, with: presentationStyle)
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
                }
            }
        }.resume()
    }
}

extension MessagesViewController {
    fileprivate func presentSearchController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        let controller = FrameSearchController()
        controller.frameController.delegate = self
        //----------------------------------------------------------------------
        /*
         if presentationStyle == .compact {

         } else {
         }
         */

        // Remove any existing child controllers.
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }

        // Embed the new controller.
        addChildViewController(controller)

        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        controller.didMove(toParentViewController: self)
    }
}
