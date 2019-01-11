import Anchorage
import UIKit

class DebugColorPickerView: UIView {

    let hueSlider: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.isContinuous = true
        slider.tintColor = .green

        return slider
    }()

    let saturationSlider: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.isContinuous = true
        slider.tintColor = .green

        return slider
    }()

    let brightnessSlider: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.isContinuous = true
        slider.tintColor = .green

        return slider
    }()

    let container: UIStackView = {
        let container = UIStackView(frame: .zero)
        container.axis = .vertical
        container.alignment = .fill
        container.distribution = .fill
        container.spacing = 20.0

        return container
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
        addSubview(container)
        [hueSlider, saturationSlider, brightnessSlider].forEach(container.addArrangedSubview(_:))
    }

    private func setUpConstraints() {
        container.centerAnchors == centerAnchors
        container.widthAnchor == widthAnchor * 0.9

        [hueSlider, saturationSlider, brightnessSlider].forEach { slider in
            slider.heightAnchor == 80
        }
    }

    required init?(coder aDecoder: NSCoder) { return nil }

}
