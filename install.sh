#!/usr/bin/env bash
# ==============================================================================
# LazaroBox.nvim — instalador unico (Linux / macOS / WSL)
#
# Uso:
#   ./install.sh                      # instalacion completa
#   ./install.sh --fonts-only         # solo la Nerd Font
#   ./install.sh --no-deps            # salta los paquetes del sistema
#   ./install.sh --no-link            # no enlaza el config en ~/.config/nvim
#   ./install.sh --yes                # sin preguntas (para CI o reinstalar)
#
#   curl -fsSL https://raw.githubusercontent.com/pichu2707/lazarobox-nvim/main/install.sh | bash
#
# El script es idempotente: cada paso comprueba antes de actuar, asi que puedes
# volver a lanzarlo sin miedo a duplicar nada.
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# Constantes
# ------------------------------------------------------------------------------

readonly LAZAROBOX_REPO="https://github.com/pichu2707/lazarobox-nvim.git"

# Fuente oficial de LazaroBox. El asset se resuelve contra la ultima release de
# Nerd Fonts, asi el instalador no envejece cuando publican una version nueva.
readonly FONT_ARCHIVE="JetBrainsMono"
readonly FONT_FAMILY="JetBrainsMono Nerd Font"
readonly FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_ARCHIVE}.zip"

# Clipboard en WSL: lua/config/options.lua:41 espera win32yank.exe en el PATH.
readonly WIN32YANK_URL="https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip"

readonly MIN_NVIM_VERSION="0.10"

# Flags
FONTS_ONLY=0
SKIP_DEPS=0
SKIP_LINK=0
ASSUME_YES=0

# Estado detectado
PLATFORM=""       # linux | macos | wsl
PKG_MANAGER=""    # apt | pacman | dnf | zypper | brew | none
REPO_DIR=""
TMP_DIR=""

# ------------------------------------------------------------------------------
# Salida
# ------------------------------------------------------------------------------

if [[ -t 1 ]]; then
	readonly C_RESET=$'\033[0m'
	readonly C_RED=$'\033[31m'
	readonly C_GREEN=$'\033[32m'
	readonly C_YELLOW=$'\033[33m'
	readonly C_BLUE=$'\033[34m'
	readonly C_BOLD=$'\033[1m'
	readonly C_DIM=$'\033[2m'
else
	readonly C_RESET="" C_RED="" C_GREEN="" C_YELLOW="" C_BLUE="" C_BOLD="" C_DIM=""
fi

step() { printf '\n%s==>%s %s%s%s\n' "$C_BLUE" "$C_RESET" "$C_BOLD" "$1" "$C_RESET"; }
info() { printf '    %s\n' "$1"; }
ok() { printf '    %s✓%s %s\n' "$C_GREEN" "$C_RESET" "$1"; }
skip() { printf '    %s·%s %s%s%s\n' "$C_DIM" "$C_RESET" "$C_DIM" "$1" "$C_RESET"; }
warn() { printf '    %s!%s %s\n' "$C_YELLOW" "$C_RESET" "$1" >&2; }
fail() { printf '    %s✗%s %s\n' "$C_RED" "$C_RESET" "$1" >&2; }

die() {
	fail "$1"
	exit 1
}

# ------------------------------------------------------------------------------
# Utilidades
# ------------------------------------------------------------------------------

has() { command -v "$1" >/dev/null 2>&1; }

confirm() {
	local prompt="$1"
	[[ $ASSUME_YES -eq 1 ]] && return 0
	# Sin TTY (curl | bash) no podemos preguntar: asumimos que si.
	[[ -t 0 ]] || return 0
	local answer
	printf '    %s? %s [S/n] ' "$C_YELLOW" "$prompt$C_RESET"
	read -r answer </dev/tty || return 0
	[[ -z "$answer" || "$answer" =~ ^[SsYy]$ ]]
}

download() {
	local url="$1" dest="$2"
	if has curl; then
		curl -fsSL --retry 3 -o "$dest" "$url"
	elif has wget; then
		wget -qO "$dest" "$url"
	else
		die "Necesito curl o wget para descargar. Instala uno de los dos y vuelve a lanzarme."
	fi
}

# Ojo: es un trap de EXIT. Si la ultima orden falla, con `set -e` ese estado se
# convierte en el codigo de salida del script. El `return 0` no es decorativo.
cleanup() {
	if [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]]; then
		rm -rf "$TMP_DIR"
	fi
	return 0
}
trap cleanup EXIT

# No leemos la cabecera del propio fichero: con `curl | bash` no hay fichero.
usage() {
	cat <<'EOF'
LazaroBox.nvim — instalador (Linux / macOS / WSL)

Uso: ./install.sh [opciones]

  --fonts-only   Instala solo la Nerd Font
  --no-deps      Salta los paquetes del sistema
  --no-link      No enlaza el config en ~/.config/nvim
  -y, --yes      No hace preguntas
  -h, --help     Muestra esta ayuda

En Windows nativo usa install.ps1 desde PowerShell.
EOF
	exit 0
}

# ------------------------------------------------------------------------------
# Deteccion de plataforma
# ------------------------------------------------------------------------------

detect_platform() {
	case "$(uname -s)" in
	Darwin)
		PLATFORM="macos"
		;;
	Linux)
		# WSL se reconoce por el kernel de Microsoft o por la variable de la distro.
		if [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then
			PLATFORM="wsl"
		else
			PLATFORM="linux"
		fi
		;;
	*)
		die "Plataforma no soportada: $(uname -s). En Windows nativo usa install.ps1 desde PowerShell."
		;;
	esac

	# En macOS solo existe brew. En Linux mandan los gestores del sistema y brew
	# queda como ultimo recurso: Homebrew tambien corre en Linux y a veces es el
	# unico gestor disponible (maquina compartida, sin sudo). Pero si hay apt,
	# instalar con apt es lo correcto.
	if [[ "$PLATFORM" == "macos" ]]; then
		PKG_MANAGER=$(has brew && echo brew || echo none)
	elif has apt-get; then
		PKG_MANAGER="apt"
	elif has pacman; then
		PKG_MANAGER="pacman"
	elif has dnf; then
		PKG_MANAGER="dnf"
	elif has zypper; then
		PKG_MANAGER="zypper"
	elif has brew; then
		PKG_MANAGER="brew"
	else
		PKG_MANAGER="none"
	fi
}

# ------------------------------------------------------------------------------
# Localizar el repositorio (o clonarlo si nos ejecutan via curl)
# ------------------------------------------------------------------------------

resolve_repo() {
	local script_dir
	script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"

	if [[ -n "$script_dir" && -f "$script_dir/init.lua" && -d "$script_dir/lua/config" ]]; then
		REPO_DIR="$script_dir"
		return
	fi

	# Nos han lanzado con `curl ... | bash`: no hay repo en disco todavia.
	local target="${LAZAROBOX_DIR:-$HOME/.config/nvim}"
	step "Obteniendo LazaroBox.nvim"

	if [[ -f "$target/init.lua" && -d "$target/.git" ]]; then
		info "Ya existe un clon en $target, actualizando"
		git -C "$target" pull --ff-only || warn "No he podido actualizar; sigo con lo que hay en disco"
	elif [[ -e "$target" ]]; then
		die "$target ya existe y no es un clon de LazaroBox. Muevelo o define LAZAROBOX_DIR."
	else
		has git || die "Necesito git para clonar el repositorio."
		git clone --depth 1 "$LAZAROBOX_REPO" "$target"
		ok "Clonado en $target"
	fi

	REPO_DIR="$target"
	# El config ya vive en su sitio: no hay nada que enlazar.
	SKIP_LINK=1
}

# ------------------------------------------------------------------------------
# Dependencias del sistema
#
# La lista sale del propio config, no de suposiciones:
#   make + compilador C  -> nvim-treesitter (:TSUpdate) y telescope-fzf-native
#   ripgrep / fd         -> telescope y snacks.picker
#   imagemagick (magick) -> image.nvim con processor = magick_cli
#   chafa                -> logo del dashboard
#   node + npm           -> live-server, copilot, claudecode, mermaid-cli
#   xclip / wl-clipboard -> portapapeles en X11 / Wayland
#   win32yank.exe        -> portapapeles en WSL
# ------------------------------------------------------------------------------

install_deps() {
	step "Dependencias del sistema"

	if [[ $SKIP_DEPS -eq 1 ]]; then
		skip "Omitidas por --no-deps"
		return
	fi

	if [[ "$PKG_MANAGER" == "none" ]]; then
		warn "No he detectado gestor de paquetes."
		[[ "$PLATFORM" == "macos" ]] &&
			warn "Instala Homebrew primero: https://brew.sh"
		warn "Instala a mano: git curl unzip make gcc ripgrep fd imagemagick chafa node npm"
		return
	fi

	case "$PKG_MANAGER" in
	apt) install_deps_apt ;;
	pacman) install_deps_pacman ;;
	dnf) install_deps_dnf ;;
	zypper) install_deps_zypper ;;
	brew) install_deps_brew ;;
	esac

	link_fd_binary
	[[ "$PLATFORM" == "wsl" ]] && install_win32yank
	install_mermaid_cli
}

# `sudo` solo si no somos root; asi el script tambien funciona en contenedores.
as_root() {
	if [[ "$(id -u)" -eq 0 ]]; then
		"$@"
	elif has sudo; then
		sudo "$@"
	else
		die "Necesito privilegios de root para instalar paquetes (no encuentro sudo)."
	fi
}

install_deps_apt() {
	info "Usando apt"
	as_root apt-get update -qq
	as_root apt-get install -y --no-install-recommends \
		git curl unzip fontconfig build-essential \
		ripgrep fd-find imagemagick chafa \
		xclip wl-clipboard \
		python3 python3-venv python3-pip \
		nodejs npm
	ok "Paquetes apt instalados"
}

install_deps_pacman() {
	info "Usando pacman"
	as_root pacman -Sy --needed --noconfirm \
		git curl unzip fontconfig base-devel \
		ripgrep fd imagemagick chafa \
		xclip wl-clipboard \
		python python-pip \
		nodejs npm
	ok "Paquetes pacman instalados"
}

install_deps_dnf() {
	info "Usando dnf"
	as_root dnf install -y \
		git curl unzip fontconfig gcc gcc-c++ make \
		ripgrep fd-find ImageMagick chafa \
		xclip wl-clipboard \
		python3 python3-pip \
		nodejs npm
	ok "Paquetes dnf instalados"
}

install_deps_zypper() {
	info "Usando zypper"
	as_root zypper --non-interactive install \
		git curl unzip fontconfig gcc gcc-c++ make \
		ripgrep fd ImageMagick chafa \
		xclip wl-clipboard \
		python3 python3-pip \
		nodejs npm
	ok "Paquetes zypper instalados"
}

install_deps_brew() {
	info "Usando Homebrew"

	local packages=(git curl unzip ripgrep fd imagemagick chafa node python3)

	# En macOS el portapapeles ya lo cubre pbcopy/pbpaste. Si llegamos aqui en
	# Linux es porque brew es el unico gestor, asi que hace falta pedirlo.
	if [[ "$PLATFORM" != "macos" ]]; then
		packages+=(xclip)
	fi

	brew install "${packages[@]}" || true
	ok "Paquetes Homebrew instalados"
}

# Debian y Fedora empaquetan fd como `fdfind` para no chocar con otro binario.
# Telescope y snacks buscan `fd`, asi que dejamos un enlace en ~/.local/bin.
link_fd_binary() {
	if has fd; then
		return
	fi
	if has fdfind; then
		mkdir -p "$HOME/.local/bin"
		ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
		ok "Enlazado fdfind -> ~/.local/bin/fd"
		case ":$PATH:" in
		*":$HOME/.local/bin:"*) ;;
		*) warn "Añade ~/.local/bin a tu PATH para que 'fd' se resuelva" ;;
		esac
	fi
}

# lua/config/version.lua comprueba `mmdc` para renderizar diagramas mermaid.
install_mermaid_cli() {
	if has mmdc; then
		skip "mermaid-cli ya presente"
		return
	fi
	if ! has npm; then
		warn "npm no disponible: me salto mermaid-cli (mmdc)"
		return
	fi
	if confirm "Instalar mermaid-cli (mmdc) para los diagramas?"; then
		npm install -g @mermaid-js/mermaid-cli >/dev/null 2>&1 ||
			as_root npm install -g @mermaid-js/mermaid-cli >/dev/null 2>&1 ||
			warn "No he podido instalar mermaid-cli; hazlo a mano con: npm i -g @mermaid-js/mermaid-cli"
		has mmdc && ok "mermaid-cli instalado"
	fi
}

# ------------------------------------------------------------------------------
# Nerd Font
#
# Descargar el .ttf NO lo instala. Una fuente solo existe para las aplicaciones
# cuando esta en un directorio que el sistema escanea y el indice se ha
# regenerado. Cada plataforma lo hace distinto, y en WSL hay una trampa:
# el terminal es un proceso de Windows, asi que la fuente tiene que estar en el
# host Windows. Instalarla dentro de la distro no arregla los glifos.
# ------------------------------------------------------------------------------

install_fonts() {
	step "Nerd Font ($FONT_FAMILY)"

	case "$PLATFORM" in
	macos) install_fonts_macos ;;
	linux) install_fonts_linux ;;
	wsl)
		# Doble instalacion a proposito:
		#   - host Windows -> es quien dibuja el terminal
		#   - dentro de WSL -> apps GUI via WSLg y :checkhealth lazarobox
		install_fonts_linux
		install_fonts_windows_host
		;;
	esac
}

# Descarga y descomprime el zip de Nerd Fonts en $1. Devuelve 1 si ya estaba.
fetch_font_archive() {
	local dest_dir="$1"

	cleanup # por si una llamada previa dejo un temporal
	TMP_DIR="$(mktemp -d)"
	local zip="$TMP_DIR/$FONT_ARCHIVE.zip"

	info "Descargando $FONT_ARCHIVE.zip desde la ultima release de Nerd Fonts"
	download "$FONT_URL" "$zip"

	has unzip || die "Necesito unzip para extraer la fuente."

	mkdir -p "$dest_dir"
	# -o sobrescribe, asi reinstalar arregla ficheros corruptos.
	# Solo las variantes utiles: el zip trae tambien .otf y ficheros de licencia.
	unzip -qo "$zip" -d "$TMP_DIR/extracted"
	find "$TMP_DIR/extracted" -type f \( -name '*.ttf' -o -name '*.otf' \) \
		-exec cp -f {} "$dest_dir/" \;
}

# Capturamos la salida antes de filtrar a proposito. Con `pipefail`, un
# `fc-list | grep -q` devuelve 141: grep sale al primer acierto, cierra la
# tuberia y fc-list muere con SIGPIPE, asi que una fuente instalada se leeria
# como ausente. Al filtrar sobre una variable no hay tuberia que romper.
font_installed_locally() {
	has fc-list || return 1
	local families
	families="$(fc-list : family 2>/dev/null | tr ',' '\n')" || return 1
	grep -qxF "$FONT_FAMILY" <<<"$families"
}

install_fonts_linux() {
	local font_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/JetBrainsMonoNerdFont"

	# Basta con que fontconfig la conozca: da igual en que carpeta la instalaras.
	# Si comprobasemos ademas $font_dir, una instalacion manual previa (ficheros
	# planos en ~/.local/share/fonts) provocaria duplicados en cada ejecucion.
	if font_installed_locally; then
		skip "$FONT_FAMILY ya registrada en el sistema"
		return
	fi

	fetch_font_archive "$font_dir"
	ok "Fuentes copiadas en $font_dir"

	# Este es el paso que falta cuando lo haces a mano: sin refrescar el indice
	# de fontconfig, el sistema no sabe que los ficheros existen.
	if has fc-cache; then
		fc-cache -f "$font_dir" >/dev/null 2>&1
		ok "Indice de fontconfig regenerado (fc-cache -f)"
	else
		warn "fc-cache no encontrado: instala fontconfig y ejecuta 'fc-cache -f'"
	fi

	if font_installed_locally; then
		ok "$FONT_FAMILY disponible para el sistema"
	else
		warn "La fuente no aparece en fc-list. Revisa permisos de $font_dir"
	fi
}

install_fonts_macos() {
	local font_dir="$HOME/Library/Fonts"

	if [[ -n "$(find "$font_dir" -name 'JetBrainsMonoNerdFont*' -print -quit 2>/dev/null)" ]]; then
		skip "$FONT_FAMILY ya presente en $font_dir"
		return
	fi

	fetch_font_archive "$font_dir"
	# macOS no necesita refrescar cache: Core Text escanea ~/Library/Fonts.
	ok "Fuentes instaladas en $font_dir"
}

# En WSL la fuente que importa es la del host Windows. Reutilizamos install.ps1
# para no duplicar la logica del registro de Windows.
install_fonts_windows_host() {
	info "Instalando tambien en el host Windows (es quien renderiza el terminal)"

	if ! has powershell.exe; then
		warn "No encuentro powershell.exe: no puedo instalar la fuente en Windows."
		warn "Ejecuta install.ps1 desde PowerShell en Windows, o instala"
		warn "$FONT_FAMILY a mano desde https://www.nerdfonts.com"
		return
	fi

	local ps_script="$REPO_DIR/install.ps1"
	if [[ ! -f "$ps_script" ]]; then
		warn "No encuentro install.ps1 en $REPO_DIR; me salto el host Windows"
		return
	fi

	# PowerShell trata las rutas UNC (\\wsl$\...) como zona remota y bloquea el
	# script. Lo copiamos al TEMP de Windows y lo lanzamos desde ahi.
	local win_temp_unix
	win_temp_unix="$(wslpath "$(powershell.exe -NoProfile -Command 'Write-Output $env:TEMP' 2>/dev/null | tr -d '\r')" 2>/dev/null || true)"

	if [[ -z "$win_temp_unix" || ! -d "$win_temp_unix" ]]; then
		warn "No he podido resolver el TEMP de Windows; me salto el host Windows"
		return
	fi

	cp -f "$ps_script" "$win_temp_unix/lazarobox-install.ps1"
	local win_path
	win_path="$(wslpath -w "$win_temp_unix/lazarobox-install.ps1")"

	if powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$win_path" -FontsOnly -Yes; then
		ok "Fuente instalada en el host Windows"
		warn "Reinicia el terminal de Windows y selecciona '$FONT_FAMILY' en sus ajustes"
	else
		warn "La instalacion en Windows ha fallado. Lanza install.ps1 a mano desde PowerShell."
	fi

	rm -f "$win_temp_unix/lazarobox-install.ps1"
}

# ------------------------------------------------------------------------------
# Portapapeles en WSL
#
# lua/config/options.lua:41 usa win32yank.exe si esta en el PATH. Va en el PATH
# de Linux: la interoperabilidad de WSL ejecuta el .exe de forma transparente.
# ------------------------------------------------------------------------------

install_win32yank() {
	if has win32yank.exe; then
		skip "win32yank.exe ya presente"
		return
	fi

	info "Instalando win32yank.exe (portapapeles Windows <-> WSL)"
	local tmp
	tmp="$(mktemp -d)"
	if download "$WIN32YANK_URL" "$tmp/win32yank.zip" 2>/dev/null && has unzip; then
		unzip -qo "$tmp/win32yank.zip" -d "$tmp"
		if [[ -f "$tmp/win32yank.exe" ]]; then
			chmod +x "$tmp/win32yank.exe"
			# El portapapeles es opcional: si no hay root, lo dejamos en el home
			# en lugar de abortar toda la instalacion.
			if [[ "$(id -u)" -eq 0 ]] || has sudo; then
				as_root install -m 755 "$tmp/win32yank.exe" /usr/local/bin/win32yank.exe
				ok "win32yank.exe instalado en /usr/local/bin"
			else
				mkdir -p "$HOME/.local/bin"
				install -m 755 "$tmp/win32yank.exe" "$HOME/.local/bin/win32yank.exe"
				ok "win32yank.exe instalado en ~/.local/bin"
				case ":$PATH:" in
				*":$HOME/.local/bin:"*) ;;
				*) warn "Añade ~/.local/bin a tu PATH para que el portapapeles funcione" ;;
				esac
			fi
		else
			warn "El zip de win32yank no contenia el ejecutable esperado"
		fi
	else
		warn "No he podido descargar win32yank; el portapapeles usara el fallback"
	fi
	rm -rf "$tmp"
}

# ------------------------------------------------------------------------------
# Enlazar el config
# ------------------------------------------------------------------------------

link_config() {
	step "Configuracion de Neovim"

	if [[ $SKIP_LINK -eq 1 ]]; then
		skip "Omitido (el config ya esta en su sitio o --no-link)"
		return
	fi

	local nvim_config="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

	# Ya apunta a este repo: nada que hacer.
	if [[ -L "$nvim_config" ]] && [[ "$(readlink -f "$nvim_config")" == "$(readlink -f "$REPO_DIR")" ]]; then
		skip "$nvim_config ya apunta a este repositorio"
		return
	fi
	if [[ "$(readlink -f "$nvim_config" 2>/dev/null)" == "$(readlink -f "$REPO_DIR")" ]]; then
		skip "El repositorio ya es tu config de Neovim"
		return
	fi

	if [[ -e "$nvim_config" || -L "$nvim_config" ]]; then
		local backup
		backup="$nvim_config.bak.$(date +%Y%m%d%H%M%S)"
		if confirm "Ya existe $nvim_config. Lo muevo a $(basename "$backup")?"; then
			mv "$nvim_config" "$backup"
			ok "Config anterior guardada en $backup"
		else
			warn "No enlazo el config. Hazlo a mano cuando quieras:"
			warn "  ln -s $REPO_DIR $nvim_config"
			return
		fi
	fi

	mkdir -p "$(dirname "$nvim_config")"
	ln -s "$REPO_DIR" "$nvim_config"
	ok "Enlazado $REPO_DIR -> $nvim_config"
}

install_git_hooks() {
	step "Git hooks"

	if [[ ! -d "$REPO_DIR/.git" ]]; then
		skip "No es un clon de git: no hay hooks que instalar"
		return
	fi
	if [[ ! -x "$REPO_DIR/scripts/install-hooks.sh" ]]; then
		skip "scripts/install-hooks.sh no disponible"
		return
	fi

	"$REPO_DIR/scripts/install-hooks.sh" >/dev/null && ok "Hooks instalados"
}

# ------------------------------------------------------------------------------
# Resumen final
# ------------------------------------------------------------------------------

check_neovim() {
	if ! has nvim; then
		warn "Neovim no esta instalado. Este instalador no lo instala por diseño."
		warn "Instalalo desde https://github.com/neovim/neovim/releases (>= $MIN_NVIM_VERSION)"
		return 1
	fi

	# Mismo cuidado que con fc-list: nada de `| head -1` sobre un comando vivo,
	# porque SIGPIPE + pipefail convertiria un exito en fallo. sed consume toda
	# la entrada, asi que no rompe la tuberia.
	local raw version
	raw="$(nvim --version 2>/dev/null)" || {
		warn "No he podido ejecutar 'nvim --version'"
		return 1
	}
	version="$(sed -n '1s/.*[Vv]\([0-9]\+\.[0-9]\+\).*/\1/p' <<<"$raw")"

	if [[ -z "$version" ]]; then
		warn "No he podido interpretar la version de Neovim"
		return 1
	fi

	local oldest
	oldest="$(printf '%s\n%s\n' "$MIN_NVIM_VERSION" "$version" | sort -V)"
	if [[ "$(sed -n '1p' <<<"$oldest")" != "$MIN_NVIM_VERSION" ]]; then
		warn "Neovim $version detectado; LazaroBox pide >= $MIN_NVIM_VERSION"
		return 1
	fi

	ok "Neovim $version"
}

summary() {
	step "Resumen"

	check_neovim || true

	local missing=()
	local tool
	for tool in git rg fd make node npm; do
		has "$tool" || missing+=("$tool")
	done
	has magick || has convert || missing+=("imagemagick")
	has chafa || missing+=("chafa")
	has mmdc || missing+=("mmdc")

	if [[ ${#missing[@]} -eq 0 ]]; then
		ok "Todas las herramientas externas presentes"
	else
		warn "Faltan (opcionales, degradan funciones): ${missing[*]}"
	fi

	# Debian y Ubuntu LTS empaquetan versiones de node antiguas; copilot y
	# claudecode necesitan una moderna. Avisamos en vez de romper en silencio.
	if has node; then
		local node_major
		node_major="$(node --version 2>/dev/null | sed 's/^v//' | cut -d. -f1)"
		if [[ "$node_major" =~ ^[0-9]+$ ]] && ((node_major < 18)); then
			warn "Node $node_major detectado; copilot y claudecode piden >= 18"
			warn "Instala una version moderna con fnm o nvm"
		fi
	fi

	if font_installed_locally; then
		ok "$FONT_FAMILY registrada"
	elif [[ "$PLATFORM" == "macos" ]]; then
		ok "Fuente instalada en ~/Library/Fonts"
	else
		warn "$FONT_FAMILY no aparece en fc-list"
	fi

	printf '\n%s%sLazaroBox listo.%s\n\n' "$C_BOLD" "$C_GREEN" "$C_RESET"
	info "1. Selecciona '$FONT_FAMILY' como fuente de tu terminal"
	info "2. Reinicia el terminal para que cargue la fuente nueva"
	info "3. Abre nvim: los plugins se instalan solos en el primer arranque"
	info "4. Verifica todo con :checkhealth lazarobox"
	printf '\n'
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

parse_args() {
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--fonts-only) FONTS_ONLY=1 ;;
		--no-deps) SKIP_DEPS=1 ;;
		--no-link) SKIP_LINK=1 ;;
		-y | --yes) ASSUME_YES=1 ;;
		-h | --help) usage ;;
		*) die "Opcion desconocida: $1 (usa --help)" ;;
		esac
		shift
	done
}

main() {
	parse_args "$@"

	printf '%s%s\n' "$C_BOLD" "╭──────────────────────────────────────╮"
	printf '%s\n' "│  LazaroBox.nvim · instalador         │"
	printf '%s%s\n' "╰──────────────────────────────────────╯" "$C_RESET"

	detect_platform
	info "Plataforma: $PLATFORM · paquetes: $PKG_MANAGER"

	resolve_repo
	info "Repositorio: $REPO_DIR"

	if [[ $FONTS_ONLY -eq 1 ]]; then
		install_fonts
		printf '\n'
		info "Selecciona '$FONT_FAMILY' en tu terminal y reinicialo."
		printf '\n'
		return
	fi

	install_deps
	install_fonts
	link_config
	install_git_hooks
	summary
}

main "$@"
