import CoreData

extension NSManagedObjectContext {
  func saveRecursively() {
    performBlockAndWait {
      if self.hasChanges {
        self.saveThisAndParentContexts()
      }
    }
  }
  
  func saveThisAndParentContexts() {
    var error: NSError? = nil
    let successfullySaved = save(&error)
    
    if successfullySaved {
      parentContext?.saveRecursively()
    } else {
      println("Error: \(error!.localizedDescription)")
    }
  }
}
