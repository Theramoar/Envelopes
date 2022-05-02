import CoreData
import SwiftUI

struct Theme {
    var accentColor: Color
    var foregroundColor: Color
    var backgroundColor: Color
}

extension ColorSet {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ColorSet> {
        return NSFetchRequest<ColorSet>(entityName: "ColorSet")
    }

    @NSManaged private var accentColorHex: String
    @NSManaged private var foregroundColorHex: String
    @NSManaged private var backgroundColorHex: String
    
    var theme: Theme {
        get {
            return Theme(accentColor: accentColorHex.color,
                   foregroundColor: foregroundColorHex.color,
                   backgroundColor: backgroundColorHex.color)
        }
        set {
            self.accentColorHex = newValue.accentColor.hex
            self.foregroundColorHex = newValue.foregroundColor.hex
            self.backgroundColorHex = newValue.backgroundColor.hex
        }
    }
}

extension ColorSet : Identifiable {}
