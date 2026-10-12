//
//  FileNodeTests.swift
//  qBitControlTests
//

import XCTest
@testable import qBitManager

final class FileNodeTests: XCTestCase {

    func test_setPriority_updatesFile() {
        let file = makeFile(index: 4, name: "video.mp4", priority: 0)

        file.setPriority(priority: 1)

        XCTAssertEqual(file.priority, 1)
        XCTAssertEqual(file.getPriority(), 1)
        XCTAssertEqual(file.index, 4)
        XCTAssertEqual(file.name, "video.mp4")
    }

    func test_setPriority_updatesNestedLeavesWithoutChangingSiblingSubtree() {
        let root = FileNode(name: "")
        let selected = FileNode(name: "selected")
        let directFile = makeFile(index: 0, name: "first.mp4", priority: 1)
        let nested = FileNode(name: "nested")
        let nestedFile = makeFile(index: 1, name: "second.mp4", priority: 7)
        let sibling = FileNode(name: "sibling")
        let siblingFile = makeFile(index: 2, name: "third.mp4", priority: 6)
        nested.add(child: nestedFile)
        selected.addMultiple(children: [directFile, nested])
        sibling.add(child: siblingFile)
        root.addMultiple(children: [selected, sibling])

        for priority in [0, 1] {
            selected.setPriority(priority: priority)

            XCTAssertEqual(directFile.priority, priority)
            XCTAssertEqual(nestedFile.priority, priority)
            XCTAssertNil(selected.priority)
            XCTAssertNil(nested.priority)
            XCTAssertEqual(selected.getPriority(), priority)
            XCTAssertEqual(nested.getPriority(), priority)
            XCTAssertEqual(siblingFile.priority, 6)
            XCTAssertEqual(sibling.getPriority(), 6)
            XCTAssertEqual(selected.getIndexes(), [0, 1])
            XCTAssertEqual(root.getIndexes(), [0, 1, 2])
            XCTAssertEqual(directFile.name, "first.mp4")
            XCTAssertEqual(nestedFile.name, "second.mp4")
            XCTAssertEqual(siblingFile.name, "third.mp4")
        }
    }

    func test_setPriority_keepsEmptyDirectoryPriorityDerived() {
        let directory = FileNode(name: "empty")

        directory.setPriority(priority: 1)

        XCTAssertNil(directory.priority)
        XCTAssertEqual(directory.getPriority(), 0)
        XCTAssertTrue(directory.getIndexes().isEmpty)
    }

    private func makeFile(index: Int, name: String, priority: Int) -> FileNode {
        FileNode(
            index: index,
            name: name,
            size: 1024,
            progress: 0.5,
            priority: priority,
            is_seed: false,
            availability: 1
        )
    }
}
