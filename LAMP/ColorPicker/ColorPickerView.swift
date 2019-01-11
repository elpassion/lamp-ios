import Anchorage
import Hue
import UIKit

class ColorPickerView: UIView {

    let gradientView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "lamp.jpg"))
        view.contentMode = .scaleAspectFill
        return view
    }()

    lazy var gradientLayer: CAGradientLayer = [
        UIColor(hex: "#ff4b1f"),
        UIColor(hex: "#ff9068")
    ].gradient()

    let pickerView: RotatingColorWheel = {
        let view = RotatingColorWheel(frame: .zero)
        view.backgroundColor = .clear
        return view
    }()

    let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        button.setTitle("Reconnect", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        button.setTitle("Play video", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    let buttonsContainer: UIStackView = {
        let container = UIStackView(frame: .zero)
        container.axis = .horizontal
        container.alignment = .fill
        container.distribution = .fillEqually
        container.spacing = 50.0

        return container
    }()

    let offButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("Off", for: .normal)

        return button
    }()

    let whiteButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("White", for: .normal)

        return button
    }()

    let pickButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("Pick", for: .normal)

        return button
    }()

    let bottomContainer: UIStackView = {
        let container = UIStackView(frame: .zero)
        container.axis = .horizontal
        container.alignment = .fill
        container.distribution = .fillEqually
        container.spacing = 20.0

        return container
    }()

    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

    init() {
        super.init(frame: .zero)

        setUpSelf()
        addSubviews()
        setUpConstraints()
    }

    private func setUpSelf() {
        backgroundColor = .white
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = gradientView.frame
    }

    private func addSubviews() {
        addSubview(gradientView)
        gradientView.addSubview(blurView)
        buttonsContainer.addArrangedSubview(resetButton)
        buttonsContainer.addArrangedSubview(playButton)
        addSubview(buttonsContainer)
        addSubview(pickerView)
        addSubview(bottomContainer)
        [offButton, whiteButton, pickButton].forEach(bottomContainer.addArrangedSubview(_:))
    }

    private func setUpConstraints() {
        [offButton, whiteButton, pickButton].forEach { $0.sizeAnchors == CGSize(width: 50, height: 50) }

        gradientView.edgeAnchors == edgeAnchors
        blurView.edgeAnchors == gradientView.edgeAnchors

        buttonsContainer.topAnchor == topAnchor + 50
        buttonsContainer.heightAnchor == 50
        buttonsContainer.centerXAnchor == centerXAnchor

        pickerView.widthAnchor == widthAnchor - 20
        pickerView.heightAnchor == pickerView.widthAnchor
        pickerView.centerAnchors == centerAnchors

        bottomContainer.bottomAnchor == safeAreaLayoutGuide.bottomAnchor
        bottomContainer.horizontalAnchors == horizontalAnchors
        bottomContainer.heightAnchor == 50
    }

    required init?(coder aDecoder: NSCoder) { return nil }

}
