import PlaygroundSupport
import UIKit
import Frinkiac

PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: - Collection View =
//------------------------------------------------------------------------------
let viewController = FrameCollectionViewController()
PlaygroundPage.current.liveView = viewController

let searchProvider = FrameSearchProvider {
    let images = $0.map { FrameImage($0, delegate: viewController) }
    viewController.images = images
}

searchProvider.find("Mr. Sparkle")
searchProvider.find("Apple Computers")
