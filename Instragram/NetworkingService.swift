//
//  NetworkingService.swift
//  FirebaseLive
//
//  Created by Frezy Mboumba on 1/16/17.
//  Copyright © 2017 Frezy Mboumba. All rights reserved.
//

import Foundation
import Firebase


struct NetworkingService {
    var window: UIWindow?
    
   
    var databaseRef: FIRDatabaseReference! {
        
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorageReference! {
        
        return FIRStorage.storage().reference()
    }
    
       var posts2 = [Post]()
    func signIn(email: String, password: String){
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                if let user = user {
                    print("\(user.displayName!) has logged in successfully!")
                    let currentUser = FIRAuth.auth()!.currentUser!
                    UserDefaults.standard.set(currentUser.displayName, forKey: "username")
                    UserDefaults.standard.synchronize()
                    
                    // call login function from AppDelegate.swift class
                    let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.login()

                    
                    
                }
                
            }else {
                print(error!.localizedDescription)
                
            }
        })
        
    }
    
    
    
    
    func signUp(username: String, fullname: String, country:String, email: String,pictureData: Data,password:String){
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                
            }else {
                
                self.setUserInfo(user: user, fullname: fullname, country: country, pictureData: pictureData,password: password, username: username)
                
            }
        })
        
    }
  
    

  func follow(follower: String, following: String, completed: @escaping ()->Void){
    
    //let timestamp = FIRServerValue.timestamp()
    let followDate = NSDate().timeIntervalSince1970 as NSNumber
    
    let userInfo = ["follower": follower,"following":following, "followDate": followDate] as [String : Any]
        
        //let userRef = self.databaseRef.child("follow").child(user.uid)
        let userRef = self.databaseRef.child("follows").childByAutoId()
        
        userRef.setValue(userInfo, withCompletionBlock: { (error, ref) in
            if error == nil {
                print("follow correcto")
            

                
            }else {
                DispatchQueue.main.async(execute: {
                                         print("hay un error el follow")
                })
                
            }

    })
    }
  
    private func setUserInfo(user: FIRUser!, fullname: String, country:String,pictureData: Data,password: String, username: String){
        
        let profilePicturePath = "profileImage\(user.uid)image.jpg"
        let profilePictureRef = storageRef.child(profilePicturePath)
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        
        profilePictureRef.put(pictureData, metadata: metaData) { (newMetadata, error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = username
               
                
                if let url = newMetadata?.downloadURL() {
                changeRequest.photoURL = url
                }
                
                changeRequest.commitChanges(completion: { (error) in
                    if error == nil {
                        
                        self.saveUserInfoToDb(user: user, fullname: fullname, country: country,password: password, username: username)
                        
                        
                    }else {
                        print(error!.localizedDescription)

                    }
                })
                
            }
        }
        
        
        
    }
    

    
    private func saveUserInfoToDb(user: FIRUser!, fullname: String, country:String,password: String, username: String){
        
        
        let userRef = databaseRef.child("users").child(user.uid)
        let newUser = User(username: username, email: user.email!, fullname: fullname,  uid: user.uid, profilePictureUrl: String(describing: user.photoURL!), country: country)
        
        userRef.setValue(newUser.toAnyObject()) { (error, ref) in
            if error == nil {
                print("\(fullname) has been signed up successfullt")
            }else {
                print(error!.localizedDescription)
            }
            
            
        }

       // self.signIn(email: user.email!, password: password)
        
    }
    
    func saveUserInfoEditToDb(user: String, fullname: String, country:String, username: String){
        
        
        /*let userRef = databaseRef.child("users").child(user)
        let newUser = User(username: username, fullname: fullname)
        
        userRef.setValue(newUser.toAnyObject()) { (error, ref) in
            if error == nil {
                print("\(fullname) has been signed up successfullt")
            }else {
                print(error!.localizedDescription)
            }
            
            
        }
        */
        // self.signIn(email: user.email!, password: password)
        
    }

    
    
    
    
    func fetchCurrentUser(completion: @escaping (User?)->()){
        
        let currentUser = FIRAuth.auth()!.currentUser!
        
        let currentUserRef = databaseRef.child("users").child(currentUser.uid)
        
        currentUserRef.observeSingleEvent(of: .value, with: { (currentUser) in
            
            let user: User = User(snapshot: currentUser)
            completion(user)
            
            
            
        }) { (error) in
            print(error.localizedDescription)
            
        }
        
        
        
    }
    
    
    func fetchCurrentUserGuesst(userId: String, completion: @escaping (User?)->()){
        
     
        
        let currentUserRef = databaseRef.child("users").child(userId)
        
        currentUserRef.observeSingleEvent(of: .value, with: { (currentUser) in
            
            let user: User = User(snapshot: currentUser)
            completion(user)
            
            
            
        }) { (error) in
            print(error.localizedDescription)
            
        }
        
        
        
    }
    
    
    
    func uploadImageToFirebase(postId: String,imageData: Data, completion: @escaping (URL)->()){
        
        let postImagePath = "postImages/\(postId)image.jpg"
        let postImageRef = storageRef.child(postImagePath)
        let postImageMetadata = FIRStorageMetadata()
        postImageMetadata.contentType = "image/jpeg"
        
        
        postImageRef.put(imageData, metadata: postImageMetadata) { (newPostImageMD, error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                if let postImageURL = newPostImageMD?.downloadURL() {
                    completion(postImageURL)
                }
            }
        }
        
    }
    
/*  let ref = FIRDatabase.database().reference()
 let postsReference = ref.child("posts")
 let newPostID = postsReference.childByAutoId().key
 
 // let postRef = databaseRef.child("posts").childByAutoId()
 let newPostReference = postsReference.child(newPostID)
 newPostReference.setValue(["postId": "sdsd","postDate":"dfdsf","postText":"sss","postImageURL":"url","userId":"d", "type": "imagen"]) { (error, ref) in*/
 
    func savePostToDB(post: Post, completed: @escaping ()->Void){
        print("entra a save")
        
        let ref = FIRDatabase.database().reference()
        let postsReference = ref.child("posts")
        let newPostID = postsReference.childByAutoId().key
        
       // let postRef = databaseRef.child("posts").childByAutoId()
        let newPostReference = postsReference.child(newPostID)
        newPostReference.setValue(["postId": post.postId,"postDate": post.postDate,"postText": post.postText,"postImageURL":post.postImageURL,"userId": post.userId, "type": post.type, "username": post.username]) { (error, ref) in
             print("recorre postref")
            if let error = error {
                print(error.localizedDescription)
            }else {
                let alertView = SCLAlertView()
                _ = alertView.showSuccess("Success", subTitle: "Post saved successfuly", closeButtonTitle: "Done", duration: 4, colorStyle: UIColor.black, colorTextButton: UIColor.white)
                completed()
            }
        }
        
    }
    
    func saveHashtagsToDB(hashtags: Hashtags, completed: @escaping ()->Void){
        
        let postRef = databaseRef.child("hashtags").childByAutoId()
        postRef.setValue(hashtags.toAnyObject()) { (error, ref) in
            if let error = error {
                print(error.localizedDescription)
            }else {/*
                let alertView = SCLAlertView()
                _ = alertView.showSuccess("Success", subTitle: "H hashtags successfuly", closeButtonTitle: "Done", duration: 4, colorStyle: UIColor.black, colorTextButton: UIColor.white)
                completed()*/
                print("hashtags guardado")
            }
        }
        
    }
    
    
    
    /*
    func saveHashtagsToDB(hashtag: Hashtag, completed: @escaping ()->Void){
        
        let hasRef = databaseRef.child("hashtags").childByAutoId()
        hasRef.setValue(hashtag.toAnyObject()) { (error, ref) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                let alertView = SCLAlertView()
                _ = alertView.showSuccess("Success", subTitle: "Post saved successfuly", closeButtonTitle: "Done", duration: 4, colorStyle: UIColor.black, colorTextButton: UIColor.white)
                completed()
            }
        }
        
    }
    */
    
    
    func uploadImageToFirebase2(postId: String,imageData: Data, completion: @escaping (URL)->()){
        
        let postImagePath = "postImages/\(postId)image.jpg"
        let postImageRef = storageRef.child(postImagePath)
        let postImageMetadata = FIRStorageMetadata()
        postImageMetadata.contentType = "image/jpeg"
        
        
        postImageRef.put(imageData, metadata: postImageMetadata) { (newPostImageMD, error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                if let postImageURL = newPostImageMD?.downloadURL() {
                    completion(postImageURL)
                }
            }
        }
        
    }
    
    
    func fetchNumberOfPosts(postId: String, completion: @escaping (Int)->()){
        
        let postsRef = databaseRef.child("posts").queryOrdered(byChild: "userId").queryEqual(toValue: postId)
        
        postsRef.observe(.value, with: { (posts) in
            
            completion(Int(posts.childrenCount))
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func fetchNumberOfFollowers(follower: String, completion: @escaping (Int)->()){
        
        let postsRef = databaseRef.child("follows").queryOrdered(byChild: "following").queryEqual(toValue: follower)
         postsRef.observe(.value, with: { (posts) in
         completion(Int(posts.childrenCount))
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func fetchNumberOfFollowings(following: String, completion: @escaping (Int)->()){
        
        let postsRef = databaseRef.child("follows").queryOrdered(byChild: "follower").queryEqual(toValue: following)
        postsRef.observe(.value, with: { (posts) in
         completion(Int(posts.childrenCount))
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    
       
    
    
    func fetchAllPosts(userId: String, completion: @escaping ([Post])->()){
    //func fetchAllPosts(completion: @escaping ([Post])->()){
    
        let postsRef = databaseRef.child("posts").queryOrdered(byChild: "userId").queryEqual(toValue: userId)
       // let postsRef = databaseRef.child("posts")

        postsRef.observe(.value, with: { (posts) in
            
            var resultArray = [Post]()
            for post in posts.children {
                
                let post = Post(snapshot: post as! FIRDataSnapshot)
                resultArray.append(post)
            }
            completion(resultArray)
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    
    
    func fetchAllFollowers(postId: String, completion: @escaping ([User])->()){
        
      //  let followsRef = databaseRef.child("follows").queryOrdered(byChild: "following").queryEqual(toValue: postId)
       let followsRef = databaseRef.child("users")
        
        followsRef.observe(.value, with: { (users) in
            
            var resultArray = [User]()
            for user in users.children {
                
                let user = User(snapshot: user as! FIRDataSnapshot)
                resultArray.append(user)
            }
            completion(resultArray)
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    
    /*

    
    func fetchAllPosts(completion: @escaping ([Post])->()){
        
        let postsRef = databaseRef.child("posts")
        postsRef.observe(.value, with: { (posts) in
            
            var resultArray = [Post]()
            for post in posts.children {
                
                let post = Post(snapshot: post as! FIRDataSnapshot)
                resultArray.append(post)
            }
            completion(resultArray)

        }) { (error) in
            print(error.localizedDescription)
        }

    }
    
    func fetchAllComments(postId: String, completion: @escaping ([Comment])->()){
        
        let commentsRef = databaseRef.child("comments").queryOrdered(byChild: "postId").queryEqual(toValue: postId)
        
        commentsRef.observe(.value, with: { (comments) in
            
            var resultArray = [Comment]()
            for comment in comments.children {
                
                let comment = Comment(snapshot: comment as! FIRDataSnapshot)
                resultArray.append(comment)
            }
            completion(resultArray)
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    func fetchNumberOfComments(postId: String, completion: @escaping (Int)->()){
        
        let commentsRef = databaseRef.child("comments").queryOrdered(byChild: "postId").queryEqual(toValue: postId)
        
        commentsRef.observe(.value, with: { (comments) in
            
            completion(Int(comments.childrenCount))
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }

    
    func fetchPostUserInfo(uid: String, completion: @escaping (User?)->()){
        
        
        let userRef = databaseRef.child("users").child(uid)
        
        userRef.observeSingleEvent(of: .value, with: { (currentUser) in
            
            let user: User = User(snapshot: currentUser)
            completion(user)
            
            
            
            
        }) { (error) in
            print(error.localizedDescription)
            
        }

        
    }

    func fetchAllUsers(completion: @escaping([User])->Void){
        
        let usersRef = databaseRef.child("users")
        usersRef.observe(.value, with: { (users) in
            
            var resultArray = [User]()
            for user in users.children {
                
                let user = User(snapshot: user as! FIRDataSnapshot)
                let currentUser = FIRAuth.auth()!.currentUser!
                
                if user.uid != currentUser.uid {
                    resultArray.append(user)
                }
                completion(resultArray)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    
    func logOut(completion: ()->()){
        
        
        if FIRAuth.auth()!.currentUser != nil {
            
            do {
                
                try FIRAuth.auth()!.signOut()
                completion()
            }
                
            catch let error {
                print("Failed to log out user: \(error.localizedDescription)")
            }
        }
        
        
    }

    func fetchGuestUser(ref:FIRDatabaseReference!, completion: @escaping (User?)->()){
        
        
        ref.observeSingleEvent(of: .value, with: { (currentUser) in
            
            let user: User = User(snapshot: currentUser)
            completion(user)
            
            
        }) { (error) in
            print(error.localizedDescription)
            
        }
        
        
        
    }
    
    func downloadImageFromFirebase(urlString: String, completion: @escaping (UIImage?)->()){
        
        let storageRef = FIRStorage.storage().reference(forURL: urlString)
        storageRef.data(withMaxSize: 1 * 1024 * 1024) { (imageData, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                
                if let data = imageData {
                    completion(UIImage(data:data))
                    
                }
            }
        }

    
}
    
  
    
    func saveCommentToDB(comment: Comment, completed: @escaping ()->Void){
        
        let postRef = databaseRef.child("comments").childByAutoId()
        postRef.setValue(comment.toAnyObject()) { (error, ref) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                let alertView = SCLAlertView()
                _ = alertView.showSuccess("Success", subTitle: "Comment saved successfuly", closeButtonTitle: "Done", duration: 4, colorStyle: UIColor(colorWithHexValue: 0x3D5B94), colorTextButton: UIColor.white)
                completed()
            }
        }
        
    }
    


*/
    
   /*
 let currentUser = FIRAuth.auth()!.currentUser!
 
 
 
 //  let userMessagesRef = FIRDatabase.database().reference().child("users").child(currentUser.uid)
 // userMessagesRef.observe(.childAdded, with: { (snapshot) in
 
 let messagesRef = FIRDatabase.database().reference().child("posts").queryOrdered(byChild: "userId").queryEqual(toValue: currentUser.uid)
 
 messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
 
 guard let dictionary = snapshot.value as? [String: AnyObject] else {
 return
 }
 
 
 for each in dictionary{
 
 print(each.value)
 }
 
 print("xxxxxxxxxxxxxxxxxx6")
 print(dictionary)
 print("xxxxxxxxxxxxxxxxxx6")
 
 }, withCancel: nil)
 

 */
 
        func fetchPosts2(completion: @escaping([Post])->Void){
    
        var following = [String]()
        let ref = FIRDatabase.database().reference()
 
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let users = snapshot.value as! [String : AnyObject]
            
            for (_,value) in users {
                if let uid = value["uid"] as? String {
                    if uid == FIRAuth.auth()?.currentUser?.uid {
                        if let followingUsers = value["following"] as? [String : String]{
                            for (_,user) in followingUsers{
                                following.append(user)
                                
                            }
                        
                        }
                        following.append(FIRAuth.auth()!.currentUser!.uid)
                        
                        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
                          
                            let postsSnap = snap.value as! [String : AnyObject]
                            for (_,post) in postsSnap {
                             for each in following {
                              if each == post["userId"] as? String {
                               let followsRef = self.databaseRef.child("posts").queryOrdered(byChild: "userId").queryEqual(toValue: post["userId"] as? String!)
                                        
                                        followsRef.observe(.value, with: { (posts) in
 
                                            var resultArray = [Post]()
                                    
                                            for post in posts.children {
                                                
                                                let post = Post(snapshot: post as! FIRDataSnapshot)
                                                
                                                resultArray.append(post)
                                               
                                            }
                                            completion(resultArray)

                                        })
                                
                                    }
                                    }
                               
                            }
                    
                        })
                    }
                }
            }
            
        })
        ref.removeAllObservers()
 
    }
////////////////// get user for name ///////////////
   /* func fetchUserGet(userId: String, completion: @escaping (User?)->()){
       let currentUserRef = databaseRef.child("users").child(userId)
        currentUserRef.observeSingleEvent(of: .value, with: { (currentUser) in
       let user: User = User(snapshot: currentUser)
            completion(user)
         
        }) { (error) in
            print(error.localizedDescription)
            
        }
       
    }
    */
    
    
    func fetchUserGet(postId: String, completion: @escaping ([User])->()){
        
        let followsRef = databaseRef.child("users").queryOrdered(byChild: "uid").queryEqual(toValue: postId)
      //  let followsRef = databaseRef.child("users")
        
        followsRef.observe(.value, with: { (users) in
            
            var resultArray = [User]()
         
            for user in users.children {
                
                let user = User(snapshot: user as! FIRDataSnapshot)
               
                resultArray.append(user)
           
            }
          
           // for object in resultArray {
           //     let username = object.username
             
           // }
             completion(resultArray)
            
           
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
////////////////////////////////////////////////////
    
    struct GlobalVariable{
        static var myStruct = [String]();
        static var userName = String();
        static var userID = String();
        static var postID = String();
        static var imageUrl = String();
        static var postText = String();
    }

    
    
}

/*
 self.fetchUserGet(postId: userID) {(users) in
 
 
 for object in users {
 let username = object.username
 print("yea baby: \(username)")
 
 if let imageurl = post["postImageURL"] as? String {
 print("imprime url: \(imageurl)")
 GlobalVariable.imageUrl = imageurl
 }
 
 GlobalVariable.userName = username
 
 
 
 }
 
 */
