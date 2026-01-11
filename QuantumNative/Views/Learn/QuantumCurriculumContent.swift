//
//  QuantumCurriculumContent.swift
//  SwiftQuantum Learning App
//
//  양자컴퓨터 커리큘럼 콘텐츠 - Localizable strings 기반
//  Learn 폴더와 호환되는 구조
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation

// MARK: - Quantum Curriculum Content Provider
struct QuantumCurriculumContent {

    // MARK: - Track Definitions
    static let allTracks: [QuantumCurriculumTrack] = [
        QuantumCurriculumTrack(
            id: "track-1",
            titleKey: "curriculum.track1.title",
            descriptionKey: "curriculum.track1.description",
            lessons: QuantumBasicsLessons.all,
            iconName: "book.fill",
            difficulty: .beginner
        ),
        QuantumCurriculumTrack(
            id: "track-2",
            titleKey: "curriculum.track2.title",
            descriptionKey: "curriculum.track2.description",
            lessons: QuantumPrinciplesLessons.all,
            iconName: "atom",
            difficulty: .beginner
        ),
        QuantumCurriculumTrack(
            id: "track-3",
            titleKey: "curriculum.track3.title",
            descriptionKey: "curriculum.track3.description",
            lessons: QuantumOperationLessons.all,
            iconName: "gearshape.2.fill",
            difficulty: .intermediate
        ),
        QuantumCurriculumTrack(
            id: "track-4",
            titleKey: "curriculum.track4.title",
            descriptionKey: "curriculum.track4.description",
            lessons: QuantumTypesLessons.all,
            iconName: "cpu.fill",
            difficulty: .intermediate
        ),
        QuantumCurriculumTrack(
            id: "track-5",
            titleKey: "curriculum.track5.title",
            descriptionKey: "curriculum.track5.description",
            lessons: QuantumStatusLessons.all,
            iconName: "chart.line.uptrend.xyaxis",
            difficulty: .intermediate
        ),
        QuantumCurriculumTrack(
            id: "track-6",
            titleKey: "curriculum.track6.title",
            descriptionKey: "curriculum.track6.description",
            lessons: QuantumApplicationsLessons.all,
            iconName: "app.connected.to.app.below.fill",
            difficulty: .advanced
        ),
        QuantumCurriculumTrack(
            id: "track-7",
            titleKey: "curriculum.track7.title",
            descriptionKey: "curriculum.track7.description",
            lessons: QuantumFutureLessons.all,
            iconName: "sparkles",
            difficulty: .advanced
        ),
        QuantumCurriculumTrack(
            id: "track-8",
            titleKey: "curriculum.track8.title",
            descriptionKey: "curriculum.track8.description",
            lessons: Quantum2026Lessons.all,
            iconName: "calendar.badge.clock",
            difficulty: .advanced
        ),
        QuantumCurriculumTrack(
            id: "track-9",
            titleKey: "curriculum.track9.title",
            descriptionKey: "curriculum.track9.description",
            lessons: QuantumKeywordsLessons.all,
            iconName: "text.book.closed.fill",
            difficulty: .intermediate
        )
    ]

    // MARK: - Get Localized Content
    static func getLocalizedTitle(for key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }

    static func getLocalizedDescription(for key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }

    static func getLocalizedContent(for key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}

// MARK: - Curriculum Track Model
struct QuantumCurriculumTrack: Identifiable {
    let id: String
    let titleKey: String
    let descriptionKey: String
    let lessons: [QuantumCurriculumLesson]
    let iconName: String
    let difficulty: CurriculumDifficulty

    var title: String {
        NSLocalizedString(titleKey, comment: "")
    }

    var description: String {
        NSLocalizedString(descriptionKey, comment: "")
    }

    var totalDuration: Int {
        lessons.reduce(0) { $0 + $1.duration }
    }

    var totalXP: Int {
        lessons.reduce(0) { $0 + $1.xpReward }
    }
}

// MARK: - Curriculum Lesson Model
struct QuantumCurriculumLesson: Identifiable {
    let id: String
    let number: Int
    let titleKey: String
    let descriptionKey: String
    let contentKey: String
    let mnemonicKey: String
    let difficultyKey: String
    let duration: Int
    let xpReward: Int

    var title: String {
        NSLocalizedString(titleKey, comment: "")
    }

    var description: String {
        NSLocalizedString(descriptionKey, comment: "")
    }

    var content: String {
        NSLocalizedString(contentKey, comment: "")
    }

    var mnemonic: String {
        NSLocalizedString(mnemonicKey, comment: "")
    }

    var difficulty: String {
        NSLocalizedString(difficultyKey, comment: "")
    }
}

// MARK: - Curriculum Difficulty
enum CurriculumDifficulty: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var localizedName: String {
        switch self {
        case .beginner: return NSLocalizedString("level.beginner", comment: "Beginner")
        case .intermediate: return NSLocalizedString("level.intermediate", comment: "Intermediate")
        case .advanced: return NSLocalizedString("level.advanced", comment: "Advanced")
        }
    }
}

// MARK: - Track 1: Quantum Basics Lessons
struct QuantumBasicsLessons {
    static let all: [QuantumCurriculumLesson] = [
        QuantumCurriculumLesson(
            id: "basics-1-1",
            number: 1,
            titleKey: "lesson.basics1.1.title",
            descriptionKey: "lesson.basics1.1.description",
            contentKey: "lesson.basics1.1.content",
            mnemonicKey: "lesson.basics1.1.mnemonic",
            difficultyKey: "lesson.basics1.1.difficulty",
            duration: 5,
            xpReward: 50
        ),
        QuantumCurriculumLesson(
            id: "basics-1-2",
            number: 2,
            titleKey: "lesson.basics1.2.title",
            descriptionKey: "lesson.basics1.2.description",
            contentKey: "lesson.basics1.2.content",
            mnemonicKey: "lesson.basics1.2.mnemonic",
            difficultyKey: "lesson.basics1.2.difficulty",
            duration: 5,
            xpReward: 50
        ),
        QuantumCurriculumLesson(
            id: "basics-1-3",
            number: 3,
            titleKey: "lesson.basics1.3.title",
            descriptionKey: "lesson.basics1.3.description",
            contentKey: "lesson.basics1.3.content",
            mnemonicKey: "lesson.basics1.3.mnemonic",
            difficultyKey: "lesson.basics1.3.difficulty",
            duration: 8,
            xpReward: 75
        ),
        QuantumCurriculumLesson(
            id: "basics-1-4",
            number: 4,
            titleKey: "lesson.basics1.4.title",
            descriptionKey: "lesson.basics1.4.description",
            contentKey: "lesson.basics1.4.content",
            mnemonicKey: "lesson.basics1.4.mnemonic",
            difficultyKey: "lesson.basics1.4.difficulty",
            duration: 10,
            xpReward: 100
        )
    ]
}

// MARK: - Track 2: Quantum Principles Lessons
struct QuantumPrinciplesLessons {
    static let all: [QuantumCurriculumLesson] = [
        QuantumCurriculumLesson(
            id: "principles-2-1",
            number: 1,
            titleKey: "lesson.principles2.1.title",
            descriptionKey: "lesson.principles2.1.description",
            contentKey: "lesson.principles2.1.content",
            mnemonicKey: "lesson.principles2.1.mnemonic",
            difficultyKey: "lesson.principles2.1.difficulty",
            duration: 10,
            xpReward: 100
        ),
        QuantumCurriculumLesson(
            id: "principles-2-2",
            number: 2,
            titleKey: "lesson.principles2.2.title",
            descriptionKey: "lesson.principles2.2.description",
            contentKey: "lesson.principles2.2.content",
            mnemonicKey: "lesson.principles2.2.mnemonic",
            difficultyKey: "lesson.principles2.2.difficulty",
            duration: 10,
            xpReward: 100
        ),
        QuantumCurriculumLesson(
            id: "principles-2-3",
            number: 3,
            titleKey: "lesson.principles2.3.title",
            descriptionKey: "lesson.principles2.3.description",
            contentKey: "lesson.principles2.3.content",
            mnemonicKey: "lesson.principles2.3.mnemonic",
            difficultyKey: "lesson.principles2.3.difficulty",
            duration: 8,
            xpReward: 100
        ),
        QuantumCurriculumLesson(
            id: "principles-2-4",
            number: 4,
            titleKey: "lesson.principles2.4.title",
            descriptionKey: "lesson.principles2.4.description",
            contentKey: "lesson.principles2.4.content",
            mnemonicKey: "lesson.principles2.4.mnemonic",
            difficultyKey: "lesson.principles2.4.difficulty",
            duration: 8,
            xpReward: 100
        )
    ]
}

// MARK: - Track 3: Quantum Operation Lessons
struct QuantumOperationLessons {
    static let all: [QuantumCurriculumLesson] = [
        QuantumCurriculumLesson(
            id: "operation-3-1",
            number: 1,
            titleKey: "lesson.operation3.1.title",
            descriptionKey: "lesson.operation3.1.description",
            contentKey: "lesson.operation3.1.content",
            mnemonicKey: "lesson.operation3.1.mnemonic",
            difficultyKey: "lesson.operation3.1.difficulty",
            duration: 10,
            xpReward: 125
        ),
        QuantumCurriculumLesson(
            id: "operation-3-2",
            number: 2,
            titleKey: "lesson.operation3.2.title",
            descriptionKey: "lesson.operation3.2.description",
            contentKey: "lesson.operation3.2.content",
            mnemonicKey: "lesson.operation3.2.mnemonic",
            difficultyKey: "lesson.operation3.2.difficulty",
            duration: 8,
            xpReward: 100
        ),
        QuantumCurriculumLesson(
            id: "operation-3-3",
            number: 3,
            titleKey: "lesson.operation3.3.title",
            descriptionKey: "lesson.operation3.3.description",
            contentKey: "lesson.operation3.3.content",
            mnemonicKey: "lesson.operation3.3.mnemonic",
            difficultyKey: "lesson.operation3.3.difficulty",
            duration: 12,
            xpReward: 150
        ),
        QuantumCurriculumLesson(
            id: "operation-3-4",
            number: 4,
            titleKey: "lesson.operation3.4.title",
            descriptionKey: "lesson.operation3.4.description",
            contentKey: "lesson.operation3.4.content",
            mnemonicKey: "lesson.operation3.4.mnemonic",
            difficultyKey: "lesson.operation3.4.difficulty",
            duration: 10,
            xpReward: 125
        )
    ]
}

// MARK: - Track 4: Quantum Types Lessons
struct QuantumTypesLessons {
    static let all: [QuantumCurriculumLesson] = [
        QuantumCurriculumLesson(
            id: "types-4-1",
            number: 1,
            titleKey: "lesson.types4.1.title",
            descriptionKey: "lesson.types4.1.description",
            contentKey: "lesson.types4.1.content",
            mnemonicKey: "lesson.types4.1.mnemonic",
            difficultyKey: "lesson.types4.1.difficulty",
            duration: 10,
            xpReward: 125
        ),
        QuantumCurriculumLesson(
            id: "types-4-2",
            number: 2,
            titleKey: "lesson.types4.2.title",
            descriptionKey: "lesson.types4.2.description",
            contentKey: "lesson.types4.2.content",
            mnemonicKey: "lesson.types4.2.mnemonic",
            difficultyKey: "lesson.types4.2.difficulty",
            duration: 10,
            xpReward: 125
        ),
        QuantumCurriculumLesson(
            id: "types-4-3",
            number: 3,
            titleKey: "lesson.types4.3.title",
            descriptionKey: "lesson.types4.3.description",
            contentKey: "lesson.types4.3.content",
            mnemonicKey: "lesson.types4.3.mnemonic",
            difficultyKey: "lesson.types4.3.difficulty",
            duration: 10,
            xpReward: 150
        ),
        QuantumCurriculumLesson(
            id: "types-4-4",
            number: 4,
            titleKey: "lesson.types4.4.title",
            descriptionKey: "lesson.types4.4.description",
            contentKey: "lesson.types4.4.content",
            mnemonicKey: "lesson.types4.4.mnemonic",
            difficultyKey: "lesson.types4.4.difficulty",
            duration: 10,
            xpReward: 175
        )
    ]
}

// MARK: - Track 5: Current Status Lessons
struct QuantumStatusLessons {
    static let all: [QuantumCurriculumLesson] = [
        QuantumCurriculumLesson(
            id: "status-5-1",
            number: 1,
            titleKey: "lesson.status5.1.title",
            descriptionKey: "lesson.status5.1.description",
            contentKey: "lesson.status5.1.content",
            mnemonicKey: "lesson.status5.1.mnemonic",
            difficultyKey: "lesson.status5.1.difficulty",
            duration: 8,
            xpReward: 100
        ),
        QuantumCurriculumLesson(
            id: "status-5-2",
            number: 2,
            titleKey: "lesson.status5.2.title",
            descriptionKey: "lesson.status5.2.description",
            contentKey: "lesson.status5.2.content",
            mnemonicKey: "lesson.status5.2.mnemonic",
            difficultyKey: "lesson.status5.2.difficulty",
            duration: 8,
            xpReward: 100
        ),
        QuantumCurriculumLesson(
            id: "status-5-3",
            number: 3,
            titleKey: "lesson.status5.3.title",
            descriptionKey: "lesson.status5.3.description",
            contentKey: "lesson.status5.3.content",
            mnemonicKey: "lesson.status5.3.mnemonic",
            difficultyKey: "lesson.status5.3.difficulty",
            duration: 10,
            xpReward: 150
        ),
        QuantumCurriculumLesson(
            id: "status-5-4",
            number: 4,
            titleKey: "lesson.status5.4.title",
            descriptionKey: "lesson.status5.4.description",
            contentKey: "lesson.status5.4.content",
            mnemonicKey: "lesson.status5.4.mnemonic",
            difficultyKey: "lesson.status5.4.difficulty",
            duration: 8,
            xpReward: 100
        )
    ]
}

// MARK: - Track 6: Applications Lessons
struct QuantumApplicationsLessons {
    static let all: [QuantumCurriculumLesson] = [
        QuantumCurriculumLesson(
            id: "apps-6-1",
            number: 1,
            titleKey: "lesson.apps6.1.title",
            descriptionKey: "lesson.apps6.1.description",
            contentKey: "lesson.apps6.1.content",
            mnemonicKey: "lesson.apps6.1.mnemonic",
            difficultyKey: "lesson.apps6.1.difficulty",
            duration: 12,
            xpReward: 175
        ),
        QuantumCurriculumLesson(
            id: "apps-6-2",
            number: 2,
            titleKey: "lesson.apps6.2.title",
            descriptionKey: "lesson.apps6.2.description",
            contentKey: "lesson.apps6.2.content",
            mnemonicKey: "lesson.apps6.2.mnemonic",
            difficultyKey: "lesson.apps6.2.difficulty",
            duration: 12,
            xpReward: 175
        ),
        QuantumCurriculumLesson(
            id: "apps-6-3",
            number: 3,
            titleKey: "lesson.apps6.3.title",
            descriptionKey: "lesson.apps6.3.description",
            contentKey: "lesson.apps6.3.content",
            mnemonicKey: "lesson.apps6.3.mnemonic",
            difficultyKey: "lesson.apps6.3.difficulty",
            duration: 12,
            xpReward: 175
        ),
        QuantumCurriculumLesson(
            id: "apps-6-4",
            number: 4,
            titleKey: "lesson.apps6.4.title",
            descriptionKey: "lesson.apps6.4.description",
            contentKey: "lesson.apps6.4.content",
            mnemonicKey: "lesson.apps6.4.mnemonic",
            difficultyKey: "lesson.apps6.4.difficulty",
            duration: 12,
            xpReward: 200
        )
    ]
}

// MARK: - Track 7: Future Lessons
struct QuantumFutureLessons {
    static let all: [QuantumCurriculumLesson] = [
        QuantumCurriculumLesson(
            id: "future-7-1",
            number: 1,
            titleKey: "lesson.future7.1.title",
            descriptionKey: "lesson.future7.1.description",
            contentKey: "lesson.future7.1.content",
            mnemonicKey: "lesson.future7.1.mnemonic",
            difficultyKey: "lesson.future7.1.difficulty",
            duration: 12,
            xpReward: 175
        ),
        QuantumCurriculumLesson(
            id: "future-7-2",
            number: 2,
            titleKey: "lesson.future7.2.title",
            descriptionKey: "lesson.future7.2.description",
            contentKey: "lesson.future7.2.content",
            mnemonicKey: "lesson.future7.2.mnemonic",
            difficultyKey: "lesson.future7.2.difficulty",
            duration: 10,
            xpReward: 125
        ),
        QuantumCurriculumLesson(
            id: "future-7-3",
            number: 3,
            titleKey: "lesson.future7.3.title",
            descriptionKey: "lesson.future7.3.description",
            contentKey: "lesson.future7.3.content",
            mnemonicKey: "lesson.future7.3.mnemonic",
            difficultyKey: "lesson.future7.3.difficulty",
            duration: 12,
            xpReward: 175
        ),
        QuantumCurriculumLesson(
            id: "future-7-4",
            number: 4,
            titleKey: "lesson.future7.4.title",
            descriptionKey: "lesson.future7.4.description",
            contentKey: "lesson.future7.4.content",
            mnemonicKey: "lesson.future7.4.mnemonic",
            difficultyKey: "lesson.future7.4.difficulty",
            duration: 10,
            xpReward: 125
        )
    ]
}

// MARK: - Track 8: 2026 Detailed Lessons
struct Quantum2026Lessons {
    static let all: [QuantumCurriculumLesson] = [
        QuantumCurriculumLesson(
            id: "detailed-8-1",
            number: 1,
            titleKey: "lesson.detailed8.1.title",
            descriptionKey: "lesson.detailed8.1.description",
            contentKey: "lesson.detailed8.1.content",
            mnemonicKey: "lesson.detailed8.1.mnemonic",
            difficultyKey: "lesson.detailed8.1.difficulty",
            duration: 12,
            xpReward: 175
        ),
        QuantumCurriculumLesson(
            id: "detailed-8-2",
            number: 2,
            titleKey: "lesson.detailed8.2.title",
            descriptionKey: "lesson.detailed8.2.description",
            contentKey: "lesson.detailed8.2.content",
            mnemonicKey: "lesson.detailed8.2.mnemonic",
            difficultyKey: "lesson.detailed8.2.difficulty",
            duration: 12,
            xpReward: 175
        ),
        QuantumCurriculumLesson(
            id: "detailed-8-3",
            number: 3,
            titleKey: "lesson.detailed8.3.title",
            descriptionKey: "lesson.detailed8.3.description",
            contentKey: "lesson.detailed8.3.content",
            mnemonicKey: "lesson.detailed8.3.mnemonic",
            difficultyKey: "lesson.detailed8.3.difficulty",
            duration: 10,
            xpReward: 150
        ),
        QuantumCurriculumLesson(
            id: "detailed-8-4",
            number: 4,
            titleKey: "lesson.detailed8.4.title",
            descriptionKey: "lesson.detailed8.4.description",
            contentKey: "lesson.detailed8.4.content",
            mnemonicKey: "lesson.detailed8.4.mnemonic",
            difficultyKey: "lesson.detailed8.4.difficulty",
            duration: 10,
            xpReward: 125
        )
    ]
}

// MARK: - Track 9: Keywords Lessons
struct QuantumKeywordsLessons {
    static let all: [QuantumCurriculumLesson] = [
        QuantumCurriculumLesson(
            id: "keywords-9-1",
            number: 1,
            titleKey: "lesson.keywords9.1.title",
            descriptionKey: "lesson.keywords9.1.description",
            contentKey: "lesson.keywords9.1.content",
            mnemonicKey: "lesson.keywords9.1.mnemonic",
            difficultyKey: "lesson.keywords9.1.difficulty",
            duration: 15,
            xpReward: 150
        ),
        QuantumCurriculumLesson(
            id: "keywords-9-2",
            number: 2,
            titleKey: "lesson.keywords9.2.title",
            descriptionKey: "lesson.keywords9.2.description",
            contentKey: "lesson.keywords9.2.content",
            mnemonicKey: "lesson.keywords9.2.mnemonic",
            difficultyKey: "lesson.keywords9.2.difficulty",
            duration: 15,
            xpReward: 150
        ),
        QuantumCurriculumLesson(
            id: "keywords-9-3",
            number: 3,
            titleKey: "lesson.keywords9.3.title",
            descriptionKey: "lesson.keywords9.3.description",
            contentKey: "lesson.keywords9.3.content",
            mnemonicKey: "lesson.keywords9.3.mnemonic",
            difficultyKey: "lesson.keywords9.3.difficulty",
            duration: 12,
            xpReward: 175
        ),
        QuantumCurriculumLesson(
            id: "keywords-9-4",
            number: 4,
            titleKey: "lesson.keywords9.4.title",
            descriptionKey: "lesson.keywords9.4.description",
            contentKey: "lesson.keywords9.4.content",
            mnemonicKey: "lesson.keywords9.4.mnemonic",
            difficultyKey: "lesson.keywords9.4.difficulty",
            duration: 12,
            xpReward: 175
        )
    ]
}

// MARK: - Extension for LearningLevel Compatibility
extension QuantumCurriculumLesson {
    /// Convert to LearningLevel for compatibility with existing views
    func toLearningLevel(trackIndex: Int) -> LearningLevel {
        let levelId = trackIndex * 100 + number
        let track: Track = trackIndex <= 2 ? .beginner : (trackIndex <= 5 ? .intermediate : .advanced)

        return LearningLevel(
            id: levelId,
            number: number,
            title: title,
            name: title,
            description: description,
            track: track,
            xpReward: xpReward,
            estimatedTime: duration,
            prerequisites: number > 1 ? [levelId - 1] : [],
            lessons: [
                LearningLevel.Lesson(
                    id: id,
                    title: title,
                    type: .theory,
                    content: content
                )
            ]
        )
    }
}

// MARK: - Extension for LearningTrack Compatibility
extension QuantumCurriculumTrack {
    /// Convert to LearningTrack for compatibility with existing views
    func toLearningTrack(index: Int) -> LearningTrack {
        LearningTrack(
            name: title,
            description: description,
            iconName: iconName,
            levels: lessons.map { $0.toLearningLevel(trackIndex: index + 1) }
        )
    }
}
