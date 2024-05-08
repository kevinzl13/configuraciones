# config oh my posh
#(@(& 'C:/Users/kevin/AppData/Local/Programs/oh-my-posh/bin/oh-my-posh.exe' init pwsh --config='C:\Users\kevin\AppData\Local\Programs\oh-my-posh\themes\groos.omp.json' --print) -join "`n") | Invoke-Expression

#config startship.rs
Invoke-Expression (&starship init powershell)

Import-Module terminal-Icons

Set-PSReadLineOption -PredictionViewStyle ListView

$env:FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

function ff {
	nvim $(fzf --preview "bat --color=always --style=numbers --line-range=:500 {}")
}

function dps {
	$(docker ps --format="ID:\t{{.ID}}\nName:\t{{.Names}}\nImage:\t{{.Image}}\nPorts:\t{{.Ports}}\nStatus:\t{{.Status}}\nNetwork:\t{{.Networks}}\n----------")
}

function dpsa {
	$(docker ps -a --format="ID:\t{{.ID}}\nName:\t{{.Names}}\nImage:\t{{.Image}}\nPorts:\t{{.Ports}}\nStatus:\t{{.Status}}\nNetwork:\t{{.Networks}}\n--------")
}

#ver markdown
function smarkd {
    param(
        [string]$Path
    )

    if (Test-Path $Path) {
        Get-Content $Path | Out-String | Show-Markdown
    } else {
        Write-Host "El archivo $Path no existe."
    }
}

function touch {
    param(
        [string]$FilePath = $PWD.Path
    )

    if (-not $FilePath) {
        throw "Se requiere el parámetro -FilePath"
    }

    if (-not (Test-Path $FilePath)) {
        New-Item -Path $FilePath -ItemType "file" -Force | Out-Null
    } else {
        $null = (Get-Item $FilePath).LastWriteTime = Get-Date
    }
}

function grep {
    param(
        [string]$Pattern,
        [string]$Path
    )

    if (-not $Pattern) {
        throw "Se requiere el parámetro -Pattern"
    }

    if (-not $Path) {
        $input | Where-Object { $_ -match $Pattern }
    } else {
        Get-Content -Path $Path | Where-Object { $_ -match $Pattern }
    }
}

$Env:KOMOREBI_CONFIG_HOME = 'C:\Users\kevin\.config\komorebi'

set-alias -name pn -value pnpm
set-alias -name vim -value nvim
set-alias activate .\venv\Scripts\activate

function htop {
    $processes = Get-Process | Select-Object Id, ProcessName, CPU, WorkingSet -First 30 | Sort-Object CPU -Descending

    $formatString = "{0,-10} {1,-30} {2,-10} {3,-10}"
    Write-Host ($formatString -f "PID", "Nombre del Proceso", "CPU (%)", "Memoria (MB)")
    Write-Host ("-" * 60)

    foreach ($process in $processes) {
        $cpu = [Math]::Round($process.CPU)
        $memory = [Math]::Round($process.WorkingSet / 1MB)
        Write-Host ($formatString -f $process.Id, $process.ProcessName, $cpu, $memory)
    }
}

function find {
    param(
        [string]$Pattern,
        [string]$Directory = $PWD
    )

    Get-ChildItem -Path $Directory -Recurse | Where-Object { $_.Name -match $Pattern }
}

function rm {
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [string]$Path,
        
        [switch]$r,
        [switch]$f,
        [switch]$v
    )

    if (-not (Test-Path -Path $Path)) {
        Write-Error "No se puede encontrar el archivo o directorio '$Path'"
        return
    }

    if ($r) {
        if ($Force) {
            Remove-Item -Path $Path -Recurse -Force
        } else {
            Remove-Item -Path $Path -Recurse
        }
    } elseif ($f) {
        Remove-Item -Path $Path -Force
    } else {
        Remove-Item -Path $Path
    }

    if ($v) {
        Write-Host "Se ha eliminado: $Path"
    }
}

function stopwsl {
	$(wsl --shutdown)
	echo "wsl stopped"
}



function Get-MemoryInfo {
    $totalMemory = (Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1MB
    $freeMemory = (Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory / 1MB
    $usedMemory = $totalMemory - $freeMemory

    [PSCustomObject]@{
        TotalMemory = $totalMemory
        FreeMemory = $freeMemory
        UsedMemory = $usedMemory
    }
}

function memoryinfo {
    $memoryInfo = Get-MemoryInfo
    Write-Output "Memoria Total: $($memoryInfo.TotalMemory) MB"
    Write-Output "Memoria Libre: $($memoryInfo.FreeMemory) MB"
    Write-Output "Memoria Usada: $($memoryInfo.UsedMemory) MB"
}
