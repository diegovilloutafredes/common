//
//  GIFImageViewTests.swift
//

import UIKit
import ImageIO
import XCTest
@testable import Common

@MainActor
final class GIFImageViewTests: XCTestCase {

    /// A view with a loaded GIF whose playback is stopped at teardown — even
    /// when an assertion fails mid-test (a trailing stopAnimating() is skipped
    /// under continueAfterFailure = false; deinit covers leaks either way).
    private func makeLoadedView(frameCount: Int, delay: TimeInterval = TestGIF.defaultFrameDelay) -> GIFImageView {
        let view = GIFImageView()
        view.loadGIF(from: TestGIF.animated(frameCount: frameCount, delay: delay))
        addTeardownBlock { @MainActor in view.stopAnimating() }
        return view
    }

    // MARK: - Leak regression (the centerpiece)

    /// Releasing an animating GIFImageView must deallocate it (weak-proxy target)
    /// and invalidate its display link (deinit), leaving nothing on the run loop.
    func test_animatingGIFImageView_deallocatesAndInvalidatesLink() {
        weak var weakView: GIFImageView?
        weak var weakLink: CADisplayLink?

        autoreleasepool {
            let view = GIFImageView()
            weakView = view
            view.loadGIF(from: TestGIF.animated(frameCount: 3))
            weakLink = view.displayLink
            XCTAssertNotNil(weakView)
            XCTAssertNotNil(weakLink, "display link should be running after loadGIF(from:)")
            // leaves scope WITHOUT stopAnimating() and WITHOUT being added to a window
        }

        XCTAssertNil(weakView, "GIFImageView leaked — the display link is retaining it (use a weak proxy target)")
        XCTAssertNil(weakLink, "CADisplayLink orphaned on the run loop — deinit must invalidate it")
    }

    // MARK: - Loading behavior

    func test_loadGIFFromData_setsUpSourceAndStartsLink() {
        let view = GIFImageView()
        XCTAssertNil(view.displayLink)

        view.loadGIF(from: TestGIF.animated(frameCount: 3))

        XCTAssertNotNil(view.imageSource)
        XCTAssertEqual(view.frameDurations.count, 3)
        XCTAssertNotNil(view.displayLink)
        view.stopAnimating()
    }

    /// Frame 0 must be painted synchronously on load. Otherwise the first frame
    /// shown is frame 1 (the display link increments before decoding) and the
    /// view is blank until `frameDurations[0]` elapses — frame 0 only appears
    /// after a full loop.
    func test_loadGIFFromData_paintsFirstFrameSynchronously() {
        let view = GIFImageView()
        XCTAssertNil(view.image)

        view.loadGIF(from: TestGIF.animated(frameCount: 3))

        XCTAssertNotNil(view.image, "frame 0 should be painted on load, not skipped until the first frame-duration elapses")
        // Pin WHICH frame: the fixture's frame 0 is hue 0 (red); frames 1 and 2
        // are green/blue. A stale-index paint (the original bug painted frame 1)
        // would still be non-nil.
        if let painted = view.image, let avg = painted.averageColor() {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
            avg.getRed(&r, green: &g, blue: &b, alpha: nil)
            XCTAssertGreaterThan(r, 0.8, "frame 0 (red) should be painted — got r:\(r) g:\(g) b:\(b)")
            XCTAssertLessThan(g, 0.3)
            XCTAssertLessThan(b, 0.3)
        } else {
            XCTFail("could not sample the painted frame")
        }
        view.stopAnimating()
    }

    func test_loadGIFFromData_ignoresInvalidData() {
        let view = GIFImageView()
        view.loadGIF(from: Data([0x00, 0x01, 0x02, 0x03]))
        XCTAssertNil(view.imageSource)
        XCTAssertNil(view.displayLink)
    }

    func test_loadGIFNamed_loadsFromGivenBundle() throws {
        let bundle = try TestGIF.makeBundleContainingGIF(named: "fixture")
        let view = GIFImageView()

        view.loadGIF(named: "fixture", in: bundle)

        XCTAssertNotNil(view.imageSource)
        XCTAssertNotNil(view.displayLink)
        view.stopAnimating()
    }

    func test_loadGIFNamed_missingResource_isIgnored() {
        let view = GIFImageView()
        view.loadGIF(named: "no-such-gif-\(UUID().uuidString)")
        XCTAssertNil(view.imageSource)
        XCTAssertNil(view.displayLink)
    }

    // MARK: - Frame timing

    func test_subThresholdFrameDelay_normalizesToDefault() {
        let view = makeLoadedView(frameCount: 2, delay: 0.01)

        XCTAssertEqual(view.frameDurations.count, 2)
        for duration in view.frameDurations {
            // 0.1 here is GIFImageView's normalization FALLBACK (not the fixture default).
            XCTAssertEqual(duration, 0.1, accuracy: 0.0001)
        }
    }

    // MARK: - Lifecycle

    func test_stopAnimating_allowsDeallocationAndInvalidatesLink() {
        weak var weakView: GIFImageView?
        weak var weakLink: CADisplayLink?
        autoreleasepool {
            let view = GIFImageView()
            weakView = view
            view.loadGIF(from: TestGIF.animated(frameCount: 2))
            weakLink = view.displayLink
            XCTAssertNotNil(weakLink)
            view.stopAnimating()
        }
        XCTAssertNil(weakView)
        // Not just released — INVALIDATED. `displayLink = nil` without
        // invalidate() would orphan a live link on the run loop forever.
        XCTAssertNil(weakLink, "stopAnimating must invalidate the link, not just drop the reference")
    }

    // MARK: - Clock (driven manually via advanceClock)

    /// The clock must advance by elapsed wall time between ticks — not by the
    /// link's nominal duration — so playback speed is correct at any callback
    /// cadence (ProMotion, Low Power Mode).
    func test_advanceClock_advancesByElapsedWallTime() {
        let view = makeLoadedView(frameCount: 3) // defaultFrameDelay (0.1s) per frame
        XCTAssertEqual(view.currentFrameIndex, 0)

        // Tick values keep a clear margin from the 0.1s frame boundary — float
        // timestamp deltas cannot be trusted to land exactly on it.
        view.advanceClock(to: 10.0)  // baseline tick — contributes no elapsed time
        XCTAssertEqual(view.currentFrameIndex, 0)
        view.advanceClock(to: 10.03) // +0.03s — below one frame duration
        XCTAssertEqual(view.currentFrameIndex, 0)
        view.advanceClock(to: 10.12) // +0.09s — total 0.12s crosses the frame duration
        XCTAssertEqual(view.currentFrameIndex, 1)
        // ~0.02s remained banked after the crossing. This tick only crosses the
        // next boundary if that remainder carried — zeroing the accumulator after
        // each frame (cumulative drift) would leave the index at 1.
        view.advanceClock(to: 10.21) // +0.09s — 0.02 + 0.09 crosses again
        XCTAssertEqual(view.currentFrameIndex, 2, "the sub-frame remainder must carry between ticks")
    }

    /// Dropped ticks bank their time: a late tick skips frames to stay on wall
    /// time instead of advancing at most one frame.
    func test_advanceClock_skipsFramesToCatchUpAfterDroppedTicks() {
        let view = makeLoadedView(frameCount: 3)

        view.advanceClock(to: 10.0)
        view.advanceClock(to: 10.25) // +0.25s = two full frames + 0.05s remainder
        XCTAssertEqual(view.currentFrameIndex, 2)
    }

    /// Time that passes while paused (window transitions reset the clock) must
    /// not fast-forward playback on resume.
    func test_advanceClock_doesNotBankPauseTime() {
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 100, height: 100))
        let view = makeLoadedView(frameCount: 3)

        view.advanceClock(to: 10.0)
        view.advanceClock(to: 10.12) // margin past the 0.1s frame boundary
        XCTAssertEqual(view.currentFrameIndex, 1)

        window.addSubview(view)     // a real window transition resets the clock
        view.advanceClock(to: 99.0) // new baseline — the gap contributes nothing
        XCTAssertEqual(view.currentFrameIndex, 1)
        view.stopAnimating()
        view.removeFromSuperview()
    }

    /// A single tick's elapsed time is capped (1s) so a pathological gap cannot
    /// spin the catch-up loop unbounded.
    func test_advanceClock_capsSingleTickCatchUp() {
        let view = makeLoadedView(frameCount: 3)

        view.advanceClock(to: 10.0)
        view.advanceClock(to: 99.0) // capped at 1s → 10 frames → 10 % 3 == 1
        XCTAssertEqual(view.currentFrameIndex, 1)
    }

    /// Backward timestamps (clock adjustments, restarted links) must rebaseline,
    /// not bank negative time that freezes playback until the debt repays.
    func test_advanceClock_toleratesBackwardTimestamps() {
        let view = makeLoadedView(frameCount: 3)

        view.advanceClock(to: 10.0)
        view.advanceClock(to: 10.12)
        XCTAssertEqual(view.currentFrameIndex, 1)

        view.advanceClock(to: 5.0)  // backwards — elapsed clamps to 0, rebaselines
        view.advanceClock(to: 5.12) // must advance normally from the new baseline
        XCTAssertEqual(view.currentFrameIndex, 2,
                       "a negative accumulator would freeze playback until the debt repaid")
    }

    // MARK: - Frame durations from metadata

    /// Kills the "hardcode every duration to 0.1" mutant: no other test loads a
    /// GIF whose delay differs from the default. 0.25s is centisecond-exact in
    /// GIF encoding and binary-exact in double — no tolerance games.
    func test_nonDefaultFrameDelay_isReadFromMetadata() {
        let view = makeLoadedView(frameCount: 2, delay: 0.25)

        XCTAssertEqual(view.frameDurations.count, 2)
        for duration in view.frameDurations {
            XCTAssertEqual(duration, 0.25, accuracy: 0.0001)
        }
    }

    // MARK: - Window lifecycle & the production tick path

    /// Deliberately spins the real run loop (~0.35s) — the ONE test proving the
    /// production tick path (CADisplayLink → WeakDisplayLinkProxy.tick →
    /// updateFrame → advanceClock) is actually wired. Every other timing test
    /// drives advanceClock manually; without this, deleting `target?.updateFrame()`
    /// from the proxy would pass the entire suite while no GIF animates.
    func test_displayLinkTickPath_advancesFramesOnRealRunLoop() {
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 100, height: 100))
        window.makeKeyAndVisible()
        let view = GIFImageView()
        window.addSubview(view)
        // 12 frames x 0.1s = a 1.2s cycle: a 0.35s spin advances ~3 frames with
        // no risk of wrapping back to index 0 (a 3-frame fixture wraps at
        // exactly ~0.3s and false-fails this assertion).
        view.loadGIF(from: TestGIF.animated(frameCount: 12))

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.35))

        XCTAssertGreaterThan(view.currentFrameIndex, 0,
                             "real display-link ticks must reach advanceClock through the proxy")
        view.stopAnimating()
        view.removeFromSuperview()
        window.isHidden = true
    }

    /// Window transitions own the pause bit: off-window loads start paused,
    /// joining a window resumes, leaving pauses again.
    func test_windowTransitions_toggleDisplayLinkPause() {
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 100, height: 100))
        let view = GIFImageView()
        view.loadGIF(from: TestGIF.animated(frameCount: 3)) // off-window → paused
        XCTAssertEqual(view.displayLink?.isPaused, true)
        XCTAssertFalse(view.isAnimating, "a paused link is not animating")

        window.addSubview(view)
        XCTAssertEqual(view.displayLink?.isPaused, false, "joining a window must resume")

        view.removeFromSuperview()
        XCTAssertEqual(view.displayLink?.isPaused, true, "leaving the window must pause")
        view.stopAnimating()
    }

    /// An explicit stopAnimating() must survive window re-entry — the
    /// documented contract is that only startAnimating() resumes it.
    func test_stopAnimating_staysStoppedAcrossWindowReentry() {
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 100, height: 100))
        let view = GIFImageView()
        window.addSubview(view)
        view.loadGIF(from: TestGIF.animated(frameCount: 3))

        view.stopAnimating()
        view.removeFromSuperview()
        window.addSubview(view) // re-enter

        XCTAssertNil(view.displayLink, "window re-entry must not resurrect an explicitly stopped animation")
        XCTAssertFalse(view.isAnimating)
        view.removeFromSuperview()
    }

    // MARK: - Invalid data must not disturb current playback

    /// `loadGIF(from:)` documents undecodable data as ignored — a playing GIF
    /// must keep playing, and the old source must not be left half-torn-down.
    func test_invalidDataAfterSuccessfulLoad_keepsCurrentPlayback() {
        let view = makeLoadedView(frameCount: 3)
        XCTAssertNotNil(view.displayLink)

        view.loadGIF(from: Data([0x00, 0x01, 0x02, 0x03]))

        XCTAssertNotNil(view.displayLink, "invalid data must not stop the running animation")
        XCTAssertNotNil(view.imageSource, "invalid data must not clear the current source")
        XCTAssertEqual(view.frameDurations.count, 3, "invalid data must not disturb the current frame table")
    }

    // MARK: - Window-aware pause state

    /// A link created while the view is off-window must start paused — otherwise
    /// it decodes frames at refresh rate for a view nothing displays.
    func test_loadGIF_offWindow_createsPausedLink() {
        let view = GIFImageView()

        view.loadGIF(from: TestGIF.animated(frameCount: 3))

        XCTAssertEqual(view.displayLink?.isPaused, true, "a link created off-window must be seeded paused")
        view.stopAnimating()
    }

    // MARK: - Static image interplay

    /// Assigning `image` directly must stop GIF playback and clear the loaded
    /// GIF, so the static image sticks and cannot be stomped by the next tick
    /// or resurrected by `startAnimating()`.
    func test_externalImageAssignment_stopsPlaybackAndClearsGIFState() {
        let view = GIFImageView()
        view.loadGIF(from: TestGIF.animated(frameCount: 3))
        let staticImage = UIImage()

        view.image = staticImage

        XCTAssertNil(view.displayLink, "setting a static image must stop GIF playback")
        XCTAssertNil(view.imageSource, "setting a static image must clear the GIF source")
        XCTAssertTrue(view.frameDurations.isEmpty, "the GIF state must be fully cleared")
        XCTAssertTrue(view.image === staticImage, "the assigned image must stick")

        // The spec's second half: the cleared GIF cannot be resurrected.
        view.startAnimating()
        XCTAssertNil(view.displayLink, "startAnimating must not resurrect a cleared GIF")
        XCTAssertTrue(view.image === staticImage)
    }

    func test_isAnimating_reflectsDisplayLinkPlayback() {
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 100, height: 100))
        let view = GIFImageView()
        window.addSubview(view)

        XCTAssertFalse(view.isAnimating)
        view.loadGIF(from: TestGIF.animated(frameCount: 3))
        XCTAssertTrue(view.isAnimating, "isAnimating must be true while the display link drives frames")

        view.stopAnimating()
        XCTAssertFalse(view.isAnimating, "isAnimating must be false after stopAnimating()")
        view.removeFromSuperview()
    }

    // MARK: - Single-frame GIFs

    /// A one-frame GIF is a static image: paint it, but never start a display
    /// link that re-decodes the same frame forever.
    func test_singleFrameGIF_paintsWithoutDisplayLink() {
        let view = GIFImageView()

        view.loadGIF(from: TestGIF.animated(frameCount: 1))

        XCTAssertNotNil(view.image, "the single frame should be painted")
        XCTAssertNil(view.displayLink, "a single-frame GIF must not start a display link")
    }

    // NOTE: the proxy's weak-target guarantee is covered black-box by
    // test_animatingGIFImageView_deallocatesAndInvalidatesLink — a white-box
    // proxy test added no distinct detection (it asserted Swift's `weak`
    // semantics, not framework code) and was removed.
}
