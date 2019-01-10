import Anchorage
import ChromaColorPicker
import UIKit

class ColorPickerView: UIView {

    let pickerView: ChromaColorPicker = {
        let view = ChromaColorPicker(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 300)))
        return view
    }()

    init() {
        super.init(frame: .zero)

        setUpSelf()
        addSubviews()
        setUpConstraints()
    }

    private func setUpSelf() {
        backgroundColor = .white
    }

    private func addSubviews() {
        addSubview(pickerView)
    }

    private func setUpConstraints() {

    }

    required init?(coder aDecoder: NSCoder) { return nil }

}
