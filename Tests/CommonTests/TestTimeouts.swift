//
//  TestTimeouts.swift
//

import Foundation

/// Single ceiling for "the async callback eventually arrives" waits.
///
/// `fulfillment` returns the moment the expectation fulfills, so green runs
/// never pay the ceiling — only broken runs do. 30s absorbs degraded runners
/// (the incident that raised HTTPServiceTests from 3s); every suite waiting on
/// the same failure mode uses this one constant so the ceiling can't drift
/// apart per file again.
let callbackDeliveryTimeout: TimeInterval = 30
