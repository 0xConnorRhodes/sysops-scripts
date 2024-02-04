# Get all items in the current directory excluding directories
$items = Get-ChildItem -File

# Sort items by creation time (oldest first)
$sortedItems = $items | Sort-Object CreationTime

# Calculate the number of digits needed for the numbering
$totalItemCount = $sortedItems.Count
$digitCount = [Math]::Floor([Math]::Log10($totalItemCount) + 1)

# Rename files with numbering
$counter = 1
foreach ($item in $sortedItems) {
    # Create the new name with leading zeros based on the total number of digits required
    $number = "{0:d2}" -f $counter

    $newName = "$number" + "_" + $item.Name 

    # Rename the item with the new name
    Rename-Item -Path $item.FullName -NewName $newName
    
    # Increment the counter
    $counter++
}
