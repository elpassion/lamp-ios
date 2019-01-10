import ChromaColorPicker
import RxCocoa
import RxSwift
import UIKit

class ColorPickerController: UIViewController {

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

        pickerView.pickerView.rx.controlEvent(.valueChanged)
            .map { [pickerView] _ -> Data in
                pickerView?.pickerView.currentColor.serialize() ?? Data()
            }
            .distinctUntilChanged()
            .throttle(0.25, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                self?.device.send(data: data)
            })
            .disposed(by: disposeBag)
    }

    private let disposeBag = DisposeBag()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        pickerView.pickerView.center = pickerView.center
    }

    required init?(coder aDecoder: NSCoder) { return nil }

}
