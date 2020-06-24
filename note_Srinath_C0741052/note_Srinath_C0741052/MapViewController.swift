
import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var notes: [Note]?
    @IBOutlet weak var mapView: MKMapView!
    fileprivate let locationManager: CLLocationManager = {
       let manager = CLLocationManager()
       manager.requestWhenInUseAuthorization()
       return manager
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Map"
        mapView.showsUserLocation = true
        currentLocationSetUp()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Helper Method
    func currentLocationSetUp() {
       locationManager.delegate = self
       locationManager.desiredAccuracy = kCLLocationAccuracyBest
       if #available(iOS 11.0, *) {
          locationManager.showsBackgroundLocationIndicator = true
       }
       locationManager.startUpdatingLocation()
    }
    
    func showNotesOnMap() {
        
    }

}

extension MapViewController: CLLocationManagerDelegate {
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let currentLocation = location.coordinate
        let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 1500, longitudinalMeters: 1500)
        mapView.setRegion(coordinateRegion, animated: true)
        locationManager.stopUpdatingLocation()
     }
     
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
     }
}
