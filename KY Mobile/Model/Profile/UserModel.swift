import Foundation

struct User {
    var UID: String
    var Name: String
    var Image: String
    var Email: String
    var Batch: String
    var StudentID: String
    
    init() {
        self.UID = ""
        self.Name = ""
        self.Image = ""
        self.Email = ""
        self.Batch = ""
        self.StudentID = ""
    }

    // Adding data to FBUser using a retrieved document from Firebase
    init?(userDict: [String: Any]) {
        self.UID = userDict["UID"] as? String ?? ""
        self.Name = userDict["Name"] as? String ?? ""
        self.Image = userDict["Image"] as? String ?? ""
        self.Email = userDict["Email"] as? String ?? ""
        self.Batch = userDict["Batch"] as? String ?? ""
        self.StudentID = userDict["StudentID"] as? String ?? ""
    }
    
    // Check if two Users are the same
    // Used to check if any changes are made to the user's details
    func equalTo(_ user: User) -> Bool {
        return (self.UID == user.UID &&
                    self.Name == user.Name &&
                    self.Image == user.Image &&
                    self.Email == user.Email &&
                    self.Batch == user.Batch &&
                    self.StudentID == user.StudentID)
    }
    
    func userToDict() -> [String: Any] {
        return ["UID": self.UID,
                "Name": self.Name,
                "Image": self.Image,
                "Email": self.Email,
                "Batch": self.Batch,
                "StudentID": self.StudentID]
    }
    
    func isNameEmpty() -> Bool {
        // Leading, trailing whitespaces and newlines are ignored
        return Name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    
    func isStudentIDValid() -> Bool {
        return StudentID.count == 4
    }
    
    
    func isBatchValid() -> Bool {
        // Only allows batches from currentYear+1 to year+3
        // eg. in 2020 it will allow 21.0 to 23.5
        // eg. in 2021 it will allow 22.0 to 24.5
        let currentYear = Calendar.current.component(.year, from: Date())
        let allowedBatches = [currentYear - 1999, currentYear - 1998, currentYear - 1997]
        
        let splitedUpBatch = Batch.split(separator: ".")
        
        if splitedUpBatch.count == 2 {
            if allowedBatches.contains((splitedUpBatch[0] as NSString).integerValue) {
                if [0, 5].contains((splitedUpBatch[1] as NSString).integerValue) {
                    return true
                }
            }
        }
        return false
    }
    
    
    func isEmailValid() -> Bool {
        let emailTest = NSPredicate(format: "SELF MATCHES %@",
                                       "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        return emailTest.evaluate(with: Email)
    }
}
