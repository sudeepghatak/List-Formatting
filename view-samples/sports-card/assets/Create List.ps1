# Connect to SharePoint
#Connect-PnPOnline -Url "Your site" -ClientId "Client Id in App registration" -Tenant "Tenant name" -DeviceLogin

# Create the List
$listName = "SportsCards"
New-PnPList -Title $listName -Template GenericList -OnQuickLaunch

# Set list description
Set-PnPList -Identity $listName -Description "Trading-card style player roster rendered with the sports-card view formatter."

# Add Columns
Add-PnPField -List $listName -DisplayName "Sport" -InternalName "Sport" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Jersey Number" -InternalName "JerseyNumber" -Type Number -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Country" -InternalName "Country" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Rating" -InternalName "Rating" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Description" -InternalName "Description" -Type Note -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Stat 1 Label" -InternalName "Stat1Label" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Stat 1 Value" -InternalName "Stat1Value" -Type Number -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Stat 2 Label" -InternalName "Stat2Label" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Stat 2 Value" -InternalName "Stat2Value" -Type Number -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Stat 3 Label" -InternalName "Stat3Label" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Stat 3 Value" -InternalName "Stat3Value" -Type Number -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Accent Color" -InternalName "AccentColor" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Background Color" -InternalName "BackgroundColor" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Player Icon" -InternalName "PlayerIcon" -Type Text -AddToDefaultView
Add-PnPField -List $listName -DisplayName "Sport Icon" -InternalName "SportIcon" -Type Text -AddToDefaultView

Write-Host "List '$listName' created successfully with all columns!" -ForegroundColor Green

# Seed the list with sample cards
# Re-declared so this block can be run on its own (e.g. selection-run in VS Code).
$listName = "SportsCards"

$sampleCards = @(
  @{
    Title           = "Lionel Messi"
    Sport           = "FOOTBALL"
    JerseyNumber    = 10
    Country         = "ARG"
    Rating          = "★★★★★"
    Description     = "Argentine forward, captain of the national team. World Cup winner 2022. One of the greatest players in football history."
    Stat1Label      = "PAC"
    Stat1Value      = 85
    Stat2Label      = "SHO"
    Stat2Value      = 92
    Stat3Label      = "DRI"
    Stat3Value      = 95
    AccentColor     = "#ff2db5"
    BackgroundColor = "#0a1f3a"
    PlayerIcon      = "Running"
    SportIcon       = "Soccer"
  },
  @{
    Title           = "Shohei Ohtani"
    Sport           = "BASEBALL"
    JerseyNumber    = 17
    Country         = "JPN"
    Rating          = "★★★★★"
    Description     = "Japanese two-way player for the LA Dodgers. AL MVP 2021, 2023. Unique pitcher-hitter combination unseen since Babe Ruth."
    Stat1Label      = "AVG"
    Stat1Value      = 78
    Stat2Label      = "HR"
    Stat2Value      = 88
    Stat3Label      = "ERA"
    Stat3Value      = 82
    AccentColor     = "#ff7a00"
    BackgroundColor = "#0a1f3a"
    PlayerIcon      = "Running"
    SportIcon       = "Baseball"
  },
  @{
    Title           = "LeBron James"
    Sport           = "BASKETBALL"
    JerseyNumber    = 23
    Country         = "USA"
    Rating          = "★★★★★"
    Description     = "American small forward for the LA Lakers. Four-time NBA champion, four-time MVP. NBA all-time leading scorer."
    Stat1Label      = "PTS"
    Stat1Value      = 92
    Stat2Label      = "AST"
    Stat2Value      = 88
    Stat3Label      = "REB"
    Stat3Value      = 80
    AccentColor     = "#ff7a00"
    BackgroundColor = "#0a1f3a"
    PlayerIcon      = "Running"
    SportIcon       = "Basketball"
  }
)

foreach ($c in $sampleCards) {
  Add-PnPListItem -List $listName -Values $c | Out-Null
  Write-Host "  Added: $($c.Title) - $($c.Sport) #$($c.JerseyNumber)" -ForegroundColor Cyan
}

Write-Host "Seeded $($sampleCards.Count) sample cards into '$listName'." -ForegroundColor Green
