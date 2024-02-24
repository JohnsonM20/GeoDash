//
//  MapView.swift
//  GeoDash
//
//  Created by Matthew Johnson on 2/24/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var showingCredits = true
    
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 100000, longitudeDelta: 100000)
        )
    )
    
    @State var locations: [Location] = []
    
    var correctLocation = Location(name: "Buckingham Palace", coordinate: CLLocationCoordinate2D(latitude: 51.501, longitude: -0.141))

    
    var body: some View {
        NavigationStack {
            MapReader { proxy in
                Map(position: $position) {
                    ForEach(locations) { location in
                        Marker(location.name, coordinate: location.coordinate)
                    }
                }
                    .onTapGesture { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            print(coordinate)
                            locations = []
                            locations.append(Location(name: "My Guess", coordinate: coordinate))
                        }
                    }
            }
                .mapStyle(.hybrid)
                
                .navigationTitle("GeoDash")
                .navigationBarTitleDisplayMode(.inline)
//                .toolbar {
//                    ToolbarItem(placement: .bottomBar) {
//                        Text("What continent is home to the Rocky Mountains?")
////                        Button() {
////                            print("Pressed")
////                        }
//                    }
//                }
        }
        
            .sheet(isPresented: $showingCredits) {
                Text("What continent is home to the Rocky Mountains?")
                    .bold()
                    .font(.title2)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .presentationDetents([.fraction(0.2), .medium])
                    .presentationDragIndicator(.visible)
                    .presentationBackgroundInteraction(.enabled)
                    .interactiveDismissDisabled()
                
                Button {
                    if let coordinate = locations.first?.coordinate {
                        getAddressFromCoordinates(coordinate) { addr in
                            //self.address = addr
                            print(addr)
                        }
                    }
                } label: {
                    Text("Guess")
                        .bold()
                }

            }
    }
    
    func getAddressFromCoordinates(_ coordinates: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)

        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Error in reverseGeocode: \(error)")
                completion("Error retrieving address")
                return
            }

            if let placemark = placemarks?.first {
                print(placemark)
                let address = [placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.postalCode].compactMap { $0 }.joined(separator: ", ")
                completion(address)
            } else {
                completion("Address not found")
            }
        }
    }

}

#Preview {
    MapView()
}

struct Location: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}
