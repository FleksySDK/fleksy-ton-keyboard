//  SubscribeKeyboardAppTracker.swift
//  Keyboard
//
//  Copyright © 2024 Thingthing. All rights reserved.
//
//

import Foundation

/// This class contains the logic to decide when the `SubscribeKeyboardApp` should be opened.
final class SubscribeKeyboardAppTracker {
    
    static let shared = SubscribeKeyboardAppTracker()
    
    private static let maxConsecutiveDaysToOpen: Int = 5
    
    private let defaults: UserDefaults
    private let maxConsecutiveDaysToOpen: Int
    private let currentDateGenerator: () -> Date
    
    init(defaults: UserDefaults = .standard,
         maxConsecutiveDaysToOpen: Int = SubscribeKeyboardAppTracker.maxConsecutiveDaysToOpen,
         currentDateGenerator: @escaping () -> Date = Date.init)
    {
        self.defaults = defaults
        self.maxConsecutiveDaysToOpen = maxConsecutiveDaysToOpen
        self.currentDateGenerator = currentDateGenerator
    }
    
    
    
    private static let nextOpenDateKey = Constants.SubscribeKeyboardAppId + ".defaults.lastOpenedDate"
    private var nextOpenDate: Date {
        get {
            if let date = defaults.value(forKey: Self.nextOpenDateKey) as? Date {
                return date
            } else {
                let now = currentDateGenerator()
                self.nextOpenDate = now
                return now
            }
        }
        set {
            defaults.setValue(newValue, forKey: Self.nextOpenDateKey)
        }
    }
    
    private static let lastIterationKey = Constants.SubscribeKeyboardAppId + ".defaults.lastIteration"
    private var lastIteration: Int {
        get {
            defaults.integer(forKey: Self.lastIterationKey)
        }
        set {
            defaults.set(newValue, forKey: Self.lastIterationKey)
        }
    }
    
    func shouldOpen() -> Bool {
        let nextOpenDate = self.nextOpenDate
        let now = currentDateGenerator()
        guard now >= nextOpenDate else {
            return false
        }
        
        if now.timeIntervalSince(nextOpenDate) > convertToSeconds(days: maxConsecutiveDaysToOpen) {
            updateNextOpenDate()
            return false
        } else {
            return true
        }
    }
    
    /// Call this method when the user manually closes the Subscribe keyboard app
    func trackAppClosedManually() {
        updateNextOpenDate()
    }
    
    private func updateNextOpenDate() {
        let iteration = lastIteration + 1
        let numberOfDaysToWait = fibonacciElement(iteration)
        let nextOpenDate = currentDateGenerator().advanced(by: convertToSeconds(days: numberOfDaysToWait))
        
        self.lastIteration = iteration
        self.nextOpenDate = nextOpenDate
    }
}

fileprivate func fibonacciElement(_ n: Int) -> Int {
    guard n > 1 else { return 1 }
    var (a, b) = (1, 1)
    
    (2...n).forEach { _ in
        (a, b) = (a + b, a)
    }
    return a
}

fileprivate func convertToSeconds(days: Int) -> TimeInterval {
    TimeInterval(days * 24 * 60 * 60)
}
