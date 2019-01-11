import Gallery
import RxCocoa
import RxSwift
import UIKit
import Photos

class ColorPickerController: UIViewController, ColorWheelDelegate, GalleryControllerDelegate {

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

        pickerView.playButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.showGallery()
            })
            .disposed(by: disposeBag)

        pickerView.offButton.rx.tap
            .map { UIColor.black }
            .bind(to: colorRelay)
            .disposed(by: disposeBag)

        pickerView.whiteButton.rx.tap
            .map { UIColor.white }
            .bind(to: colorRelay)
            .disposed(by: disposeBag)

        pickerView.pickButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showPicker()
            })
            .disposed(by: disposeBag)
    }

    private let disposeBag = DisposeBag()
    private let colorRelay = BehaviorRelay<UIColor>(value: .white)

    func didSelect(color: UIColor) {
        colorRelay.accept(color)
    }

    func didRotate() {
        colorRelay.accept(colorRelay.value.updating(brightness: pickerView.pickerView.brightness))
    }

    var gallery: GalleryController?

    func showGallery() {
        Config.tabsToShow = [.videoTab]

        let gallery = GalleryController()
        self.gallery = gallery
        gallery.delegate = self
        present(gallery, animated: true)
    }

    func showPicker() {
        let alert = UIAlertController(style: .actionSheet)
        alert.addColorPicker(color: colorRelay.value) { [weak self] color in
            self?.colorRelay.accept(color)
        }
        alert.addAction(title: "Done", style: .cancel)
        alert.show()
    }

    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {

    }

    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        gallery?.dismiss(animated: false) { [unowned self] in
            PHCachingImageManager().requestAVAsset(forVideo: video.asset, options: nil, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) in
                let asset = asset as! AVURLAsset

                DispatchQueue.main.async {
                    let videoController = VideoController(device: self.device, url: asset.url)
                    self.navigationController?.pushViewController(videoController, animated: true)
                }
            })
        }
    }

    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {

    }

    func galleryControllerDidCancel(_ controller: GalleryController) {
        gallery?.dismiss(animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) { return nil }

}
