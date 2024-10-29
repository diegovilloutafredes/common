//
//  CustomViewController.swift
//

import UIKit

// MARK: - CustomViewController
final public class CustomViewController<View: UIView & ViewLifecycleable>: BaseViewController {
    private let _view: View

    public init(view: View) {
        self._view = view
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("NSCoder is not supported")
    }

    @UIViewBuilder public override var mainView: UIView { _view.setConstraints { $0.snap(to: $1) } }

    public override func viewDidLoad() {
        super.viewDidLoad()
        _view.onViewDidLoad()
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        _view.onViewWillLayoutSubviews()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _view.onViewDidLayoutSubviews()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _view.onViewWillAppear()
    }

    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        _view.onViewIsAppearing()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _view.onViewDidAppear()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _view.onViewWillDisappear()
    }
}
