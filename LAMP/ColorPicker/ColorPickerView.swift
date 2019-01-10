import Anchorage
import ChromaColorPicker
import UIKit

class ColorPickerView: UIView {

    let pickerView: ChromaColorPicker = {
        let view = ChromaColorPicker(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 300)))
        return view
    }()

    let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reconnect", for: .normal)
        return button
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
        addSubview(resetButton)
        addSubview(pickerView)
    }

    private func setUpConstraints() {
        resetButton.topAnchor == topAnchor + 50
        resetButton.sizeAnchors == CGSize(width: 200, height: 40)
        resetButton.centerXAnchor == centerXAnchor
    }

    required init?(coder aDecoder: NSCoder) { return nil }

}
