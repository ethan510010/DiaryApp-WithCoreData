//
//  WriteDiaryViewController.swift
//  DiaryApp
//
//  Created by EthanLin on 2018/1/19.
//  Copyright © 2018年 EthanLin. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class WriteDiaryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, CLLocationManagerDelegate, SelectedDatePickerDelegate {
    //UIImagePickerControllerDelegate => 實作選取圖片完後觸發的事件
    //UINavigationControllerDelegate => 開啟相機或存取照片時畫面跳轉所用
    
    //執行SelectedDatePickerDelegate的方法
    func passDatePickerTime(selectedDate:String){
        diaryDateString = selectedDate
        
    }
    
    var diary: Diary!
    
    //接收前一個畫面過來的資料
    var diaryTitleText: String?
    var diaryContentText: String?
    var diaryLocationText: String?
    var diaryDateString: String?
    //日記標題
    @IBOutlet weak var diaryTitle: UITextField!
    // diaryTextView相關

    //位置Label
    @IBOutlet weak var locationLabel: UILabel!
    
    var photoArray =  [UIImage]()
    
    let textViewFont = UIFont.systemFont(ofSize: 22)
    
    @IBOutlet weak var diaryTextView: UITextView!
    
    //處理地圖相關
    let locationManager = CLLocationManager()
    
    
    //在鍵盤上加入toolBar
    @IBOutlet var toolBar: UIView!
    
    //toolBar的動作
    // 開啟相機
    @IBAction func openCamera(_ sender: UIButton) {
        cameraUseWay(1)
    }
    
    //定位
    @IBAction func findLocation(_ sender: UIButton) {
        getLocation()
    }
    
    
    //存檔按鈕
    @IBAction func saveDiaryAndGotoView3(_ sender: UIBarButtonItem) {
        //可以存Diary的功能
        if diary != nil{
            updateDiary()
        }else{
            saveDiary()
        }
         self.navigationController?.popToRootViewController(animated: true)
        
        //鍵盤跳出
        diaryTextView.resignFirstResponder()
        
        //textView清除
        diaryTitle.text = ""
        diaryTextView.text = ""
        
    }
    
    //點選相簿按鈕
    @IBAction func takePicture(_ sender: UIBarButtonItem) {
        self.cameraUseWay(2)
        
    }
    
    //選擇日期按鈕
    
    @IBAction func selectDate(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "selectDate", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectDate"{
            if let dateSelectedVC = segue.destination as? ViewController{
                dateSelectedVC.datePickerDelegate = self
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //地圖功能的委派
        locationManager.delegate = self
        
        //在虛擬鍵盤上加上按鈕
        diaryTextView.inputAccessoryView = toolBar
        
        configureDiaryData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //寫入一個方法來判斷到底要開相機還是選相簿
     func cameraUseWay(_ kind:Int){
        let picker = UIImagePickerController()
        switch kind {
        case 1:
            //開啟相機
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                picker.sourceType = UIImagePickerControllerSourceType.camera
                picker.allowsEditing = true // 可對照片做編輯
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }else{
                print("No camera")
            }
        default:
            //開啟相簿
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
                picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                picker.allowsEditing = true //可對照片做編輯
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }
        }
    }
    
    //相簿照片被點按後的事件
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let photo = info[UIImagePickerControllerOriginalImage] as! UIImage?
        
        if let okPhoto = photo{
            insertPicture(okPhoto, mode: .fitTextView)
            photoArray.append(okPhoto)
        }
        
//        self.photoImage = photo
//        //呼叫插入圖片的方法
//        if let okPhoto = photoImage{
//             insertPicture(okPhoto, mode: .fitTextLine)
//        }
//        insertPicture(photo!, mode: .fitTextView)
        dismiss(animated: true, completion: nil)
    }
 
    //在textView中插入圖片的方法
    //插入圖片
    func insertPicture(_ image:UIImage, mode:ImageAttachmentMode = .default){
        //獲取textView的所有文本，轉成可變的文本
        let mutableStr = NSMutableAttributedString(attributedString: diaryTextView.attributedText)
        
        //创建图片附件
        let imgAttachment = NSTextAttachment(data: nil, ofType: nil)
        var imgAttachmentString: NSAttributedString
        imgAttachment.image = image
        
        //设置图片显示方式
        if mode == .fitTextLine {
            //与文字一样大小
            imgAttachment.bounds = CGRect(x: 0, y: -4, width: diaryTextView.font!.lineHeight,
                                          height: diaryTextView.font!.lineHeight)
        } else if mode == .fitTextView {
            //撑满一行
            let imageWidth = diaryTextView.frame.width - 10
            let imageHeight = image.size.height/image.size.width*imageWidth
            imgAttachment.bounds = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        }
        
        imgAttachmentString = NSAttributedString(attachment: imgAttachment)
        
        //获得目前光标的位置
        let selectedRange = diaryTextView.selectedRange
        //插入文字
        mutableStr.insert(imgAttachmentString, at: selectedRange.location)
        //设置可变文本的字体属性
        mutableStr.addAttribute(NSAttributedStringKey.font, value: textViewFont,
                                range: NSMakeRange(0,mutableStr.length))
        //再次记住新的光标的位置
        let newSelectedRange = NSMakeRange(selectedRange.location+1, 0)
        
        //重新给文本赋值
        diaryTextView.attributedText = mutableStr
        //恢复光标的位置（上面一句代码执行之后，光标会移到最后面）
        diaryTextView.selectedRange = newSelectedRange
        //移动滚动条（确保光标在可视区域内）
        self.diaryTextView.scrollRangeToVisible(newSelectedRange)
    }
    
    
    enum ImageAttachmentMode {
        case `default`  //默认（不改变大小）
        case fitTextLine  //使尺寸适应行高
        case fitTextView  //使尺寸适应textView
    }
    
    
    //得到位置的函式
    func getLocation(){
       locationManager.requestWhenInUseAuthorization()
       //控制精準度
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
    }
    
    //把座標轉換成地址
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //轉換成地址後就停止更新資料
        locationManager.stopUpdatingLocation()
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(manager.location!) { (placeMarks, error) in
            if let placeMarksData = placeMarks{
                print(placeMarksData)
                let locationData = placeMarksData[0]
                //
                let city = locationData.locality!
                let state = locationData.administrativeArea!
                let zipCode = locationData.postalCode!
                let country = locationData.isoCountryCode!
                
                let location = "\(city), \(state), \(zipCode), \(country)"
                
                self.locationLabel.text = location
                
            }else{
                print(error?.localizedDescription)
            }
        }
    }
    
    
    //可以存日記的函數
    func saveDiary(){
        
        //如果日記的title不為空才實際進行儲存
        guard let title = diaryTitle.text, !title.isEmpty else {
            return
        }
  
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //創造 Managed Objects
        let diary = NSEntityDescription.insertNewObject(forEntityName: "Diary", into: context) as! Diary
        
         //把資料存進coreData
        //存標題
        diary.diaryTitle = title
        
        //存位置
        if let locationText = locationLabel.text{
            diary.diaryLocation = locationText
        }
        
        //存日期
        diary.diaryDate = diaryDateString
//        print(diary.diaryDate)
        
        if diaryTextView.text.characters.count > 0{
            //把資料存進coreData
            //存內容
            diary.diaryContent = diaryTextView.text
 
            //存圖片
            for eachPhoto in self.photoArray{
                var diaryImage = NSEntityDescription.insertNewObject(forEntityName: "DiaryImage", into: context) as! DiaryImage
                diaryImage.diaryImage = UIImageJPEGRepresentation(eachPhoto, 0.75) as NSData?
                diary.addToDiaryImages(diaryImage)
            }
   
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            print(path)
        }
        do {
            try context.save()
        } catch  {
            print(error.localizedDescription)
        }
        
    }
    
    func updateDiary(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        diary.setValue(self.diaryTitle.text, forKey: "diaryTitle")
        diary.setValue(self.diaryTextView.text, forKey: "diaryContent")
        diary.setValue(self.locationLabel.text, forKey: "diaryLocation")
        diary.setValue(self.diaryDateString, forKey: "diaryDate")
        
        
        do {
            try context.save()
        } catch  {
            print(error.localizedDescription)
        }
       
    }
    
    //方便到時候傳值直接執行函式裡面的內容
    func configureDiaryData(){
        diaryTitle.text = diaryTitleText
        diaryTextView.text = diaryContentText
        locationLabel.text = diaryLocationText
    }
    
}
