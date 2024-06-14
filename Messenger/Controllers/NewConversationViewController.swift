//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by MRK on 12.04.2024.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    public var completion: ((SearchResult) -> (Void))?

    
    private let spinner = JGProgressHUD(style: .dark)
    
    //private var users = [[String: String]]()
    private var users = [[String: String]]()
    
    //private var results = [[String: String]]()
    private var results = [SearchResult]()
    
    private var hasFetched = false
    
    // kullanıcı arama kısmı
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        return searchBar
    }()
    
    // arama kısmında tablo görünümü
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(NewConversationCell.self,
                       forCellReuseIdentifier: NewConversationCell.identifier)
        
        return table
    }()
    
    
    private let noResultLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true // varsayılan olarak gizlenmiş
        label.text = "No  Results"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultLabel)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancle",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultLabel.frame = CGRect(x: view.width/4,
                                     y: (view.height-200) / 2,
                                     width: view.width/2,
                                     height: 100)
    }
    
    // cancele tıklayınca kapatır
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationCell.identifier, for: indexPath) as! NewConversationCell
        cell.configure(with: model)
        return cell
    }
    // listelenen kullanıcılardan birisine tıkladıktan sonra olacaklar
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // start conversation
        let targetUserData = results[indexPath.row]
        
        dismiss(animated: true, completion: { [weak self] in
            
            self?.completion?(targetUserData)
        })
        
        // iki kez çağırma yapıyordu bu da arama kısmından mesajlarşma kımına geçerken iki kez poencere açılmasına neden oluyprdu. Bu hatayı bu şekilde çözdüm
        //completion?(targetUserData)
        
    }
    
    // her bir kullanıcı için belli bir yükseklik alanı vermek için
    // listelemede kullanıcılar iç içe girmemesi için
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}

extension NewConversationViewController: UISearchBarDelegate {
    
    //func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: "", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        spinner.show(in: view) // yükleniyor simgesi
        
        self.searchUsers(query: text)
        
    }
    
    func searchUsers(query: String) {
        // firebasede her zmana arama yapmayacağım.
        // ilk baktığımda diziye kaydedeceğim
        // ikinci baktığımda dizide olacak zaten
        
        
        
        // check if array has firebase results
        //  kullanıcı verilerinin daha önce Firebase'den alınıp alınmadığını belirtir
        if hasFetched {
            // if it does: filter
            filterUsers(with: query)
            
        }
        else {
            // if not, fetch them filter
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            })
        }
        

    }
    
    func filterUsers(with term: String) {
        // update the UI: eitehr show results or show no results label
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        self.spinner.dismiss()
        
        let results: [SearchResult] = self.users.filter({
            
            //kulklanıcı kendisini listeleyemiyor
            guard let email = $0["email"], email != safeEmail else {
                return false
            }
            
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            
            // arama kısmının geçerli olduğu tüm sonuçları listelemek için
            return name.hasPrefix(term.lowercased())
            
        }).compactMap({
            guard let email = $0["email"],
                    let name = $0["name"] else {
                return nil
            }
            
            return SearchResult(name: name, email: email)
        })
        
        self.results = results
        
        updateUI()
        
    }
    
    // ekranda gösterilecek olanları sseçiyorum sonuç değişkenine göre
    func updateUI() {
        if results.isEmpty {
            self.noResultLabel.isHidden = false
            self.tableView.isHidden = true
        }
        else {
            self.noResultLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
}

struct SearchResult {
    let name: String
    let email: String
}
