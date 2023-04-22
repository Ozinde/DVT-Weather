#  DVT Weather App

#  Implementation

##  App Description

DVT Weather is an app that provides users with weather information about various locations around the world as well as provides a 5 day weather forecast for a particular city.
Locations can be viewed through a map as well as a table that displays city names. The last received weather update can be viewed for the the users current location when their device is offline.
Clicking on a pin on the map will display weather information for that location.

##  Core Data

The Core Data layer underpins a lot of the functionality in the app. 
It is used in the HomeController to store the most recent weather forecast.
It is used in the FavoritesController to save or remove a location from favorites.
In the FavoritesController, data for the table view is populated with saved data in Core Data.
In the MapController, saved locations will populate the map with pins. Adding a new pin will automatically be saved to favorites and as such, can be viewed in the FavoritesController

#  Conventions

In the spirit of readabilty, the naming conventions of the app are that in which variables, constants and outlets have been named in full with minimal abreviations. 
Controllers have been named after the function or purpose they fundamentally serve and model files may contain more than one struct given their interconnectedness or if they are closely related.
Within a controller file, variables and outlets will be found at the top, followed by override functions, personally constucted functions and then lastly class extensions used to group together delegate methods.
Outlets have been marked as weak to limit the retention cycle and minimize memory leaks. This also applies to functions with a trailing closure, particularly the getWeather() method in the HomeController
The fileprivate access modifier has been used for all functions unless they form part of a protocol, inheriting from a superclass or class functionality is required.
Variables and constants have been marked with the private modifier. An exception to this is where access is required in another file.

#  Architecture

The app makes use of the model, view and controller (MVC) structure and the apps files have been grouped in accordance to this method of design.
The model files include methods that involve the business logic of the app such as making API requests. The view files include customs views that are used in the storyboard as well as "Nibs". The controller files react to user input and update the views and model as required.
An additional folder labelled Misc has been created to place files that do not strictly adhere to the MVC pattern. An example of this is the UIViewController extension file that is used to add functions that can be used across view controllers.
The singleton pattern is used in various instance particularly with the Core Data operations as well as with Google Places functions. 

#  Third Party Libraries
At the moment, only the Google Places library has been imported through cocoapods to provide the Places API functionality. The main functionalty used from this API is a location lookup or search.

#  How to build

With the project open in Xcode, simply pressing the build button will build the project.
Alternatively, a user can navigate to the **Product** menu item and select **Build**.
Selecting **Run** will launch the app on a device or simulator.

#  Requirements

Xcode 14
Swift 5
A device running iOS 16.0 or higher

#  Deployment Target

iOS 16.0

