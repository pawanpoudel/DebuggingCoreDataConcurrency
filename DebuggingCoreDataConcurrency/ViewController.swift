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
    
    if let newPrivateQueueContext =
      coreDataStack.newPrivateQueueContext()
    {
      newPrivateQueueContext.performBlock {
        let newUser =
          NSEntityDescription
            .insertNewObjectForEntityForName("User",
              inManagedObjectContext: newPrivateQueueContext)
                as! User
        
        newUser.name = "The Dude"
        newUser.email = "dude@rubikscube.com"
        
        newPrivateQueueContext.saveRecursively()
      }
    }
  }
}
