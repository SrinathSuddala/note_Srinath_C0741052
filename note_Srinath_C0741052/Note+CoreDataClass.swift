import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject {
    @nonobjc public class func fetchRequest(with searchText: String, categoryUuid: UUID) -> NSFetchRequest<Note> {
        let fetch = NSFetchRequest<Note>(entityName: "Note")
        fetch.predicate = NSPredicate(format: "title contains[c] %@ OR desc contains[c] %@ AND category.uuid == %@", argumentArray: [searchText, searchText, categoryUuid])
        fetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        return fetch
    }
    
    @nonobjc public class func fetchRequest(with categoryUuid: UUID) -> NSFetchRequest<Note> {
        let fetch = NSFetchRequest<Note>(entityName: "Note")
        fetch.predicate = NSPredicate(format: "category.uuid == %@", argumentArray: [categoryUuid])
        fetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        return fetch
    }
}
