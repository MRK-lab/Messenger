//
//  RegisterViewController.swift
//  Messenger
//
//  Created by MRK on 12.04.2024.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)


    // aşşağı kaydırmak için
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    // login ekranına logo eklemek
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let firsNameFiedl: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "   First Name..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width:5,
                                             height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        
        return field
    }()
    
    private let lastNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "   Last Name..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width:5,
                                             height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        
        return field
    }()
    
    // email Field
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "   Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width:5,
                                             height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "   Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width:5,
                                             height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        field.isSecureTextEntry = true
        return field
    }()
    
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Log In"
        view.backgroundColor = .systemBackground // login arayüz rengi
        
        // login ekranında sağ tarafta navigation bar  ayarları ve didTapRegister fonksiyonunu kullanacak
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        registerButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firsNameFiedl)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePic))
        imageView.addGestureRecognizer(gesture)
        
    }
    
    @objc private func didTapChangeProfilePic(){
        presentPhotoActionSheet()
    }
    
    
    
    // logoyu ekranda göstermek ve boyutlandırmak için gerekli ayarkar
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size=scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        
        imageView.layer.cornerRadius = imageView.width/2.0
        
        firsNameFiedl.frame = CGRect(x: 30,
                                  y: imageView.bottom+10,
                                  width: scrollView.width-60,
                                 height: 52)
        
        lastNameField.frame = CGRect(x: 30,
                                  y: firsNameFiedl.bottom+10,
                                  width: scrollView.width-60,
                                 height: 52)
        
        emailField.frame = CGRect(x: 30,
                                  y: lastNameField.bottom+10,
                                  width: scrollView.width-60,
                                 height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                  y: emailField.bottom+10,
                                  width: scrollView.width-60,
                                 height: 52)
        
        registerButton.frame = CGRect(x: 30,
                                  y: passwordField.bottom+10,
                                  width: scrollView.width-60,
                                 height: 52)
        
    }
    
    @objc private func loginButtonTapped(){
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let firstName = firsNameFiedl.text,
            let lastName = lastNameField.text,
            let email = emailField.text,
            let password = passwordField.text,
                !email.isEmpty,
                !password.isEmpty,
                !firstName.isEmpty,
                !lastName.isEmpty,
                password.count >= 6 else{
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        // Firebase log in
        
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            
            guard let strongSelf = self else{
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else{
                // user already exists
                strongSelf.alertUserLoginError(message: "Looks like a user account for that email address already exists")
                return
            }
        
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResunlt, error in
                
                guard authResunlt != nil, error == nil else{
                    print("Error creating user")
                    return
                }
                
                //let user = result.user
                //print("Create User: \(user)")
                
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                
                let chatUser = ChatAppUser(firstName: firstName,
                                           lastName: lastName,
                                           emailAddress: email)
                DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                    if success {
                        // upload image
                        guard let image = strongSelf.imageView.image, let data = image.pngData() else{
                            return
                        }
                        let fileName = chatUser.profilePictureFileName
                        StorageManager.shared.uploadProgilePicture(with: data,
                                                                   fileName: fileName,
                                                                   completion: { result in
                            switch result {
                            case .success(let downloadUrl):
                                UserDefaults.standard.setValue(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case .failure(let error):
                                print("Sorage manager error: \(error)")
                            }
                        })
                    }
                })
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                
            })
        })
        
    }
    
    func alertUserLoginError(message: String = "Please enter all information to create a new account."){
        let alert = UIAlertController(title: "Wooops", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        vc.title="Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    

}


/*
 Bu kod parçasında, textFieldShouldReturn(_:) yöntemi, kullanıcının Return tuşuna bastığında davranışını tanımlar. Eğer kullanıcı e-posta alanında ise ve Return tuşuna basarsa, şifre alanına odaklanır (passwordField.becomeFirstResponder()). Eğer kullanıcı şifre alanında ise ve Return tuşuna basarsa, loginButtonTapped() metodunu çağırır. Bu genellikle bir giriş ekranında kullanıcıların e-posta ve şifre alanlarını doldurduktan sonra Return tuşuna basarak oturum açmalarını sağlar.
 */
extension RegisterViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField{
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField{
            loginButtonTapped()
        }
        
        return true
    }
    
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Chose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        self.imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

