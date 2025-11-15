# Script to replace machines with MachineFrameDestroyed and delete specified machines in triage shuttle maps
# Aurora Song - Machine Protection for Triage Events

$ErrorActionPreference = "Stop"

Write-Host "Starting triage shuttle machine replacement script..." -ForegroundColor Cyan

# Define the files to process and their machine configurations
$fileConfigs = @{
    "caduceus_merc.yml" = @{
        Replace = @("BiomassReclaimer", "ChemDispenser", "ChemMaster", "CryoPod", "GasThermoMachineFreezer", "MedicalTechFab")
        Delete = @("ChemistryHotplate", "MachineCentrifuge", "MachineElectrolysisUnit", "KitchenReagentGrinder",
                   "VendingMachineChemicals", "VendingMachineCoffee", "VendingMachineEngivend", "VendingMachineMedical",
                   "VendingMachineMediDrobe", "VendingMachineSeeds", "VendingMachineTankDispenserEVA")
    }
    "caduceus_xeno.yml" = @{
        Replace = @("BiomassReclaimer", "ChemDispenser", "ChemMaster", "CryoPod", "GasThermoMachineFreezer", "MedicalTechFab")
        Delete = @("ChemistryHotplate", "MachineCentrifuge", "MachineElectrolysisUnit", "KitchenReagentGrinder",
                   "VendingMachineChemicals", "VendingMachineCoffee", "VendingMachineEngivend", "VendingMachineMedical",
                   "VendingMachineMediDrobe", "VendingMachineSeeds", "VendingMachineTankDispenserEVA")
    }
    "searchlight.yml" = @{
        Replace = @("ChemDispenser", "ChemMaster", "MedicalTechFab")
        Delete = @("ChemistryHotplate", "MachineElectrolysisUnit", "KitchenReagentGrinder")
    }
    "searchlight_merc.yml" = @{
        Replace = @("ChemDispenser", "ChemMaster", "MedicalTechFab")
        Delete = @("ChemistryHotplate", "MachineElectrolysisUnit", "KitchenReagentGrinder")
    }
    "searchlight_xeno.yml" = @{
        Replace = @("ChemDispenser", "ChemMaster", "MedicalTechFab")
        Delete = @("ChemistryHotplate", "MachineElectrolysisUnit", "KitchenReagentGrinder")
    }
    "tyne.yml" = @{
        Replace = @("MedicalTechFab")
        Delete = @("VendingMachineWallMedical")
    }
    "tyne_merc.yml" = @{
        Replace = @("MedicalTechFab")
        Delete = @("VendingMachineWallMedical")
    }
    "tyne_xeno.yml" = @{
        Replace = @("MedicalTechFab")
        Delete = @("VendingMachineWallMedical")
    }
}

$basePath = "Resources\Maps\_AS\Shuttles\Triage"

function Process-MachineEntity {
    param(
        [string]$FilePath,
        [string]$ProtoName,
        [string]$Action  # "Replace" or "Delete"
    )

    $content = Get-Content $FilePath -Raw

    # Find all instances of this proto
    $pattern = "(?ms)(- proto: $ProtoName\r?\n  entities:\r?\n(?:  - uid: \d+\r?\n(?:    components:\r?\n(?:    - type: .*?\r?\n(?:      .*?\r?\n)*)*)*)*?)(?=- proto: |\z)"

    $matches = [regex]::Matches($content, $pattern)

    if ($matches.Count -eq 0) {
        Write-Host "  No instances of $ProtoName found (might already be processed)" -ForegroundColor Yellow
        return $content
    }

    foreach ($match in $matches) {
        $entityBlock = $match.Value

        if ($Action -eq "Replace") {
            # Extract just the entity definitions (uid and transform)
            $uidPattern = "(?ms)  - uid: (\d+)\r?\n    components:\r?\n((?:    - type: .*?\r?\n(?:      .*?\r?\n)*)*?)(?=  - uid: |\z|^- proto:)"
            $uidMatches = [regex]::Matches($entityBlock, $uidPattern)

            $newBlock = "- proto: MachineFrameDestroyed`n  entities:`n"

            foreach ($uidMatch in $uidMatches) {
                $uid = $uidMatch.Groups[1].Value
                $components = $uidMatch.Groups[2].Value

                # Extract only Transform component
                $transformPattern = "(?ms)(    - type: Transform\r?\n(?:      .*?\r?\n)*?)(?=    - type: |  - uid: |\z)"
                $transformMatch = [regex]::Match($components, $transformPattern)

                if ($transformMatch.Success) {
                    $transform = $transformMatch.Value
                    $newBlock += "  - uid: $uid`n    components:`n$transform"
                }
            }

            # Replace the entire entity block
            $content = $content.Replace($entityBlock, $newBlock)
            Write-Host "  Replaced $ProtoName with MachineFrameDestroyed ($($uidMatches.Count) instances)" -ForegroundColor Green

        } elseif ($Action -eq "Delete") {
            # Simply remove the entire block
            $content = $content.Replace($entityBlock, "")
            Write-Host "  Deleted $ProtoName" -ForegroundColor Red
        }
    }

    return $content
}

# Process each file
foreach ($fileName in $fileConfigs.Keys) {
    $filePath = Join-Path $basePath $fileName

    if (-not (Test-Path $filePath)) {
        Write-Host "Skipping $fileName - file not found" -ForegroundColor Yellow
        continue
    }

    Write-Host "`nProcessing $fileName..." -ForegroundColor Cyan

    $config = $fileConfigs[$fileName]
    $content = Get-Content $filePath -Raw

    # Process replacements
    foreach ($proto in $config.Replace) {
        $content = Process-MachineEntity -FilePath $filePath -ProtoName $proto -Action "Replace"
    }

    # Process deletions
    foreach ($proto in $config.Delete) {
        $content = Process-MachineEntity -FilePath $filePath -ProtoName $proto -Action "Delete"
    }

    # Save the modified content
    Set-Content -Path $filePath -Value $content -NoNewline
    Write-Host "  Saved $fileName" -ForegroundColor Green
}

Write-Host "`n=== Script completed ===" -ForegroundColor Cyan
Write-Host "Processed $($fileConfigs.Count) files" -ForegroundColor Green
Write-Host "All machines have been replaced or deleted as specified." -ForegroundColor Green
