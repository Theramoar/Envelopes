import Foundation
import CoreData


extension Challenge {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Challenge> {
        return NSFetchRequest<Challenge>(entityName: "Challenge")
    }

    @NSManaged public var goal: String?
    @NSManaged public var days: Int32
    @NSManaged public var totalSum: Float
    @NSManaged public var savedSum: Float
    @NSManaged public var step: Float
    @NSManaged public var correction: Float
    @NSManaged public var isActive: Bool
    @NSManaged public var isReminderSet: Bool
    @NSManaged public var envelopes: NSOrderedSet?
    
//    @NSManaged public var colorString: String?
    @NSManaged public var reminderTime: Date?
    @NSManaged public var reminderStartDate: Date?
    @NSManaged public var reminderFrequency: Int32
    
    @NSManaged public var lastOpenedDate: Date?
    
    @NSManaged public var appTheme: ThemeSet?
    
    public var envelopesArray: [Envelope] {
        envelopes?.array as? [Envelope] ?? []
    }
    
    var frequency: Frequency {
        let position = Int(reminderFrequency)
        return Frequency.allCases[position]
    }
}

// MARK: Generated accessors for envelopes
extension Challenge {

    @objc(insertObject:inEnvelopesAtIndex:)
    @NSManaged public func insertIntoEnvelopes(_ value: Envelope, at idx: Int)

    @objc(removeObjectFromEnvelopesAtIndex:)
    @NSManaged public func removeFromEnvelopes(at idx: Int)

    @objc(insertEnvelopes:atIndexes:)
    @NSManaged public func insertIntoEnvelopes(_ values: [Envelope], at indexes: NSIndexSet)

    @objc(removeEnvelopesAtIndexes:)
    @NSManaged public func removeFromEnvelopes(at indexes: NSIndexSet)

    @objc(replaceObjectInEnvelopesAtIndex:withObject:)
    @NSManaged public func replaceEnvelopes(at idx: Int, with value: Envelope)

    @objc(replaceEnvelopesAtIndexes:withEnvelopes:)
    @NSManaged public func replaceEnvelopes(at indexes: NSIndexSet, with values: [Envelope])

    @objc(addEnvelopesObject:)
    @NSManaged public func addToEnvelopes(_ value: Envelope)

    @objc(removeEnvelopesObject:)
    @NSManaged public func removeFromEnvelopes(_ value: Envelope)

    @objc(addEnvelopes:)
    @NSManaged public func addToEnvelopes(_ values: NSOrderedSet)

    @objc(removeEnvelopes:)
    @NSManaged public func removeFromEnvelopes(_ values: NSOrderedSet)

}

extension Challenge : Identifiable {

}
