import SwiftUI

struct PianoView: View {
    @ObservedObject var engine: GameEngine
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Render White Keys
                ForEach(0..<whiteKeys.count, id: \.self) { index in
                    let note = whiteKeys[index]
                    let width = geometry.size.width / CGFloat(whiteKeys.count)
                    let height = geometry.size.height
                    let x = CGFloat(index) * width
                    
                    PianoKey(note: note, isBlack: false) {
                        AudioManager.shared.play(note: note)
                        engine.check(note: note)
                    }
                    .frame(width: width, height: height)
                    .position(x: x + width / 2, y: height / 2)
                    .zIndex(0)
                }
                
                // Render Black Keys
                ForEach(blackKeys, id: \.self) { note in
                    let whiteKeyWidth = geometry.size.width / CGFloat(whiteKeys.count)
                    let width = whiteKeyWidth * 0.6
                    let height = geometry.size.height * 0.6
                    let xPos = calculateBlackKeyXPosition(for: note, whiteKeyWidth: whiteKeyWidth)
                    
                    PianoKey(note: note, isBlack: true) {
                        AudioManager.shared.play(note: note)
                        engine.check(note: note)
                    }
                    .frame(width: width, height: height)
                    .position(x: xPos, y: height / 2)
                    .zIndex(1)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
    
    var whiteKeys: [Note] {
        var keys: [Note] = []
        // Add B2 at the lower end
        keys.append(Note(name: .B, octave: 2, accidental: .natural, clef: .bass, duration: .quarter))
        
        for octave in 3...4 {
            for name in NoteName.allCases {
                keys.append(Note(name: name, octave: octave, accidental: .natural, clef: .treble, duration: .quarter))
            }
        }
        keys.append(Note(name: .C, octave: 5, accidental: .natural, clef: .treble, duration: .quarter))
        return keys
    }
    
    var blackKeys: [Note] {
        var keys: [Note] = []
        for octave in 3...4 {
            keys.append(Note(name: .C, octave: octave, accidental: .sharp, clef: .treble, duration: .quarter))
            keys.append(Note(name: .D, octave: octave, accidental: .sharp, clef: .treble, duration: .quarter))
            keys.append(Note(name: .F, octave: octave, accidental: .sharp, clef: .treble, duration: .quarter))
            keys.append(Note(name: .G, octave: octave, accidental: .sharp, clef: .treble, duration: .quarter))
            keys.append(Note(name: .A, octave: octave, accidental: .sharp, clef: .treble, duration: .quarter))
        }
        return keys
    }
    
    func calculateBlackKeyXPosition(for note: Note, whiteKeyWidth: CGFloat) -> CGFloat {
        var baseIndex = 0
        switch note.name {
        case .C: baseIndex = 0
        case .D: baseIndex = 1
        case .F: baseIndex = 3
        case .G: baseIndex = 4
        case .A: baseIndex = 5
        default: break
        }
        
        // Account for B2 at index 0, so octave 3 starts at index 1
        baseIndex += (note.octave - 3) * 7 + 1
        
        // Center of the black key is at the boundary of the white keys.
        return CGFloat(baseIndex + 1) * whiteKeyWidth
    }
}

struct PianoKey: View {
    let note: Note
    let isBlack: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(isBlack ? Color.black : Color.white)
                    .border(Color.black, width: 1)
                
                if !isBlack {
                    Text(note.name.rawValue)
                        .foregroundColor(.black)
                        .padding(.bottom, 5)
                        .font(.caption)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
