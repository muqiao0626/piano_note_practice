import SwiftUI

struct ContentView: View {
    @StateObject var engine = GameEngine()
    @State private var showDebug = false
    @State private var bassClefOffset: CGFloat = -180
    
    var body: some View {
        VStack {
            // Header / Score
            HStack {
                Text("Score: \(engine.score)")
                    .font(.title)
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
                .frame(height: 250)
        }
        .frame(minWidth: 600, minHeight: 500)
        .background(Color.white) 
    }
}
