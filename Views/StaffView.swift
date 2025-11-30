import SwiftUI

struct StaffView: View {
    let note: Note
    var showDebug: Bool = false
    var bassClefOffset: CGFloat = -10
    
    let lineSpacing: CGFloat = 20
    let staffSpacing: CGFloat = 60 // Space between Treble and Bass staves
    
    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            let staffHeight = 4 * lineSpacing
            
            // Treble Clef Position
            let trebleX = centerX - 120
            let trebleY = centerY - (staffSpacing / 2) - (staffHeight / 2)
            
            // Bass Clef Position
            let bassX = centerX - 120
            let bassY = centerY + (staffSpacing / 2) + (staffHeight / 2) + bassClefOffset // Use dynamic offset
            
            ZStack {
                // Draw Grand Staff Lines using Path for precision
                Path { path in
                    // Treble Staff (Top)
                    let trebleCenterY = centerY - (staffSpacing / 2) - (staffHeight / 2)
                    drawStaff(path: &path, centerX: centerX, centerY: trebleCenterY, width: 300)
                    
                    // Bass Staff (Bottom)
                    let bassCenterY = centerY + (staffSpacing / 2) + (staffHeight / 2)
                    drawStaff(path: &path, centerX: centerX, centerY: bassCenterY, width: 300)
                    
                    // Vertical bar connecting staves
                    let topY = trebleCenterY - (staffHeight / 2)
                    let bottomY = bassCenterY + (staffHeight / 2)
                    path.move(to: CGPoint(x: centerX - 150, y: topY))
                    path.addLine(to: CGPoint(x: centerX - 150, y: bottomY))
                }
                .stroke(Color.black, lineWidth: 1)
                
                // Clefs
                VStack(spacing: 0) {
                    Text("𝄞").font(.system(size: 60))
                        .position(x: trebleX, y: trebleY)
                    
                    Text("𝄢").font(.system(size: 60))
                        .position(x: bassX, y: bassY)
                }
                .frame(height: geometry.size.height)

                // Note
                NoteHeadView(note: note, lineSpacing: lineSpacing)
                    .position(x: centerX, y: calculateNoteYPosition(for: note, in: geometry.size.height))
                
                // Debug Lines
                if showDebug {
                    Path { path in
                        let y = calculateNoteYPosition(for: note, in: geometry.size.height)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(Color.red, style: StrokeStyle(lineWidth: 1, dash: [5]))
                }
            }
        }
        .frame(height: 350)
        .padding()
    }
    
    func drawStaff(path: inout Path, centerX: CGFloat, centerY: CGFloat, width: CGFloat) {
        let startX = centerX - (width / 2)
        let endX = centerX + (width / 2)
        
        // 5 lines. Center line is at centerY.
        // Offsets: -2*spacing, -1*spacing, 0, +1*spacing, +2*spacing
        for i in -2...2 {
            let y = centerY + CGFloat(i) * lineSpacing
            path.move(to: CGPoint(x: startX, y: y))
            path.addLine(to: CGPoint(x: endX, y: y))
        }
    }
    
    func calculateNoteYPosition(for note: Note, in totalHeight: CGFloat) -> CGFloat {
        let staffHeight = 4 * lineSpacing
        let centerY = totalHeight / 2
        
        // Treble Center (B4)
        let trebleCenterY = centerY - (staffSpacing / 2) - (staffHeight / 2)
        
        // Bass Center (D3)
        let bassCenterY = centerY + (staffSpacing / 2) + (staffHeight / 2)
        
        if note.clef == .treble {
            // B4 is at trebleCenterY.
            // B4 offset is 6 (relative to C4=0).
            let b4Offset = 6 + (4 - 4) * 7 // 6
            let currentOffset = note.staffOffset
            let diff = currentOffset - b4Offset
            
            // Positive diff means higher pitch -> lower Y
            // Each step is half a line spacing
            return trebleCenterY - (CGFloat(diff) * (lineSpacing / 2))
        } else {
            // D3 is at bassCenterY.
            // D3 offset is -6 (relative to C4=0).
            let d3Offset = 1 + (3 - 4) * 7 // -6
            let currentOffset = note.staffOffset
            let diff = currentOffset - d3Offset
            
            return bassCenterY - (CGFloat(diff) * (lineSpacing / 2))
        }
    }
}

struct NoteHeadView: View {
    let note: Note
    let lineSpacing: CGFloat
    
    var body: some View {
        ZStack {
            // Ledger Lines
            if needsLedgerLine(note: note) {
                VStack(spacing: lineSpacing) {
                    ForEach(0..<numberOfLedgerLines(note: note), id: \.self) { _ in
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 40, height: 1) // 1px height
                    }
                }
                .offset(y: ledgerLineOffset(note: note))
            }
            
            // Note Head
            // Standard note head height is usually equal to line spacing (space height).
            // Width is slightly larger.
            let headHeight = lineSpacing
            let headWidth = headHeight * 1.3
            
            if note.duration == .whole {
                Ellipse()
                    .stroke(Color.black, lineWidth: 2)
                    .frame(width: headWidth, height: headHeight)
                    .rotationEffect(.degrees(-20))
            } else {
                Ellipse()
                    .fill(note.duration == .half ? Color.clear : Color.black)
                    .overlay(
                        Ellipse()
                            .stroke(Color.black, lineWidth: 2)
                    )
                    .frame(width: headWidth, height: headHeight)
                    .rotationEffect(.degrees(-20))
            }
            
            // Stem
            if note.duration != .whole {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 1.5, height: 35)
                    // Stem direction logic is complex, simplified here:
                    // If note is above center line, stem down. Below, stem up.
                    // For now, let's just put it up for simplicity or adjust based on clef/pitch later.
                    // Let's stick to "Up" for now but offset correctly.
                    .offset(x: (headWidth / 2) - 1, y: -15)
            }
            
            // Accidental
            if note.accidental != .natural {
                Text(note.accidental.rawValue)
                    .font(.title)
                    .offset(x: -25)
            }
        }
    }
    
    func needsLedgerLine(note: Note) -> Bool {
        if note.clef == .treble {
            // Middle C (C4) is below.
            if note.octave == 4 && note.name == .C { return true }
            // A5 is above top line (F5).
            if note.octave == 5 && (note.name == .A || note.name == .B) { return true }
        } else {
            // Bass Clef
            // Middle C (C4) is above. Needs line.
            if note.octave == 4 && note.name == .C { return true }
            // E2 is below G2. Needs line.
            if note.octave == 2 { return true } // Simplified
            if note.octave == 3 && note.name == .C { return false }
        }
        return false
    }
    
    func numberOfLedgerLines(note: Note) -> Int {
        return 1
    }
    
    func ledgerLineOffset(note: Note) -> CGFloat {
        return 0
    }
}
