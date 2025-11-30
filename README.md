# Piano Practice - Note Reading Trainer

A SwiftUI-based piano practice application designed to help users improve their music note reading skills on both treble and bass clefs.

## Overview

This application is an interactive sight-reading trainer that displays musical notes on a grand staff and challenges users to identify and play the correct notes on a virtual piano keyboard. It's designed for macOS and iOS (requires macOS 12+ or iOS 15+).

## Features

### 🎵 Core Functionality
- **Grand Staff Display**: Visual representation with both treble (𝄞) and bass (𝄢) clefs
- **Interactive Piano Keyboard**: Two-octave piano (B2-C5) with both white and black keys
- **Audio Playback**: Realistic piano sound synthesis with harmonics and ADSR envelope
- **Real-time Feedback**: Instant visual feedback when playing correct or incorrect notes
- **Timed Sessions**: 30-second timer per note to encourage quick recognition
- **Progress Tracking**: Tracks accuracy and performance throughout practice sessions

### 🎯 Practice Sessions
Users can customize their practice with different session lengths:
- 20 notes
- 40 notes  
- 60 notes
- 80 notes
- 100 notes

### 📊 Performance Analytics
- **Correct Sessions**: Number of correctly identified notes
- **Total Sessions**: Total number of notes attempted (includes timeouts and skips)
- **Accuracy Percentage**: Calculated as (Correct / Total) × 100%
- **Summary Screen**: Displays detailed results after each practice session

## Application Structure

### Models
- **`Note.swift`**: Core data model for musical notes
  - Supports note names (C, D, E, F, G, A, B)
  - Handles accidentals (natural, sharp ♯, flat ♭)
  - Manages clefs (treble, bass)
  - Implements note durations (whole, half, quarter)
  - Calculates MIDI values and staff positions

- **`GameEngine.swift`**: Game logic controller
  - Generates random notes between C3 and C5
  - Validates user input against target notes
  - Manages scoring and feedback messages
  - Handles MIDI value comparison for enharmonic equivalents (e.g., E♯ = F)

- **`PracticeSession.swift`**: Session state management
  - Tracks current session progress
  - Manages app state (start, practice, summary)
  - Handles session counters and completion logic

- **`AudioManager.swift`**: Audio synthesis engine
  - Uses AVAudioEngine for real-time audio playback
  - Generates piano-like tones with 6 harmonic overtones
  - Implements ADSR envelope (Attack, Decay, Sustain, Release)
  - Calculates accurate frequencies from MIDI values

### Views
- **`StartScreen.swift`**: Initial screen for configuring practice sessions
- **`PracticeView.swift`** (in `ContentView.swift`): Main practice interface with timer and controls
- **`SummaryScreen.swift`**: End-of-session results display
- **`StaffView.swift`**: Musical staff rendering with proper note positioning
- **`PianoView.swift`**: Interactive piano keyboard with 2+ octaves

## How It Works

### Practice Flow
1. **Start Screen**: User selects the number of notes to practice
2. **Practice Session**:
   - A random note is displayed on the grand staff
   - Timer starts counting down from 30 seconds
   - User clicks the corresponding piano key
   - App provides immediate feedback (Correct/Try again)
   - On correct answer, advances to next note after 0.5s
   - On timeout, automatically advances to next note
   - User can skip difficult notes
3. **Summary Screen**: Shows accuracy, correct count, and total attempts

### Note Generation Logic
- Generates notes randomly between C3 and C5
- C5 has only 5% probability to reduce bias
- Octave 3 notes use bass clef
- Octave 4+ notes use treble clef
- Includes all accidentals (natural, sharp, flat)
- Avoids generating the same note consecutively

### Audio Synthesis
The app generates realistic piano sounds by:
1. Calculating the fundamental frequency using the MIDI value
2. Adding 6 harmonic overtones with decreasing amplitudes
3. Applying an ADSR envelope for natural attack and decay
4. Outputting stereo audio at 44.1kHz sample rate

### Note Recognition
- Compares MIDI values rather than literal note names
- Handles enharmonic equivalents correctly (e.g., F = E♯, C♭ = B)
- Provides real-time visual feedback with color-coded messages

## Technical Details

### Platform Requirements
- **macOS**: Version 12 (Monterey) or later
- **iOS**: Version 15 or later

### Dependencies
- SwiftUI for UI framework
- AVFoundation for audio synthesis
- No external packages required

### Key Technologies
- **SwiftUI**: Declarative UI framework
- **Combine**: Reactive state management with `@Published` and `@ObservedObject`
- **AVAudioEngine**: Real-time audio synthesis
- **Timer**: Session countdown and timeout handling

### Build System
- Swift Package Manager (SPM)
- Package name: `NoteQuestClone`
- Build command: `swift build`

## Debug Features

The app includes a debug mode (toggle in practice view) that provides:
- Bass clef vertical offset adjustment slider
- Red guide line showing note position
- Real-time offset value display

This helps with fine-tuning the visual alignment of notes on the staff.

## User Controls

### During Practice
- **Skip Button**: Skip the current note (counts as incorrect)
- **End Practice Button**: Exit current session and view results
- **Piano Keys**: Click to play and check notes
- **Debug Toggle**: Show/hide debugging tools

### Session Navigation
- Timer automatically advances on timeout (30s)
- Correct answers advance after brief delay (0.6s)
- Skip button immediately advances to next note

## Performance Metrics

The app tracks three key metrics:
1. **Current Session**: Which note in the sequence (1-based index)
2. **Correct Sessions**: How many notes were identified correctly
3. **Total Sessions**: How many notes were attempted (correct + incorrect + timeouts)

Note: The `selectedNoteCount` determines when practice ends, but `totalSessions` may differ if user skips or times out.

## Code Organization

```
piano_learn/
├── NoteQuestApp.swift          # App entry point
├── ContentView.swift           # Main view coordinator + PracticeView
├── Package.swift               # SPM configuration
├── Models/
│   ├── Note.swift             # Note data model
│   ├── GameEngine.swift       # Game logic
│   ├── PracticeSession.swift  # Session state
│   └── AudioManager.swift     # Audio synthesis
└── Views/
    ├── StartScreen.swift      # Initial setup screen
    ├── SummaryScreen.swift    # Results screen
    ├── PianoView.swift        # Piano keyboard
    └── StaffView.swift        # Musical staff display
```

## Future Enhancements

Based on the code comments, potential improvements include:
- Support for chords (multiple simultaneous notes)
- Note sequences/melodies
- Adjustable difficulty levels
- Customizable time limits
- Different clef-only practice modes
- MIDI keyboard input support

## License

This project appears to be a learning/educational tool. No license information is currently specified.
