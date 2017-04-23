//
//  User.swift
//  FirebaseLive
//
//  Created by Frezy Mboumba on 1/16/17.
//  Copyright © 2017 Frezy Mboumba. All rights reserved.
//

import Foundation
import Firebase

struct User {
    
    var email: String!
    var fullname: String
    var uid: String!
    var profilePictureUrl: String
    var country: String
    var ref: FIRDatabaseReference!
    var key: String = ""
    var isVerified: Bool = false
    var username: String
    
    
    
    init(snapshot: FIRDataSnapshot){
        self.username = (snapshot.value as! NSDictionary)["username"] as! String
        self.email = (snapshot.value as! NSDictionary)["email"] as! String
        self.fullname = (snapshot.value as! NSDictionary)["fullname"] as! String
        self.uid = (snapshot.value as! NSDictionary)["uid"] as! String
        self.country = (snapshot.value as! NSDictionary)["country"] as! String
        self.profilePictureUrl = (snapshot.value as! NSDictionary)["profilePictureUrl"] as! String
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.isVerified = (snapshot.value as! NSDictionary)["isVerified"] as! Bool
    }
    
    
    init(username: String, email: String, fullname: String, uid: String, profilePictureUrl: String, country: String){
        self.username = username
        self.email = email
        self.fullname = fullname
        self.uid = uid
        self.profilePictureUrl = profilePictureUrl
        self.country = country
        self.ref = FIRDatabase.database().reference()
        
    }
    
    func getFullname() -> String{
        
        return "\(fullname)"
    }
    
    
    
    
    func toAnyObject() -> [String: Any]{
        return ["username":self.username, "email":self.email,"fullname":self.fullname,"country":self.country,"uid":self.uid,"profilePictureUrl":profilePictureUrl,"isVerified":self.isVerified]
    }
    
    
    
    
    
    
}
