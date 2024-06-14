//
//  StorageManager.swift
//  Messenger
//
//  Created by MRK on 4.06.2024.
//

import Foundation
import FirebaseStorage


// final class miras alımını engeller

//final class StorageManager {
final class StorageManager {

    // shared uygulamanın her yerinde erişilebilir bir singleton değişkenidir
    static let shared = StorageManager()
    
    // Firebase Storage'ın kök referansına erişimi
    private let storage = Storage.storage().reference()
    
    /*
      /images/name-gmail.com_profile_pictures.png
     */
    
    // yükleme işlemi tamamlandığında çağrılacak geri arama (callback) türünü tanımlar. Result türü, işlemin sonucunu veya bir hatayı döndürecek.
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    
    /// upload picture to firebase storage and returns completion with url string to download
    public func uploadProgilePicture(with data: Data,
                                     fileName: String,
                                     completion: @escaping UploadPictureCompletion){
        // firebase resmi yükleme kısmı
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: {metadata, error in guard error == nil else {
                // failed
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            // yükleme başarılıysa resim url i alınır
            self.storage.child("images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("dowload url returned: \(urlString)")
                completion(.success(urlString))
            })
            
        })
    }
    
    
    ///  Upload image that will be sent in a conversation message
    public func uploadMessagePhoto(with data: Data,
                                     fileName: String,
                                     completion: @escaping UploadPictureCompletion){
        // firebase resmi yükleme kısmı
        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in guard error == nil else {
                // failed
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            // yükleme başarılıysa resim url i alınır
            self?.storage.child("message_images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("dowload url returned: \(urlString)")
                completion(.success(urlString))
            })
            
        })
    }
    
    ///  Upload video that will be sent in a conversation message
    public func uploadMessageVideo(with fileUrl: URL,
                                     fileName: String,
                                     completion: @escaping UploadPictureCompletion){
        // firebase video yükleme kısmı
        storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else {
                // failed
                print("Failed to upload video file to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            // yükleme başarılıysa resim url i alınır
            self?.storage.child("message_videos/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("dowload url returned: \(urlString)")
                completion(.success(urlString))
            })
            
        })
    }
    
    
    // oluşacak hata durumları
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    // profil resminin url ini diğer birimlerle paylaşmak için
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL(completion: {url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
        }
            completion(.success(url))
        })
    }
    
}
