import UIKit
import CoreData

class DetailsViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate   {

    @IBOutlet weak var kaydetButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var isimTextField: UITextField!
    @IBOutlet weak var fiyatTextField: UITextField!
    @IBOutlet weak var bedenTextField: UITextField!
    
    var secilenUrunIsmi = ""
    var secilenUrunId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kaydetButton.isHidden = true
        
        if secilenUrunIsmi != "" {
            
            // core data seçilen ürün bilgisini gösterir
            if let uuidString = secilenUrunId?.uuidString {
               
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Alisveris")
                fetchRequest.predicate = NSPredicate(format: "id = %@ ", uuidString )
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let sonuclar = try context.fetch(fetchRequest)
                    if sonuclar.count > 0 {
                        
                        for sonuc in sonuclar  as! [NSManagedObject] {
                            
                            if let isim = sonuc.value(forKey: "isim") as? String {
                                isimTextField.text = isim
                            }
                            if let fiyat = sonuc.value(forKey: "fiyat") as? String {
                                fiyatTextField.text = fiyat
                            }
                            if let beden = sonuc.value(forKey: "beden") as? String {
                                bedenTextField.text = beden
                            }
                            if let gorselData = sonuc.value(forKey: "gorsel") as? Data {
                                let image = UIImage(data: gorselData)
                                imageView.image = image
                            }
                    }
                }
            }
                catch {
                    print("hata var")
                }
            }
            
        }
        else {
            kaydetButton.isHidden = false
            kaydetButton.isEnabled = false
            
            isimTextField.text = ""
            fiyatTextField.text = ""
            bedenTextField.text = ""
            
        }

        let gestureRecognizer  = UITapGestureRecognizer(target: self, action: #selector(klavyeyiKapama))
        view.addGestureRecognizer(gestureRecognizer)
        
        
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
        view.addGestureRecognizer(imageGestureRecognizer)
        
}
    
    @objc func gorselSec () {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.dismiss(animated: true, completion: nil)
        picker.sourceType = .savedPhotosAlbum
        present(picker, animated: true, completion: nil)
    }
    
    @objc func klavyeyiKapama (){
        
        view.endEditing(true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        kaydetButton.isEnabled = true      // resim ekledikten sonra button aktif oluyor
        self.dismiss(animated: true , completion: nil)
    }
    
    @IBAction func kaydetmeButonu(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let alisveris = NSEntityDescription.insertNewObject(forEntityName: "Alisveris", into: context)
        
        alisveris.setValue(bedenTextField.text!, forKey: "beden")
        alisveris.setValue(isimTextField.text!, forKey: "isim")
        alisveris.setValue(UUID(), forKey: "id")
        
        if let fiyat = Int(fiyatTextField.text!) {
            
            alisveris.setValue(fiyatTextField.text, forKey: "fiyat")
        }
        
        let data = imageView.image?.jpegData(compressionQuality: 0.6)
        alisveris.setValue(data, forKey: "gorsel")
        
        do {
            try context.save()
        } catch {
            
            print("error :  \(error)") 
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("Veri girildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
}

    

