import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Показываем первый вопрос при загрузке экрана
        show(quiz: convert(model: questions[currentQuestionIndex]))
        imageView.layer.cornerRadius = 20   // Настраиваем скругление углов у изображения
        imageView.layer.masksToBounds = true    // Обрезаем содержимое за границей вью
        imageView.layer.borderWidth = 8     // Ширина рамки
    }
    
    // MARK: - Structures
    
    // Модель для вопроса квиза
    struct QuizQuestion {
        let image: String           // Название изображения
        let text: String            // Текст вопроса
        let correctAnswer: Bool     // Правильный ответ
    }
    
    // Модель для отображения вопроса на экране
    struct QuizStepViewModel {
        let image: UIImage          // Готовое изображение
        let question: String        // Текст вопроса
        let questionNumber: String  //Номер вопроса
    }
    
    // Метод для отображения результатов квиза
    struct QuizResultsViewModel {
      let title: String             // Заголовок алерта
      let text: String              // Текст с результатами
      let buttonText: String        // Текст кнопки алерта
    }
    
    // MARK: - Properties
    
    // Массив вопросов для квиза
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text:"Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
    ]
    
    private var currentQuestionIndex = 0    // Индекс текущего вопроса
    private var correctAnswer = 0           // Счетчик правильных ответов
    
    //MARK: - IBOutlets
    
    @IBOutlet private var imageView: UIImageView!   // Отображения постера
    @IBOutlet private var textLabel: UILabel!       // Текст вопроса
    @IBOutlet private var counterLabel: UILabel!    // Счетчик вопросов
    @IBOutlet weak var noButton: UIButton!          // Кнопка "Нет"
    @IBOutlet weak var yesButton: UIButton!         // Кнопка "Да"

    // MARK: - IBActions
    
    // Обработчик нажатия кнопки "Да"
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // Обработчик нажатия кнопки "Нет"
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
        //MARK: - Private Methods
    
    // Конвертирует модель вопроса в модель для отображения
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),    // Загружаем изображение
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")   // Форматируем номер
        return questionStep
    }
    
    // Показывает вопрос на экране
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor // Сбрасываем цвет рамки
        yesButton.isEnabled = true  // Активируем кнопки, после их отключения
        noButton.isEnabled = true
    }
    
    // Показывает алерт с результатами
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            // Сбрасываем игру при нажатии на кнопку
            self.currentQuestionIndex = 0
            self.correctAnswer = 0
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }
        
        // Показываем алерт
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    // Показывает результат ответа
    private func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false // Блокируем кнопки от спама
        noButton.isEnabled = false
        if isCorrect {
                correctAnswer += 1  // Увеличиваем счетчик правильных ответов
            }
        // Меняем цвет рамки в зависимости от ответа
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // Через 1 секунду переходим к следующему вопросу
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showNextQuestionOrResults()
            }
        }
    
    // Определяет, показывать следующий вопрос или результаты
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {    // Если вопросы закончились - показываем результаты
            let text = "Ваш результат: \(correctAnswer)/\(questions.count)" // 1
            let viewModel = QuizResultsViewModel( // 2
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {                            // Иначе переходим к следующему вопросу
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            show(quiz: viewModel)
        }
    }
}
