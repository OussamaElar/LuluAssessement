//
//  LuluAssessementTests.swift
//  LuluAssessementTests
//
//  Created by developer on 7/3/22.
//

import XCTest
import CoreData
@testable import LuluAssessement

class LuluAssessementTests: XCTestCase {
    
    
    var persistData: PersistData!
    var garmentViewModel =  GarmentViewModel()

    override func setUp() {
        super.setUp()
        initFakeData()
        persistData = PersistData(container: fakePersistantContainer)
    }
    
    override func tearDown() {
        flushData()
        super.tearDown()
    }
    
    func test_init_PersistData() {
        // test for proper initialization of persistData class
        let instance = PersistData()
        XCTAssertNotNil(instance)
    }
    
    func test_coreDataStackInitialization() {
        // test for NSPersistentContainer(the actual core data stack) initializes successfully
        guard let appDelagate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let presistDataStack = appDelagate.persistentContainer
        /*Asserts that an expression is not nil.
         Generates a failure when expression == nil.*/
        XCTAssertNotNil( presistDataStack )
      }
    
    func test_create_newGarement() {
        
        // test for adding new garments to the list
        let garment1 = Garment(name: "Dress", dateAdded: Date.now)
        let garment2 = Garment(name: "Jeans", dateAdded: Date.now)
        let garment3 = Garment(name: "Tshirt", dateAdded: Date.now)
        persistData.addToList(with: garment1) { result in
            switch result {
            case .success(()):
                XCTAssert(true)
            case .failure( _):
                XCTFail()
            }
        }
        persistData.addToList(with: garment2) { result in
            switch result {
            case .success(()):
                XCTAssert(true)
            case .failure( _):
                XCTFail()
            }
        }
        persistData.addToList(with: garment3) { result in
            switch result {
            case .success(()):
                XCTAssert(true)
            case .failure( _):
                XCTFail()
            }
        }
    }
    
    func test_fetch_all_garments() {
        
        //get all garments
        persistData.fetchItems { result in
            switch result {
            case .success(let garements):
                    print("garemnts", garements)
                    XCTAssertTrue(garements.count == 3)
            case .failure(_):
                    XCTFail()
            }
        }
    }
    // test for deleting on garment item
    func test_delete_item() {
        
        var garmentItems: [GarmentItem] = []
        persistData.fetchItems { result in
            switch result {
            case .success(let garments):
                    print("garemnts", garments)
                    garmentItems = garments
            case .failure(_):
                    print("Error fetching")
            }
        }
        let item = garmentItems[0]
        persistData.deleteItem(with: item.objectID) { result in
            switch result {
            case .success(()):
                self.persistData.fetchItems { result in
                    switch result {
                    case .success(let garments):
                            print("garemnts", garments)
                            garmentItems = garments
                    case .failure(_):
                            print("Error fetching")
                    }
                }
                print(garmentItems.count)
                XCTAssertTrue(garmentItems.count == 2)
            case .failure(_):
                XCTFail()
            }
        }
    }
    
    //MARK: test for sorting
    
    func test_sorting_alpha() {
        
        var garmentItems: [GarmentItem] = []
        persistData.fetchItems { result in
            switch result {
            case .success(let garments):
                    print("garemnts", garments)
                    garmentItems = garments
            case .failure(_):
                    print("Error fetching")
            }
        }
        
        let sortedArray = garmentItems.sorted(by: {$0.garmentName?.lowercased() ?? "" < $1.garmentName?.lowercased() ?? ""})
        
        let testArray = garmentViewModel.sortByAlpha(model: garmentItems)
        
        for i in 0...testArray.count - 1 {
            if testArray[i].garmentName != sortedArray[i].garmentName {
                XCTFail()
            }
        }
    }
    
    func test_sorting_date() {
        
        var garmentItems: [GarmentItem] = []

        persistData.fetchItems { result in
            switch result {
            case .success(let garments):
                    garmentItems = garments
            case .failure(_):
                    print("Error fetching")
            }
        }
        
        let sortedArray = garmentItems.sorted(by: {$0.dateAdded?.compare($1.dateAdded ?? Date.now) == .orderedDescending})
        let testArray = garmentViewModel.sortByDate(model: garmentItems)
        print("testArray", testArray)
        print("garmentArray", garmentItems)
        for i in 0...testArray.count - 1 {
            if testArray[i].garmentName != sortedArray[i].garmentName {
                XCTFail()
            }
        }
    }
    
    //MARK: mock in-memory persistant store
    lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main] )!
        return managedObjectModel
    }()
       
    lazy var fakePersistantContainer: NSPersistentContainer = {
       
        let container = NSPersistentContainer(name: "LuluAssessement", managedObjectModel: self.managedObjectModel)
        let description = container.persistentStoreDescriptions.first
        description?.type = NSInMemoryStoreType
        description?.shouldAddStoreAsynchronously = false
        container.loadPersistentStores { (description, error) in
           // Check if the data store is in memory
           precondition( description.type == NSInMemoryStoreType )
           // Check if creating container wrong
           if let error = error {
               fatalError("Create an in-mem coordinator failed \(error)")
           }
        }
        return container
   }()
}

extension LuluAssessementTests {
    
    // delete all data
    func flushData() {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "GarmentItem")
        let objs = try! fakePersistantContainer.viewContext.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            fakePersistantContainer.viewContext.delete(obj)
        }
        try! fakePersistantContainer.viewContext.save()
    }
    // create new fake data each time running a test
    func initFakeData() {
        func insertItems(name: String, date: Date) -> GarmentItem?{
            let obj = NSEntityDescription.insertNewObject(forEntityName: "GarmentItem", into: fakePersistantContainer.viewContext)
            print(obj)
            obj.setValue(name, forKey: "garmentName")
            obj.setValue(date, forKey: "dateAdded")
            
            return obj as? GarmentItem
        }
        _ = insertItems(name: "Dress", date: Date.now + 1)
        _ = insertItems(name: "Jeans", date: Date.now + 2)
        _ = insertItems(name: "Tshirt", date: Date.now + 3)
        do {
            try fakePersistantContainer.viewContext.save()
        }  catch {
            print("couldn't Create fake data \(error)")
        }
    }
    
}
