//
//  DiaryCategoryTableViewController.swift
//  DiaryApp
//
//  Created by EthanLin on 2018/1/23.
//  Copyright © 2018年 EthanLin. All rights reserved.
//

import UIKit
import CoreData

class DiaryCategoryTableViewController: UITableViewController, NSFetchedResultsControllerDelegate{
    
    
    var diaryCategoryArray = [Diary]()
    
    var mySelection: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.fetchDiaryCategory()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaryCategoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "diaryCategoryCell", for: indexPath) as! DiaryCategoryTableViewCell
        
        cell.diaryTitle.text = diaryCategoryArray[indexPath.row].diaryTitle
        cell.diaryLocation.text = diaryCategoryArray[indexPath.row].diaryLocation
        cell.diaryDateLabel.text = diaryCategoryArray[indexPath.row].diaryDate
        
        
//        cell.imageView?.image = UIImage(data: (diaryCategoryArray[indexPath.row].diaryImages?.allObjects as! [DiaryImage])[0].diaryImage! as Data)
        
        return cell
        
    }
    
    
    //選到tableViewCell要做的事
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //點選後不會一直維持灰色
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        //為了給下面的方法用而存的
        mySelection = indexPath.row
        
        let existedDiary = self.diaryCategoryArray[indexPath.row]
        
        
        performSegue(withIdentifier: "writeDiary", sender: existedDiary)
        
        
    }
    
    // 試著把值傳到WriteDiaryViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "writeDiary"{
            if let writeDiaryVC = segue.destination as? WriteDiaryViewController{
                if let selection = mySelection{
                    print(selection)
                    let aDiary = diaryCategoryArray[selection]
                    writeDiaryVC.diaryTitleText = aDiary.diaryTitle
                    writeDiaryVC.diaryLocationText = aDiary.diaryLocation
                    writeDiaryVC.diaryContentText = aDiary.diaryContent
                    writeDiaryVC.diary = sender as? Diary
                    //為了讓新增日記裡面不會有內容
                    mySelection = nil
                }else{
                    print("test")
                    writeDiaryVC.diaryTitleText = ""
                    writeDiaryVC.diaryContentText = ""
                    writeDiaryVC.diaryLocationText = ""
                }

            }
        }
    }
    
    //Bar button 的動作(新增日記)
    @IBAction func backToView2AndAddNewDiary(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "writeDiary", sender: nil)
        
    }

    
    
    //讀取core Data資料
    func fetchDiaryCategory(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            diaryCategoryArray = try context.fetch(Diary.fetchRequest())
        } catch  {
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
    
    
    //編輯tableView同時刪除core Data
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if editingStyle == .delete{
            let diary = diaryCategoryArray[indexPath.row]
            context.delete(diary)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do{
                diaryCategoryArray = try context.fetch(Diary.fetchRequest())
            }catch{
                print(error.localizedDescription)
            }
            
        }
        tableView.reloadData()
    }
    
    //如果未來想要加上搜尋功能
    //    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Diary")
    //    let searchString = self.searchBar.text
    //    request.predicate = NSPredicate(format: "diaryTitle == %@", searchString)
    //
    //    do{
    //        let result = try context.fetch(request)
    
    
    
    //    }
    //    }catch{
    //        print(error)
    //    }
}
