import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Показываем первый вопрос при загрузке экрана
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
        setUpImage()
        let statisticService = StatisticService() 
        print(Bundle.main.bundlePath)
        print(NSHomeDirectory())
        UserDefaults.standard.set(true, forKey: "viewDidLoad")
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // проверка, что вопрос не nil
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        show(quiz: viewModel)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)}
    }
    
    // MARK: - iii
    private func show(quiz result: QuizResultsViewModel) {
        let alertPresenter = AlertPresenter(presentingController: self)
        
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
                self.setAnswerButtonsState(isEnabled: true)
            }
        )
        alertPresenter.showAlert(model: alertModel)
    }
    
    // MARK: - Properties
    
    private var currentQuestionIndex = 0    // Индекс текущего вопроса
    private var correctAnswers = 0           // Счетчик правильных ответов
    private let questionsAmount: Int = 10    // Общее количество вопросов для квиза
    private var questionFactory: QuestionFactoryProtocol? = QuestionFactory()     // Фабрика вопросов
    private var currentQuestion: QuizQuestion?    // Вопрос, который виден пользователю
    let statisticService = StatisticService()

    
    //MARK: - IBOutlets
    
    @IBOutlet private var imageView: UIImageView!   // Отображения постера
    @IBOutlet private var textLabel: UILabel!       // Текст вопроса
    @IBOutlet private var counterLabel: UILabel!    // Счетчик вопросов
    @IBOutlet weak var noButton: UIButton!          // Кнопка "Нет"
    @IBOutlet weak var yesButton: UIButton!         // Кнопка "Да"
    
    // MARK: - Structures
    
    
    
    //MARK: - Private Methods
    
    // Конвертирует модель вопроса в модель для отображения
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),    // Загружаем изображение
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")   // Форматируем номер
        return questionStep
    }
    
    // Показывает вопрос на экране
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor // Сбрасываем цвет рамки
        setAnswerButtonsState(isEnabled: true)  // Активируем кнопки, после их отключения
    }
    
    // Показывает алерт с результатами
    
    
    
    // Показывает результат ответа
    private func showAnswerResult(isCorrect: Bool) {
        setAnswerButtonsState(isEnabled: false) // Блокируем кнопки от спама
        if isCorrect {
            correctAnswers += 1  // Увеличиваем счетчик правильных ответов
        }
        // Меняем цвет рамки в зависимости от ответа
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // Через 1 секунду переходим к следующему вопросу
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    // Определяет, показывать следующий вопрос или результаты
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount) \nКоличество сыгранных квизов: \(statisticService.gamesCount) \nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date)) \nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%)"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
             savedTotalCorrectAnswers(correctAnswers)
            show(quiz: viewModel)
        } else {                            // Иначе переходим к следующему вопросу
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func setAnswerButtonsState(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func setUpImage() {
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func savedTotalCorrectAnswers(_ value: Int) {
        let correctAnswers = UserDefaults.standard.integer(forKey: "totalCorrectAnswers")
        UserDefaults.standard.set(correctAnswers + value, forKey: "totalCorrectAnswers")
    }
    
    // MARK: - IBActions
    
    // Обработчик нажатия кнопки "Да"
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // Обработчик нажатия кнопки "Нет"
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    //MARK: - Работает Бахвалов
    
    
    
    
}
