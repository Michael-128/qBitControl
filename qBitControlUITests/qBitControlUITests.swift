//

import XCTest

final class qBitControlUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func test8kLibraryStartupAndScroll() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-8k-mocks"]
        app.launch()

        // Wait for task count text or table element to appear
        let taskCountText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Tasks'")).firstMatch
        XCTAssertTrue(taskCountText.waitForExistence(timeout: 60), "App failed to load 8k task list within 60s")

        // Swipe up to test scrolling performance
        let collectionOrTable = app.tables.firstMatch.exists ? app.tables.firstMatch : app.collectionViews.firstMatch
        XCTAssertTrue(collectionOrTable.exists, "Torrent list view not found")
        collectionOrTable.swipeUp()
        collectionOrTable.swipeUp()
    }
}
