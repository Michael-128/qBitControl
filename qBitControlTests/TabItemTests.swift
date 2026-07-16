import XCTest
@testable import qBitManager
import SwiftUI

final class TabItemTests: XCTestCase {

    func test_resetsOnServerChange_defaultsToTrue() {
        let tab = TabItem(label: "Test", systemImage: "star", value: .settings) {
            AnyView(Text("test"))
        }

        XCTAssertTrue(tab.resetsOnServerChange)
    }

    func test_resetsOnServerChange_canBeSetToFalse() {
        var tab = TabItem(label: "Settings", systemImage: "gear", value: .settings) {
            AnyView(Text("settings"))
        }
        tab.resetsOnServerChange = false

        XCTAssertFalse(tab.resetsOnServerChange)
    }
}
