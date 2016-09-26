import PlaygroundSupport
import Frinkiac

PlaygroundPage.current.needsIndefiniteExecution = true

private func finish() {
    PlaygroundPage.current.finishExecution()
}

Frinkiac.random {
    let caption = try? $0().0
    print(caption?.memeLink)
    print(caption?.imageLink)
    finish()
}.resume()
