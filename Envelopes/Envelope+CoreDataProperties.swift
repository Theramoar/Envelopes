//
//  Envelope+CoreDataProperties.swift
//  Envelopes
//
//  Created by MihailsKuznecovs on 14/07/2021.
//
//

import Foundation
import CoreData


extension Envelope {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Envelope> {
        return NSFetchRequest<Envelope>(entityName: "Envelope")
    }

    @NSManaged public var sum: Float
    @NSManaged public var isOpened: Bool
    @NSManaged public var parent: Challenge?

}
