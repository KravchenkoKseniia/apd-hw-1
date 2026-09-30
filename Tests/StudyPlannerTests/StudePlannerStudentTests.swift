import XCTest
@testable import StudyPlanner

final class StudyPlannerTests: XCTestCase {
    
    let validJSON = """
        [
          {
            "id": "swift-chapter-1",
            "title": "Read Swift concurrency chapter",
            "estimatedMinutes": 45,
            "category": "reading",
            "isCompleted": false
          },
          {
            "id": "collections-drill",
            "title": "Practice collection transformations",
            "estimatedMinutes": 30,
            "category": "practice",
            "isCompleted": true
          },
          {
            "id": "planner-milestone",
            "title": "Build study planner milestone",
            "estimatedMinutes": 90,
            "category": "project",
            "isCompleted": false
          }
        ]
        """
    
    let invalidJSONWithZeroMinutes = """
        [
          {
            "id": "swift-chapter-1",
            "title": "Read Swift concurrency chapter",
            "estimatedMinutes": 0,
            "category": "reading",
            "isCompleted": false
          }
        ]
        """
    
    let invalidJSONWithBlankTitle = """
        [
          {
            "id": "swift-chapter-1",
            "title": "   ",
            "estimatedMinutes": 45,
            "category": "reading",
            "isCompleted": false
          }
        ]
        """
    
    let duplicatedJSON = """
        [
          {
            "id": "swift-chapter-1",
            "title": "Read Swift concurrency chapter",
            "estimatedMinutes": 45,
            "category": "reading",
            "isCompleted": false
          },
          {
            "id": "collections-drill",
            "title": "Practice collection transformations",
            "estimatedMinutes": 30,
            "category": "practice",
            "isCompleted": true
          },
          {
            "id": "swift-chapter-1",
            "title": "Build study planner milestone",
            "estimatedMinutes": 90,
            "category": "project",
            "isCompleted": false
          }
        ]
        """
    
    func testValidJSON() throws {
        let jsonData = validJSON.data(using: .utf8)
        let plan = try StudyPlan.decode(from: jsonData!)
        
        XCTAssertEqual(plan.items.count, 3)
        XCTAssertEqual(plan.items(in: .reading).count, 1)
    }
    
    func testInvalidJSONWithBlankTitle() throws {
        let jsonData = invalidJSONWithBlankTitle.data(using: .utf8)
        
        XCTAssertThrowsError(try StudyPlan.decode(from: jsonData!)) { error in
            XCTAssertEqual(error as? StudyPlanError, StudyPlanError.blankTitle)
        }
    }
    
    func testInvalidJSONWithZeroMinutes() throws {
        let jsonData = invalidJSONWithZeroMinutes.data(using: .utf8)
        
        XCTAssertThrowsError(try StudyPlan.decode(from: jsonData!)) { error in
            XCTAssertEqual(error as? StudyPlanError, StudyPlanError.nonPositiveEstimatedMinutes)
        }
    }
    
    func testDuplicationDetected() throws {
        let jsonData = duplicatedJSON.data(using: .utf8)
        
        XCTAssertThrowsError(try StudyPlan.decode(from: jsonData!)) { error in
            XCTAssertEqual(error as? StudyPlanError, StudyPlanError.duplicateID("swift-chapter-1"))
        }
    }
    
    func testMarkCompleted() throws {
        let jsonData = validJSON.data(using: .utf8)
        var plan = try StudyPlan.decode(from: jsonData!)
        try plan.markCompleted(id: "planner-milestone")
        
        XCTAssertTrue(plan.items.first(where: { $0.id == "planner-milestone" })?.isCompleted ?? false)
    }
    
    func testMarkCompletedIdempotent() throws {
        let jsonData = validJSON.data(using: .utf8)
        var plan = try StudyPlan.decode(from: jsonData!)
        try plan.markCompleted(id: "collections-drill")
        
        XCTAssertTrue(plan.items.first(where: { $0.id == "collections-drill" })?.isCompleted ?? false)
    }
    
    func testMarkCompletedInvalidID() throws {
        let jsonData = validJSON.data(using: .utf8)
        var plan = try StudyPlan.decode(from: jsonData!)
        
        XCTAssertThrowsError(try plan.markCompleted(id: "invalid-id"))
    }
    
    func testIncompleteMinutes() throws {
        let jsonData = validJSON.data(using: .utf8)
        let plan = try StudyPlan.decode(from: jsonData!)
        
        XCTAssertEqual(plan.incompleteMinutes(), 135)
    }
    
    func testMarkCompletedAndIncompleteMinutes() throws {
        let jsonData = validJSON.data(using: .utf8)
        var plan = try StudyPlan.decode(from: jsonData!)
        try plan.markCompleted(id: "swift-chapter-1")
        try plan.markCompleted(id: "planner-milestone")
        
        XCTAssertEqual(plan.incompleteMinutes(), 0)
    }
}
