import RxCocoa
import RxSwift
import UIKit

class ColorPickerController: UIViewController, ColorWheelDelegate {

    let device: HM10Device

    init(device: HM10Device) {
        self.device = device

        super.init(nibName: nil, bundle: nil)
    }

    var pickerView: ColorPickerView! {
        return view as? ColorPickerView
    }

    override func loadView() {
        view = ColorPickerView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.pickerView.delegate = self

        colorRelay
            .map { $0.normalized().serialize() }
            .distinctUntilChanged()
            .throttle(0.25, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                self?.device.send(data: data)
            })
            .disposed(by: disposeBag)

        pickerView.resetButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                let loading = LoadingViewController()
                self?.navigationController?.setViewControllers([loading], animated: true)
            })
            .disposed(by: disposeBag)
    }

    private let disposeBag = DisposeBag()
    private let colorRelay = BehaviorRelay<UIColor>(value: .white)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        pickerView.pickerView.center = pickerView.center
    }

    func didSelect(color: UIColor) {
        colorRelay.accept(color)
    }

    func didRotate() {
        colorRelay.accept(colorRelay.value.updating(brightness: pickerView.pickerView.brightness))
    }

    required init?(coder aDecoder: NSCoder) { return nil }

}
