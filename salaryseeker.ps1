### seek salary seeker
### rewritten from https://github.com/b3n-j4m1n/salary-seeker

Param (
    [Parameter(Mandatory=$true)]
    [int]$job_id    
)

### initial variables
$counter = 1
$response = 1
$upper_lim = 2000000
$lower_lim = 30000
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
    $response=(ConvertFrom-Json(Invoke-WebRequest -UseBasicParsing -Uri "https://chalice-search-api.cloud.seek.com.au/search?keywords=$($job_data.teaser)&advertiserid=$($job_data.advertiser.id)&sourcesystem=houston&salaryrange=$($salary_var)-$($upper_lim)"))
    if($response.totalCount -eq 1) {
        $lower_lim=$salary_var
        $salary_var=($salary_var + (($upper_lim - $salary_var) / 2)) 
        #Write-Host "found, upper limit: $($upper_lim), lower limit: $($salary_var)"
        }
    elseif($response.TotalCount -eq 0) {
        $upper_lim=$salary_var
        $salary_var=($salary_var - (($salary_var - $lower_lim) / 2))
        #write-host "none found, new upper: $($upper_lim), new lower: $($salary_var)"
        }
    $counter ++
}
$salary_max = $salary_var

### variable reset
$upper_lim = $salary_max
$lower_lim = 25000
$salary_var = ($lower_lim + (($upper_lim - $lower_lim) / 2))

### find maximum
    while ($counter -lt 16) {
    $response=(ConvertFrom-Json(Invoke-WebRequest -UseBasicParsing -Uri "https://chalice-search-api.cloud.seek.com.au/search?keywords=$($job_data.teaser)&advertiserid=$($job_data.advertiser.id)&sourcesystem=houston&salaryrange=$($lower_lim)-$($salary_var)"))
    if($response.totalCount -eq 1) {
        $upper_lim=$salary_var
        #printf line
        $salary_var=($salary_var - (($salary_var - $lower_lim) / 2)) 
        }
    elseif($response.TotalCount -eq 0) {
        $upper_lim=$salary_var
        #printf line
        $salary_var=($salary_var + (($upper_lim - $salary_var) / 2))
        }
    $counter ++
} 
$salary_min = $salary_var

Write-Host "-----------------"
Write-Host "Minimum salary: $([math]::round($salary_min,2)) | Maximum salary: $([math]::Round($salary_max,2))"