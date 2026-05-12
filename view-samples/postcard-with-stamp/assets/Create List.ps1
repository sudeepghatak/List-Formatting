# Connect to SharePoint
#Connect-PnPOnline -Url "Your site" -ClientId "Client Id in App registration" -Tenant "Tenant name" -DeviceLogin

# Create the List
$listName = "Postcards"
New-PnPList -Title $listName -Template GenericList -OnQuickLaunch

# Set list description
Set-PnPList -Identity $listName -Description "Postcards with stamp and postmark rendered with the postcard-with-stamp view formatter."

# Add Columns
Add-PnPField -List $listName -DisplayName "Message" -InternalName "Message" -Type Note -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Signoff" -InternalName "Signoff" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Stamp Country" -InternalName "StampCountry" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Stamp Price" -InternalName "StampPrice" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Stamp Icon" -InternalName "StampIcon" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Stamp Color" -InternalName "StampColor" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Postmark City" -InternalName "PostmarkCity" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Postmark Date" -InternalName "PostmarkDate" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Postmark Country" -InternalName "PostmarkCountry" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Address Line 1" -InternalName "AddressLine1" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Address Line 2" -InternalName "AddressLine2" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Address Line 3" -InternalName "AddressLine3" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Address Line 4" -InternalName "AddressLine4" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Background Color" -InternalName "BackgroundColor" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Accent Color" -InternalName "AccentColor" -Type Text -AddToDefaultView

Write-Host "List '$listName' created successfully with all columns!" -ForegroundColor Green

# Seed the list with sample postcards
# Re-declared so this block can be run on its own (e.g. selection-run in VS Code).
$listName = "Postcards"

$samplePostcards = @(
  @{
    Title           = "Greetings from Queenstown!"
    Message         = "Spent the morning on a jet boat down the Shotover, then up the gondola for lunch overlooking the lake. The leaves are turning gold and the air smells like pine. Can't wait to show you the photos when we're back. Missing the office coffee - but not by much!"
    Signoff         = "- Sudeep"
    StampCountry    = "Aotearoa"
    StampPrice      = "$2.80"
    StampIcon       = "Globe2"
    StampColor      = "#c0392b"
    PostmarkCity    = "QUEENSTOWN"
    PostmarkDate    = "14 APR 2026"
    PostmarkCountry = "NEW ZEALAND"
    AddressLine1    = "Ashish Ghatak"
    AddressLine2    = "42 Te Atatu Road"
    AddressLine3    = "Auckland 0610"
    AddressLine4    = "New Zealand"
    BackgroundColor = "#f3e9d2"
    AccentColor     = "#0e3a73"
  },
  @{
    Title           = "Thank you, Priya!"
    Message         = "Your work on the Q1 migration was outstanding. You stayed late three nights running, kept the team upbeat, and shipped it a week ahead of schedule. The whole department noticed - and so did the client. Couldn't have done it without you."
    Signoff         = "- Leadership Team"
    StampCountry    = "Star Award"
    StampPrice      = "2026"
    StampIcon       = "FavoriteStarFill"
    StampColor      = "#1a7f37"
    PostmarkCity    = "KUDOS"
    PostmarkDate    = "11 MAY 2026"
    PostmarkCountry = "DELIVERED"
    AddressLine1    = "Priya Sharma"
    AddressLine2    = "Senior Engineer"
    AddressLine3    = "Cloud Migration Team"
    AddressLine4    = "Wellington Office"
    BackgroundColor = "#fdf6e3"
    AccentColor     = "#8a6712"
  },
  @{
    Title           = "Hello from Tokyo"
    Message         = "The conference wrapped up earlier than expected so I'm taking the afternoon to wander Shibuya. Will send a proper write-up of the Microsoft sessions on Monday - three really good ones on Copilot extensibility worth replicating internally."
    Signoff         = "SG"
    StampCountry    = "Nippon"
    StampPrice      = "Y120"
    StampIcon       = "TemporaryAccessPass"
    StampColor      = "#1a1a1a"
    PostmarkCity    = "TOKYO"
    PostmarkDate    = "03 JUN 2026"
    PostmarkCountry = "JAPAN"
    AddressLine1    = "Engineering Distribution"
    AddressLine2    = "All-Hands Channel"
    AddressLine3    = "Teams"
    AddressLine4    = ""
    BackgroundColor = "#f7f7f4"
    AccentColor     = "#c0392b"
  },
  @{
    Title           = "Hello from Paris!"
    Message         = "Walked along the Seine this morning and stumbled into a tiny boulangerie near Saint-Germain. Best croissant of my life. The Louvre tomorrow, then back home Friday. The kids will love the Eiffel Tower magnets I picked up."
    Signoff         = "Bisous, M."
    StampCountry    = "Republique"
    StampPrice      = "EUR 1.50"
    StampIcon       = "Airplane"
    StampColor      = "#1f4e8a"
    PostmarkCity    = "PARIS 75"
    PostmarkDate    = "22 MAY 2026"
    PostmarkCountry = "FRANCE"
    AddressLine1    = "M. Pierre Lambert"
    AddressLine2    = "15 Rue de la Paix"
    AddressLine3    = "75002 Paris"
    AddressLine4    = "France"
    BackgroundColor = "#f3e9d2"
    AccentColor     = "#1f4e8a"
  }
)

foreach ($p in $samplePostcards) {
  Add-PnPListItem -List $listName -Values $p | Out-Null
  Write-Host "  Added: $($p.Title) - postmark $($p.PostmarkCity)" -ForegroundColor Cyan
}

Write-Host "Seeded $($samplePostcards.Count) sample postcards into '$listName'." -ForegroundColor Green
