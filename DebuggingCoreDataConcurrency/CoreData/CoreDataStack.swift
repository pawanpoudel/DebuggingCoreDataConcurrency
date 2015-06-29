import Foundation
import CoreData

class CoreDataStack {
  func newPrivateQueueContext() -> NSManagedObjectContext? {
    let parentContext = self.mainQueueContext
    
    if parentContext == nil {
      return nil
    }
    
    var privateQueueContext =
      NSManagedObjectContext(concurrencyType:
        .PrivateQueueConcurrencyType)
    privateQueueContext.parentContext = parentContext
    privateQueueContext.mergePolicy =
      NSMergeByPropertyObjectTrumpMergePolicy
    return privateQueueContext
  }
  
  lazy var mainQueueContext: NSManagedObjectContext? = {
    let parentContext = self.masterContext
    
    if parentContext == nil {
      return nil
    }
    
    var mainQueueContext =
      NSManagedObjectContext(concurrencyType:
        .MainQueueConcurrencyType)
    mainQueueContext.parentContext = parentContext
    mainQueueContext.mergePolicy =
      NSMergeByPropertyObjectTrumpMergePolicy
    return mainQueueContext
  }()
  
  private lazy var masterContext: NSManagedObjectContext? = {
    let coordinator = self.persistentStoreCoordinator
    
    if coordinator == nil {
      return nil
    }
    
    var masterContext =
      NSManagedObjectContext(concurrencyType:
        .PrivateQueueConcurrencyType)
    masterContext.persistentStoreCoordinator = coordinator
    masterContext.mergePolicy =
      NSMergeByPropertyObjectTrumpMergePolicy
    return masterContext
  }()
  
  // MARK: - Setting up Core Data stack
  
  private lazy var managedObjectModel: NSManagedObjectModel = {
    let modelURL = NSBundle.mainBundle().URLForResource("DebuggingCoreDataConcurrency", withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelURL)!
  }()
  
  private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
    var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("DebuggingCoreDataConcurrency.sqlite")
    var error: NSError? = nil
    var failureReason = "There was an error creating or loading the application's saved data."
    
    if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
      coordinator = nil
      var dict = [String: AnyObject]()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
      dict[NSLocalizedFailureReasonErrorKey] = failureReason
      dict[NSUnderlyingErrorKey] = error
      error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
      
      println("Unresolved error \(error), \(error!.userInfo)")
      exit(1)
    }
    
    return coordinator
  }()
  
  private lazy var applicationDocumentsDirectory: NSURL = {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count-1] as! NSURL
  }()
  
  private func saveContext () {
    if let moc = self.mainQueueContext {
      var error: NSError? = nil
      if moc.hasChanges && !moc.save(&error) {
        println("Unresolved error \(error), \(error!.userInfo)")
        exit(1)
      }
    }
  }
}
