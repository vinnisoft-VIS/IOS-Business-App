//
//  InvestorHomeVC.swift
//  BulkExchange
//
//  Created by Gaurav on 21/03/22.
//

import UIKit
import AVKit
import SwiftGifOrigin
import Kingfisher

class InvestorHomeVC: UIViewController {
    
    
    @IBOutlet weak var imgNoData: UIImageView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var tblView: UITableView!
    
    var audioPlayer = AVAudioPlayer()
    var responseData:[InvestorDealData]?
    var likedDeals = [Int]()
    var dealsLikesCount = [Int]()
    override func viewDidLoad() {
        super.viewDidLoad()
        initialLoads()
        self.imgNoData.isHidden = true
        self.imgNoData.image = UIImage.gif(name: "no_data_found")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
                
        self.getDeals()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.txtSearch.resignFirstResponder()
    }
    
    //MARK: - BUTTON ACTIONS
    @IBAction func btnChat(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "IChatVC") as! IChatVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

//MARK: - HELPER FUNCTIONS
extension InvestorHomeVC{
        
    func initialLoads(){
        btnChat.addSubview(addBadge(value: "4"))
    }
    func playLikeSound(){
        let likeSound = URL(fileURLWithPath: Bundle.main.path(forResource: "LikePressed", ofType: "wav")!)
        do {
             audioPlayer = try AVAudioPlayer(contentsOf: likeSound)
             audioPlayer.play()
        } catch {
           // couldn't load file :(
        }
    }
}


extension InvestorHomeVC:UITableViewDataSource,UITableViewDelegate{
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.responseData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "IHomeTblCell", for: indexPath) as! IHomeTblCell
        cell.selectionStyle = .none
        
        let dict = self.responseData?[indexPath.row]
        cell.lblName.text = dict?.user
        cell.lblDealName.text = dict?.name
        let isPrivate = dict?.is_private
        if isPrivate == 1 {
            cell.lblAccountType.text = StringsConstants.privateAccount
        } else {
            cell.lblAccountType.text = StringsConstants.publicAccount
        }
        let url = URL(string: dict?.profile_image ?? "")
        cell.imgUser.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"), options: nil, progressBlock: nil, completionHandler: nil)

        cell.lblBussinessType.text = dict?.business_type
        cell.lblBussinessCategory.text = dict?.business_category
        cell.lblfundingTYpe.text = dict?.funding_type
        cell.lblLikesCount.text = "\(dealsLikesCount[indexPath.row])"
        let commentsCount = String(dict?.comments_count ?? 0)
        cell.lblCommentsCount.text = "\(commentsCount) Comment"
        let isLiked = likedDeals[indexPath.row]
        if isLiked == 1 {
            cell.imgLike.image = UIImage(named: "LikeS")
        } else {
            cell.imgLike.image = UIImage(named: "LikeUS")
        }
        
        cell.callBackLikeBtn = { [weak self] in
            
            if let self = self {
                
                UIView.animate(withDuration: 0.3,
                               animations: {

                    let likesCount = self.dealsLikesCount[indexPath.row]
                    
                    if self.likedDeals[indexPath.row] == 1 {
                                                
                        if likesCount != 0 {
                            
                            self.dealsLikesCount[indexPath.row] = likesCount - 1
                            cell.lblLikesCount.text = "\(self.dealsLikesCount[indexPath.row])"
                            
                        }
                        
                        self.likedDeals[indexPath.row] = 0
                        
                        let likeStatus = self.likedDeals[indexPath.row]
                        if likeStatus == 1 {
                            cell.imgLike.image = UIImage(named: "LikeS")
                        } else {
                            cell.imgLike.image = UIImage(named: "LikeUS")
                        }
                                                
                    }  else {
                        
                        self.likedDeals[indexPath.row] = 1
                        
                        let likeStatus = self.likedDeals[indexPath.row]
                        if likeStatus == 1 {
                            cell.imgLike.image = UIImage(named: "LikeS")
                        } else {
                            cell.imgLike.image = UIImage(named: "LikeUS")
                        }
                        
                        self.dealsLikesCount[indexPath.row] = likesCount + 1
                        cell.lblLikesCount.text = "\(self.dealsLikesCount[indexPath.row])"

                    }
                    cell.imgLike.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    
                },
                               completion: { _ in
                    UIView.animate(withDuration: 0.3) {
                        
                        cell.imgLike.transform = CGAffineTransform.identity
                        
                    }
                })
                
                if let dealId = dict?.id{
                    
                    self.likeUnlikeDeal(id: dealId, index: indexPath.row) { [weak self] (isConnected, likesCount) in
                        
                        if let self = self {
                            
                            UIView.animate(withDuration: 0.3,
                                           animations: {
                                
                                cell.lblLikesCount.text = "\(self.dealsLikesCount[indexPath.row])"

                                self.likedDeals[indexPath.row] = isConnected

                                if self.likedDeals[indexPath.row] == 1 {
                                    
                                    cell.imgLike.image = UIImage(named: "LikeS")
                                    
                                }  else {
                                    
                                    cell.imgLike.image = UIImage(named: "LikeUS")
                                    
                                }
                                
                                cell.imgLike.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                                
                            },
                                           completion: { _ in
                                UIView.animate(withDuration: 0.3) {
                                    
                                    cell.imgLike.transform = CGAffineTransform.identity
                                    
                                }
                            })
                        }
                    }
                }
            }
        }
        
        cell.callBackViewDocumentBtn = { [weak self] in
            if let docUrl = dict?.doc{
                if let id = dict?.id{
                    let vc = self?.storyboard?.instantiateViewController(withIdentifier: "IViewDocumentVC") as! IViewDocumentVC
                    vc.deal.id = id
                    vc.deal.docUrl = docUrl
                    vc.callBack = { [weak self] in
                        
                        let vc = self?.storyboard?.instantiateViewController(withIdentifier: "DealStageVC") as! DealStageVC
                        vc.dealId = id
                        vc.isFromHome = true
                        self?.navigationController?.pushViewController(vc, animated: true)
                        
                    }
                    vc.modalPresentationStyle = .overFullScreen
                    self?.present(vc, animated: true)
                }
            }
        }
        
        cell.callBackViewProfileBtn = { [weak self] in
            if let self = self{
                self.presentActionSheet(options: [Strings.viewProfile,Strings.sendMessage,Strings.cancel]) { option in
                    switch option{
                    case Strings.viewProfile:
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "IStartupProfileVC") as! IStartupProfileVC
                        if let id = dict?.user_id{
                            vc.id = id
                        }
                        self.navigationController?.pushViewController(vc, animated: true)
                    case Strings.sendMessage:
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "IChatDetailsVC") as! IChatDetailsVC
                        self.navigationController?.pushViewController(vc, animated: true)
                    default:
                        print("")
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DealDetailsVC") as! DealDetailsVC
        let dict = self.responseData?[indexPath.row]
        vc.dealId = dict?.id ?? 0
        vc.callBack = { [weak self] in

            let vc = self?.storyboard?.instantiateViewController(withIdentifier: "DealStageVC") as! DealStageVC
            vc.dealId = dict?.id ?? 0
            vc.isFromHome = true
            self?.navigationController?.pushViewController(vc, animated: true)

        }
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}


//MARK: - TEXTFILED DELEGATE
extension InvestorHomeVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


//MARK: - API CALL
extension InvestorHomeVC {
    func getDeals() {
        likedDeals.removeAll()
        let params = [String: Any]()
        RVApiManager.postAPI(Apis.getInvestorDeals, parameters: params, Vc: self, showLoader: true) { (data: InvestorDealModel) in
            if let success = data.success {
                if success{
                    if let response = data.data {
                        self.responseData = response
                        for i in response{
                            if let isLiked = i.is_liked{
                                self.likedDeals.append(isLiked)
                            }
                            if let likesCount = i.likes{
                                self.dealsLikesCount.append(likesCount)
                            }
                        }
                        if self.responseData?.count ?? 0 > 0 {
                            self.tblView.isHidden = false
                            self.imgNoData.isHidden = true
                        } else {
                            self.tblView.isHidden = true
                            self.imgNoData.isHidden = false
                        }
                        self.tblView.reloadData()
                    }
                } else {
                    self.showAlert(message: data.message ?? "", title: AlertsTitles.alert)
                }
            }
        }
    }
    
    func likeUnlikeDeal(id:Int,index:Int, completion:@escaping(Int,Int)->()) {
        let params = [String: Any]()
        RVApiManager.getAPI("\(Apis.likeUnlikeDeal)/\(id)", parameters: params, Vc: self, showLoader: false) { [weak self] (data: StartupDealDetailsModel) in
            if let self = self{
                if let success = data.success {
                    if success{
                        if let responseData =  data.data{
                            if let isLiked = responseData.is_liked {
                                self.likedDeals[index] = isLiked
                                if let likes = responseData.likes{
                                    self.dealsLikesCount[index] = likes
                                    completion(isLiked, likes)
                                }
                            }
                        }
                    } else {
                        self.showAlert(message: data.message ?? AlertsMessages.somethingWentWrong, title: "")
                    }
                }else{
                    self.showAlert(message: data.message ?? AlertsMessages.somethingWentWrong, title: "")
                }
            }
        }
    }

}
