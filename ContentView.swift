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
    
    @State private var sessionTimer: Int = 30
    @State private var timerSubscription: Timer?
    
    var body: some View {
        VStack {
            // Header with Timer and Controls
            HStack {
                Text("Session: \(session.currentSession + 1)/\(session.selectedNoteCount)")
                    .font(.title2)
                    .padding()
                
                Spacer()
                
                // Session Timer
                VStack(spacing: 2) {
                    Text("\(sessionTimer)s")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(sessionTimer <= 10 ? .red : .primary)
                    Text("Time Left")
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
                    timerSubscription?.invalidate()
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
        }
        .onDisappear {
            timerSubscription?.invalidate()
        }
        .onChange(of: engine.feedbackMessage) { newValue in
            if newValue.contains("Correct") {
                // User got it right - move to next session
                session.correctSessions += 1
                session.totalSessions += 1
                session.currentSession += 1
                
                if session.isPracticeComplete {
                    timerSubscription?.invalidate()
                    session.endPractice()
                } else {
                    // Reset timer after GameEngine generates new note (0.5s delay in GameEngine)
                    timerSubscription?.invalidate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        sessionTimer = 60
                        startSessionTimer()
                    }
                }
            }
        }
        .frame(minWidth: 600, minHeight: 500)
        .background(Color.white)
    }
    
    private func startSessionTimer() {
        timerSubscription = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if sessionTimer > 0 {
                sessionTimer -= 1
            } else {
                // Time's up - mark as incorrect and move to next
                timer.invalidate()
                session.totalSessions += 1
                session.currentSession += 1
                
                if session.isPracticeComplete {
                    session.endPractice()
                } else {
                    // Reset timer and generate new note
                    sessionTimer = 60
                    engine.generateNote()
                    startSessionTimer()
                }
            }
        }
    }
    
    private func skipSession() {
        timerSubscription?.invalidate()
        session.totalSessions += 1
        session.currentSession += 1
        
        if session.isPracticeComplete {
            session.endPractice()
        } else {
            sessionTimer = 60
            engine.generateNote()
            startSessionTimer()
        }
    }
}
