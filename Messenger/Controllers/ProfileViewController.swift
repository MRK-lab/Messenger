//
//  ProfileViewController.swift
//  Messenger
//
//  Created by MRK on 12.04.2024.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    let data = ["Log Out"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
    }
    
    // profil sayfasında proıfil fotoğrafını göstermek için
    // resm url sini önce firebaseden alıp indirieceğim daha sonra bu resmi profil ekraında göstereceğim
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/"+fileName
        print(path)
        /*
         ####################
         Kullanıcı çıkış yaptıktan sonra eski pach geçerli sayılıyor. Bu ndeneler eski kullanıcın
         profil resmi gözüküyor. Bunu düzelmek için simülasyonda uygulamayı kapatıp açıyorum.
         Olası çözüm Log out dan sonra yeni kullanıcı giriş yaptığı zaman pachı güncellemek olacaktır
         */
        
        let headerView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: self.view.width,
                                        height: 300))
        headerView.backgroundColor = .link
        
        let imageView = UIImageView(frame:  CGRect(x: (headerView.width-150) / 2,
                                                   y: 75,
                                                   width: 150,
                                                   height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        headerView.addSubview(imageView)
        
        // profil fotoğrafını StorageManagerden alıp yerine koydum
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                self?.downloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        })
        
        return headerView
    }
    
    // resmi indirmek için kullandığım kütüphane
    func downloadImage(imageView: UIImageView, url: URL) {
        URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }).resume()
    }
    
    
}

extension ProfileViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet = UIAlertController(title: "",
                                     message: "",
                                     preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out",
                                      style: .destructive,
                                    handler: { [weak self] _ in
            
                            guard let strongSelf = self else {
                                return
                            }
                            
                            do{
                                try FirebaseAuth.Auth.auth().signOut()
                                
                                // çıkış sonrası log in ekranına geçsin
                                let vc = LoginViewController()
                                let nav = UINavigationController(rootViewController: vc)
                                    nav.modalPresentationStyle = .fullScreen
                                strongSelf.present(nav, animated: true)
                                
                            }
                            catch{
                                print("Failed to log out")
                            }
                            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                           handler: nil))
        present(actionSheet, animated: true)
        
    }
    
}
