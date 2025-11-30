import SwiftUI

struct ContentView: View {
    @StateObject var session = PracticeSession()
    @StateObject var engine = GameEngine()
    @State private var showDebug = false
    @State private var bassClefOffset: CGFloat = -180
    
    var body: some View {
        switch session.appState {
        case .start:
            StartScreen(session: session)
        case .practice:
            PracticeView(session: session, engine: engine, showDebug: $showDebug, bassClefOffset: $bassClefOffset)
        case .summary:
            SummaryScreen(session: session, engine: engine)
        }
    }
}

struct PracticeView: View {
    @ObservedObject var session: PracticeSession
    @ObservedObject var engine: GameEngine
    @Binding var showDebug: Bool
    @Binding var bassClefOffset: CGFloat
    
    @State private var practiceTimer: Timer?
    @State private var sessionTimer: Int = 60
    
    var body: some View {
        VStack {
            // Header with Timer and Controls
            HStack {
                Text("Score: \(engine.score)")
                    .font(.title)
                    .padding()
                
                Spacer()
                
                // Session Timer
                VStack(spacing: 2) {
                    Text("\(sessionTimer)s")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(sessionTimer <= 10 ? .red : .primary)
                    Text("Session Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                Spacer()
                
                Toggle("Debug", isOn: $showDebug)
                    .padding()
                
                Spacer()
                
                Text(engine.feedbackMessage)
                    .font(.headline)
                    .foregroundColor(engine.feedbackColor)
                    .padding()
            }
            
            if showDebug {
                HStack {
                    Text("Bass Clef Offset: \(Int(bassClefOffset))")
                    Slider(value: $bassClefOffset, in: -200...200, step: 10)
                }
                .padding()
            }
            
            Spacer()
            
            // Staff
            if let note = engine.currentNotes.first {
                StaffView(note: note, showDebug: showDebug, bassClefOffset: bassClefOffset)
            }
            
            Spacer()
            
            // Piano
            PianoView(engine: engine)
                .frame(height: 200)
            
            // Control Buttons
            HStack(spacing: 20) {
                Button(action: {
                    skipSession()
                }) {
                    Text("Skip")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 50)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    practiceTimer?.invalidate()
                    session.endPractice()
                }) {
                    Text("End Practice")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 180, height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .onAppear {
            startSessionTimer()
            startPracticeTimer()
        }
        .onDisappear {
            practiceTimer?.invalidate()
        }
        .frame(minWidth: 600, minHeight: 500)
        .background(Color.white)
    }
    
    private func startSessionTimer() {
        sessionTimer = 60
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if sessionTimer > 0 {
                sessionTimer -= 1
            } else {
                timer.invalidate()
                // Auto-advance to next note
                session.totalSessions += 1
                engine.generateNote()
                startSessionTimer()
            }
        }
    }
    
    private func skipSession() {
        session.totalSessions += 1
        engine.generateNote()
        startSessionTimer()
    }
    
    private func startPracticeTimer() {
        practiceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if session.isPracticeTimeUp {
                practiceTimer?.invalidate()
                session.endPractice()
            }
        }
    }
}
