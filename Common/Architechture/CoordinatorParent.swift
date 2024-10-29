//
//  CoordinatorParent.swift
//

// MARK: - CoordinatorParent
public protocol CoordinatorParent: AnyObject {
    func onProcessDone(by child: some Coordinator)
}
