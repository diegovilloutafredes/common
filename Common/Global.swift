//
//  Global.swift
//

/// Global functions
/// Global functions
// MARK: - dispatchOnGlobal

/// Dispatches a block of code asynchronously on a global concurrent queue with the specified quality of service.
/// - Parameters:
///   - qos: The quality of service class for the work to be performed. Defaults to `.default`.
///   - action: The block of code to execute.
public func dispatchOnGlobal(_ qos: DispatchQoS.QoSClass = .default, action: @escaping Action) { DispatchQueue.global(qos: qos).async(execute: action) }


// MARK: - dispatchOnGlobalAfter

/// Dispatches a block of code asynchronously on a global concurrent queue after a specified deadline.
/// - Parameters:
///   - qos: The quality of service class for the work to be performed. Defaults to `.default`.
///   - deadline: The time at which the block should execute.
///   - action: The block of code to execute.
public func dispatchOnGlobalAfter(_ qos: DispatchQoS.QoSClass = .default, deadline: DispatchTime, action: @escaping Action) { DispatchQueue.global(qos: qos).asyncAfter(deadline: deadline, execute: action) }


// MARK: - dispatchOnMain

/// Dispatches a block of code asynchronously on the main queue.
/// - Parameter action: The block of code to execute.
public func dispatchOnMain(_ action: @escaping Action) { DispatchQueue.main.async(execute: action) }


// MARK: - dispatchOnMainAfter

/// Dispatches a block of code asynchronously on the main queue after a specified deadline.
/// - Parameters:
///   - deadline: The time at which the block should execute.
///   - action: The block of code to execute.
public func dispatchOnMainAfter(_ deadline: DispatchTime, action: @escaping Action) { DispatchQueue.main.asyncAfter(deadline: deadline, execute: action) }


// MARK: - EmptyResult

/// A result type that represents either a successful void completion or a failure with an error.
public enum EmptyResult<Failure: Error> {
    /// Indicates a successful completion.
    case success
    /// Indicates a failure with an error.
    case failure(Failure)
}
