import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject {
    @nonobjc public class func fetchRequest(with searchText: String) -> NSFetchRequest<Note> {
        let fetch = NSFetchRequest<Note>(entityName: "Note")
        fetch.predicate = NSPredicate(format: "title contains[c] %@ OR desc contains[c] %@", argumentArray: [searchText, searchText])
        fetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        return fetch
    }
}
