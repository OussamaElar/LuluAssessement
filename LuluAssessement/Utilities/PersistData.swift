//
//  GarmentViewModel.swift
//  LuluAssessement
//
//  Created by Ouss Elar on 7/1/22.
//

import Foundation
import UIKit
import CoreData


class PersistData {
    
    enum DataPersistError: Error {
        case failedToSaveData
        case failedToFetchData
        case faildToDeleteData
    }

    let persistentContainer: NSPersistentContainer!
    
    lazy var backgroundContext: NSManagedObjectContext = {
            return self.persistentContainer.newBackgroundContext()
    }()
    
    init(container: NSPersistentContainer) {
            self.persistentContainer = container
            self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    convenience init() {
       //Use the actual core data container for savaing data when the app is running 
       guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
           fatalError("Can not get shared app delegate")
       }
       self.init(container: appDelegate.persistentContainer)
    }
    
    func addToList(with model: Garment, completion: @escaping (Result<Void, DataPersistError>) -> Void) {
        let context = backgroundContext
        guard let item = NSEntityDescription.insertNewObject(forEntityName: "GarmentItem", into: backgroundContext) as? GarmentItem else { return  }
        item.garmentName = model.name
        item.dateAdded = model.dateAdded
        do {
            try context.save()
            completion(.success(()))
        } catch {
                completion(.failure(DataPersistError.failedToSaveData))
        }
    }
    
    func fetchItems(completion: @escaping (Result<[GarmentItem], DataPersistError>) -> Void) {
        let context = persistentContainer.viewContext
    
        let request: NSFetchRequest<GarmentItem>
        
        request = GarmentItem.fetchRequest()
        
        do {
            let items = try context.fetch(request)
            completion(.success(items))
        } catch {
            completion(.failure(DataPersistError.failedToFetchData))
        }
    }
    
    func deleteItem(with objectId: NSManagedObjectID, completion: @escaping(Result<Void, DataPersistError>) -> Void) {
        let context = backgroundContext
        let obj = context.object(with: objectId)
        
        context.delete(obj)
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DataPersistError.faildToDeleteData))
        }
    }
}
