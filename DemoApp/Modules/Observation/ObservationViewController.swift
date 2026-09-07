//
//  ObservationViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ObservationViewController
final class ObservationViewController: BaseCollectionViewableViewController<ObservationViewModelProtocol> {

    private enum Layout {
        static let cardMargin: CGFloat = 16
        static let sectionMargin: CGFloat = 12
        static let barNarrow: CGFloat = 80
        static let barWide: CGFloat = 240
    }

    private lazy var countLabel = UILabel("Count: 0")
        .font(.monospacedSystemFont(ofSize: 34, weight: .bold))
        .textColor(.label)
        .textAlignment(.center)

    private lazy var modeLabel = UILabel()
        .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
        .textColor(.secondaryLabel)
        .textAlignment(.center)
        .numberOfLines(0)

    private lazy var incrementButton = actionButton("Increment", color: .systemBlue) { [weak self] in self?.viewModel.increment() }
    private lazy var resetButton = actionButton("Reset", color: .systemGray) { [weak self] in self?.viewModel.reset() }
    private lazy var markAllReadButton = actionButton("Mark all read", color: .systemGreen) { [weak self] in self?.viewModel.markAllRead() }
    private lazy var addMessageButton = actionButton("Add message", color: .systemTeal) { [weak self] in self?.viewModel.addMessage() }
    private lazy var removeMessageButton = actionButton("Remove last", color: .systemOrange) { [weak self] in self?.viewModel.removeLastMessage() }
    private lazy var toggleBarButton = actionButton("Toggle width", color: .systemPink) { [weak self] in self?.toggleBar() }
    private lazy var saveDraftButton = actionButton("Save draft", color: .systemIndigo) { [weak self] in self?.viewModel.saveDraft() }

    private lazy var bar = UIView()
        .backgroundColor(.systemPink)
        .round(radius: 12)
        .with { $0.isAccessibilityElement = true; $0.accessibilityIdentifier = "observation.bar"; $0.accessibilityLabel = "Width bar" }
        .setConstraints { $0.set(height: 24) }

    /// Constant written in `updateContent()` from `viewModel.isBarExpanded`.
    private lazy var barWidth = bar.widthAnchor.constraint(equalToConstant: Layout.barNarrow)

    private lazy var barLabel = UILabel()
        .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
        .textColor(.secondaryLabel)
        .textAlignment(.center)

    private lazy var badge = UnreadBadgeView { [weak self] in self?.viewModel.messages ?? [] }

    private lazy var savesLabel = UILabel("Saves: 0")
        .font(.monospacedSystemFont(ofSize: 20, weight: .bold))
        .textColor(.label)
        .textAlignment(.center)

    private lazy var list = VList(dataSource: self, delegate: self) { $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize }
        .register(MessageCell.self)
        .backgroundColor(.clear)
        .isScrollEnabled(false)

    /// Sized to the list's content in `viewDidLayoutSubviews()` — derived geometry, kept out of the hook.
    private lazy var listHeight = list.heightAnchor.constraint(equalToConstant: MessageCell.height * 4)

    /// The revision last pushed into the list; `updateContent()` re-runs for any tracked change,
    /// so the reload is gated on the revision it read.
    private var renderedRevision: Int = .zero

    /// Acts on each `viewModel.event` once, however many times the hook re-runs.
    private var eventCursor = ViewEventCursor()

    @UIViewBuilder override var mainView: UIView {
        UIScrollView {
            VStack(margins: .init(top: 24, left: Layout.cardMargin, bottom: 32, right: Layout.cardMargin), spacing: 16) {
                demoSection(
                    title: "ViewController.updateContent()",
                    description: "The default shape. The buttons only mutate tracked properties on the @Observable view model; the controller reads them in one hook that UIKit (iOS 26) or Common (iOS 17–18) re-runs."
                ) {
                    VStack(spacing: 12) {
                        countLabel
                        modeLabel
                        HStack(distribution: .fillEqually, spacing: 8) {
                            incrementButton
                            resetButton
                        }
                    }
                }
                demoSection(
                    title: "BaseView.updateContent()",
                    description: "A BaseView renders itself from the message models. Tap a row or \"Mark all read\" and watch it update with no delegate."
                ) {
                    badge
                }
                demoSection(
                    title: "BaseViewModelableCell.updateContent()",
                    description: "Cells bind in updateContent() instead of viewModel didSet. Assignment binds synchronously (these rows self-size), later model changes re-run it — no reloadData."
                ) {
                    VStack(spacing: 12) {
                        markAllReadButton
                        list
                    }
                }
                demoSection(
                    title: "Collections behind a revision",
                    description: "The array is @ObservationIgnored; membership changes bump a tracked revision and the controller reloads the list above only when the revision it rendered moved. Tapping a row never reloads."
                ) {
                    HStack(distribution: .fillEqually, spacing: 8) {
                        addMessageButton
                        removeMessageButton
                    }
                }
                demoSection(
                    title: "Constraints from state",
                    description: "The bar's width is a constraint constant written in updateContent() from a tracked Bool. The tap mutates inside an animation block — .flushUpdates on iOS 26, animateConstraints(constraintChanges:) below — so the layout pass that applies the hook's change is animated."
                ) {
                    VStack(spacing: 12) {
                        VStack(alignment: .leading) { bar }   // .leading: the bar keeps its own width
                        barLabel
                        toggleBarButton
                    }
                }
                demoSection(
                    title: "State vs events",
                    description: "One tap does both. The saves count is state: the hook reads it and may render it many times. The confirmation is a ViewEvent: the same hook consumes it through a cursor, once per firing, with no view protocol."
                ) {
                    VStack(spacing: 12) {
                        savesLabel
                        saveDraftButton
                    }
                }
            }
            .setConstraints {
                $0.snap(to: $1)
                $0.setWidth(to: $1.widthAnchor)
            }
        }
        .setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }
    }

    override func setupView() {
        super.setupView()
        backgroundColor(.systemBackground)
        set(title: viewModel.title)
        modeLabel.text("ObservationMode.current = .\(ObservationMode.current)")
        listHeight.isActive = true
        barWidth.isActive = true
    }

    /// Single render point: text, flags and the bar's constraint constant. The list height is
    /// derived from layout and is synced after it instead.
    override func updateContent() {
        super.updateContent()
        countLabel.text("Count: \(viewModel.count)")
        resetButton.isEnabled(viewModel.count > .zero)
        savesLabel.text("Saves: \(viewModel.saves)")
        removeMessageButton.isEnabled(viewModel.messages.isNotEmpty)
        barWidth.constant = viewModel.isBarExpanded ? Layout.barWide : Layout.barNarrow   // applied by the layout pass that follows
        barLabel.text("bar.width = \(Int(barWidth.constant))")
        if renderedRevision != viewModel.revision {
            renderedRevision = viewModel.revision
            list.reloadData()
            badge.setNeedsContentUpdate()   // the badge's rows changed; its own tracking only covers isRead
        }
        eventCursor.consume(viewModel.event) { event in
            switch event {
            case .draftSaved: Snackbar.show(.init(message: "Draft saved"))
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard list.bounds.width > .zero else { return }   // not laid out yet: the content size is meaningless
        let contentHeight = list.collectionViewLayout.collectionViewContentSize.height   // zero when the list is empty
        guard listHeight.constant != contentHeight else { return }
        listHeight.constant = contentHeight
    }

    /// Mutates inside an animation block so the layout pass that applies the hook's constant change is animated.
    /// iOS 26 flushes the pending update pass itself; below, `layoutIfNeeded()` runs the hook inside the block.
    private func toggleBar() {
        if #available(iOS 26.0, *), ObservationMode.current == .native {
            UIView.animate(withDuration: 0.3, delay: .zero, options: .flushUpdates) { [weak self] in self?.viewModel.toggleBar() }
        } else {
            animateConstraints { [weak self] in self?.viewModel.toggleBar() }
        }
    }

    private func actionButton(_ title: String, color: UIColor, onTap: @escaping Action) -> UIButton {
        UIButton(configuration: .filled().with {
            $0.title = title
            $0.baseBackgroundColor = color
            $0.cornerStyle = .capsule
        })
        .onTap(onTap)
        .setConstraints { $0.set(height: 44) }
    }

    private func demoSection(title: String, description: String, @UIViewBuilder content: () -> UIView) -> UIView {
        VStack(margins: .init(all: Layout.sectionMargin), spacing: 8) {
            UILabel(title).font(.boldSystemFont(ofSize: 14)).textColor(.label).numberOfLines(0)
            UILabel(description).font(.systemFont(ofSize: 12)).textColor(.secondaryLabel).numberOfLines(0)
            content()
        }
        .backgroundColor(.secondarySystemBackground)
        .round(radius: 12)
    }
}
