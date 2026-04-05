//
//  Coordinator.swift
//

// MARK: - Coordinator
// MARK: - Coordinator

/// A protocol defining the responsibilities of a Coordinator.
/// Coordinators are responsible for managing navigation flow and view controller hierarchy.
public protocol Coordinator: AnyObject {
    
    /// Starts the coordinator's flow.
    /// This method should set up the initial view controller(s) and present them.
    func start()
}
