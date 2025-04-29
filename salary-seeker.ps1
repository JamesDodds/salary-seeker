### seek salary seeker
### rewritten from https://github.com/b3n-j4m1n/salary-seeker
### updated 29/April/2025 - updated to use new API endpoint

Param (
    [Parameter(Mandatory=$true)]
    [int]$job_id    
)

### initial variables
$counter = 0
$response = 1
$upper_lim = 400000
$lower_lim = 30000
$salary_var = ($lower_lim + (($upper_lim - $lower_lim)/2))
$base_url = "https://www.seek.com.au/api/jobsearch/v5/search"
$job_data=(ConvertFrom-Json(Invoke-WebRequest -UseBasicParsing -Uri "$($base_url)?jobid=$($job_id)")).data

### Go!

Clear-Host
Write-Host "Job Title:" $job_data.title "| Advertiser:" $job_data.advertiser.description
Write-Host "Type: $($job_data.workTypes) | Location: $($job_data.locations.label)"
Write-Host $job_data.teaser
Write-Host "Job ID: $($job_data.id)"
Write-Host "Advertiser ID: $($job_data.advertiser.id)"
Write-Host "Advertiser Name: $($job_data.advertiser.description)"

### find maximum
while ($counter -lt 16) {
    $response = (ConvertFrom-Json(Invoke-WebRequest -UseBasicParsing -Uri "$($base_url)?keywords=$($job_data.teaser)&advertiserid=$($job_data.advertiser.id)&sourcesystem=houston&salaryrange=$([math]::round($salary_var,0))-$([math]::round($upper_lim,0))")).data
    if (($response | Measure-Object).Count -eq 1) {
        $lower_lim = $salary_var
        $salary_var = ($salary_var + (($upper_lim - $salary_var) / 2))
    } elseif (($response | Measure-Object).Count -eq 0) {
        $upper_lim = $salary_var
        $salary_var = ($salary_var - (($salary_var - $lower_lim) / 2))
    }
    $counter++
}

$salary_max = $salary_var
Write-Verbose "BETWEEN CALCS - Var: $($salary_var), lower: $($lower_lim), upper: $($upper_lim)"

### variable reset
$counter = 0
$lower_lim = 25000
$upper_lim = $salary_max
$salary_var = ($lower_lim + (($upper_lim - $lower_lim) / 2))

### find minimum
while ($counter -lt 16) {
    $response = (ConvertFrom-Json(Invoke-WebRequest -UseBasicParsing -Uri "$($base_url)?advertiserid=$($job_data.advertiser.id)&sourcesystem=houston&salaryrange=$([math]::round($lower_lim,0))-$([math]::round($salary_var,0))")).data | where {$_.id -eq $job_id}
    if (($response | Measure-Object).Count -eq 1) {
        $upper_lim = $salary_var
        $salary_var = ($salary_var - (($salary_var - $lower_lim) / 2))
    } elseif (($response | Measure-Object).Count -eq 0) {
        $lower_lim = $salary_var
        $salary_var = ($salary_var + (($upper_lim - $salary_var) / 2))
    }
    $counter++
}

$salary_min = $salary_var

Write-Host "-----------------"
Write-Host "Minimum salary: `$$([math]::round($salary_min,2)) | Maximum salary: `$$([math]::Round($salary_max,2))"
if ($job_data.salaryLabel -ne "") { Write-Host -NoNewline "`rReported Range: $($job_data.salaryLabel)" }
Write-Host "-----------------"
Write-Host "Last URL: $($base_url)?advertiserid=$($job_data.advertiser.id)&sourcesystem=houston&salaryrange=$([math]::round($salary_min,0))-$([math]::round($salary_max,0)))"

# Write-Host -NoNewline " | Advertised Range: $($job_data.salaryRange)"
