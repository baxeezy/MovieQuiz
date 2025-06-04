import XCTest
@testable import MovieQuiz

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        //Given
        let poster = app.images["Poster"]
        XCTAssertTrue(poster.waitForExistence(timeout: 5), "Poster did not appear in time")
        let firstPosterData = poster.screenshot().pngRepresentation
        
        let yesButton = app.buttons["Yes"]
        XCTAssertTrue(yesButton.waitForExistence(timeout: 2), "Yes button did not appear in time")
        
        //When
        yesButton.tap()
        XCTAssertTrue(poster.waitForExistence(timeout: 5), "Poster did not update in time")
        let secondPosterData = poster.screenshot().pngRepresentation
        
        
        //Then
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 2), "Index Label not found")
        XCTAssertNotEqual(firstPosterData, secondPosterData, "Poster image did not change")
        XCTAssertEqual(indexLabel.label, "2/10", "Quiz did not advance to second question")
    }
    
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testGameFinish() {
        sleep(2)
        for _ in 1...10 {
        app.buttons["Yes"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Game results"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }
    
    func testAlertDismiss() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Game results"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertFalse(alert.exists)
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}
