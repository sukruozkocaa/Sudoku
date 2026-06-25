import Foundation

enum DailyChallengeService {
    static func todayKey(for date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func seed(for dateKey: String) -> UInt64 {
        var hasher = Hasher()
        hasher.combine(dateKey)
        hasher.combine("sudoku.daily")
        return UInt64(bitPattern: Int64(truncatingIfNeeded: hasher.finalize()))
    }

    static func generate(for dateKey: String = todayKey()) -> SudokuPuzzle {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let level = (dayOfYear % 8) + 1
        return SudokuGenerator.generate(
            difficulty: .medium,
            level: level,
            seed: seed(for: dateKey)
        )
    }
}
