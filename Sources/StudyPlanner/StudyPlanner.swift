import Foundation

public enum StudyCategory: String, Codable, CaseIterable {
    case reading, practice, project
}

public enum StudyPlanError: Error, Equatable {
    case blankTitle
    case nonPositiveEstimatedMinutes
    case duplicateID(String)
    case unknownID(String)
}

public struct StudyItem: Codable, Equatable {
    public let id: String
    public let title: String
    public let estimatedMinutes: Int
    public let category: StudyCategory
    public private(set) var isCompleted: Bool

    public init(
        id: String,
        title: String,
        estimatedMinutes: Int,
        category: StudyCategory,
        isCompleted: Bool = false
    ) throws {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw StudyPlanError.blankTitle }
        guard estimatedMinutes > 0 else { throw StudyPlanError.nonPositiveEstimatedMinutes }
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.estimatedMinutes = estimatedMinutes
        self.category = category
        self.isCompleted = isCompleted
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let title = try container.decode(String.self, forKey: .title)
        let estimatedMinutes = try container.decode(Int.self, forKey: .estimatedMinutes)
        let category = try container.decode(StudyCategory.self, forKey: .category)
        let isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        try self.init(id: id, title: title, estimatedMinutes: estimatedMinutes, category: category, isCompleted: isCompleted)
    }
    
    mutating func markAsCompleted() {
        self.isCompleted = true
    }
}

public struct StudyPlan: Codable, Equatable {
    public private(set) var items: [StudyItem]

    public init(items: [StudyItem]) throws {
        var seenIDs = Set<String>()
        for item in items {
            let isNew = seenIDs.insert(item.id).inserted
            if !isNew {
                throw StudyPlanError.duplicateID(item.id)
            }
        }
        self.items = items.sorted { ($0.title, $0.id) < ($1.title, $1.id) }
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let items = try container.decode([StudyItem].self, forKey: .items)
        try self.init(items: items)
    }

    public static func decode(from data: Data) throws -> StudyPlan {
        let decoder = JSONDecoder()
        let items: [StudyItem] = try decoder.decode([StudyItem].self, from: data)
        return try StudyPlan(items: items)
    }

    public func items(in category: StudyCategory) -> [StudyItem] {
        var result: [StudyItem] = []
        for item in items where item.category == category {
            result.append(item)
        }
        return result
    }

    public func incompleteMinutes() -> Int {
        var totalMinutes: Int = 0
        for item in items where !item.isCompleted {
            totalMinutes += item.estimatedMinutes
        }
        return totalMinutes
    }

    public mutating func markCompleted(id: String) throws {
        guard let index = items.firstIndex(where: {$0.id == id}) else {
            throw StudyPlanError.unknownID(id)
        }
        items[index].markAsCompleted()
    }

    public mutating func importMerging(_ importedItems: [StudyItem]) throws {
        fatalError("Implement optional bonus")
    }
}
