import Foundation
import CoreData

class User: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var email: String

}
