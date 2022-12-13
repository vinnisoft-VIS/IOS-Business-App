//
//  IDealsVC.swift
//  BulkExchange
//
//  Created by Gaurav on 22/03/22.
//

import UIKit
import Kingfisher
import SwiftGifOrigin

class IDealsVC: UIViewController {
    
    @IBOutlet weak var imgNoData: UIImageView!
    @IBOutlet weak var tblView: UITableView!
    
    var responseData: [InvestorDealData]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialLoads()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getDeals()
        self.tabBarController?.tabBar.isHidden = false
    }

}

//MARK: - HELPER FUNCTIONS
extension IDealsVC{
    
    private func initialLoads(){
        self.imgNoData.isHidden = true
        self.imgNoData.image = UIImage.gif(name: "no_data_found")
        self.configureNaviBar(title: ViewControllerTitles.myDeals, isBackButton: false)
    }

}

//MARK: - TABLE VIEW
extension IDealsVC: UITableViewDataSource,UITableViewDelegate{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.responseData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "IDealsTblCell", for: indexPath) as! IDealsTblCell
        
        cell.selectionStyle = .none
        let dict = self.responseData?[indexPath.row]
        
        if let img = dict?.profile_image{
            cell.imgUser.setImage(img: img)
        }
        if let name = dict?.user_name{
            cell.lblUserName.text = name
        }
        if let dealName = dict?.deal_name{
            cell.lblDealName.text = dealName
        }
        if let businessType = dict?.business_type{
            cell.lblBussinessType.text = businessType
        }
        if let stage = dict?.stage{
            
            let suffixStr:String = {
                if stage == 1{
                    return Strings.st
                } else if stage == 2{
                    return Strings.nd
                }else {
                    return Strings.rd
                }
            }()
            
            cell.lblDealStage.text = "\(Strings.stage) \(stage)\(suffixStr)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DealStageVC") as! DealStageVC
        
        let dict = self.responseData?[indexPath.row]

        if let stage = dict?.stage {
            vc.dealStage = stage
        }
        if let id = dict?.deal_id {
            vc.dealId = id
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}


//MARK: - API CALL
extension IDealsVC {
    func getDeals() {
        let params = [String: Any]()
        RVApiManager.getAPI(Apis.getInvestorMyDeals, parameters: params, Vc: self, showLoader: true) { (data: InvestorDealModel) in
            if let success = data.success {
                if success{
                    if let response = data.data {
                        self.responseData = response
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
}
