import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private var engine: AVAudioEngine?
    private var player: AVAudioPlayerNode?
    private var format: AVAudioFormat?
    private let audioQueue = DispatchQueue(label: "com.pianolearn.audio", qos: .userInitiated)
    
    init() {
        // Initialize audio asynchronously to not block UI
        audioQueue.async { [weak self] in
            self?.setupAudio()
        }
    }
    
    private func setupAudio() {
        engine = AVAudioEngine()
        player = AVAudioPlayerNode()
        
        guard let engine = engine, let player = player else { return }
        
        engine.attach(player)
        
        // Use the output node's format to ensure compatibility
        let outputFormat = engine.outputNode.inputFormat(forBus: 0)
        format = AVAudioFormat(
            standardFormatWithSampleRate: 44100.0,
            channels: outputFormat.channelCount
        )
        
        guard let format = format else { return }
        
        engine.connect(player, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
        } catch {
            print("Audio Engine failed to start: \(error)")
        }
    }
    
    func play(note: Note) {
        // Play audio asynchronously to not block UI
        audioQueue.async { [weak self] in
            self?.playSync(note: note)
        }
    }
    
    private func playSync(note: Note) {
        guard let player = player,
              let engine = engine,
              let format = format,
              engine.isRunning else {
            return
        }
        
        let frequency = frequencyFor(note: note)
        let sampleRate = format.sampleRate
        let duration = 1.0 // Longer duration for piano-like sound
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return
        }
        
        buffer.frameLength = frameCount
        guard let channels = buffer.floatChannelData else { return }
        
        let channelCount = Int(format.channelCount)
        
        // Piano-like harmonics: fundamental + overtones
        // Using relative amplitudes typical of piano tones
        let harmonics: [(frequency: Double, amplitude: Float)] = [
            (1.0, 1.0),      // Fundamental
            (2.0, 0.5),      // 2nd harmonic
            (3.0, 0.3),      // 3rd harmonic
            (4.0, 0.2),      // 4th harmonic
            (5.0, 0.15),     // 5th harmonic
            (6.0, 0.1),      // 6th harmonic
        ]
        
        for i in 0..<Int(frameCount) {
            let t = Float(i) / Float(sampleRate)
            
            // ADSR Envelope for piano-like dynamics
            let attack: Float = 0.01  // Quick attack
            let decay: Float = 0.1    // Fast decay
            let sustain: Float = 0.1  // Sustain level
            let release: Float = 0.1  // Release time
            
            var envelope: Float = 1.0
            if t < attack {
                // Attack phase
                envelope = t / attack
            } else if t < attack + decay {
                // Decay phase
                let decayProgress = (t - attack) / decay
                envelope = 1.0 - (1.0 - sustain) * decayProgress
            } else if t < Float(duration) - release {
                // Sustain phase
                envelope = sustain
            } else {
                // Release phase
                let releaseProgress = (t - (Float(duration) - release)) / release
                envelope = sustain * (1.0 - releaseProgress)
            }
            
            // Generate sample with harmonics
            var sample: Float = 0.0
            for harmonic in harmonics {
                let harmonicFreq = frequency * harmonic.frequency
                let theta = Float(i) / Float(sampleRate) * Float(harmonicFreq) * 2.0 * Float.pi
                sample += sin(theta) * harmonic.amplitude
            }
            
            // Normalize and apply envelope
            sample = sample / Float(harmonics.count) * 0.3 * envelope
            
            // Fill all channels
            for channel in 0..<channelCount {
                channels[channel][i] = sample
            }
        }
        
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !player.isPlaying {
            player.play()
        }
    }
    
    private func frequencyFor(note: Note) -> Double {
        // Use the Note's midiValue which is already correctly calculated
        // A4 = MIDI 69 = 440Hz
        // Formula: frequency = 440 * 2^((midiNote - 69) / 12)
        let midiNote = note.midiValue
        let semitones = midiNote - 69 // 69 is A4
        return 440.0 * pow(2.0, Double(semitones) / 12.0)
    }
}
