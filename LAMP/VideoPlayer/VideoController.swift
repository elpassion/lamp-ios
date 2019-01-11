import AVKit
import Hue
import RxCocoa
import RxSwift
import UIKit

class VideoController: UIViewController {

    let device: HM10Device

    init(device: HM10Device, url: URL) {
        self.player = AVPlayer(url: url)
        self.device = device

        super.init(nibName: nil, bundle: nil)
    }

    let player: AVPlayer

    let videoOutput: AVPlayerItemVideoOutput = {
        let pixBuffAttributes: [String : AnyObject] = [kCVPixelBufferPixelFormatTypeKey as String :  Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) as AnyObject]
        return AVPlayerItemVideoOutput(pixelBufferAttributes: pixBuffAttributes)
    }()

    let colorRelay = PublishRelay<UIColor>()
    let disposeBag = DisposeBag()

    let controller = AVPlayerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        colorRelay
            .map { $0.saturated() }
            .do(onNext: { [weak self] color in
                DispatchQueue.main.async {
                    self?.controller.view.backgroundColor = color
                }
            })
            .map { $0.normalized().serialize() }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] data in
                self?.device.send(data: data)
            })
            .disposed(by: disposeBag)

        player.addObserver(self, forKeyPath: "timeControlStatus", options: .initial, context: nil)

        controller.player = player
        player.currentItem?.add(videoOutput)

        present(controller, animated: true) { [weak self] in
            self?.player.play()
        }
    }

    private func captureFrame() {
        guard !paused else { return }

        let operation = VideoOperation(player: player, output: videoOutput)
        operation.completionBlock = { [weak self, weak operation] in
            if let color = operation?.color {
                self?.colorRelay.accept(color)
            }

            self?.captureFrame()
        }

        processingQueue.addOperation(operation)
    }

    private let processingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive

        return queue
    }()

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let player = object as? AVPlayer, keyPath == "timeControlStatus", let item = player.currentItem {
            paused = player.timeControlStatus != .playing

            if !paused {
                captureFrame()
            } else if item.currentTime() == item.duration {
                navigationController?.popViewController(animated: true)
            }
        }
    }

    private var paused: Bool = false

    required init?(coder aDecoder: NSCoder) { return nil }

}
