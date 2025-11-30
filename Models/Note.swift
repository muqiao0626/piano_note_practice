import Foundation

enum NoteName: String, CaseIterable {
    case C, D, E, F, G, A, B
}

enum Accidental: String, CaseIterable {
    case natural = ""
    case sharp = "♯"
    case flat = "♭"
}

enum Clef: String, CaseIterable {
    case treble
    case bass
}

enum NoteDuration: CaseIterable {
    case whole
    case half
    case quarter
}

struct Note: Equatable, Identifiable, Hashable {
    let id = UUID()
    let name: NoteName
    let octave: Int
    let accidental: Accidental
    let clef: Clef
    let duration: NoteDuration
    
    var fullName: String {
        "\(name.rawValue)\(accidental.rawValue)\(octave)"
    }
    
    // Helper to calculate offset from Middle C (C4)
    // This is a simplified calculation for visual placement on the staff
    var staffOffset: Int {
        let baseOffset: Int
        switch name {
        case .C: baseOffset = 0
        case .D: baseOffset = 1
        case .E: baseOffset = 2
        case .F: baseOffset = 3
        case .G: baseOffset = 4
        case .A: baseOffset = 5
        case .B: baseOffset = 6
        }
        return baseOffset + (octave - 4) * 7
    }
    
    // MIDI Value for pitch comparison (C4 = 60)
    var midiValue: Int {
        let baseValue: Int
        switch name {
        case .C: baseValue = 0
        case .D: baseValue = 2
        case .E: baseValue = 4
        case .F: baseValue = 5
        case .G: baseValue = 7
        case .A: baseValue = 9
        case .B: baseValue = 11
        }
        
        var value = baseValue + (octave + 1) * 12
        
        switch accidental {
        case .sharp: value += 1
        case .flat: value -= 1
        case .natural: break
        }
        
        return value
    }
    
    static func random(minOctave: Int = 3, maxOctave: Int = 5) -> Note {
        let name = NoteName.allCases.randomElement()!
        let octave = Int.random(in: minOctave...maxOctave)
        let accidental = Accidental.allCases.randomElement()!
        let clef: Clef = octave < 4 ? .bass : .treble
        let duration = NoteDuration.allCases.randomElement()!
        
        return Note(name: name, octave: octave, accidental: accidental, clef: clef, duration: duration)
    }
}
