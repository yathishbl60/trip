import CoreLocation
import Foundation
import MapKit
import Testing
import TripDomain
import TripPlaces

/// Exercises only the exported adapter contract; no search or network request runs.
@MainActor struct PlaceConversionTests {
    @Test func nativeContactAndCategoryValuesSurviveConversion() {
        let item = MKMapItem(location: CLLocation(latitude: 13.75, longitude: 100.5), address: nil)
        item.name = "Market Cafe"
        item.pointOfInterestCategory = .cafe
        item.phoneNumber = "+66 1234 5678"
        item.url = URL(string: "https://example.com/cafe")
        let place = PlaceFactory.make(item)
        #expect(place.name == item.name && place.category == .cafe)
        #expect(place.coordinate == Coordinate(latitude: 13.75, longitude: 100.5))
        #expect(place.phoneNumber == item.phoneNumber && place.website == item.url)
        #expect(place.isLive && place.rating == nil && place.reviews == nil)
    }

    @Test func identifierFallbackIsStableAndDistinguishesNamedPlaces() {
        let item = MKMapItem(location: CLLocation(latitude: 13.75, longitude: 100.5), address: nil)
        item.name = "Market Cafe"
        let first = PlaceFactory.make(item)
        let same = PlaceFactory.make(item)
        item.name = "Market Hotel"
        let other = PlaceFactory.make(item)
        #expect(first.id == same.id)
        #expect(first.id != other.id)
    }

    @Test func uncategorizedItemsHaveUsableFallbackValues() {
        let item = MKMapItem(location: CLLocation(latitude: 13.75, longitude: 100.5), address: nil)
        let place = PlaceFactory.make(item)
        #expect(place.category == .place && !place.name.isEmpty)
        #expect(place.address == nil && place.website == nil && place.phoneNumber == nil)
        #expect(!place.id.isEmpty)
    }

    @Test func categorySearchFiltersAndConversionUseTheSameClassification() {
        for category in PlaceCategory.allCases {
            for nativeCategory in category.mapCategories {
                let item = MKMapItem(location: CLLocation(latitude: 13.75, longitude: 100.5), address: nil)
                item.pointOfInterestCategory = nativeCategory
                #expect(PlaceFactory.make(item).category == category)
            }
        }
    }
}
