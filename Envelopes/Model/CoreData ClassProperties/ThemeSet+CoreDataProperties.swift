import Foundation
import CoreData
import SwiftUI


extension ThemeSet {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ThemeSet> {
        return NSFetchRequest<ThemeSet>(entityName: "ThemeSet")
    }

    @NSManaged public var dark: ColorSet
    @NSManaged public var light: ColorSet
    @NSManaged public var isDefault: Bool
    
    func theme(for colorScheme: ColorScheme) -> Theme {
        colorScheme == .light ? light.theme : dark.theme
    }

}

extension ThemeSet : Identifiable {}
