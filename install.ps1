<#
.SYNOPSIS
    LazaroBox.nvim — instalador para Windows nativo.

.DESCRIPTION
    Instala la Nerd Font oficial, las dependencias externas del config y enlaza
    LazaroBox en %LOCALAPPDATA%\nvim.

    Todo se hace a nivel de usuario: no necesita permisos de administrador.

    En Windows una fuente no queda instalada solo con copiar el .ttf: hay que
    registrarla en HKCU\Software\Microsoft\Windows NT\CurrentVersion\Fonts. Este
    script hace las dos cosas.

.PARAMETER FontsOnly
    Instala unicamente la Nerd Font. Es el modo que usa install.sh cuando detecta
    WSL, porque el terminal lo dibuja Windows y no la distro.

.PARAMETER NoDeps
    No instala paquetes con winget.

.PARAMETER NoLink
    No enlaza el config en %LOCALAPPDATA%\nvim.

.PARAMETER Yes
    No hace preguntas.

.EXAMPLE
    .\install.ps1

.EXAMPLE
    irm https://raw.githubusercontent.com/pichu2707/lazarobox-nvim/main/install.ps1 | iex
#>

[CmdletBinding()]
param(
    [switch]$FontsOnly,
    [switch]$NoDeps,
    [switch]$NoLink,
    [switch]$Yes
)

$ErrorActionPreference = 'Stop'

# PowerShell 5.1 negocia TLS 1.0 por defecto y GitHub lo rechaza.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ------------------------------------------------------------------------------
# Constantes
# ------------------------------------------------------------------------------

$LazaroboxRepo = 'https://github.com/pichu2707/lazarobox-nvim.git'
$FontArchive   = 'JetBrainsMono'
$FontFamily    = 'JetBrainsMono Nerd Font'
$FontUrl       = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FontArchive.zip"
$MinNvim       = [version]'0.10'

# Instalacion de fuentes por usuario (Windows 10 1803+). Sin admin.
$UserFontDir  = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
$FontRegKey   = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'

# ------------------------------------------------------------------------------
# Salida
# ------------------------------------------------------------------------------

function Write-Step { param([string]$Text) Write-Host "`n==> $Text" -ForegroundColor Blue }
function Write-Info { param([string]$Text) Write-Host "    $Text" }
function Write-Ok   { param([string]$Text) Write-Host "    OK  $Text" -ForegroundColor Green }
function Write-Skip { param([string]$Text) Write-Host "    --  $Text" -ForegroundColor DarkGray }
function Write-Warn { param([string]$Text) Write-Host "    !   $Text" -ForegroundColor Yellow }
function Write-Fail { param([string]$Text) Write-Host "    X   $Text" -ForegroundColor Red }

function Confirm-Action {
    param([string]$Prompt)
    if ($Yes) { return $true }
    # Sin consola interactiva asumimos que si.
    if ([Console]::IsInputRedirected) { return $true }
    $answer = Read-Host "    ? $Prompt [S/n]"
    return ($answer -eq '' -or $answer -match '^[SsYy]$')
}

function Test-Command {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

# ------------------------------------------------------------------------------
# Localizar el repositorio
# ------------------------------------------------------------------------------

function Resolve-Repo {
    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { $null }

    if ($scriptDir -and
        (Test-Path (Join-Path $scriptDir 'init.lua')) -and
        (Test-Path (Join-Path $scriptDir 'lua\config'))) {
        return $scriptDir
    }

    # Nos han lanzado con `irm ... | iex`: hay que traer el repo.
    $target = if ($env:LAZAROBOX_DIR) { $env:LAZAROBOX_DIR } else { Join-Path $env:LOCALAPPDATA 'nvim' }
    Write-Step 'Obteniendo LazaroBox.nvim'

    if ((Test-Path (Join-Path $target 'init.lua')) -and (Test-Path (Join-Path $target '.git'))) {
        Write-Info "Ya existe un clon en $target, actualizando"
        git -C $target pull --ff-only 2>$null
    }
    elseif (Test-Path $target) {
        throw "$target ya existe y no es un clon de LazaroBox. Muevelo o define LAZAROBOX_DIR."
    }
    else {
        if (-not (Test-Command git)) { throw 'Necesito git para clonar. Instalalo con: winget install Git.Git' }
        git clone --depth 1 $LazaroboxRepo $target
        Write-Ok "Clonado en $target"
    }

    # El config ya vive en su sitio.
    $script:NoLink = $true
    return $target
}

# ------------------------------------------------------------------------------
# Nerd Font
# ------------------------------------------------------------------------------

function Test-FontInstalled {
    if (-not (Test-Path $FontRegKey)) { return $false }
    $values = (Get-ItemProperty -Path $FontRegKey).PSObject.Properties.Name
    return [bool]($values | Where-Object { $_ -like 'JetBrainsMonoNerdFont*' })
}

function Install-NerdFont {
    Write-Step "Nerd Font ($FontFamily)"

    if (Test-FontInstalled) {
        Write-Skip "$FontFamily ya registrada para este usuario"
        return
    }

    $tmp = Join-Path ([IO.Path]::GetTempPath()) ("lazarobox-font-" + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $tmp -Force | Out-Null

    try {
        $zip = Join-Path $tmp "$FontArchive.zip"
        Write-Info "Descargando $FontArchive.zip desde la ultima release de Nerd Fonts"
        Invoke-WebRequest -Uri $FontUrl -OutFile $zip -UseBasicParsing

        $extracted = Join-Path $tmp 'extracted'
        Expand-Archive -Path $zip -DestinationPath $extracted -Force

        New-Item -ItemType Directory -Path $UserFontDir -Force | Out-Null
        if (-not (Test-Path $FontRegKey)) {
            New-Item -Path $FontRegKey -Force | Out-Null
        }

        # Filtramos con Where-Object en lugar de -Include: combinado con -Recurse,
        # -Include tiene un comportamiento inconsistente segun la version de
        # PowerShell y puede devolver cero resultados sin dar error.
        $fonts = Get-ChildItem -Path $extracted -Recurse -File |
            Where-Object { $_.Extension -in '.ttf', '.otf' }
        if (-not $fonts) { throw 'El zip no contenia ficheros de fuente' }

        $count = 0
        foreach ($font in $fonts) {
            $dest = Join-Path $UserFontDir $font.Name
            Copy-Item -Path $font.FullName -Destination $dest -Force

            # Copiar no basta: sin esta entrada de registro, ninguna aplicacion
            # ve la fuente. Este es el paso que se olvida al instalar a mano.
            $suffix   = if ($font.Extension -eq '.otf') { '(OpenType)' } else { '(TrueType)' }
            $regName  = "$($font.BaseName) $suffix"
            New-ItemProperty -Path $FontRegKey -Name $regName -Value $dest -PropertyType String -Force | Out-Null
            $count++
        }

        Write-Ok "$count ficheros copiados en $UserFontDir"
        Write-Ok 'Fuentes registradas en HKCU (instalacion por usuario, sin admin)'
        Write-Warn 'Las aplicaciones ya abiertas no veran la fuente: reinicia el terminal'
    }
    finally {
        Remove-Item -Path $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ------------------------------------------------------------------------------
# Windows Terminal: dejar la fuente seleccionada
#
# Instalar la fuente y no activarla deja el trabajo a medias, que es justo el
# problema que este instalador viene a resolver.
# ------------------------------------------------------------------------------

function Set-WindowsTerminalFont {
    Write-Step 'Windows Terminal'

    $settings = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
    if (-not (Test-Path $settings)) {
        Write-Skip 'Windows Terminal no encontrado: configura la fuente en tu terminal a mano'
        return
    }

    if (-not (Confirm-Action "Poner '$FontFamily' como fuente por defecto en Windows Terminal?")) {
        Write-Skip 'Windows Terminal sin tocar'
        return
    }

    try {
        $raw = Get-Content -Path $settings -Raw
        $json = $raw | ConvertFrom-Json

        $backup = "$settings.lazarobox.bak"
        Copy-Item -Path $settings -Destination $backup -Force
        Write-Info "Copia de seguridad en $backup"

        if (-not $json.profiles) {
            Write-Warn 'settings.json sin seccion profiles: no lo modifico'
            return
        }
        # Las versiones antiguas de Windows Terminal usaban un array de perfiles
        # sin bloque `defaults`. Ahi no hay sitio donde escribir la fuente global.
        if ($json.profiles -is [Array]) {
            Write-Warn 'settings.json con formato antiguo (profiles como array): configura la fuente a mano'
            return
        }
        if (-not $json.profiles.defaults) {
            $json.profiles | Add-Member -NotePropertyName 'defaults' -NotePropertyValue ([PSCustomObject]@{}) -Force
        }

        $fontValue = [PSCustomObject]@{ face = $FontFamily }
        $json.profiles.defaults | Add-Member -NotePropertyName 'font' -NotePropertyValue $fontValue -Force

        $json | ConvertTo-Json -Depth 32 | Set-Content -Path $settings -Encoding UTF8
        Write-Ok "Windows Terminal usara '$FontFamily'"
    }
    catch {
        Write-Warn "No he podido editar settings.json: $($_.Exception.Message)"
        Write-Warn "Selecciona '$FontFamily' a mano en los ajustes del terminal"
    }
}

# ------------------------------------------------------------------------------
# Dependencias
#
# Misma lista que install.sh, sacada de lo que el config usa de verdad:
#   compilador C -> nvim-treesitter y telescope-fzf-native
#   ripgrep / fd -> telescope y snacks.picker
#   imagemagick  -> image.nvim (processor = magick_cli)
#   node + npm   -> live-server, copilot, claudecode, mermaid-cli
# ------------------------------------------------------------------------------

function Install-Dependencies {
    Write-Step 'Dependencias del sistema'

    if ($NoDeps) {
        Write-Skip 'Omitidas por -NoDeps'
        return
    }

    if (-not (Test-Command winget)) {
        Write-Warn 'winget no disponible (necesita App Installer desde Microsoft Store).'
        Write-Warn 'Instala a mano: git, ripgrep, fd, nodejs, python, imagemagick, zig'
        return
    }

    # zig hace de compilador C para treesitter: es la opcion mas simple en
    # Windows si no quieres arrastrar todo Visual Studio Build Tools.
    $packages = @(
        @{ Id = 'Git.Git';                    Cmd = 'git' },
        @{ Id = 'BurntSushi.ripgrep.MSVC';    Cmd = 'rg' },
        @{ Id = 'sharkdp.fd';                 Cmd = 'fd' },
        @{ Id = 'OpenJS.NodeJS.LTS';          Cmd = 'node' },
        @{ Id = 'Python.Python.3.12';         Cmd = 'python' },
        @{ Id = 'ImageMagick.ImageMagick';    Cmd = 'magick' },
        @{ Id = 'zig.zig';                    Cmd = 'zig' },
        @{ Id = 'GnuWin32.Make';              Cmd = 'make' }
    )

    foreach ($pkg in $packages) {
        if (Test-Command $pkg.Cmd) {
            Write-Skip "$($pkg.Cmd) ya presente"
            continue
        }
        Write-Info "Instalando $($pkg.Id)"
        winget install --id $pkg.Id --exact --silent `
            --accept-package-agreements --accept-source-agreements 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "$($pkg.Id) instalado"
        }
        else {
            Write-Warn "winget no ha podido instalar $($pkg.Id); hazlo a mano si lo necesitas"
        }
    }

    Install-MermaidCli
}

function Install-MermaidCli {
    if (Test-Command mmdc) {
        Write-Skip 'mermaid-cli ya presente'
        return
    }
    if (-not (Test-Command npm)) {
        Write-Warn 'npm no disponible en esta sesion: reinicia la terminal y lanza "npm i -g @mermaid-js/mermaid-cli"'
        return
    }
    if (Confirm-Action 'Instalar mermaid-cli (mmdc) para los diagramas?') {
        npm install -g @mermaid-js/mermaid-cli 2>$null | Out-Null
        if (Test-Command mmdc) { Write-Ok 'mermaid-cli instalado' }
        else { Write-Warn 'No he podido instalar mermaid-cli' }
    }
}

# ------------------------------------------------------------------------------
# Enlazar el config
# ------------------------------------------------------------------------------

function Install-ConfigLink {
    param([string]$RepoDir)

    Write-Step 'Configuracion de Neovim'

    if ($NoLink) {
        Write-Skip 'Omitido (el config ya esta en su sitio o -NoLink)'
        return
    }

    $nvimConfig = Join-Path $env:LOCALAPPDATA 'nvim'

    if (Test-Path $nvimConfig) {
        $item = Get-Item $nvimConfig -Force

        # Junction o symlink que ya apunta al repo: nada que hacer.
        # PowerShell 5.1 devuelve Target como array y 7.x como string, asi que
        # indexar a ciegas con [0] daria un caracter en 7.x en lugar de la ruta.
        if ($item.LinkType -and $item.Target) {
            $linkTarget = if ($item.Target -is [Array]) { $item.Target[0] } else { $item.Target }
            $resolved = Resolve-Path $linkTarget -ErrorAction SilentlyContinue
            if ($resolved -and $resolved.Path -eq (Resolve-Path $RepoDir).Path) {
                Write-Skip "$nvimConfig ya apunta a este repositorio"
                return
            }
        }

        if ((Resolve-Path $nvimConfig).Path -eq (Resolve-Path $RepoDir).Path) {
            Write-Skip 'El repositorio ya es tu config de Neovim'
            return
        }

        $backup = "$nvimConfig.bak." + (Get-Date -Format 'yyyyMMddHHmmss')
        if (Confirm-Action "Ya existe $nvimConfig. Lo muevo a $(Split-Path $backup -Leaf)?") {
            Move-Item -Path $nvimConfig -Destination $backup -Force
            Write-Ok "Config anterior guardada en $backup"
        }
        else {
            Write-Warn 'No enlazo el config. Hazlo a mano cuando quieras:'
            Write-Warn "  New-Item -ItemType Junction -Path `"$nvimConfig`" -Target `"$RepoDir`""
            return
        }
    }

    # Junction en lugar de SymbolicLink: no necesita admin ni modo desarrollador.
    New-Item -ItemType Junction -Path $nvimConfig -Target $RepoDir | Out-Null
    Write-Ok "Enlazado $RepoDir -> $nvimConfig"
}

# ------------------------------------------------------------------------------
# Resumen
# ------------------------------------------------------------------------------

function Test-Neovim {
    if (-not (Test-Command nvim)) {
        Write-Warn 'Neovim no esta instalado. Este instalador no lo instala por diseño.'
        Write-Warn 'Instalalo con: winget install Neovim.Neovim'
        return
    }
    $line = (nvim --version | Select-Object -First 1)
    if ($line -match 'v?(\d+\.\d+)') {
        $found = [version]$Matches[1]
        if ($found -lt $MinNvim) {
            Write-Warn "Neovim $found detectado; LazaroBox pide >= $MinNvim"
            return
        }
        Write-Ok "Neovim $found"
    }
}

function Write-Summary {
    Write-Step 'Resumen'

    Test-Neovim

    $missing = @()
    foreach ($tool in @('git', 'rg', 'fd', 'node', 'npm', 'magick', 'mmdc')) {
        if (-not (Test-Command $tool)) { $missing += $tool }
    }
    if ($missing.Count -eq 0) {
        Write-Ok 'Todas las herramientas externas presentes'
    }
    else {
        Write-Warn "Faltan (opcionales, degradan funciones): $($missing -join ', ')"
        Write-Info 'Algunas solo apareceran tras reiniciar la terminal (PATH)'
    }

    if (Test-FontInstalled) { Write-Ok "$FontFamily registrada" }
    else { Write-Warn "$FontFamily no aparece registrada" }

    Write-Host "`nLazaroBox listo.`n" -ForegroundColor Green
    Write-Info "1. Reinicia el terminal para que cargue la fuente nueva"
    Write-Info "2. Comprueba que la fuente activa es '$FontFamily'"
    Write-Info '3. Abre nvim: los plugins se instalan solos en el primer arranque'
    Write-Info '4. Verifica todo con :checkhealth lazarobox'
    Write-Host ''
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

Write-Host '+---------------------------------------+' -ForegroundColor White
Write-Host '|  LazaroBox.nvim - instalador Windows  |' -ForegroundColor White
Write-Host '+---------------------------------------+' -ForegroundColor White

$repoDir = Resolve-Repo
Write-Info "Repositorio: $repoDir"

if ($FontsOnly) {
    Install-NerdFont
    Write-Host ''
    Write-Info "Selecciona '$FontFamily' en tu terminal y reinicialo."
    Write-Host ''
    return
}

Install-Dependencies
Install-NerdFont
Set-WindowsTerminalFont
Install-ConfigLink -RepoDir $repoDir
Write-Summary
