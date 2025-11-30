import Foundation
import SwiftUI

enum AppState {
    case start
    case practice
    case summary
}

class PracticeSession: ObservableObject {
    @Published var appState: AppState = .start
    @Published var selectedNoteCount: Int = 20 // number of notes to practice
    @Published var totalSessions: Int = 0
    @Published var correctSessions: Int = 0
    @Published var currentSession: Int = 0
    
    let noteCountOptions = [20, 40, 60, 80, 100]
    
    func startPractice() {
        appState = .practice
        totalSessions = 0
        correctSessions = 0
        currentSession = 0
    }
    
    func endPractice() {
        appState = .summary
    }
    
    func resetForNewPractice() {
        appState = .start
        totalSessions = 0
        correctSessions = 0
        currentSession = 0
    }
    
    var isPracticeComplete: Bool {
        return currentSession >= selectedNoteCount
    }
    
    var remainingSessions: Int {
        return max(0, selectedNoteCount - currentSession)
    }
}
