//
//  ViewController.swift
//  SNSSample
//
//  Created by しゅん on 2019/12/13.
//  Copyright © 2019 g-chan. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //カメラボタン押下時の処理
    @IBAction func cameraButtonTappped(_ sender: Any) {
        //画像データの入力元としてカメラを使用する
        let sourceType:UIImagePickerController.SourceType = .camera
        
        //カメラが使用可能かチェックする
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = sourceType
            //デリゲートメソッドがこのクラスにあることを宣言
            imagePickerController.delegate = self
            //カメラ画面を表示する
            self.present(imagePickerController,animated: true,completion: nil)
        } else {
            label.text = "カメラは使用できません"
        }
    }
    
    //撮影が完了時の処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //カメラ画面の終了
        picker.dismiss(animated: true, completion: nil)
        
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //画像がイメージビューからはみ出さないように設定する
            imageView.contentMode = .scaleAspectFit
            //イメージビューに画像を表示する
            imageView.image = image
        }
        if picker.sourceType == .camera {
            label.text = "撮影を完了しました"
        } else {
            label.text = "画像データを読み込みました"
        }
    }
    
    //撮影キャンセル時の処理
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        if picker.sourceType == .camera {
            label.text = "撮影をキャンセルしました"
        } else {
            label.text = "画像データの読み込みをキャンセルしました。"
        }

    }
    
    //ステータスバーの非表示
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //保存ボタン押下時の処理
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let image = imageView.image else {
            label.text = "imageVire.imageが空です"
            return
        }
        //イメージビューの画像をフォトライブラリに保存
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(ViewController.image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //保存終了時の処理
    @objc func image(image:UIImage,didFinishSavingWithError error:NSError!,contextInfo:UnsafeMutableRawPointer) {
        
        if error != nil {
            label.text = "画像データを保存できませんでした"
        } else {
            label.text = "画像データを保存しました"
        }
    }
    
    @IBAction func selectionButtonTapped(_ sender: Any) {
        //フォトライブラリが使用可能か確認する
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            self.present(imagePickerController,animated: true,completion:nil)
            
        } else {
            label.text = "フォトライブラリは使用できません"
        }
    }
    
    @IBAction func otherButtonTapped(_ sender: Any) {
        //アクションシートの上に表示されるタイトル
        let actionController:UIAlertController = UIAlertController(title:"メニュー",message: nil,preferredStyle: .actionSheet)
        
        //アクションシート内のTwitterのボタン
        let twitterAction:UIAlertAction = UIAlertAction(title: "Twitter", style: .default, handler: {//ボタン選択時に以下が実行される
            (action:UIAlertAction!) -> Void in
            self.label.text = "Twitterを選択しました"
            self.post(serviceType:SLServiceTypeTwitter)})
        
        //アクションシート内のFacebookのボタン
        let facebookAction:UIAlertAction = UIAlertAction(title: "Facebook", style: .default, handler: {//ボタン選択時に以下が実行される
        (action:UIAlertAction!) -> Void in
        self.label.text = "Facebookを選択しました"
        self.post(serviceType:SLServiceTypeFacebook)})
        
        //アクションシート内のキャンセルのボタン
        let cancelAction:UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel//指定することで赤文字で表示される
            , handler: {//ボタン選択時に以下が実行される
        (action:UIAlertAction!) -> Void in
        self.label.text = "キャンセルしました"})
        //アクションの登録
        actionController.addAction(twitterAction)
        actionController.addAction(facebookAction)
        actionController.addAction(cancelAction)
        //アクションシートの表示
        present(actionController,animated: true,completion: nil)
    }
    
    //Twitter、Facebookが選択されたときに実行されるようにしたメソッド
    func post(serviceType:String) {
        //選択に応じたダイアログを表示する
        let composer:SLComposeViewController = SLComposeViewController(forServiceType: serviceType)!
        //イメージビューに画像があれば投稿用の画像としてセットする
        composer.add(imageView.image)
        //投稿後に以下が実行される
        composer.completionHandler = {
            (result:SLComposeViewControllerResult) in
            switch result {
            case .done:
                self.label.text = "投稿しました"
            case .cancelled:
                self.label.text = "投稿をキャンセルしました"
            @unknown default:
                self.label.text = "エラーが発生しました"
            }
        }
        //投稿ダイアログを表示する
        self.present(composer,animated: true,completion: nil)
    }
}

