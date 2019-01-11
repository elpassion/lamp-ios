import RxCocoa
import RxSwift
import UIKit

class DebugPickerController: UIViewController {

    let device: HM10Device

    init(device: HM10Device) {
        self.device = device

        super.init(nibName: nil, bundle: nil)
    }

    var pickerView: DebugColorPickerView! {
        return view as? DebugColorPickerView
    }

    override func loadView() {
        view = DebugColorPickerView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let color: Observable<UIColor> = Observable.combineLatest(
            pickerView.hueSlider.rx.value.asObservable(),
            pickerView.saturationSlider.rx.value.asObservable(),
            pickerView.brightnessSlider.rx.value.asObservable()
        ).map { (hue, saturation, brightness) -> UIColor in
            UIColor(hue: CGFloat(hue), saturation: CGFloat(saturation), brightness: CGFloat(brightness), alpha: 1.0)
        }

        color
            .debounce(0.25, scheduler: MainScheduler.instance)
            .do(onNext: { [weak self] color in
                self?.view.backgroundColor = color
            })
            .map { $0.serialize() }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] data in
                self?.device.send(data: data)
            })
            .disposed(by: disposeBag)
    }

    private let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) { return nil }

}
