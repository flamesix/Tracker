import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testViewController() {
            let vc = TrackerViewController()
            
            assertSnapshot(matching: vc, as: .image)
        }

}
