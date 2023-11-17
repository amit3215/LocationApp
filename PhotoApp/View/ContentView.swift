//
//  ContentView.swift
//  PhotoApp
//
//  Created by Amit Kumar on 17/9/2023.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @EnvironmentObject var locationViewModel: LocationViewModel
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -33.85075, longitude: 151.212519),
                                                   span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    @State private var isMapViewVisible = true
    @State private var tappedLocation: Location = Location(location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
    @State private var isDetailViewPresented = false
    
    var body: some View {
        NavigationView {
            if isMapViewVisible {
                Map(coordinateRegion: $region, annotationItems: $locationViewModel.locations) { location in
                    MapAnnotation(coordinate: location.location.wrappedValue) {
                        PlaceAnnotationView(title: location.name.wrappedValue)
                            .onLongPressGesture {
                                tappedLocation = location.wrappedValue
                                self.isDetailViewPresented = true
                            }
                    }
                }
                .frame(width: 400, height: UIScreen.main.bounds.size.height - 100)
                .defersSystemGestures(on: .all)
                .navigationBarItems(trailing: Button(action: { isMapViewVisible.toggle() }) {
                    Text(isMapViewVisible ? "List" : "Map")
                })
                .onTapGesture { point in
                    tappedLocation = self.locationViewModel.coordinateFrom(point: point, region: region)
                }
                .onAppear {
                    if let region = locationViewModel.adjustRegionToAnnotations() {
                        self.region = region
                    }
                }
                .sheet(isPresented: $isDetailViewPresented) {
                    DetailView(location: $tappedLocation)
                }
            } else {
                List($locationViewModel.locations) { $location in
                    NavigationLink(destination: DetailView(location: $location)) {
                        LabeledContent(location.name, value: String(format: "Distance: %.2f", location.distance))
                    }
                }
                .listStyle(.inset)
                .navigationBarItems(leading: Button(action: { locationViewModel.sort() }) {
                    Text("Sort")
                },
                                    trailing: Button(action: { isMapViewVisible.toggle() }) {
                    Text(isMapViewVisible ? "List" : "Map")
                })
            }
            
        }
        .task {
            await self.locationViewModel.getLocationData(completion: { success in
                if let region = self.locationViewModel.adjustRegionToAnnotations() {
                    self.region = region
                }
            })
        }
    }
}
