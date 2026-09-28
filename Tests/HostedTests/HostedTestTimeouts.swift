//
//  HostedTestTimeouts.swift
//

import Foundation

/// Single ceiling for "the presentation, dismissal or callback eventually happens" waits in the hosted lane, as
/// `callbackDeliveryTimeout` is in the unit lane. `fulfillment` returns the moment an expectation fulfills, so green
/// runs never pay it; a loaded machine needs the room.
let transitionTimeout: TimeInterval = 30
