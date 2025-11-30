// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "NoteQuestClone",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .executable(name: "NoteQuestClone", targets: ["NoteQuestClone"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "NoteQuestClone",
            dependencies: [],
            path: ".",
            exclude: ["README.md", "task.md", "implementation_plan.md"],
            sources: ["NoteQuestApp.swift", "ContentView.swift", "Models", "Views"]
        )
    ]
)
