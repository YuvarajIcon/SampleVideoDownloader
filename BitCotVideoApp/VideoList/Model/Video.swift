//
//  Video.swift
//  BitCotVideoApp
//
//  Created by Yuvaraj Selvam on 13/12/23.
//

import Foundation
import CoreData

@objc(Video)
public class Video: NSManagedObject {
    open class var entityName: String {
        return "Video"
    }
    
    @nonobjc open class func fetchRequest() -> NSFetchRequest<Video> {
        return NSFetchRequest<Video>(entityName: self.entityName)
    }
    
    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var downloadURL: String
    @NSManaged public var localURL: String?
    @NSManaged public var thumbnailURL: String?
    @NSManaged public var progress: NSNumber
    
    var isAvailableOffline: Bool {
        progress == 1 && localURL != nil
    }
    
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: Self.entityName, in: context)!
        self.init(entity: entity, insertInto: context)
    }
    
    static func fetchAll() -> [Video] {
        do {
            let fetchRequest = self.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            let videoEntities = try CoreDataManager.shared.context.fetch(fetchRequest)
            return videoEntities
        } catch {
            print("Error fetching video entities: \(error)")
            return []
        }
    }
    
    static func fetch(forURL url: String) -> Video? {
        do {
            let fetchRequest: NSFetchRequest<Video> = self.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Video.downloadURL), url)
            let videoEntities = try CoreDataManager.shared.context.fetch(fetchRequest)
            return videoEntities.first
        } catch {
            print("Error fetching video entity: \(error)")
            return nil
        }
    }
    
    static func delete(atURL url: String) {
        guard let entity = fetch(forURL: url) else {
            return
        }
        CoreDataManager.shared.context.delete(entity)
        CoreDataManager.shared.save()
    }
}
