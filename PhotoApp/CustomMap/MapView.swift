//
//  CustomMapView.swift
//  PhotoApp
//
//  Created by Anshika Gupta on 15/9/2023.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {

    typealias UIViewType = MKMapView
    @State private var myMapView: MKMapView?
    @Binding var locationArray: [Location]
    var onClickAction: ((_ location: Location) -> Void)
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var control: MapView
        let sfCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        init(_ control: MapView) {
            self.control = control
        }

        func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
            if let annotationView = views.first {
                if let annotation = annotationView.annotation {
                    if annotation is MKUserLocation {
                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
                        mapView.setRegion(region, animated: true)
                        zoomToFitMapAnnotations(map: mapView)
                    }
                }
            }
        }//did add
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? MKPointAnnotation {
                // Handle the tap on the MKPointAnnotation here
                // You can access the annotation's properties like title, subtitle, and coordinate
                let title = annotation.title ?? ""
                let subtitle = annotation.subtitle ?? ""
                let coordinate = annotation.coordinate
                let array = self.control.locationArray.filter {
                    $0.location.latitude == coordinate.latitude
                }
                
                if let data = array.first {
                    self.control.onClickAction(data)
                }
//                if let array  = self.control.$locationArray.filter{State(initialValue: $0.location.latitude.wrappedValue)  == coordinate.latitude} {
//                    self.control.onClickAction(coordinate)
//                }
                print("Tapped on annotation - Title: \(title), Subtitle: \(subtitle), Coordinate: \(coordinate)")
            }
        }

        func zoomToFitMapAnnotations(map:MKMapView) {
            if(map.annotations.count == 0) {  return }
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)

            map.annotations.forEach {

                topLeftCoord.longitude = fmin(topLeftCoord.longitude, $0.coordinate.longitude);
                topLeftCoord.latitude = fmax(topLeftCoord.latitude, $0.coordinate.latitude);

                bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, $0.coordinate.longitude);
                bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, $0.coordinate.latitude);
            }

            let resd = CLLocationCoordinate2D(latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5, longitude: topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5)

            let span = MKCoordinateSpan(latitudeDelta: fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.3, longitudeDelta: fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.3)

            var region = MKCoordinateRegion(center: resd, span: span);

            region = map.regionThatFits(region)

            map.setRegion(region, animated: true)


        }
        @objc func addAnnotationOnTapGesture(sender: UITapGestureRecognizer) {
            
            if sender.state == .ended {
                print("in addAnnotationOnTapGesture")
                let point = sender.location(in: control.myMapView)
                print("point is \(point)")
                let coordinate = control.myMapView?.convert(point, toCoordinateFrom: control.myMapView)
                self.control.locationArray.append(Location(location: coordinate!))
                print("coordinate?.latitude is \(String(describing: coordinate?.latitude))")
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate ?? sfCoord
                annotation.title = "Start"
                control.myMapView?.addAnnotation(annotation)
            }
        }
    }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.showsUserLocation = true
        map.delegate = context.coordinator
    
        DispatchQueue.main.async {
            self.myMapView = map
        }
    
        let gRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.addAnnotationOnTapGesture(sender:)))
        map.addGestureRecognizer(gRecognizer)

        return map
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {

        for location in self.locationArray {
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.location
            self.myMapView?.addAnnotation(annotation)
        }
    }
}
