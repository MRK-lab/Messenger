//
//  ViewController.swift
//  Messenger
//
//  Created by MRK on 12.04.2024.
//

import UIKit
import FirebaseAuth

class ConversationViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = .red
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    // program açıldığında giriş yapılan kullanıcı gözükecek aksi halde login ekranı
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
        

}

