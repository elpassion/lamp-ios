import ChromaColorPicker
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

        pickerView.pickerView.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        pickerView.pickerView.center = pickerView.center
    }

    // MARK: - ChromaColorPickerDelegate

    @objc private func valueChanged() {
        device.send(color: pickerView.pickerView.currentColor)
    }

    required init?(coder aDecoder: NSCoder) { return nil }

}
