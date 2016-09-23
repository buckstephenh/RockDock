    //
//  User.swift
//  RockDock
//
//  Created by Stephen Buck on 9/11/16.
//  Copyright © 2016 Stephen Buck. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {
    
    //uuid is perm
    var uuid : String
    var handle: String?
    var email: String?
    
    // MARK: Properties
    
    struct PropertyKey {
        static let uuidKey = "uuid"
        static let handleKey = "handle"
        static let emailKey = "email"
    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("users")
    
    override init(){
        
        self.uuid = String()
        self.handle = String()
        self.email = String()
        super.init()
    }
    
    init(uuid: String, handle: String?, email:String?) {
        self.uuid = uuid
        self.handle = handle
        self.email = email
        super.init()
    }
    
    static func getUser() -> User {
        var user: User = User()
        //if the user can be retrieved from previous invocations, grab it, otherwise generate a new uuid
    
        if let users = NSKeyedUnarchiver.unarchiveObject(withFile: User.ArchiveURL.path) as? [User]{
            return users[0]
        } else {
           //create a new user
            let uuid = UUID().uuidString
            user = User(uuid: uuid, handle: "", email: "")
            
            //store the new user in the array
            let users = [user]
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(users, toFile: User.ArchiveURL.path)
            if !isSuccessfulSave {
                    print("Failed to save user...")
            }
              
            
        }
        return user
    }
    
    // MARK: NSCoding
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(uuid, forKey: PropertyKey.uuidKey)
        aCoder.encode(handle, forKey: PropertyKey.handleKey)
        aCoder.encode(email, forKey: PropertyKey.emailKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let uuid = aDecoder.decodeObject(forKey: PropertyKey.uuidKey) as! String
        
        // Because photo is an optional property of Rock, use conditional cast.
        let handle = aDecoder.decodeObject(forKey: PropertyKey.handleKey) as? String
        
        let email = aDecoder.decodeObject(forKey: PropertyKey.emailKey) as? String
        
        // Must call designated initializer.
        self.init(uuid: uuid, handle: handle, email: email)
    }
}
