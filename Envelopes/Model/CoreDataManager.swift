//
//  Persistence.swift
//  Envelopes
//
//  Created by Misha Kuznecov on 09/06/2021.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    let container: NSPersistentContainer
    
    var challenges: [Challenge] = []
    
    var activeChallenge: Challenge? {
        challenges.first { $0.isActive }
    }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Envelopes")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        challenges = loadDataFromContainer(ofType: Challenge.self)
    }
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    func loadDataFromContainer<T: NSManagedObject>(ofType type: T.Type) -> [T] {
        var data = [T]()

        let entityName = NSStringFromClass(type)
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)

        do {
            data = try context.fetch(fetchRequest)
        } catch {
            print("Error loading data \(error.localizedDescription)")
        }
        return data
    }
    
    func saveChallenge(goal: String, days: Int, totalSum: Float, step: Float,correction: Float, currentColor: AppColor, notificationTime: Date) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Challenge", in: context) else { return }
        let newChallenge = NSManagedObject(entity: entity, insertInto: context) as! Challenge

        newChallenge.goal = goal
        newChallenge.days = Int32(days)
        newChallenge.totalSum = totalSum
        newChallenge.savedSum = 0.0
        newChallenge.step = step
        newChallenge.correction = correction
        newChallenge.colorString = currentColor.rawValue
        newChallenge.reminderTime = notificationTime
        
        challenges.forEach {$0.isActive = false}
        
        newChallenge.isActive = true
        
        var envelopes = [Envelope]()
        var envelopeSum: Float = 1
        
        for _ in 1...days {
            guard let entity = NSEntityDescription.entity(forEntityName: "Envelope", in: context) else { return }
            let newEnv = NSManagedObject(entity: entity, insertInto: context) as! Envelope
            newEnv.sum = envelopeSum
            envelopes.append(newEnv)
            envelopeSum += step
        }
        envelopes.shuffle()
        envelopes[0].sum += correction

        newChallenge.envelopes = NSOrderedSet(array: envelopes)
        challenges.append(newChallenge)
        saveContext()
        NotificationCenter.default.post(name: NSNotification.Name("ModelWasUpdated"), object: nil)
    }
    
    func openEnvelope(for challenge: Challenge, at index: Int) {
        challenge.savedSum += challenge.envelopesArray[index].sum.roundedUpTwoDecimals()
        challenge.envelopesArray[index].isOpened = true
        challenge.lastOpenedDate = Date()
        saveContext()
    }
    
    
    func setActiveChallenge(atIndex index: Int) {
        challenges.forEach { $0.isActive = false }
        challenges[index].isActive = true
        saveContext()
        NotificationCenter.default.post(name: NSNotification.Name("ModelWasUpdated"), object: nil)
    }
    
    func saveCurrentColor(accentColor: AppColor) {
        guard let challenge = activeChallenge else { return }
        challenge.colorString = accentColor.rawValue
        saveContext()
        NotificationCenter.default.post(name: NSNotification.Name("ModelWasUpdated"), object: nil)
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
        challenges.removeAll { $0 == object }
        saveContext()
        NotificationCenter.default.post(name: NSNotification.Name("ModelWasUpdated"), object: nil)
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}