import UIKit

class LoadingViewController: UIViewController {

    let connector = BluetoothConnector()

    var loadingView: LoadingView! {
        return view as? LoadingView
    }

    override func loadView() {
        view = LoadingView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadingView.animationView.play()

        connector.connect { [weak self] device in
            let controller = ColorPickerController(device: device)
            self?.navigationController?.pushViewController(controller, animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        loadingView.titleLabel.fade(to: "LEDOWO", duration: 1.0)
    }

}
