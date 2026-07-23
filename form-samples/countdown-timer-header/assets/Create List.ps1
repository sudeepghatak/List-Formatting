# Connect to SharePoint
Connect-PnPOnline -Url "https://yourtenant.sharepoint.com/sites/yoursite" -clientId "CLIENT_ID" -tenant "TENANT_ID" -DeviceLogin
# Create the list
$listName = "TaskCountdown"
New-PnPList -Title $listName -Template GenericList -OnQuickLaunch

# Set list description
Set-PnPList -Identity $listName -Description "Task list with countdown-timer-header form formatter showing due-date urgency."

# Add columns
Add-PnPField -List $listName -DisplayName "Due Date" -InternalName "DueDate" -Type DateTime -AddToDefaultView

Write-Host "List '$listName' created with Title and DueDate columns." -ForegroundColor Green

# Seed sample items — one per urgency tier
# Re-declared so this block can be run independently (e.g. selection-run in VS Code).
$listName = "TaskCountdown"
$today = [DateTime]::Today

$sampleItems = @(
  @{
    Title   = "Submit Annual Report"
    DueDate = $today.AddDays(14)
    _Tier   = "Calm (green) — 14 days out"
  },
  @{
    Title   = "Review Budget Proposal"
    DueDate = $today.AddDays(5)
    _Tier   = "Warning (amber) — 5 days out"
  },
  @{
    Title   = "Sign Off on Vendor Contract"
    DueDate = $today.AddDays(2)
    _Tier   = "Urgent (red) — 2 days out"
  },
  @{
    Title   = "Submit Expense Claims"
    DueDate = $today
    _Tier   = "Due Today (crimson 0)"
  },
  @{
    Title   = "Complete Compliance Training"
    DueDate = $today.AddDays(-3)
    _Tier   = "Overdue (crimson) — 3 days past"
  }
)

foreach ($item in $sampleItems) {
  $values = @{
    Title   = $item.Title
    DueDate = $item.DueDate
  }
  Add-PnPListItem -List $listName -Values $values | Out-Null
  Write-Host "  Added [$($item._Tier)]: $($item.Title)" -ForegroundColor Cyan
}

Write-Host "Seeded $($sampleItems.Count) items into '$listName'." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Open '$listName' in SharePoint" -ForegroundColor Yellow
Write-Host "  2. Go to List Settings > Configure Layout" -ForegroundColor Yellow
Write-Host "  3. Paste countdown-timer-header.json into the Header Format field" -ForegroundColor Yellow
Write-Host "  4. Open any item form to see the urgency banner" -ForegroundColor Yellow
