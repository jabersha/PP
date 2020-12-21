import XCTest
@testable import Interview

class ListContactServiceTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGetListExpectedURLHostAndPath() {
      let apiRespository = ListContactService()
        apiRespository.fetchContacts { contacts, error in }
    }
    
    func testSaveAndGetCoreData(){
        let apiRespository = ListContactService()
        apiRespository.deleteAllRecords()
        
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode([Contact].self, from: mockData!)
            apiRespository.saveOffline(contatos: decoded)
        }catch {
           return
        }
        
        let contatos = apiRespository.getContacts()
        print(contatos[0].name)

    }
    }




var mockData: Data? {
    """
    [{
      "id": 2,
      "name": "Beyonce",
      "photoURL": "https://api.adorable.io/avatars/285/a2.png"
    }]
    """.data(using: .utf8)
}
