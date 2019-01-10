import RxSwift
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

        connector.connect()
            .delay(2.0, scheduler: MainScheduler.instance)
            .subscribe(onSuccess: { [unowned self] device in
                self.show(device: device)
            })
            .disposed(by: disposeBag)

        loadingView.animationView.play()
    }

    private func show(device: HM10Device) {
        let controller = ColorPickerController(device: device)
        navigationController?.pushViewController(controller, animated: true)
    }

    private let disposeBag = DisposeBag()

}
