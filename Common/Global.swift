//
//  Global.swift
//

/// Global functions
// MARK: - dispatchOnGlobal
public func dispatchOnGlobal(_ qos: DispatchQoS.QoSClass = .default, action: @escaping Action) { DispatchQueue.global(qos: qos).async(execute: action) }


// MARK: - dispatchOnGlobalAfter
public func dispatchOnGlobalAfter(_ qos: DispatchQoS.QoSClass = .default, deadline: DispatchTime, action: @escaping Action) { DispatchQueue.global(qos: qos).asyncAfter(deadline: deadline, execute: action) }


// MARK: - dispatchOnMain
public func dispatchOnMain(_ action: @escaping Action) { DispatchQueue.main.async(execute: action) }


// MARK: - dispatchOnMainAfter
public func dispatchOnMainAfter(_ deadline: DispatchTime, action: @escaping Action) { DispatchQueue.main.asyncAfter(deadline: deadline, execute: action) }
