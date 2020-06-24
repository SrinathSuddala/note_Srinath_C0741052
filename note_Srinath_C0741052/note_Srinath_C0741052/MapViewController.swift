
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
        addNotesAnnotations()
        // Do any additional setup after loading the view.
    }
    
    func addNotesAnnotations() {
        guard let notes = notes else {return}
        for note in notes {
            addAnnotationOnLocation(pointedCoordinate: CLLocationCoordinate2D(latitude: note.lat, longitude: note.long), title: note.title)
        }
    }
    
    func addAnnotationOnLocation(pointedCoordinate: CLLocationCoordinate2D, title: String?) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = pointedCoordinate
        mapView.addAnnotation(annotation)
    }
    
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
