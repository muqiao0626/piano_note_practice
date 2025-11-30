import SwiftUI

struct StartScreen: View {
    @ObservedObject var session: PracticeSession
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Piano Practice")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Select Practice Duration")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Picker("Duration", selection: $session.selectedDuration) {
                ForEach(session.durationOptions, id: \.self) { duration in
                    Text("\(duration) min").tag(duration)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 40)
            
            Button(action: {
                session.startPractice()
            }) {
                Text("Start Practice")
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
