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
    
    var databaseRef: FIRDatabaseReference! {
        
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorageReference! {
        
        return FIRStorage.storage().reference()
    }
    
    
    
    
    func signUp(username: String, firstname: String, lastname:String, country:String, email: String,pictureData: Data,password:String){
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                print("aqui1")
            }else {
                print("aqui2")
                self.setUserInfo(user: user, firstname: firstname, lastname: lastname, country: country, pictureData: pictureData,password: password, username: username)
                
            }
        })
        
    }
  
    private func setUserInfo(user: FIRUser!, firstname: String, lastname:String, country:String,pictureData: Data,password: String, username: String){
        
        let profilePicturePath = "profileImage\(user.uid)image.jpg"
        let profilePictureRef = storageRef.child(profilePicturePath)
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        
        profilePictureRef.put(pictureData, metadata: metaData) { (newMetadata, error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = "\(firstname) \(lastname)"
                
                if let url = newMetadata?.downloadURL() {
                changeRequest.photoURL = url
                }
                
                changeRequest.commitChanges(completion: { (error) in
                    if error == nil {
                        
                        self.saveUserInfoToDb(user: user, firstname: firstname, lastname: lastname, country: country,password: password, username: username)
                        
                        
                    }else {
                        print(error!.localizedDescription)

                    }
                })
                
            }
        }
        
        
        
    }
    

    
    private func saveUserInfoToDb(user: FIRUser!, firstname: String, lastname:String, country:String,password: String, username: String){
        
        
        let userRef = databaseRef.child("users").child(user.uid)
        let newUser = User(username: username, email: user.email!, firstname: firstname, lastname: lastname,  uid: user.uid, profilePictureUrl: String(describing: user.photoURL!), country: country)
        
        userRef.setValue(newUser.toAnyObject()) { (error, ref) in
            if error == nil {
                print("\(firstname) \(lastname) has been signed up successfullt")
            }else {
                print(error!.localizedDescription)
            }
            
            
        }

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
    
    
    
    func savePostToDB(post: Post, completed: @escaping ()->Void){
        
        let postRef = databaseRef.child("posts").childByAutoId()
        postRef.setValue(post.toAnyObject()) { (error, ref) in
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
    
    
    
    /*
    func signIn(email: String, password: String){
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                if let user = user {
                    print("\(user.displayName!) has logged in successfully!")
                    
                    let appDel = UIApplication.shared.delegate as! AppDelegate
                    appDel.takeToHome()
                    
                    
                }
                
            }else {
                print(error!.localizedDescription)
                
            }
        })
        
    }
    
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
    
}
