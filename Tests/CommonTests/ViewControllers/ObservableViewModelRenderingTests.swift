//
//  ObservableViewModelRenderingTests.swift
//

import Observation
import UIKit
import XCTest
@testable import Common

// MARK: - Fixtures (file scope: the @Observable macro cannot expand on a nested private type)

@available(iOS 17.0, *)
@MainActor
fileprivate protocol StatusViewModelProtocol: ViewModel, CollectionViewable {
    var statusText: String { get }
    var revision: Int { get }
}

@available(iOS 17.0, *)
@Observable
@MainActor
fileprivate final class StatusViewModel: StatusViewModelProtocol {
    private(set) var statusText = "idle"
    private(set) var revision: Int = .zero
    @ObservationIgnored private var items: [Int] = [] {
        didSet { revision += 1 }
    }
    func load() {
        items = []
        statusText = "loading"
    }
    func finish() {
        items = [1, 2, 3]
        statusText = "done"
    }
    func getNumberOfItems(in section: Int) -> Int { items.count }
    func onCellForItem(in section: Int, at index: Int) -> ViewModel? { nil }
    func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { .empty }
    func onSizeForItem(in section: Int, at index: Int) -> Size { (10, 10) }
}

@available(iOS 17.0, *)
fileprivate final class StatusViewController: BaseCollectionViewableViewController<StatusViewModelProtocol> {
    let label = UILabel()
    private(set) var updates: Int = .zero
    private(set) var reloads: Int = .zero
    private var renderedRevision: Int = .zero
    @UIViewBuilder override var mainView: UIView { VStack { label } }
    override func updateContent() {
        super.updateContent()
        updates += 1
        label.text = viewModel.statusText
        if renderedRevision != viewModel.revision {
            renderedRevision = viewModel.revision
            reloads += 1
        }
    }
}

/// Reproduces the DemoApp shape: an `@Observable @MainActor` view model behind a `@MainActor`
/// protocol existential, rendered by the controller's own `updateContent()` override.
@available(iOS 17.0, *)
@MainActor
final class ObservableViewModelRenderingTests: XCTestCase {

    private var window: UIWindow?

    override func tearDown() {
        ObservationMode.override = nil
        window?.isHidden = true
        window = nil
        super.tearDown()
    }

    private func host(_ vc: UIViewController) {
        let window = UIWindow(frame: .init(x: .zero, y: .zero, width: 320, height: 480))
        window.rootViewController = vc
        window.isHidden = false
        self.window = window
    }

    func test_nativeMode_controllerOverrideRerunsWhenObservableViewModelChanges() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("native path needs iOS 26") }
        ObservationMode.override = .native
        let viewModel = StatusViewModel()
        let vc = StatusViewController(viewModel: viewModel)
        host(vc)

        vc.updatePropertiesIfNeeded()
        XCTAssertEqual(vc.label.text, "idle")
        XCTAssertEqual(vc.updates, 1)

        viewModel.load()
        vc.updatePropertiesIfNeeded()
        XCTAssertEqual(vc.label.text, "loading")
        XCTAssertEqual(vc.reloads, 1, "revision bump must be seen")

        viewModel.finish()
        vc.updatePropertiesIfNeeded()
        XCTAssertEqual(vc.label.text, "done")
        XCTAssertEqual(vc.reloads, 2)
    }

    func test_manualMode_controllerOverrideRerunsWhenObservableViewModelChanges() {
        ObservationMode.override = .manual
        let viewModel = StatusViewModel()
        let vc = StatusViewController(viewModel: viewModel)
        vc.loadViewIfNeeded()
        vc.view.frame = .init(x: .zero, y: .zero, width: 320, height: 480)

        vc.view.layoutIfNeeded()
        XCTAssertEqual(vc.label.text, "idle")

        viewModel.load()
        XCTAssertTrue(vc.view.layer.needsLayout())
        vc.view.layoutIfNeeded()
        XCTAssertEqual(vc.label.text, "loading")
        XCTAssertEqual(vc.reloads, 1)
    }
}
