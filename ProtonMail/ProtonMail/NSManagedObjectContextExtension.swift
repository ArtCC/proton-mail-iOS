//
//  NSManagedObjectContextExtension.swift
//  ProtonMail
//
//
// Copyright 2015 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    public func deleteAll(_ entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.includesPropertyValues = false
        
        perform { () -> Void in
            do {
                let objects = try self.fetch(fetchRequest)
                for object in objects as! [NSManagedObject] {
                    if object.managedObjectContext != nil {
                        self.delete(object)
                    }
                }
                PMLog.D("Deleted \(objects.count) objects.")
                if let error = self.saveUpstreamIfNeeded() {
                    PMLog.D("error: \(error)")
                }
            } catch let ex as NSError {
                PMLog.D("error: \(ex)")
            }
        }
    }
    
    public func managedObjectWithEntityName(_ entityName: String, forKey key: String, matchingValue value: CVarArg) -> NSManagedObject? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "%K == %@", key, value)
        
        do {
            let results = try fetch(fetchRequest)
            return results.first as? NSManagedObject
        } catch let ex as NSError {
            PMLog.D("error: \(ex)")
        }
        return nil
    }
    
    public func managedObjectsWithEntityName(_ entityName: String, forManagedObjectIDs objectIDs: [NSManagedObjectID], error: NSErrorPointer) -> [NSManagedObject]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = NSPredicate(format: "SELF in %@", objectIDs)
        do {
            let results = try fetch(request)
            return results as? [NSManagedObject]
        } catch let ex as NSError {
            PMLog.D("error: \(ex)")
        }
        return nil
    }
    
    public func saveUpstreamIfNeeded() -> NSError? {
        var error: NSError?
        do {
            if hasChanges {
                try save()
                if let parentContext = parent {
                    parentContext.performAndWait() { () -> Void in
                        error = parentContext.saveUpstreamIfNeeded()
                    }
                }
            }
        } catch let ex as NSError {
            error = ex
        }
        return error
    }
}
