//
//  DetailView.swift
//  PhotoApp
//
//  Created by Amit Kumar on 17/9/2023.
//

import SwiftUI

struct DetailView: View {
    @State private var nameValue = ""
    @State private var notesValue = ""
    @Binding var location: Location
    @EnvironmentObject var locationViewModel: LocationViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack(spacing: 10) {
            LabeledContent("Latitute", value: String(describing: location.location.latitude))
            LabeledContent("Longitude", value: String(describing: location.location.longitude))
            LabeledContent("Distance", value: String(describing: location.distance))
            LabeledContent {
                TextField(location.name, text: $nameValue)
                    .padding()
                    .border(Color.gray, width: 1)
            } label: {
                Text("Name")
            }
            
            LabeledContent {
                TextEditor(text: $notesValue)
                    .padding()
                    .border(Color.gray, width: 1)
            } label: {
                Text("Notes")
            }
            Button(action: {
                // Perform some action when the "Done" button is tapped
                if let index = self.locationViewModel.locations.firstIndex(where: { $0.id == location.id }) {
                    self.locationViewModel.locations[index].name = nameValue
                    self.locationViewModel.locations[index].note = notesValue
                }
                locationViewModel.writeData()
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .navigationTitle(nameValue)
        .navigationBarTitleDisplayMode(.inline)
        .padding(20)
        .border(.black, width: 2)
        .onAppear() {
            notesValue = location.note
            nameValue = location.name
        }
    }
}
