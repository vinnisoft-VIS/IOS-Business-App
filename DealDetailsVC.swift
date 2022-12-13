//
//  DealDetailsVC.swift
//  BulkExchange
//
//  Created by Lalit Kumar on 20/04/22.
//

import UIKit
import IQKeyboardManager
class DealDetailsVC: UIViewController {

    @IBOutlet weak var lblCommentsTitle: UILabel!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblCommentsCount: UILabel!
    @IBOutlet weak var lblLikesCount: UILabel!
    @IBOutlet weak var lblFundingType: UILabel!
    @IBOutlet weak var lblFundingGoal: UILabel!
    @IBOutlet weak var lblFundingAmount: UILabel!
    @IBOutlet weak var lblEstimateProfit: UILabel!
    @IBOutlet weak var lblEstimateRevenue: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblBussinessType: UILabel!
    @IBOutlet weak var lblDealName: UILabel!
    @IBOutlet weak var btnRequestInfo: UIButton!
    @IBOutlet weak var imgBadge: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var btnViewDocument: UIButton!
    @IBOutlet weak var txtViewComment: UITextView!
    @IBOutlet weak var tblViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewMsgBottom: NSLayoutConstraint!

    
    var dealId = 0
    var docUrl = String()
    var callBack : (()->())?
    var comments : [Comments]?
    var isFromStartUp = Bool()
    var isBoardMember = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialLoads()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true 
        
        self.getDealsDetails()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    @IBAction func btnViewDocument(_ sender: UIButton) {
        
        if isBoardMember {
            
            let vc = StoryBoards.boardMember.instantiateViewController(withIdentifier: "BMViewDocumentVC") as! BMViewDocumentVC
            vc.deal.id = dealId
            vc.deal.docUrl = docUrl
            vc.modalPresentationStyle = .overFullScreen
            vc.callBack = { [weak self] in
                self?.navigationController?.popViewController(animated: false)
                self?.callBack?()
            }
            self.present(vc, animated: true)
            
        } else {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "IViewDocumentVC") as! IViewDocumentVC
            vc.deal.id = dealId
            vc.deal.docUrl = docUrl
            vc.modalPresentationStyle = .overFullScreen
            vc.callBack = { [weak self] in
                self?.navigationController?.popViewController(animated: false)
                self?.callBack?()
            }
            self.present(vc, animated: true)
            
        }

    }
    
    @IBAction func btnPostComment(_ sender: UIButton) {
        
        if txtViewComment.text != "" {
            self.addCommentOnDeal()
        }
    }
}


//MARK: - HELPER FUNCTIONS
extension DealDetailsVC{
    
    private func initialLoads(){
            
        self.configureNaviBar(title: "", isBackButton: true)
        adjustTextViewProperties()
        
        if isFromStartUp {
            btnViewDocument.isHidden = true
        } else {
            btnViewDocument.isHidden = false
        }
  
    }
    
    private func adjustTextViewProperties(){
        
//        txtViewComment.translatesAutoresizingMaskIntoConstraints = true
//        txtViewComment.sizeToFit()
//        txtViewComment.isScrollEnabled = false
        txtViewComment.placeholder = Strings.commentsPlaceholder
//        txtViewComment.addPadding()
        
    }
        
}

//MARK: - TABLE VIEW
extension DealDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsTblCell", for: indexPath) as! CommentsTblCell
        
        let comment = comments?[indexPath.row]
        
        if let comnt = comment?.comment {
            cell.lblComment.text = comnt
        }
        
        if let img = comment?.profile_image {
            cell.imgUser.setImage(img: img)
        }
        
        if let username = comment?.user {
            cell.lblName.text  = username
        }
        

        cell.callBackReply = { [weak self] in
            
            if let self = self {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "RepliesVC") as! RepliesVC
                if let commentId = comment?.id {
                    vc.commentId = commentId
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
            
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
}

// MARK: - IQKeyBoardManager Methods

extension DealDetailsVC{
    
       func addObserver() {
           NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
       }
       
       func removeObserver() {
           NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
       }
       
       @objc func keyboardWillShow(_ notification: Notification) {
           
           
           if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
               let keyboardRectangle = keyboardFrame.cgRectValue
               let keyboardHeight = keyboardRectangle.height
                   UIView.animate(withDuration: 0.2, animations: {
                       if CurrentDevice.iPhone6 || CurrentDevice.iPhone6P || CurrentDevice.olderPhones{
                               self.viewMsgBottom.constant = keyboardHeight+8
                       } else {
                               self.viewMsgBottom.constant = (keyboardHeight) - self.view.safeAreaInsets.bottom
                       }
                   })
               self.scrollToBottom()
           }
       }
       
       @objc func keyboardWillHide(_ notification: Notification) {
           UIView.animate(withDuration: 0.2, animations: {
               self.tableView.contentInset = .zero
               self.viewMsgBottom.constant = 8
               
           })
       }
    
    func scrollToBottom() {
        if self.comments?.count ?? 0 > 3{
            let lastSectionIndex = tableView.numberOfSections - 1
            let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
            let pathToLastRow = IndexPath.init(row: lastRowIndex, section: lastSectionIndex)
            tableView.scrollToRow(at: pathToLastRow, at: .none, animated: false)
        }
    }
}

//MARK: - API CALL
extension DealDetailsVC {
    func getDealsDetails() {
        let params = [String: Any]()
        let url = "\(Apis.getInvetorDealDetails)/\(self.dealId)"
        RVApiManager.getAPI(url, parameters: params, Vc: self, showLoader: true) { (data: StartupDealDetailsModel) in
            if let success = data.success {
                if success{
                    if let response = data.data {
                        if let userName = response.user {
                            self.lblName.text = userName
                        }
                        if let docUrl = response.doc {
                            self.docUrl = docUrl
                        }
                        if let url = URL(string: response.profile_image ?? "") {
                            self.imgUser.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"), options: nil, progressBlock: nil, completionHandler: nil)
                        }
                        if let dealName = response.name {
                            self.lblDealName.text = dealName
                        }
                        if let bussinnessType = response.business_type {
                            self.lblBussinessType.text = bussinnessType
                        }
                        if let desc = response.description {
                            self.lblDesc.text = desc
                        }
                        if let fundingGoal = response.funding_goal {
                            let intFundingGoal = Int(fundingGoal)
                            self.lblFundingGoal.text = intFundingGoal?.roundedWithAbbreviations
                        }
                        if let estimateRevenue = response.estimate_revenue {
                            let intRevenue = Int(estimateRevenue)
                            self.lblEstimateRevenue.text = intRevenue?.roundedWithAbbreviations
                        }
                        if let estimateProfit = response.estimate_profit {
                            let intProfit = Int(estimateProfit)
                            self.lblEstimateProfit.text = intProfit?.roundedWithAbbreviations
                        }
                        if let fundingAmount = response.funding_amount {
                            let intFunding = Int(fundingAmount)
                            self.lblFundingAmount.text = intFunding?.roundedWithAbbreviations
                        }
                        if let fundingType = response.funding_type {
                            self.lblFundingType.text = fundingType
                        }
                        if let likesCount = response.likes {
                            self.lblLikesCount.text = String(likesCount)
                        }
                        if let comments = response.comments_count {
                            self.lblCommentsCount.text = "\(comments) Comments"
                        }
                        if let commentsList = response.comments {
                            if commentsList.count > 0 {
                                self.lblCommentsTitle.text = StringsConstants.comments
                            } else {
                                self.lblCommentsTitle.text = ""
                            }
                           // self.commentsResponse = commentsList
                           // self.tableViewHeightConstraint.constant = CGFloat((self.commentsResponse?.count ?? 0) * 150)
                        }
                        
                        if let isLiked = response.is_liked {
                            if isLiked == 1 {
                                self.imgLike.image = UIImage(named: "LikeS")
                            } else {
                                self.imgLike.image = UIImage(named: "LikeUS")
                            }
                        }
                        
                        if let comments = response.comments{
                            self.comments = comments
                            self.tblViewHeight.constant = CGFloat.greatestFiniteMagnitude
                            self.tableView.reloadData()
                            self.tableView.layoutIfNeeded()
                            self.tblViewHeight.constant = self.tableView.contentSize.height
                        }
                    }
                } else {
                    self.showAlert(message: data.message ?? "", title: AlertsTitles.alert)
                }
            }
        }
    }
    
    func addCommentOnDeal() {
        let params = ["deal_id":dealId,"comment":txtViewComment.text ?? ""] as [String : Any]
        RVApiManager.postAPI(Apis.addComment, parameters: params, Vc: self, showLoader: false) { [weak self] (data: StartupDealDetailsModel) in
            if let self = self{
                if let success = data.success {
                    if success{
                        self.txtViewComment.text = ""
                        self.getDealsDetails()
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
