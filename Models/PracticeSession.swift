import Foundation
import SwiftUI

enum AppState {
    case start
    case practice
    case summary
}

class PracticeSession: ObservableObject {
    @Published var appState: AppState = .start
    @Published var selectedDuration: Int = 10 // minutes
    @Published var totalSessions: Int = 0
    @Published var correctSessions: Int = 0
    @Published var practiceStartTime: Date?
    @Published var practiceEndTime: Date?
    
    let durationOptions = [10, 20, 30, 40, 50, 60]
    
    func startPractice() {
        appState = .practice
        totalSessions = 0
        correctSessions = 0
        practiceStartTime = Date()
        practiceEndTime = Date().addingTimeInterval(TimeInterval(selectedDuration * 60))
    }
    
    func endPractice() {
        appState = .summary
    }
    
    func resetForNewPractice() {
        appState = .start
        totalSessions = 0
        correctSessions = 0
        practiceStartTime = nil
        practiceEndTime = nil
    }
    
    var isPracticeTimeUp: Bool {
        guard let endTime = practiceEndTime else { return false }
        return Date() >= endTime
    }
    
    var remainingPracticeTime: TimeInterval {
        guard let endTime = practiceEndTime else { return 0 }
        return max(0, endTime.timeIntervalSinceNow)
    }
}
