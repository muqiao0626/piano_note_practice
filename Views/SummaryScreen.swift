import SwiftUI

struct SummaryScreen: View {
    @ObservedObject var session: PracticeSession
    @ObservedObject var engine: GameEngine
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Practice Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 20) {
                Text("Results")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 50) {
                    VStack {
                        Text("\(session.correctSessions)")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.green)
                        Text("Correct")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("\(session.totalSessions)")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.blue)
                        Text("Total")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                
                if session.totalSessions > 0 {
                    let percentage = (Double(session.correctSessions) / Double(session.totalSessions)) * 100
                    Text(String(format: "Accuracy: %.1f%%", percentage))
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
            
            Button(action: {
                session.resetForNewPractice()
            }) {
                Text("Practice Again")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 250, height: 60)
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            
            Spacer()
        }
        .padding()
    }
}
