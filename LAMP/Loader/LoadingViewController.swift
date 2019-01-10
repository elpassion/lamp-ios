import UIKit

class LoadingViewController: UIViewController {

    var loadingView: LoadingView! {
        return view as? LoadingView
    }

    override func loadView() {
        view = LoadingView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadingView.animationView.play()
    }

}
