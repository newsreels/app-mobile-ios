//
//  ResumableTimer.swift
//  Bullet
//
//  Created by Faris Muhammed on 30/06/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import Foundation
class ResumableTimer: NSObject {

    private var timer: Timer? = Timer()
    private var callback: () -> Void

    private var startTime: TimeInterval?
    private var elapsedTime: TimeInterval?

    // MARK: Init

    init(interval: Double, callback: @escaping () -> Void) {
        self.callback = callback
        self.interval = interval
    }

    // MARK: API

    var isRepeatable: Bool = false
    var interval: Double = 0.0

    func isPaused() -> Bool {
        guard let timer = timer else { return false }
        return !timer.isValid
    }

    func start() {
        runTimer(interval: interval)
    }

    func pause() {
        elapsedTime = Date.timeIntervalSinceReferenceDate - (startTime ?? 0.0)
        timer?.invalidate()
    }

    func resume() {
        interval -= elapsedTime ?? 0.0
        runTimer(interval: interval)
    }

    func invalidate() {
        timer?.invalidate()
    }

    func reset() {
        startTime = Date.timeIntervalSinceReferenceDate
        runTimer(interval: interval)
    }

    // MARK: Private

    private func runTimer(interval: Double) {
        startTime = Date.timeIntervalSinceReferenceDate

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: isRepeatable) { [weak self] _ in
            self?.callback()
        }
    }
}
