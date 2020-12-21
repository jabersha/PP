import Foundation
import CoreData
import UIKit


private let apiURL = "https://run.mocky.io/v3/1d9c3bbe-eb63-4d09-980a-989ad740a9ac"
let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
var imagem:[UIImage?] = []


/*
 Json Contract
[
  {
    "id": 1,
    "name": "Shakira",
    "photoURL": "https://api.adorable.io/avatars/285/a1.png"
  }
]
*/

class ListContactService {
    
    
    func fetchContacts(completion: @escaping ([Contact]?, Error?) -> Void) {
        guard let api = URL(string: apiURL) else {
            return
        }
        if UserDefaults.standard.bool(forKey: CacheKeys.OFFLINE_CONTACT.rawValue){
            let lista = self.getContacts()
            UserDefaults.standard.setValue(false, forKey: CacheKeys.OFFLINE_CONTACT.rawValue)
            completion(lista, nil)
        } else {
            
            let session = URLSession.shared
            let task = session.dataTask(with: api) { (data, response, error) in
                guard let jsonData = data else {
                    return completion(nil,error)
                }
                
                do {
                    let decoder = JSONDecoder()
                    let decoded = try decoder.decode([Contact].self, from: jsonData)

                    self.deleteAllRecords()
                    self.saveOffline(contatos: decoded)
                    let lista = self.getContacts()
                    
                    if !UserDefaults.standard.bool(forKey: CacheKeys.FIRST_ACESS.rawValue){
                        UserDefaults.standard.setValue(true, forKey: CacheKeys.FIRST_ACESS.rawValue)
                    }
                    
                    completion(lista, nil)
                } catch let error {
                    completion(nil, error)
                }
            }
            task.resume()
        }
    }
    
    func saveOffline(contatos: [Contact]){
        if let entity = NSEntityDescription.entity(forEntityName: "List", in: context) {
            var index = 0
            for contacts in contatos{
                let newEntity = NSManagedObject(entity: entity, insertInto: context)
                index += 1
                
                newEntity.setValue(contacts.id, forKey: "id")
                newEntity.setValue(contacts.name, forKey: "name")
                newEntity.setValue(contacts.photoURL, forKey: "photoURL")
                if let imageURL = URL(string: contacts.photoURL){
                    let data = try? Data(contentsOf: imageURL)
                    if let data = data {
                        let image = UIImage(data: data)
                        imagem.append(image)
                        let img = image?.pngData()
                        newEntity.setValue(img, forKey: "img")
                    }
                }
                do{
                    try context.save()
                } catch {
                    print("Falhou ao salvar elemento de index:\(index)")
                }
            }

        }

    }
    
    func getContacts() -> [Contact]{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
        request.returnsObjectsAsFaults = false
        var lista = [Contact]()
        var img = UIImage()
        do{
            let result = try! context.fetch(request)
            for data in result as! [NSManagedObject]{
                let imagem = data.value(forKey: "img")
                if imagem != nil{
                    img = UIImage(data: imagem as! Data)!
                }

                
                lista.append(Contact.init(id: data.value(forKey: "id") as! Int , name: data.value(forKey: "name") as! String, photoURL: data.value(forKey: "photoURL") as? String ?? "", img: img ))
                

            }
        }
        print("Total de items do banco \(lista.count)")
        return lista
        
        
    }
    
    func deleteAllRecords(){
        let deleteEntity = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteEntity)
        do {
            try context.execute(deleteRequest)
            try context.save()
            print ("Deletado com sucesso")
        } catch {
            print ("Delete falhou")
        }
    }
    
    
}
