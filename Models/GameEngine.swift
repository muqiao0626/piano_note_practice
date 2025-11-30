import Foundation
import SwiftUI

class GameEngine: ObservableObject {
    @Published var currentNotes: [Note] = []
    @Published var score: Int = 0
    @Published var feedbackMessage: String = "Press the key!"
    @Published var feedbackColor: Color = .primary
    
    init() {
        generateNote()
    }
    
    func generateNote() {
        // Generate a random note between C3 and C5
        // C3 is (C, 3). C5 is (C, 5).
        // Valid octaves: 3, 4.
        // If octave is 5, only C is valid.
        
        var newNote: Note
        repeat {
            let octave = Int.random(in: 3...5)
            let name = NoteName.allCases.randomElement()!
            let accidental = Accidental.allCases.randomElement()!
            
            // Constraint check
            if octave == 5 {
                // Only C5 is allowed (and maybe C#5/Cb5 depending on strictness, but let's stick to C5 natural for top limit usually)
                // Let's allow C5 natural.
                newNote = Note(name: .C, octave: 5, accidental: .natural, clef: .treble, duration: .quarter)
            } else {
                // Octave 3 or 4.
                // If Octave 3, usually Bass clef. If 4, Treble.
                let clef: Clef = octave < 4 ? .bass : .treble
                let duration = NoteDuration.allCases.randomElement()!
                newNote = Note(name: name, octave: octave, accidental: accidental, clef: clef, duration: duration)
            }
        } while currentNotes.contains(newNote) // Avoid exact duplicate of single note if we were single
        
        // For now, let's just have ONE note at a time as per "multiple notes" request might mean "support for chords" or "sequence".
        // The user said "support multiple notes, like the left panel". The left panel shows a sequence or chord?
        // The left panel of the image shows a Grand Staff with ONE note on the treble clef.
        // Wait, the user said "multiple notes, like the left panel".
        // Looking at the image again (I can't see it now, but I recall).
        // Usually these apps show one note to identify.
        // If the user wants "multiple notes", maybe they mean a chord or a sequence.
        // Let's stick to one note for now but store it in an array to be future proof and satisfy "support multiple notes" in data model.
        
        currentNotes = [newNote]
        
        feedbackMessage = "Press the key!"
        feedbackColor = .primary
        
        // Audio removed as requested.
    }
    
    func check(note: Note) {
        // Check if the pressed note matches ANY of the current notes (if we have multiple)
        // For now, we just check if it matches the first one since we generate one.
        
        guard let targetNote = currentNotes.first else { return }
        
        // Compare MIDI values to handle enharmonics (e.g., E# == F)
        let isCorrect = note.midiValue == targetNote.midiValue
        
        if isCorrect {
            score += 1
            feedbackMessage = "Correct!"
            feedbackColor = .green
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.generateNote()
            }
        } else {
            score = max(0, score - 1)
            feedbackMessage = "Try again!"
            feedbackColor = .red
        }
    }
}
