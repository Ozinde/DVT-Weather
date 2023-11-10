#  DVT Weather App

#  Implementation

##  App Description

DVT Weather is an app that provides users with weather information about various locations around the world as well as provides a 5 day weather forecast for a particular place.
Locations can be viewed through a map as well as a table that displays city names. The last received weather update can be viewed for the the users current location when their device is offline.
Clicking on a pin on the map will display weather information for that location.

##  Core Data

The Core Data layer underpins a lot of the functionality in the app. 
It is used in the HomeController to store the most recent weather forecast for the user's current location.
It is used in the FavoritesController to save or remove a location from favorites.
In the FavoritesController, data for the table view is populated with saved data results found in Core Data.
In the MapController, saved locations will populate the map with pins. Adding a new pin will automatically be saved to favorites and as such, can be viewed in the FavoritesController as well.

#  Conventions

In the spirit of readabilty, the naming conventions of the app are such that variables, constants and outlets have been named in full with minimal abreviations. 
Controllers have been named after the function or purpose they fundamentally serve and model files may contain more than one struct given their relationship or level of interconnectedness.
Within a controller file, variables and outlets will be found at the top, followed by override functions, personally constucted functions and then lastly class extensions used to group together delegate methods.
Outlets have been marked as weak to limit the retention cycle and minimize memory leaks.
The fileprivate access modifier has been used for all functions unless they form part of a protocol, inheriting from a superclass or class functionality is required.
Variables and constants have been marked with the private modifier. An exception to this is where access is required in another file.

#  Considerations

Some of the weather types were not provided for as per the given assets for the app. An example of this is with the snow and fog weather conditions. As such, I have taken the liberty to create assets that correspond to these weather types. 
It is worth noting, however, that the assets I have created are not exhaustive in terms of all the weather conditions that can be found and received from the Open Weather API.

#  Architecture

The app makes use of the model, view and controller (MVC) structure and the apps files have been grouped in accordance to this method of design.
The model files include methods that involve the business logic of the app such as the logic behind making API requests. The view files include customs views that are used in the storyboard as well as "Nibs". The controller files react to user input and update the views and model as required.
An additional folder labelled Misc has been created to place files that do not strictly adhere to the MVC pattern. An example of this is the UIViewController extension file that is used to add functions that can be used across view controllers.
The singleton pattern is used in various instance particularly with the Core Data operations as well as with Google Places API functions. 

#  Third Party Libraries
At the moment, only the Google Places library has been imported through cocoapods to provide the Places API functionality. 
The main functionalty used from this API is a location lookup or search.

#  How to build

With the project open in Xcode, simply pressing the build button will build the project.
Alternatively, a user can navigate to the **Product** menu item and select **Build**.
Selecting **Run** will launch the app on a device or simulator.

#  Functionality

##  SplashController

The SplashController encapsulates the functionality of a splash screen, displaying the app name and logo.

##  HomeController

The HomeController presents weather forecast information for the user's current location upon launch. 
A segue to the HomeController from the MapController or Favorites controller will display weather information for a place on the map or a favorite location respectively. 
Should the device be in a state of no network connection, an offline mode with the last saved forecast will be displayed instead of a full forecast. 
When pressed, the button in the top left corner with a camera icon will segue to the PhotosController where photos for a location can be viewed and subsequently, edited. 

##  MapController

The MapController embodies weather forecast functionality based on a particular point on the map. 
Tapping and holding on a point on the map will drop a pin. 
Once the pin is tapped, the Home tab will be presented with forecast information for the chosen location. 
A pin on the map also corresponds with a location that is viewable under the Favorites tab. 

##  FavoritesController

The FavoritesController is where forecasts for saved locations can be viewed for ease of use.
A new location can be added to favorites by tapping on the search bar, entering the name of a place and tapping on it.
Once saved, the location can on also be viewed on the map as a pin.
Tapping on a location in the favorites tab will present the Home tab and display a forecast for the particular location.

##  ResultsViewController

The ResultsViewController provides the search bar found in the favorites tab with its' functionality. 
It allows the tableView of the search bar to be populated with results from the Google Places API.

##  PhotosController

The PhotosController presents a collection of photos for a particular location.
It can be accessed by tapping on the camera icon in the Home tab.
The photos are retrieved by making a network request to the Flickr API.
Tapping on an image will allow a user to make edits to the the selected photo.

##  PhotoFilterViewController

The PhotoFilterViewController allows a user to select from a variety of filters that can be added to a photo selected from the PhotosController.
Once a filter has been chosen, the edited image can then be saved to the device's photo library by tapping on the checkmark icon.

#  Requirements

Xcode 14
Swift 5
A device running iOS 15.5 or higher

#  Deployment Target

iOS 15.5

