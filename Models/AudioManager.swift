import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private var engine: AVAudioEngine
    private var player: AVAudioPlayerNode
    
    init() {
        engine = AVAudioEngine()
        player = AVAudioPlayerNode()
        engine.attach(player)
        
        let format = engine.outputNode.inputFormat(forBus: 0)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
        } catch {
            print("Audio Engine failed to start: \(error)")
        }
    }
    
    func play(note: Note) {
        let frequency = frequencyFor(note: note)
        let sampleRate = 44100.0
        let duration = 0.5
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return
        }
        
        buffer.frameLength = frameCount
        let channels = buffer.floatChannelData
        
        for i in 0..<Int(frameCount) {
            let theta = Float(i) / Float(sampleRate) * Float(frequency) * 2.0 * Float.pi
            let amplitude: Float = 0.5 * (1.0 - Float(i) / Float(frameCount)) // Simple decay
            channels?[0][i] = sin(theta) * amplitude
        }
        
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !player.isPlaying {
            player.play()
        }
    }
    
    private func frequencyFor(note: Note) -> Double {
        // A4 is 440Hz.
        // Calculate semitones from A4.
        // Note: This is a simplified calculation.
        
        _ = Note(name: .A, octave: 4, accidental: .natural, clef: .treble, duration: .quarter)
        let semitones = semitonesFromA4(note: note)
        return 440.0 * pow(2.0, Double(semitones) / 12.0)
    }
    
    private func semitonesFromA4(note: Note) -> Int {
        let noteValues: [NoteName: Int] = [
            .C: -9, .D: -7, .E: -5, .F: -4, .G: -2, .A: 0, .B: 2
        ]
        
        var baseValue = noteValues[note.name]!
        baseValue += (note.octave - 4) * 12
        
        switch note.accidental {
        case .sharp: baseValue += 1
        case .flat: baseValue -= 1
        case .natural: break
        }
        
        return baseValue
    }
}
