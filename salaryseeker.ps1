### seek salary seeker
### rewritten from https://github.com/b3n-j4m1n/salary-seeker

Param (
    [Parameter(Mandatory=$true)]
    [int]$job_id    
)

### initial variables
$counter = 0
$response = 1
$upper_lim = 250000
$lower_lim = 20000
$salary_var = ($lower_lim + (($upper_lim - $lower_lim)/2))
$job_data=(ConvertFrom-Json(Invoke-WebRequest -UseBasicParsing -Uri "https://chalice-search-api.cloud.seek.com.au/search?jobid=$($job_id)")).data

### Go!

clear
Write-Host "Job Title:" $job_data.title "| Advertiser:" $job_data.advertiser.description
Write-Host "Type: $($job_data.workType) | Location: $($job_data.location)"
Write-Host $job_data.teaser
Write-Host "Job ID: $($job_data.id)"
### find maximum
while ($counter -lt 16) {
    $response=(ConvertFrom-Json(Invoke-WebRequest -UseBasicParsing -Uri "https://chalice-search-api.cloud.seek.com.au/search?keywords=$($job_data.teaser)&advertiserid=$($job_data.advertiser.id)&sourcesystem=houston&salaryrange=$([math]::round($salary_var,0))-$([math]::round($upper_lim,0))")).data | where {$_.id -eq $job_id}
    if(($response|measure-object).Count -eq 1) {
        $lower_lim=$salary_var
        $salary_var=($salary_var + (($upper_lim - $salary_var) / 2))
        #Write-host "MAX found 1, new upper: $($upper_lim), new lower: $($salary_var)" 
        }
    elseif(($response|measure-object).Count -eq 0) {
        $upper_lim=$salary_var
        $salary_var=($salary_var - (($salary_var - $lower_lim) / 2))
        #write-host "MAX found 0, new upper: $($upper_lim), new lower: $($salary_var)" 
        }
    $counter ++
    #Write-Host "MAX - Var: $($salary_var), lower: $($lower_lim), upper: $($upper_lim)"
}

$salary_max = $salary_var
Write-verbose "BETWEEN CALCS - Var: $($salary_var), lower: $($lower_lim), upper: $($upper_lim)"
### variable reset
$counter = 0
$lower_lim = 25000
$upper_lim = $salary_max
$salary_var = ($lower_lim + (($upper_lim - $lower_lim) / 2))

### find minimum
    while ($counter -lt 16) {
    $response=(ConvertFrom-Json(Invoke-WebRequest -UseBasicParsing -Uri "https://chalice-search-api.cloud.seek.com.au/search?keywords=$($job_data.teaser)&advertiserid=$($job_data.advertiser.id)&sourcesystem=houston&salaryrange=$([math]::round($lower_lim,0))-$([math]::round($salary_var,0))")).data | where {$_.id -eq $job_id}
    if(($response|measure-object).Count -eq 1) {
        $upper_lim=$salary_var
        $salary_var=($salary_var - (($salary_var - $lower_lim) / 2)) 
        #write-host "MIN found 1, new upper: $([math]::round($salary_var,2)), new lower: $([math]::round($lower_lim,2))" 
        }
    elseif(($response|measure-object).Count -eq 0) {
        $lower_lim=$salary_var
        $salary_var=($salary_var + (($upper_lim - $salary_var) / 2))
        #write-host "MIN found 0, new upper: $([math]::round($salary_var,2)), new lower: $([math]::round($lower_lim,2))"
        }
    $counter ++
} 
$salary_min = $salary_var

Write-Host "-----------------"
Write-Host -NoNewline "Minimum salary: `$$([math]::round($salary_min,2)) | Maximum salary: `$$([math]::Round($salary_max,2))"
if ($job_data.salary -ne ""){Write-Host -nonewline "`r | Reported Range: $($job_data.salary)" }
