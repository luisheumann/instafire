//
//  homeVC.swift
//  Instragram
//
//  Created by Ahmad Idigov on 10.12.15.
//  Copyright © 2015 Akhmed Idigov. All rights reserved.
//

import UIKit
import Parse
import Firebase
import SDWebImage

class homeVC: UICollectionViewController {

      var DataPost = [Post]()

    var storageRef: FIRStorageReference! {
        
        return FIRStorage.storage().reference()
    }

 
    var databaseRef: FIRDatabaseReference! {
        
        return FIRDatabase.database().reference()
    }
    
    var netService = NetworkingService()
    
    // refresher variable
    var refresher : UIRefreshControl!
    
    // size of page
    var page : Int = 12
 
    // arrays to hold server information
    var uuidArray = [String]()
    var picArray = [UIImage]()
    var imagenget = UIImage()
    
    var usersArray = [User]()

    var postsArray = [Post]()
    
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // always vertical scroll
        self.collectionView?.alwaysBounceVertical = true
        
        // background color
        collectionView?.backgroundColor = .white

        // title at the top
        self.navigationItem.title = GlobalVariable.userName
        
        // pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(homeVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        // receive notification from editVC
        NotificationCenter.default.addObserver(self, selector: #selector(homeVC.reload(_:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
        
        
        // load posts func
      
        
 //let currentUser = FIRAuth.auth()!.currentUser!
       // let currentUserRef = databaseRef.child("users/posts").child(currentUser.uid)
       
        print("pasa por aqui")
        
        //  netService.fetchAllPosts {(posts) in
       
        
        
      loadUserDetails()
  //loadPosts()
        fetchAllPosts()
        
   /*
        let following = "G2xtDaZaXOXMg5EcLyBBYWAbSYf1"
        let follower = "9ZlIDcCQGUfUdQANSwOoBcVtNgx2"
        
        self.netService.follow(follower: follower,following: following,  completed: {
            
            self.dismiss(animated: true, completion: nil)
        })
        
        */
        
        
        
        
    }
    
    
    // refreshing func
    func refresh() {
        
        // reload posts
     //  loadPosts()
        
        // stop refresher animating
        refresher.endRefreshing()
    }
    
    
    // reloading func after received notification
    func reload(_ notification:Notification) {
        collectionView?.reloadData()
    }
    
    
    func loadUserDetails() {
            netService.fetchCurrentUser { (user) in
                if let user = user {
                    
                    
                    let username = user.username
                    let fullname = user.getFullname()
                    let ImageUserUrl = user.profilePictureUrl
                    let imgUserURL = URL(string: ImageUserUrl)
                    let dataUserImage = NSData(contentsOf: (imgUserURL!))
                    let imagenUser = UIImage(data: dataUserImage as! Data)!
                    
                    GlobalVariable.userName = username
                    GlobalVariable.Fullname = fullname
                    GlobalVariable.ImagenUser = imagenUser
                    GlobalVariable.UserId = user.uid!
                    GlobalVariable.ImagenUserUrl = ImageUserUrl
                    
                }
            }
    }
    
    
    
    private func fetchAllPosts(){
      //  netService.fetchAllPosts {(posts) in
        let currentUser = FIRAuth.auth()!.currentUser!
    self.netService.fetchAllPosts(userId: currentUser.uid) {(posts) in

            self.postsArray = posts
            self.postsArray.sort(by: { (post1, post2) -> Bool in
                Int(post1.postDate) > Int(post2.postDate)
            })
            
           // self.tableView.reloadData()
              self.collectionView?.reloadData()
        }
    }
    
    
 

    
    
    
    
    
    
    
    
    
    
    
    
    ////////////////////////////////
    // load posts func/*
   /* func loadPosts() {
     
        
        /*
                */
          let currentUser = FIRAuth.auth()!.currentUser!
     
                self.netService.fetchAllPosts(userId: currentUser.uid) {(posts) in
                    self.postsArray = posts
      
                    self.uuidArray.removeAll(keepingCapacity: false)
                    self.picArray.removeAll(keepingCapacity: false)
                    
                    
                    for item in self.postsArray {
                        print(item.userId)
                    
                        let imgURL = URL(string: item.postImageURL)
                        let data = NSData(contentsOf: (imgURL!))
                        let imagennew = UIImage(data: data as! Data)!
                      
                        self.picArray.append(imagennew)
                        self.uuidArray.append(item.postId)
                        GlobalVariable.ImagenPic = imagennew
                        
                    }
                    
                  
                    
               self.collectionView?.reloadData()
                }
                
        
        
        
    }*/
    
    // load more while scrolling down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
            loadMore()
        }
    }
    
    
    // paging
    func loadMore() {
        /*
        // if there is more objects
        if page <= picArray.count {
            
            // increase page size
            page = page + 12
            
            // load more posts
            let query = PFQuery(className: "posts")
            query.whereKey("username", equalTo: PFUser.current()!.username!)
            query.limit = page
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.uuidArray.removeAll(keepingCapacity: false)
                    self.picArray.removeAll(keepingCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.uuidArray.append(object.value(forKey: "uuid") as! String)
                        self.picArray.append(object.value(forKey: "pic") as! PFFile)
                    }
                    
                    self.collectionView?.reloadData()
                    
                } else {
                    print(error?.localizedDescription ?? String())
                }
            })

        }
        */
    }
    
    
    // cell numb
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.postsArray.count
    }
    
    
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        return size
    }
    
    
    // cell config
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // define cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! pictureCell

        cell.picImg.sd_setImage(with: URL(string: self.postsArray[indexPath.row].postImageURL), placeholderImage: UIImage(named: "default-thumbnail"))
      //  sd_image = imagennew
        
        
        return cell
    }

    

    
    // header config
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // define header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! headerView
        
                header.webTxt.text  = GlobalVariable.userName
                header.fullnameLbl.text = GlobalVariable.Fullname
                header.avaImg.sd_setImage(with: URL(string: GlobalVariable.ImagenUserUrl), placeholderImage: UIImage(named: "default"))
        
  // COUNT POSTS
        header.button.setTitle("edit profile", for: UIControlState())

        let currentUser = FIRAuth.auth()!.currentUser!
        self.netService.fetchNumberOfPosts(postId: currentUser.uid) { (numberOfComments) in
        header.posts.text = String( numberOfComments )
                   
         }
    
// COUNT followers
        
        self.netService.fetchNumberOfFollowers(follower: currentUser.uid) { (numberOfComments) in
            header.followers.text = String( numberOfComments )
            
        }
        
// COUNT followings
        
        self.netService.fetchNumberOfFollowings(following: currentUser.uid) { (numberOfComments) in
            header.followings.text = String( numberOfComments )
            
        }

        
    
        
        
        // STEP 3. Implement tap gestures
        // tap posts
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.postsTap))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        // tap followers
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        // tap followings
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.followingsTap))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        
        return header
    }
    
    
    // taped posts label
    func postsTap() {
        if !picArray.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.top, animated: true)
        }
    }
    
    // tapped followers label
    func followersTap() {
        
       // user = PFUser.current()!.username!
        category = "followers"
        
        // make references to followersVC
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC
        
        // present
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    // tapped followings label
    func followingsTap() {
        
        user = PFUser.current()!.username!
        category = "followings"
        
        // make reference to followersVC
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC

        // present
        self.navigationController?.pushViewController(followings, animated: true)
    }
    
    
    // clicked log out
    @IBAction func logout(_ sender: AnyObject) {
    
        // implement log out
        PFUser.logOutInBackground { (error) -> Void in
            if error == nil {
                
                // remove logged in user from App memory
                UserDefaults.standard.removeObject(forKey: "username")
                UserDefaults.standard.synchronize()
                
                let signin = self.storyboard?.instantiateViewController(withIdentifier: "signInVC") as! signInVC
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = signin
                
            }
        }
        
    }
    
    
    // go post
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // send post uuid to "postuuid" variable
        postuuid.append(uuidArray[indexPath.row])
        
        // navigate to post view controller
        let post = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
    }
  
    
    
    struct GlobalVariable{
        static var myStruct = [String]();
        static var UserId = String();
        static var ImagenPic = UIImage();
        static var ImagenUser = UIImage();
        static var ImagenUserUrl = String();
        static var userName = String();
        static var Fullname = String();
        
    }

 }
