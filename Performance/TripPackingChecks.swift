import Foundation

enum TripPackingChecks {
    static func run() throws {
        try deduplication()
        try identity()
        try projectionPrivacy()
        try legacyProjection()
    }

    private static func deduplication() throws {
        var plan = TripPlan(title: "Packing")
        plan.checklist = [TripChecklistItem(title: "Café voucher")]
        plan.checklist[0].isComplete = true
        let original = plan.checklist[0].id
        let titles = [" cafe voucher ", "Shoes", "shoes", "", "Two\nitems", String(repeating: "x", count: 81)]
        try require(TripChecklistEditing.append(titles, to: &plan) == 1, "Packing duplicate or invalid title accepted")
        try require(plan.checklist[0].id == original && plan.checklist[0].isComplete, "Packing replaced completed items")
        plan.checklist = (0..<TripLimits.checklistItems).map { TripChecklistItem(title: "Item \($0)") }
        try require(TripChecklistEditing.append(["Another item"], to: &plan) == 0, "Packing exceeded checklist limit")
    }

    private static func identity() throws {
        var plan = TripPlan(title: "Packing")
        plan.checklist = [TripChecklistItem(title: "Charger")]
        let identity = TripChecklistIdentity(tripID: plan.id, itemID: plan.checklist[0].id)
        try require(TripChecklistIdentity(identity.rawValue) == identity, "Checklist identity did not round trip")
        try require(identity.resolve(in: plan)?.title == "Charger", "Checklist identity failed to resolve")
        try require(identity.resolve(in: TripPlan(copying: plan)) == nil, "Checklist identity crossed trips")
        plan.checklist.removeAll()
        try require(identity.resolve(in: plan) == nil, "Deleted checklist item resolved")
        for value in ["", identity.rawValue + "/extra", "/" + identity.rawValue, identity.rawValue + "/"] {
            try require(TripChecklistIdentity(value) == nil, "Malformed checklist identity accepted")
        }
    }

    private static func projectionPrivacy() throws {
        var plan = TripJourneyFixtures.plan()
        plan.checklist = [TripChecklistItem(title: "PRIVATE_PACKING_ITEM"), TripChecklistItem(title: "PRIVATE_OTHER_ITEM")]
        plan.checklist[0].isComplete = true
        let surface = TripSurfacePlan(plan)
        let text = String(decoding: try JSONEncoder().encode(surface), as: UTF8.self)
        try require(!text.contains("PRIVATE_"), "Checklist text leaked to widgets")
        try require(surface.checklistProgress?.completed == 1 && surface.checklistProgress?.remaining == 1, "Checklist counts failed")
        let context = TripPackingContext(plan)
        plan.title = "Different title"
        plan.notes = "PRIVATE_NOTE"
        plan.checklist.removeAll()
        try require(context == TripPackingContext(plan), "Packing context includes private text or checklist state")
        let progress = TripChecklistProgress(total: -4, completed: 100)
        try require(progress.total == 0 && progress.completed == 0, "Checklist progress escaped bounds")
    }

    private static func legacyProjection() throws {
        let plan = TripSurfacePlan(TripJourneyFixtures.plan())
        var value = try JSONSerialization.jsonObject(with: JSONEncoder().encode(plan)) as! [String: Any]
        value.removeValue(forKey: "checklistProgress")
        let restored = try JSONDecoder().decode(TripSurfacePlan.self, from: JSONSerialization.data(withJSONObject: value))
        try require(restored.checklistProgress == nil && restored.id == plan.id, "Legacy widget snapshot broke")
        var empty = TripPlan(title: "Empty")
        try require(TripChecklistBriefing(empty).progress.total == 0, "Empty checklist has progress")
        empty.checklist = [TripChecklistItem(title: "Charger")]
        empty.checklist[0].isComplete = true
        try require(TripChecklistBriefing(empty).pending.isEmpty, "Completed checklist still lists pending items")
    }
}
