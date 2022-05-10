import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private let container: NSPersistentContainer
    private var context: NSManagedObjectContext {
        container.viewContext
    }
    
    var challenges: [Challenge] = []
    var themeSets: [ThemeSet] = []
    
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
        themeSets = loadDataFromContainer(ofType: ThemeSet.self)
    }
    
//MARK: - Challenge Related Actions
    func saveChallenge(goal: String, days: Int, totalSum: Float, step: Float, correction: Float, isReminderSet: Bool, notificationTime: Date, notificationStartDate: Date?, notificationFrequency: Int, colorThemeSet: ThemeSet? = nil) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Challenge", in: context) else { return }
        let newChallenge = NSManagedObject(entity: entity, insertInto: context) as! Challenge

        newChallenge.goal = goal
        newChallenge.days = Int32(days)
        newChallenge.totalSum = totalSum
        newChallenge.savedSum = 0.0
        newChallenge.step = step
        newChallenge.correction = correction
        newChallenge.isReminderSet = isReminderSet
        newChallenge.appTheme = colorThemeSet
        
        if isReminderSet {
            newChallenge.reminderStartDate = notificationStartDate
            newChallenge.reminderTime = notificationTime
            newChallenge.reminderFrequency = Int32(notificationFrequency)
        }
        
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
        
        setActive(challenge: newChallenge)
    }
    
    func openEnvelope(for challenge: Challenge, at index: Int) {
        let envelope = challenge.envelopesArray[index]
        challenge.savedSum += envelope.sum.roundedUpTwoDecimals()
        envelope.isOpened = true
        let today = Date()
        envelope.openedDate = today
        challenge.lastOpenedDate = today
        saveContext()
    }
    
    
    func setActive(challenge: Challenge) {
        challenges.forEach { $0.isActive = false }
        challenge.isActive = true
        saveContext()
        NotificationCenter.default.post(name: .challengeModelWasUpdated, object: nil)
        NotificationCenter.default.post(name: .themeSetModelWasUpdated, object: nil)
    }
    
    func setNotificationData(_ newTime: Date, _ startDate: Date, _ frequency: Int, _ notificationEnabled: Bool) {
        activeChallenge?.reminderTime = newTime
        activeChallenge?.reminderStartDate = startDate
        activeChallenge?.reminderFrequency = Int32(frequency)
        activeChallenge?.isReminderSet = notificationEnabled
        saveContext()
        NotificationCenter.default.post(name: .challengeModelWasUpdated, object: nil)
    }
    
    func setNotificationEnable(_ notificationEnabled: Bool) {
        activeChallenge?.isReminderSet = notificationEnabled
        saveContext()
        NotificationCenter.default.post(name: .challengeModelWasUpdated, object: nil)
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
        challenges.removeAll { $0 == object }
        saveContext()
        NotificationCenter.default.post(name: .challengeModelWasUpdated, object: nil)
    }
    
    
//MARK: - ThemeSet Related Actions
    func saveTheme(darkTheme: Theme, lightTheme: Theme, isDefault: Bool = false) {
        guard let entity = NSEntityDescription.entity(forEntityName: "ThemeSet", in: context) else { return }
        let newTheme = NSManagedObject(entity: entity, insertInto: context) as! ThemeSet
        
        guard let entity = NSEntityDescription.entity(forEntityName: "ColorSet", in: context) else { return }
        
        let darkSet = NSManagedObject(entity: entity, insertInto: context) as! ColorSet
        darkSet.theme = darkTheme
        newTheme.dark = darkSet
        
        let lightSet = NSManagedObject(entity: entity, insertInto: context) as! ColorSet
        lightSet.theme = lightTheme
        newTheme.light = lightSet
        
        newTheme.isDefault = isDefault
        saveContext()
        #warning("Insert instead append, so the theme was appeared first in the list")
        themeSets.append(newTheme)
        NotificationCenter.default.post(name: .themeSetModelWasUpdated, object: nil)
    }
    
    func replace(deleted deletedThemeSet: ThemeSet, with replacementThemeSet: ThemeSet) {
        let currentThemeChallenges = challenges.filter { $0.appTheme == deletedThemeSet }
        currentThemeChallenges.forEach {$0.appTheme =  replacementThemeSet }
        saveContext()
    }
    
    func setActive(themeSet: ThemeSet) {
        activeChallenge?.appTheme = themeSet
        saveContext()
        NotificationCenter.default.post(name: .themeSetModelWasUpdated, object: nil)
    }
    
    func delete(colorThemeSet: ThemeSet) {
        context.delete(colorThemeSet)
        themeSets.removeAll { $0 == colorThemeSet }
        saveContext()
        NotificationCenter.default.post(name: .themeSetModelWasUpdated, object: nil)
    }
    
    
//MARK: - Private Methods
    private func loadDataFromContainer<T: NSManagedObject>(ofType type: T.Type) -> [T] {
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
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
