//
//  INetworkVC.swift
//  BulkExchange
//
//  Created by Gaurav on 21/03/22.
//

import UIKit

class INetworkVC: UIViewController {

    @IBOutlet weak var clcView: UICollectionView!
    @IBOutlet weak var imgNoData: UIImageView!

    var callBackScroll:((Bool,Bool)->())?
    var lastContentOffset: CGFloat = 0
    var investorResponse: [InvestorData]?
    var connectedUsers = [Int]()
    var searchText = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getInvestors()
    }

}

//MARK: - Functions

extension INetworkVC:PIMyNetworkSearch{
    func searchText(text: String) {
        self.searchText = text
        if (self.view.window != nil) {
            self.getInvestors()
        }
    }
}

//MARK: - COLLECTION VIEW
extension INetworkVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout , UIScrollViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.investorResponse?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = clcView.dequeueReusableCell(withReuseIdentifier: "IMyNetworkClcCell", for: indexPath) as! IMyNetworkClcCell
        let dict = self.investorResponse?[indexPath.row]
        cell.lblName.text = dict?.name
        cell.lblType.text = dict?.role?.capitalizingFirstLetter()
        
        switch connectedUsers[indexPath.row]{
            
        case 0:
            
            cell.btnConnect.backgroundColor = AppColors.color1
            cell.btnConnect.layer.borderWidth = 1
            cell.btnConnect.layer.borderColor = AppColors.color1.cgColor
            cell.btnConnect.setTitleColor(.white, for: .normal)
            cell.btnConnect.setTitle(ButtonTitles.connect, for: .normal)
            
        case 1:
            
            cell.btnConnect.backgroundColor = .clear
            cell.btnConnect.layer.borderWidth = 1
            cell.btnConnect.layer.borderColor = AppColors.color1.cgColor
            cell.btnConnect.setTitleColor(AppColors.color1, for: .normal)
            cell.btnConnect.setTitle(ButtonTitles.pending, for: .normal)
            
        default:
            
            cell.btnConnect.backgroundColor = AppColors.color1
            cell.btnConnect.layer.borderWidth = 1
            cell.btnConnect.layer.borderColor = AppColors.color1.cgColor
            cell.btnConnect.setTitleColor(.white, for: .normal)
            cell.btnConnect.setTitle(ButtonTitles.connected, for: .normal)
            
        }
        
        cell.callBackBtnConnect = { [weak self] in
            
            if let self = self{
                
                if self.connectedUsers[indexPath.row] == 0{
                    
                    self.connectedUsers[indexPath.row] = 1
                    cell.btnConnect.backgroundColor = .clear
                    cell.btnConnect.layer.borderWidth = 1
                    cell.btnConnect.layer.borderColor = AppColors.color1.cgColor
                    cell.btnConnect.setTitleColor(AppColors.color1, for: .normal)
                    cell.btnConnect.setTitle(ButtonTitles.pending, for: .normal)
                    
                    if let id = dict?.id{
                        
                        self.sendConnectRequest(id: id, index: indexPath.row) { isConnected in
                            
                            switch self.connectedUsers[indexPath.row]{
                                
                            case 0:
                                
                                cell.btnConnect.backgroundColor = AppColors.color1
                                cell.btnConnect.layer.borderWidth = 1
                                cell.btnConnect.layer.borderColor = AppColors.color1.cgColor
                                cell.btnConnect.setTitleColor(.white, for: .normal)
                                cell.btnConnect.setTitle(ButtonTitles.connect, for: .normal)
                                
                            case 1:
                                
                                cell.btnConnect.backgroundColor = .clear
                                cell.btnConnect.layer.borderWidth = 1
                                cell.btnConnect.layer.borderColor = AppColors.color1.cgColor
                                cell.btnConnect.setTitleColor(AppColors.color1, for: .normal)
                                cell.btnConnect.setTitle(ButtonTitles.pending, for: .normal)
                                
                            default:
                                
                                cell.btnConnect.backgroundColor = AppColors.color1
                                cell.btnConnect.layer.borderWidth = 1
                                cell.btnConnect.layer.borderColor = AppColors.color1.cgColor
                                cell.btnConnect.setTitleColor(.white, for: .normal)
                                cell.btnConnect.setTitle(ButtonTitles.connected, for: .normal)
                                
                            }
                        }
                    }

                    
                } else if self.connectedUsers[indexPath.row] == 1{
                    
                    self.connectedUsers[indexPath.row] = 0
                    cell.btnConnect.backgroundColor = AppColors.color1
                    cell.btnConnect.layer.borderWidth = 1
                    cell.btnConnect.layer.borderColor = AppColors.color1.cgColor
                    cell.btnConnect.setTitleColor(.white, for: .normal)
                    cell.btnConnect.setTitle(ButtonTitles.connect, for: .normal)
                    
                    if let id = dict?.id{
                        
                        self.sendConnectRequest(id: id, index: indexPath.row) { isConnected in
                            
                            switch self.connectedUsers[indexPath.row]{
                                
                            case 0:
                                
                                cell.btnConnect.backgroundColor = AppColors.color1
                                cell.btnConnect.layer.borderWidth = 1
                                cell.btnConnect.layer.borderColor = AppColors.color1.cgColor
                                cell.btnConnect.setTitleColor(.white, for: .normal)
                                cell.btnConnect.setTitle(ButtonTitles.connect, for: .normal)
                                
                            case 1:
                                
                                cell.btnConnect.backgroundColor = .clear
                                cell.btnConnect.layer.borderWidth = 1
                                cell.btnConnect.layer.borderColor = AppColors.color1.cgColor
                                cell.btnConnect.setTitleColor(AppColors.color1, for: .normal)
                                cell.btnConnect.setTitle(ButtonTitles.pending, for: .normal)
                                
                            default:
                                
                                cell.btnConnect.backgroundColor = AppColors.color1
                                cell.btnConnect.layer.borderWidth = 1
                                cell.btnConnect.layer.borderColor = AppColors.color1.cgColor
                                cell.btnConnect.setTitleColor(.white, for: .normal)
                                cell.btnConnect.setTitle(ButtonTitles.connected, for: .normal)
                                
                            }
                        }
                    }
                    
                } else {
                    
                    self.showAlertWithOkAndCancel(message: AlertsMessages.sureToDisconnect, strtitle: "", okTitle: Strings.disconnect, cancel: Strings.cancel) { ok in
                        
                        self.connectedUsers[indexPath.row] = 0
                        cell.btnConnect.backgroundColor = AppColors.color1
                        cell.btnConnect.layer.borderWidth = 1
                        cell.btnConnect.layer.borderColor = AppColors.color1.cgColor
                        cell.btnConnect.setTitleColor(.white, for: .normal)
                        cell.btnConnect.setTitle(ButtonTitles.connect, for: .normal)
                        
                        if let id = dict?.id{
                            
                            self.sendConnectRequest(id: id, index: indexPath.row) { isConnected in
                                
                                switch self.connectedUsers[indexPath.row]{
                                    
                                case 0:
                                    
                                    cell.btnConnect.backgroundColor = AppColors.color1
                                    cell.btnConnect.layer.borderWidth = 1
                                    cell.btnConnect.layer.borderColor = AppColors.color1.cgColor
                                    cell.btnConnect.setTitleColor(.white, for: .normal)
                                    cell.btnConnect.setTitle(ButtonTitles.connect, for: .normal)
                                    
                                case 1:
                                    
                                    cell.btnConnect.backgroundColor = .clear
                                    cell.btnConnect.layer.borderWidth = 1
                                    cell.btnConnect.layer.borderColor = AppColors.color1.cgColor
                                    cell.btnConnect.setTitleColor(AppColors.color1, for: .normal)
                                    cell.btnConnect.setTitle(ButtonTitles.pending, for: .normal)
                                    
                                default:
                                    
                                    cell.btnConnect.backgroundColor = AppColors.color1
                                    cell.btnConnect.layer.borderWidth = 1
                                    cell.btnConnect.layer.borderColor = AppColors.color1.cgColor
                                    cell.btnConnect.setTitleColor(.white, for: .normal)
                                    cell.btnConnect.setTitle(ButtonTitles.connected, for: .normal)
                                    
                                }
                            }
                        }
                        
                    } handlerCancel: { ok in
                        
                        
                    }
                }
                
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: clcView.frame.width/2 - 8, height: 191)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "IPublicProfileVC") as! IPublicProfileVC
        let dict = investorResponse?[indexPath.row]
        if let id = dict?.id{
            vc.id = id
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        let swipingDown = y <= 0
        let shouldSnap = y > 145
        callBackScroll?(swipingDown,shouldSnap)
    }
}



//MARK: - API CALL
extension INetworkVC {
    func getInvestors() {
        let params = ["search":searchText]
        connectedUsers.removeAll()
        RVApiManager.postAPI(Apis.getInvestorsStartups, parameters: params, Vc: self, showLoader: true) { (data: InvestorModel) in
            if let success = data.success {
                if success{
                    if let response = data.data {
                        self.investorResponse = response
                        for i in response{
                            if let isConnected = i.is_connected{
                                self.connectedUsers.append(isConnected)
                            }
                        }
                        if response.count > 0{
                            self.clcView.isHidden = false
                            self.imgNoData.isHidden = true
                            self.imgNoData.image = nil
                        }else{
                            self.clcView.isHidden = true
                            self.imgNoData.isHidden = false
                            self.imgNoData.loadGif(name: "no_data_found")
                        }
                        self.clcView.reloadData()
                    }
                } else {
                    self.showAlert(message: data.message ?? "", title: AlertsTitles.alert)
                }
            }
            
        }
    }
    
    
    func sendConnectRequest(id:Int,index:Int, completion:@escaping(Int)->()) {
        let params = [String: Any]()
        RVApiManager.getAPI("\(Apis.sendInvestorConnectionRequest)/\(id)", parameters: params, Vc: self, showLoader: false) { [weak self] (data: StartupProfileModel) in
            if let self = self{
                if let success = data.success {
                    if success{
                        if let responseData =  data.data{
                            if let isConnected = responseData.is_connected {
                                self.connectedUsers[index] = isConnected
                                completion(isConnected)
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
