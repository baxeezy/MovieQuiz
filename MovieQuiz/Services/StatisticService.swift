import UIKit

final class StatisticService: StatisticServiceProtocol {
    
    private let statisticService: StatisticServiceProtocol = StatisticService()
    
    private enum Keys: String {
        case correct, total, date
        case gamesCount
        case totalAccuracySum
    }
    
    private let storage: UserDefaults = .standard

    var totalAccuracy: Double {
        guard gamesCount > 0 else { return 0 }
                return storage.double(forKey: Keys.totalAccuracySum.rawValue) / Double(gamesCount)
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            GameResult(
                correct: storage.integer(forKey: Keys.correct.rawValue),
                total: storage.integer(forKey: Keys.total.rawValue),
                date: storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            )
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let gameAccuracy = (Double(count) / Double(amount)) * 100
        let currentSum = storage.double(forKey: Keys.totalAccuracySum.rawValue)
        storage.set(currentSum + gameAccuracy, forKey: Keys.totalAccuracySum.rawValue)
        gamesCount += 1
        let newResult = GameResult(correct: count, total: amount, date: Date())
        if newResult.isBetterThan(bestGame) {
            bestGame = newResult
        }
    }
}
