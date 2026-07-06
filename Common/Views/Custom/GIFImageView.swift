//
//  GIFImageView.swift
//

import UIKit
import ImageIO

/// A `UIImageView` that plays animated GIFs using ImageIO.
///
/// Frames are decoded one at a time on a `CADisplayLink` as they are shown, so
/// memory stays flat regardless of the GIF's frame count.
///
/// ```swift
/// let view = GIFImageView()
/// view.loadGIF(named: "spinner")   // "spinner.gif" in the main bundle
/// // or: view.loadGIF(from: data)
/// ```
///
/// Playback pauses automatically while the view is not in a window and resumes
/// when it joins one; an explicit ``stopAnimating()`` stays stopped until
/// ``startAnimating()`` is called. Assigning ``image`` directly stops playback
/// and clears the loaded GIF, so the assigned image sticks. Each frame is
/// decoded on the main thread as it is displayed, which is inexpensive for
/// typical UI GIFs but can hitch for very large ones.
public final class GIFImageView: UIImageView {

    private(set) var displayLink: CADisplayLink?
    private(set) var imageSource: CGImageSource?
    private(set) var frameDurations: [TimeInterval] = []
    private(set) var currentFrameIndex = 0
    private var timeAccumulator: TimeInterval = .zero
    private var lastTickTimestamp: CFTimeInterval?
    private var isRenderingFrame = false

    // MARK: - UIImageView overrides

    /// Setting an image from outside stops GIF playback and clears the loaded
    /// GIF, so the assigned image cannot be overwritten by the next frame tick
    /// or resurrected by ``startAnimating()``.
    public override var image: UIImage? {
        get { super.image }
        set {
            super.image = newValue
            guard !isRenderingFrame else { return }
            clearGIFState()
        }
    }

    /// `true` while the display link is actively driving GIF frames (also when
    /// `UIImageView`'s own `animationImages` animation is running).
    public override var isAnimating: Bool {
        super.isAnimating || displayLink?.isPaused == false
    }

    // MARK: - Loading

    /// Loads and animates `<name>.gif` from `bundle` (the main bundle by default).
    /// A missing resource is ignored (and logged in debug builds).
    public func loadGIF(named name: String, in bundle: Bundle = .main) {
        guard
            let url = bundle.url(forResource: name, withExtension: "gif"),
            let data = try? Data(contentsOf: url)
        else {
            Logger.log("GIFImageView: gif '\(name)' not found")
            return
        }
        loadGIF(from: data)
    }

    /// Loads and animates a GIF from raw `data`. Undecodable data is ignored —
    /// a GIF that is already playing keeps playing.
    public func loadGIF(from data: Data) {
        // kCGImageSourceShouldCache=false keeps the source from caching every
        // decoded frame — memory stays flat as we decode on demand.
        let options = [kCGImageSourceShouldCache: false] as CFDictionary
        guard
            let source = CGImageSourceCreateWithData(data as CFData, options),
            CGImageSourceGetCount(source) > 0
        else { return }

        stopAnimating()
        imageSource = source
        let count = CGImageSourceGetCount(source)
        frameDurations = (0..<count).map { frameDuration(at: $0, source: source) }
        currentFrameIndex = 0
        timeAccumulator = 0
        lastTickTimestamp = nil
        // Paint frame 0 now — otherwise the view is blank until the first
        // frame-duration elapses.
        renderFrame(at: 0)
        startDisplayLink()
    }

    // MARK: - Animation control

    public override func startAnimating() {
        if displayLink.isNil && imageSource.isNotNil {
            startDisplayLink()
        }
        super.startAnimating()
    }

    public override func stopAnimating() {
        displayLink?.invalidate()
        displayLink = nil
        super.stopAnimating()
    }

    // MARK: - Lifecycle

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        displayLink?.isPaused = window.isNil
        // Never bank time that passed while paused (or between windows).
        lastTickTimestamp = nil
    }

    deinit {
        displayLink?.invalidate()
    }

    // MARK: - Private

    fileprivate func updateFrame() {
        guard let displayLink else { return }
        advanceClock(to: displayLink.timestamp)
    }

    /// Advances the GIF clock to `now` (a `CADisplayLink` timestamp), skipping
    /// frames to stay on wall time when callbacks were dropped, and decodes at
    /// most one frame per call.
    func advanceClock(to now: CFTimeInterval) {
        guard imageSource.isNotNil, !frameDurations.isEmpty else { return }
        // Elapsed wall time since the previous tick — not the link's nominal
        // `duration`, which understates it whenever the callback cadence is
        // below the display's maximum rate (ProMotion, Low Power Mode, dropped
        // ticks). The first tick after a start/reset contributes 0; a single
        // tick's elapsed time is capped at 1s to bound catch-up jumps.
        let elapsed = max(0, min(now - (lastTickTimestamp ?? now), 1.0))
        lastTickTimestamp = now
        timeAccumulator += elapsed

        let previousIndex = currentFrameIndex
        while timeAccumulator >= frameDurations[currentFrameIndex] {
            timeAccumulator -= frameDurations[currentFrameIndex]
            currentFrameIndex = (currentFrameIndex + 1) % frameDurations.count
        }
        guard currentFrameIndex != previousIndex else { return }
        renderFrame(at: currentFrameIndex)
    }

    /// Decodes and displays frame `index` without tearing down the GIF state
    /// (internal paints must not trigger the `image` setter's cleanup).
    private func renderFrame(at index: Int) {
        guard
            let imageSource,
            let cgImage = CGImageSourceCreateImageAtIndex(imageSource, index, nil)
        else { return }
        isRenderingFrame = true
        image = UIImage(cgImage: cgImage)
        isRenderingFrame = false
    }

    private func clearGIFState() {
        displayLink?.invalidate()
        displayLink = nil
        imageSource = nil
        frameDurations = []
        currentFrameIndex = 0
        timeAccumulator = 0
        lastTickTimestamp = nil
    }

    private func startDisplayLink() {
        // A single-frame GIF is a static image — nothing to animate.
        guard frameDurations.count > 1 else { return }
        // Target a weak proxy, not `self`: CADisplayLink strongly retains its
        // target and the run loop retains the link, so targeting `self` would
        // keep the view alive forever. With the proxy, the view can deallocate
        // and `deinit` invalidates the link.
        let proxy = WeakDisplayLinkProxy(target: self)
        let link = CADisplayLink(target: proxy, selector: #selector(WeakDisplayLinkProxy.tick(_:)))
        // Seed the pause state: a link created while the view is off-window
        // must not decode frames nobody can see.
        link.isPaused = window.isNil
        link.add(to: .main, forMode: .common)
        lastTickTimestamp = nil
        displayLink = link
    }

    private func frameDuration(at index: Int, source: CGImageSource) -> TimeInterval {
        var duration: TimeInterval = 0.1
        guard
            let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
            let gif = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any]
        else { return duration }

        if let unclamped = gif[kCGImagePropertyGIFUnclampedDelayTime] as? NSNumber {
            duration = unclamped.doubleValue
        } else if let clamped = gif[kCGImagePropertyGIFDelayTime] as? NSNumber {
            duration = clamped.doubleValue
        }
        if duration < 0.02 { duration = 0.1 }
        return duration
    }
}

/// Forwards `CADisplayLink` ticks to a ``GIFImageView`` without retaining it.
///
/// `CADisplayLink` strongly retains its target and the run loop retains the link,
/// so targeting the view directly creates a `view → link → view` cycle the run
/// loop keeps alive — the view never deallocates. Targeting this proxy (which
/// holds the view weakly) lets the view deallocate; its `deinit` then invalidates
/// the link, releasing the proxy.
final class WeakDisplayLinkProxy: NSObject {

    weak var target: GIFImageView?

    init(target: GIFImageView) {
        self.target = target
        super.init()
    }

    @objc func tick(_ link: CADisplayLink) {
        target?.updateFrame()
    }
}
