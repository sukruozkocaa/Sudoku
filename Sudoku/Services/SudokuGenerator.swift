import Foundation

enum SudokuGenerator {
    static func generate(difficulty: Difficulty, level: Int, seed: UInt64? = nil) -> SudokuPuzzle {
        let config = difficulty.gridConfig
        let solution = generateSolution(config: config, seed: seed)
        let clueCount = difficulty.baseClueCount(for: level)
        let initialGrid = createPuzzle(from: solution, config: config, clueCount: clueCount, seed: seed)
        return SudokuPuzzle(
            solution: solution,
            initialGrid: initialGrid,
            difficulty: difficulty,
            level: level
        )
    }

    private static func generateSolution(config: SudokuGridConfig, seed: UInt64?) -> [[Int]] {
        var grid = Array(repeating: Array(repeating: 0, count: config.size), count: config.size)
        _ = solve(grid: &grid, config: config, seed: seed)
        return grid
    }

    private static func solve(grid: inout [[Int]], config: SudokuGridConfig, seed: UInt64?) -> Bool {
        for row in 0..<config.size {
            for column in 0..<config.size {
                guard grid[row][column] == 0 else { continue }

                let numbers = shuffledNumbers(maxNumber: config.maxNumber, seed: seed, row: row, column: column)
                for number in numbers {
                    if isValidPlacement(grid: grid, row: row, column: column, number: number, config: config) {
                        grid[row][column] = number
                        if solve(grid: &grid, config: config, seed: seed) { return true }
                        grid[row][column] = 0
                    }
                }
                return false
            }
        }
        return true
    }

    private static func createPuzzle(
        from solution: [[Int]],
        config: SudokuGridConfig,
        clueCount: Int,
        seed: UInt64?
    ) -> [[Int?]] {
        var puzzle = solution.map { row in row.map { Optional($0) } }
        var positions = (0..<config.cellCount).map { index in
            (index / config.size, index % config.size)
        }
        positions = shuffled(positions, seed: seed, salt: 991)

        var removed = config.cellCount - clueCount

        while removed > 0, let position = positions.popLast() {
            let backup = puzzle[position.0][position.1]
            puzzle[position.0][position.1] = nil
            removed -= 1

            if !hasUniqueSolution(puzzle: puzzle, config: config) {
                puzzle[position.0][position.1] = backup
            }
        }

        ensureEditableCellsInEveryBox(puzzle: &puzzle, solution: solution, config: config, seed: seed)
        return puzzle
    }

    private static func ensureEditableCellsInEveryBox(
        puzzle: inout [[Int?]],
        solution: [[Int]],
        config: SudokuGridConfig,
        seed: UInt64?
    ) {
        for boxIndex in 0..<config.boxCount {
            guard isBoxFullyFilled(puzzle: puzzle, boxIndex: boxIndex, config: config) else { continue }

            let origin = config.boxOrigin(for: boxIndex)
            var candidates: [(Int, Int)] = []

            for row in origin.row..<(origin.row + config.boxHeight) {
                for column in origin.column..<(origin.column + config.boxWidth) {
                    candidates.append((row, column))
                }
            }

            candidates = shuffled(candidates, seed: seed, salt: boxIndex + 17)

            for position in candidates {
                let backup = puzzle[position.0][position.1]
                puzzle[position.0][position.1] = nil

                if hasUniqueSolution(puzzle: puzzle, config: config) {
                    break
                }

                puzzle[position.0][position.1] = backup
            }
        }
    }

    private static func isBoxFullyFilled(
        puzzle: [[Int?]],
        boxIndex: Int,
        config: SudokuGridConfig
    ) -> Bool {
        let origin = config.boxOrigin(for: boxIndex)

        for row in origin.row..<(origin.row + config.boxHeight) {
            for column in origin.column..<(origin.column + config.boxWidth) {
                if puzzle[row][column] == nil {
                    return false
                }
            }
        }
        return true
    }

    private static func hasUniqueSolution(puzzle: [[Int?]], config: SudokuGridConfig) -> Bool {
        var grid = puzzle.map { row in row.map { $0 ?? 0 } }
        var solutionCount = 0
        countSolutions(grid: &grid, config: config, count: &solutionCount, limit: 2)
        return solutionCount == 1
    }

    private static func countSolutions(
        grid: inout [[Int]],
        config: SudokuGridConfig,
        count: inout Int,
        limit: Int
    ) {
        guard count < limit else { return }

        for row in 0..<config.size {
            for column in 0..<config.size {
                guard grid[row][column] == 0 else { continue }

                for number in 1...config.maxNumber {
                    if isValidPlacement(grid: grid, row: row, column: column, number: number, config: config) {
                        grid[row][column] = number
                        countSolutions(grid: &grid, config: config, count: &count, limit: limit)
                        grid[row][column] = 0
                        if count >= limit { return }
                    }
                }
                return
            }
        }
        count += 1
    }

    private static func isValidPlacement(
        grid: [[Int]],
        row: Int,
        column: Int,
        number: Int,
        config: SudokuGridConfig
    ) -> Bool {
        for index in 0..<config.size {
            if grid[row][index] == number || grid[index][column] == number {
                return false
            }
        }

        let origin = config.boxOrigin(for: config.boxIndex(row: row, column: column))
        for rowOffset in 0..<config.boxHeight {
            for columnOffset in 0..<config.boxWidth {
                let checkRow = origin.row + rowOffset
                let checkColumn = origin.column + columnOffset
                if grid[checkRow][checkColumn] == number {
                    return false
                }
            }
        }
        return true
    }

    private static func shuffledNumbers(maxNumber: Int, seed: UInt64?, row: Int, column: Int) -> [Int] {
        let numbers = Array(1...maxNumber)
        guard let seed else { return numbers.shuffled() }
        var generator = SeededRandomNumberGenerator(seed: seed &+ UInt64(row * 97 + column * 13))
        return numbers.shuffled(using: &generator)
    }

    private static func shuffled<T>(_ values: [T], seed: UInt64?, salt: Int) -> [T] {
        guard let seed else { return values.shuffled() }
        var generator = SeededRandomNumberGenerator(seed: seed &+ UInt64(salt))
        return values.shuffled(using: &generator)
    }
}
