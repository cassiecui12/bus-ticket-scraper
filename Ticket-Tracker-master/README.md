# Ticket-Tracker

## Instructions for how to develop, use, and test the code.

#### Generating the SQL Database

Using the script.sql file, build an SQL Server with the database name BusDB under the server name ".".

#### Using Web Driver

Ensure that you have a Chromium Web Driver Browser and that it is the same version as your normal Chrome Browser. If you do not have a Chrome browser, you will need to download one and add it to your System Environment Variables PATH.

#### Building and running the application.

Download the project, open the solution file in Visual Studio 2019, and build and run the application. Note that you will need to install the Selenium package

#### Using the application.

Search for a route between any two given itineraries. When pressing the "Go" button, your Web Driver will attempt to properly search for the route you have searched.

![Image](https://i.imgur.com/cQ0n72b.png)

When clicking Go, a Thread is created which handles accessing the Intercity website and inserting the details of the trip which is required in order to initialize the route you have selected. As you can see, the previous results of a different trip (Auckland - Central to Hamilton - Central) have moved across to this route, since all Auckland - Central to Tokoroa trips are the same as Auckland to Hamilton routes (this is the case with many North Island Itineraries).

Then, review your choice of dates using the checkboxes in the bottom left and then press search. Your Web Driver will scroll through the various dates and automatically stored them in the relevant SQL Tables as well as inform you via the coloured boxes whether or not a valid date has been found.

## Key

![Image description](https://i.imgur.com/tp5MAQX.png)

When searching through a list of dates, the status icon will be updated depending on the new status of the date. Below is a key for the colours at this stage.

Red: Not valid. There isn't a $1 deal, and unless this is because someone was searching that specific date within the last 15 minutes, there probably won't be one again.

Green: Valid. There was a $1 deal, but there might not be one in the future. Still, if you find one, it might be worth keeping in order to build an itinerary.

Blue: Searching. This date is currently being searched by Ticket Tracker. Hold tight and you'll soon have your result displayed.

Yellow: Unchecked. You haven't checked all the routes for this date. It could be valid, it could be unvalid, but you don't know yet. Being smart about the dates you search is important for efficiency. Most routes go through Auckland - Central to Hamilton - Central and reverse, so searching through that route makes searches for various other north island trips all the more faster.

Note that just because a ticket involving 2 routes is invalid, doesn't mean one of them couldn't be valid! Happy hunting and storing.

## Hints

Searching through Auckland - Hamilton and Hamilton - Auckland allows you to essentially determine other routes without searching such as Auckland - Wellington, Rotorua, and Taupo.
