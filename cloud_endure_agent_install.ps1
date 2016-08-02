## installs cloudendure agent, require cloudendure username and password
## passed in as a Base64 encoded string
## $ce_path needs to be set to FULL path to cloudendure exe
## $log_path needs to be set to FULL path of logging folder, preferably a cifs share

# cloudendure executable
$ce_path = '\\corpaws001\AWS-Share\Cloudendure\Logging\upgrade_win.exe'

# log paths
$log_path = '\\corpaws001\AWS-Share\Cloudendure\Logging\' + $env:COMPUTERNAME + '.log'

$ce_log_path = '\\corpaws001\AWS-Share\Cloudendure\Logging\' + $env:COMPUTERNAME + '-cloudendure.log'

# throw all errors
$ErrorActionPreference = 'Stop'

# local installer path
$ce_local_path = 'C:\Temp\upgrade_win.exe'

# temp path
$tpath = 'C:\Temp\'

#$log_path = 'C:\Temp\' + $(hostname) + '.log'

$installer = "https://dashboard.cloudendure.com/upgrade_win.exe"

# return usn
function getUserName($key)
{

    return [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($key))
}

# return pass
function getPassword($key)
{

    return [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($key))
}

# log actions
function logMessage($message)
{
  $now = (Get-Date).ToString();
  $m = $now + "  --  " + $message;
  Write-Host $m
  $m >> $log_path;
}

function isInstalled()
{
    $s = Get-Service cloudendureservice -ea 0
    if($s -eq $null)
    {
        return $false
    }
    else
    {
        return $true
    }
}

function copyInstaller()
{

    if( $(Test-Path $tpath) -eq $false)
    {
        md $tpath | Out-Null
    }
    [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    (New-Object System.Net.WebClient).DownloadFile($installer, "C:\Temp\upgrade_win.exe")
}


function Main($u, $p)
{
    $isInstalled = isInstalled
    if ($isInstalled -eq $false)
    {
        # cpy installer to local dir
        copyInstaller
        cd $tpath

        # get local drives
        $drives = gwmi win32_logicaldisk | where { $_.DriveType -eq 3}

        # create drives string
        $drives_string = [string]::join(',', $($drives| select -exp Name))

        # log start

        logMessage ('Start')
        logMessage ('Cloudendure syncing drives: ' + $drives_string )

        # build command to execute
        $exec = $ce_local_path + ' -u ' + $(getUserName $u ) + ' -p ' + $(getPassword $p) + ' --drives="' + $drives_string + '" --no-prompt #--log-file=' + $ce_log_path

        # execute and store output in a var
        $output = Invoke-Expression $exec

        # log var
        logMessage $output
        logMessage 'Finished'
    }
    else
    {
        logMessage 'Cloudendure already installed'
    }
}


try{
    if ($args.Length -ne 2)
    {
        Write-Host 'Invalid Number of arguments, usage:'
        Write-Host '.\cloud_endure_agent_install.ps1 Username Password'
        Write-Host ''
        Write-Host 'Both username and pass need to be Base64 encoded'
    }
    else
    {
        Main $args[0] $args[1]

    }
}
catch
{
    logMessage "There was an error`nError:";
  logMessage ($_ | Out-String);
}
