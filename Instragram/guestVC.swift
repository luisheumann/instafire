//
//  guestVC.swift
//  Instragram
//
//  Created by Ahmad Idigov on 11.12.15.
//  Copyright © 2015 Akhmed Idigov. All rights reserved.
//

import UIKit
import Parse
import Firebase

var guestname = [String]()
var guestid = [String]()
class guestVC: UICollectionViewController {
    
    
     var netService = NetworkingService()
    // UI objects
    var refresher : UIRefreshControl!
    var page : Int = 12
    
    // arrays to hold data from server
    var uuidArray = [String]()
    var picArray = [PFFile]()
    
    var usersArray = [User]()
    
    var postsArray = [Post]()
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // allow vertical scroll
        self.collectionView!.alwaysBounceVertical = true
        
        // backgroung color
        self.collectionView?.backgroundColor = .white
        
        // top title
        self.navigationItem.title = guestname.last?.uppercased()
        
        // new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(guestVC.back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(guestVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        // pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(guestVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        // call load posts function
        loadPosts()
        
        print("caraculo:\(guestid)")
    }
    
    
    // back function
    func back(_ sender : UIBarButtonItem) {
        
        // push back
        _ = self.navigationController?.popViewController(animated: true)
        
        // clean guest username or deduct the last guest userame from guestname = Array
        if !guestname.isEmpty {
            guestname.removeLast()
        }
    }
    
    
    // refresh function
    func refresh() {
        refresher.endRefreshing()
        loadPosts()
    }
    
 
    let userId = "G2xtDaZaXOXMg5EcLyBBYWAbSYf1"
    // posts loading function
    
    
    func loadUser(){
        
            netService.fetchCurrentUserGuesst(userId: userId) { (user) in
 
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
    
    
    func loadPosts() {
        
        self.netService.fetchAllPosts(userId: userId) {(posts) in
            
            self.postsArray = posts
            self.postsArray.sort(by: { (post1, post2) -> Bool in
                Int(post1.postDate) > Int(post2.postDate)
            })
            
            // self.tableView.reloadData()
            self.collectionView?.reloadData()
        }
    }
    
    
    // load more while scrolling down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
           // self.loadMore()
        }
    }
    
    
    // paging
    func loadMore() {
        
        // if there is more objects
        if page <= picArray.count {
            
            // increase page size
            page = page + 12
            
            // load more posts
            let query = PFQuery(className: "posts")
            query.whereKey("username", equalTo: guestname.last!)
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
                    
                    print("loaded +\(self.page)")
                    self.collectionView?.reloadData()
                    
                } else {
                    print(error?.localizedDescription ?? String())
                }
            })
            
        }
        
    }
    
    
    // cell numb
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postsArray.count
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
        
       
        self.netService.fetchNumberOfPosts(postId: userId) { (numberOfComments) in
            header.posts.text = String( numberOfComments )
            
        }
        
        // COUNT followers
        
        self.netService.fetchNumberOfFollowers(follower: userId) { (numberOfComments) in
            header.followers.text = String( numberOfComments )
            
        }
        
        // COUNT followings
        
        self.netService.fetchNumberOfFollowings(following: userId) { (numberOfComments) in
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

    
    // tapped posts label
    func postsTap() {
        if !picArray.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.top, animated: true)
        }
    }
    
    // tapped followers label
    func followersTap() {
        user = guestname.last!
        category = "followers"
        
        // defind followersVC
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC
        
        // navigate to it
        self.navigationController?.pushViewController(followers, animated: true)
        
    }
    
    // tapped followings label
    func followingsTap() {
        user = guestname.last!
        category = "followings"
        
        // define followersVC
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC
        
        // navigate to it
        self.navigationController?.pushViewController(followings, animated: true)
        
    }
    
    
    // go post
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // send post uuid to "postuuid" variable
        postuuid.append(usersArray[indexPath.row].uid)
        
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
