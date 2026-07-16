import Common
import UIKit

// MARK: - ImageDemoSection

struct ImageDemoSection {
    let header: String
    let items: [ImageDemoCellViewModelImpl]
}

// MARK: - ImageLoadingViewModelProtocol

protocol ImageLoadingViewModelProtocol: ViewModel, CollectionViewable {
    var title: String { get }
    func clearCache() async
    func preloadBatch()
    func reload()
}

// MARK: - ImageLoadingViewModel

@MainActor
final class ImageLoadingViewModel {
    let title = "Image Loading"

    weak var view: CollectionViewReloadable?

    private lazy var sections: [ImageDemoSection] = makeSections()

    private func makeSections() -> [ImageDemoSection] {
        let placeholder = UIImage(systemName: "photo")?
            .withTintColor(.tertiaryLabel, renderingMode: .alwaysOriginal)
        let failureImage = UIImage(systemName: "exclamationmark.triangle.fill")?
            .withTintColor(.systemRed, renderingMode: .alwaysOriginal)

        // Section 0 — Fade Transition: fresh network fetch with animation
        let fadeURLs = (1...5).map { URL(string: "https://picsum.photos/seed/\($0)/300/200")! }
        let fadeSection = ImageDemoSection(
            header: "FADE TRANSITION — Network fetch with animation",
            items: fadeURLs.enumerated().map { i, url in
                ImageDemoCellViewModelImpl(
                    imageURL: url,
                    title: "Image #\(i + 1)",
                    subtitle: "picsum.photos/seed/\(i + 1)/300/200 · fade(0.25s)",
                    badge: "NETWORK",
                    badgeColor: .systemBlue,
                    options: ImageLoadOptions(placeholder: placeholder, transition: .fade(0.25))
                )
            }
        )

        // Section 1 — Cache Hits: same URLs, instantly served from L1 (no fade)
        let cacheSection = ImageDemoSection(
            header: "CACHE HITS — Same URLs, instant from L1 memory",
            items: fadeURLs.enumerated().map { i, url in
                ImageDemoCellViewModelImpl(
                    imageURL: url,
                    title: "Image #\(i + 1)",
                    subtitle: "Same URL — L1 hit, no animation applied",
                    badge: "CACHE",
                    badgeColor: .systemGreen,
                    options: ImageLoadOptions(placeholder: placeholder, transition: .fade(0.25))
                )
            }
        )

        // Section 2 — Image Formats: JPEG, PNG, WebP via httpbin
        let formatSection = ImageDemoSection(
            header: "IMAGE FORMATS — JPEG · PNG · WebP",
            items: [
                ImageDemoCellViewModelImpl(
                    imageURL: URL(string: "https://httpbin.org/image/jpeg")!,
                    title: "JPEG",
                    subtitle: "image/jpeg · lossy, widely supported",
                    badge: "JPEG",
                    badgeColor: .systemOrange,
                    options: ImageLoadOptions(placeholder: placeholder, transition: .fade(0.3))
                ),
                ImageDemoCellViewModelImpl(
                    imageURL: URL(string: "https://httpbin.org/image/png")!,
                    title: "PNG",
                    subtitle: "image/png · lossless with alpha channel",
                    badge: "PNG",
                    badgeColor: .systemPurple,
                    options: ImageLoadOptions(placeholder: placeholder, transition: .fade(0.3))
                ),
                ImageDemoCellViewModelImpl(
                    imageURL: URL(string: "https://httpbin.org/image/webp")!,
                    title: "WebP",
                    subtitle: "image/webp · modern, efficient format",
                    badge: "WEBP",
                    badgeColor: .systemTeal,
                    options: ImageLoadOptions(placeholder: placeholder, transition: .fade(0.3))
                ),
            ]
        )

        // Section 3 — Error Handling: 404, 503, binary garbage
        let errorSection = ImageDemoSection(
            header: "ERROR HANDLING — 404 · 503 · Decode failure",
            items: [
                ImageDemoCellViewModelImpl(
                    imageURL: URL(string: "https://httpbin.org/status/404")!,
                    title: "HTTP 404",
                    subtitle: "→ ImageLoaderError.badResponse(404)",
                    badge: "404",
                    badgeColor: .systemRed,
                    options: ImageLoadOptions(placeholder: placeholder, failureImage: failureImage, transition: .none)
                ),
                ImageDemoCellViewModelImpl(
                    imageURL: URL(string: "https://httpbin.org/status/503")!,
                    title: "HTTP 503",
                    subtitle: "→ ImageLoaderError.badResponse(503)",
                    badge: "503",
                    badgeColor: .systemRed,
                    options: ImageLoadOptions(placeholder: placeholder, failureImage: failureImage, transition: .none)
                ),
                ImageDemoCellViewModelImpl(
                    imageURL: URL(string: "https://httpbin.org/bytes/64")!,
                    title: "Decode Failure",
                    subtitle: "64 random bytes → ImageLoaderError.decodingFailed",
                    badge: "ERR",
                    badgeColor: .systemOrange,
                    options: ImageLoadOptions(placeholder: placeholder, failureImage: failureImage, transition: .none)
                ),
            ]
        )

        // Section 4 — Cell Reuse: 20 cells to scroll and test in-flight cancellation
        let reuseSection = ImageDemoSection(
            header: "CELL REUSE — Scroll fast to test request cancellation",
            items: (20...39).map { i in
                ImageDemoCellViewModelImpl(
                    imageURL: URL(string: "https://picsum.photos/seed/\(i)/200/200")!,
                    title: "Scroll Cell #\(i - 19)",
                    subtitle: "picsum.photos/seed/\(i) · fast scroll cancels in-flight",
                    badge: nil,
                    badgeColor: .systemBlue,
                    options: ImageLoadOptions(placeholder: placeholder, transition: .fade(0.3))
                )
            }
        )

        // Section 5 — Preload demo: tap Preload before scrolling here → instant cache hit, no fade
        let preloadSection = ImageDemoSection(
            header: "PRELOAD — Tap Preload ↑ before scrolling here",
            items: (50...57).map { i in
                ImageDemoCellViewModelImpl(
                    imageURL: URL(string: "https://picsum.photos/seed/\(i)/300/200")!,
                    title: "Preload #\(i - 49)",
                    subtitle: "Preloaded → no fade · Not preloaded → fade(0.3s)",
                    badge: "PRE",
                    badgeColor: .systemIndigo,
                    options: ImageLoadOptions(placeholder: placeholder, transition: .fade(0.3))
                )
            }
        )

        // Section 6 — Force Refresh: same URLs as Section 0 but always fetches from network
        let forceRefreshSection = ImageDemoSection(
            header: "FORCE REFRESH — Same URLs as Section 0, cache ignored",
            items: fadeURLs.prefix(3).enumerated().map { i, url in
                ImageDemoCellViewModelImpl(
                    imageURL: url,
                    title: "Force #\(i + 1)",
                    subtitle: "Scroll back → still fades · Section 0 same URL → instant",
                    badge: "FORCE",
                    badgeColor: .systemPink,
                    options: ImageLoadOptions(
                        placeholder: placeholder,
                        transition: .fade(0.3),
                        cachePolicy: .reloadIgnoringCache
                    )
                )
            }
        )

        return [fadeSection, cacheSection, formatSection, errorSection, reuseSection, preloadSection, forceRefreshSection]
    }
}

// MARK: - ImageLoadingViewModelProtocol

extension ImageLoadingViewModel: ImageLoadingViewModelProtocol {
    func clearCache() async {
        await ImageLoader.shared.cache.clearAll()
        sections = makeSections()
        reload()
    }

    func preloadBatch() {
        let urls = sections[5].items.map(\.imageURL)
        Task { await ImageLoader.shared.preload(urls: urls) }
    }

    func reload() {
        view?.reloadData()
    }
}

// MARK: - ViewLifecycleable

extension ImageLoadingViewModel: ViewLifecycleable {
    func onViewWillDisappear() { Task { await ImageLoader.shared.cancelPreloads() } }
}

// MARK: - CollectionViewable

extension ImageLoadingViewModel: CollectionViewable {
    func getNumberOfSections() -> Int { sections.count }

    func getNumberOfItems(in section: Int) -> Int { sections[section].items.count }

    func onCellForItem(in section: Int, at index: Int) -> ViewModel? { sections[section].items[index] }

    func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { ImageDemoCell.reuseIdentifier }

    func onHeaderItemReuseIdentifierRequested(in section: Int) -> String { ListSectionHeaderView.reuseIdentifier }

    func onHeaderItemDataSourceRequested(in section: Int) -> ViewModel? {
        ListSectionHeaderViewModelImpl(title: sections[section].header)
    }

    func onSizeForItem(in section: Int, at index: Int) -> (width: Double, height: Double) { (view?.screenWidth ?? 375, 92) }

    func onSizeForHeaderItem(in section: Int) -> (width: Double, height: Double) { (view?.screenWidth ?? 375, 36) }

    func onMinimumLineSpacingFor(section: Int) -> Double { 4 }

    func onInsetFor(section: Int) -> Inset { (top: 4, left: 0, bottom: 8, right: 0) }
}

// MARK: - CollectionViewReloadable

protocol CollectionViewReloadable: AnyObject, ScreenSizeMeasurable {
    func reloadData()
}
