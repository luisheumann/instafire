//
//  Follow
//
//
//  Created by HULK  on 1/22/17.
//  Copyright © 2017 Frezy Mboumba. All rights reserved.
//

import Foundation
import Firebase

struct Follow {
    
   
    var follower: String!
    var following: String!
    var followDate: NSNumber
 
    
    init(follower: String, following: String, followDate: NSNumber){
        self.follower = follower
        self.following = following
        self.followDate = followDate

       
    }
    
    init(snapshot:FIRDataSnapshot!) {
        self.follower = (snapshot.value! as! NSDictionary)["follower"] as! String
        self.following = (snapshot.value! as! NSDictionary)["following"] as! String
        self.followDate = (snapshot.value! as! NSDictionary)["followDate"] as! NSNumber

        

    }
    
    func toAnyObject()->[String: Any] {
        return ["follower":self.follower, "following":self.following, "followDate":self.followDate]
    }
    
}
