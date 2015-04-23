import UIKit
import CoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        createUserInBackground()
    }
    
    private func createUserInBackground() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.createUser()
        }
    }
    
    private func createUser() {
        let coreDataStack = CoreDataStack()
        
        if let mainQueueContext = coreDataStack.mainQueueContext {
            let newUser = NSEntityDescription.insertNewObjectForEntityForName("User",
                inManagedObjectContext: mainQueueContext) as! User
            newUser.name = "The Dude"
            newUser.email = "dude@rubikscube.com"
            
            mainQueueContext.saveRecursively()
        }
    }
}
