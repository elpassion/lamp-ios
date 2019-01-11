import AVKit
import Foundation

class VideoOperation: AsyncOperation {

    let player: AVPlayer
    let output: AVPlayerItemVideoOutput

    var color: UIColor?

    init(player: AVPlayer, output: AVPlayerItemVideoOutput) {
        self.player = player
        self.output = output
    }

    override func main() {
        guard let time = player.currentItem?.currentTime(),
              let duration = player.currentItem?.asset.duration else {
            state = .finished
            return
        }

        let seconds = min(CMTimeGetSeconds(time) + 0.1, CMTimeGetSeconds(duration))
        let incremented = CMTimeMakeWithSeconds(seconds, preferredTimescale: time.timescale)

        guard let buffer = output.copyPixelBuffer(forItemTime: incremented, itemTimeForDisplay: nil) else {
            state = .finished
            return
        }

        let ciImage = CIImage(cvPixelBuffer: buffer)
        let image = UIImage(ciImage: ciImage)

        image.getColors { [weak self] colors in
            self?.color = colors.background
            self?.state = .finished
            self?.completionBlock?()
        }
    }

}
