//
//  Rock.swift
//  RockDock
//
//  Created by Stephen Buck on 9/2/16.
//  Copyright © 2016 Stephen Buck. All rights reserved.
//

import UIKit

class Rock: NSObject, NSCoding {
    

    // MARK: Properties
    
    struct PropertyKey {
        static let nameKey = "name"
        static let photoKey = "photo"
        static let ratingKey = "rating"
        static let ownerKey = "owner"
    }
    
    var name: String
    var photo: UIImage?
    var rating: Int
    var owner: String?
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("rocks")



// MARK: Initialization

    init?(name: String, photo: UIImage?, rating: Int, owner:
        String?) {
        
    // Initialize stored properties.
    self.name = name
    self.photo = photo
    self.rating = rating
    self.owner = owner
    
    super.init()

    // Initialization should fail if there is no name or if the rating is negative.
    if name.isEmpty || rating < 0 {
        return nil
    }
}
    
    // MARK: NSCoding
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(photo, forKey: PropertyKey.photoKey)
        aCoder.encode(rating, forKey: PropertyKey.ratingKey)
        aCoder.encode(owner, forKey: PropertyKey.ownerKey)
    }
        
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
        
        // Because photo is an optional property of Rock, use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photoKey) as? UIImage
        
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.ratingKey)
        
        let owner = aDecoder.decodeObject(forKey: PropertyKey.ownerKey) as? String
        
        // Must call designated initializer.
        self.init(name: name, photo: photo, rating: rating, owner: owner)
    }
}
