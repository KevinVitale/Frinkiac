import UIKit
import Messages
import Frinkiac

class MessagesViewController: MSMessagesAppViewController {
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        presentSearchController(for: activeConversation!, with: presentationStyle)
    }
}

extension MessagesViewController {
    fileprivate func presentSearchController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        let controller = FrameSearchController()
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

        controller.searchProvider.find("computer hacking")
    }
}
