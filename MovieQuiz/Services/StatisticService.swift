import UIKit

final class StatisticService: StatisticServiceProtocol {
    
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
    }
    
    private let storage: UserDefaults = .standard

    // Общая точность ответов за все время
    var totalAccuracy: Double {
        let totalCorrectAnswers = Double(storage.integer(forKey: "totalCorrectAnswers"))
        guard gamesCount > 0 else { return 0.0 }
        let total = ((totalCorrectAnswers) / (Double(gamesCount)*10))*100
        return total
    }
    
    // Количество игр за все время
    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    // Лучший результат
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: "bestGameCorrect")    // Результат правильных ответов у лучшего результата
            let total = storage.integer(forKey: "bestGameTotal")    // Количество вопросов квиза у лучшего результата
            let date = storage.object(forKey: "bestGameDate") as? Date ?? Date()    // Дата завершения квиза у лучшего результата
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: "bestGameCorrect")
            storage.set(newValue.total, forKey: "bestGameTotal")
            storage.set(newValue.date, forKey: "bestGameDate")
        }
    }
    
    // Реализовать функцию сохранения лучшего результата store — с проверкой на то, что новый результат лучше сохранённого в UserDefaults;
    // Этот метод принимает результат игры: количество правильных ответов и общее число заданных вопросов по окончании.
    func store(correct count: Int, total amount: Int) {
        // 1. Создаем новый результат игры
        let newResult = GameResult(correct: count, total: amount, date: Date())
        
        // 2. Получаем текущий лучший результат из UserDefaults
        let savedCorrect = storage.integer(forKey: "bestGameCorrect")
        let savedTotal = storage.integer(forKey: "bestGameTotal")
        let savedDate = storage.object(forKey: "bestGameDate") as? Date ?? Date()
        let savedResult = GameResult(correct: savedCorrect, total: savedTotal, date: savedDate)
        
        // 3. Сравниваем результаты
        if newResult.isBetterThan(savedResult) {
            // 4. Сохраняем новый лучший результат
            storage.set(newResult.correct, forKey: "bestGameCorrect")
            storage.set(newResult.total, forKey: "bestGameTotal")
            storage.set(newResult.date, forKey: "bestGameDate")
        }
    }
}
