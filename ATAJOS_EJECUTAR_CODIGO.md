# Atajos de LazaroBox.nvim

Esta es la guia de control de keymaps. El objetivo no es memorizarlo todo: es saber que existe, donde buscarlo y que prefijo toca cada area.

## Camino rapido

1. Pulsa `<leader>` y espera un momento para ver los grupos disponibles con Which-Key.
2. Usa `<leader>fk` para buscar cualquier atajo por nombre con Telescope.
3. Usa `:Keymaps` si prefieres abrir el buscador como comando.
4. Usa `:map <atajo>` si necesitas comprobar exactamente que comando ejecuta Neovim.

`<leader>` suele ser `Space`. Compruebalo con `:echo mapleader` si tienes dudas.

## Mapa mental

| Prefijo | Area | Uso principal |
| --- | --- | --- |
| `<leader>a` | AI | Claude / Avante |
| `<leader>b` | Buffers | Cerrar o saltar a buffers |
| `<leader>c` | Code docs | Generar documentacion con Neogen |
| `<leader>f` | Find | Buscar archivos, config, keymaps |
| `<leader>g` | Git | Comandos Git locales con Fugitive |
| `<leader>G` | GitHub | Issues y pull requests con Snacks |
| `<leader>h` | Harpoon / hunks | Harpoon y acciones de Gitsigns |
| `<leader>i` | Imagenes / REPL | Preview de imagen y REPL helpers |
| `<leader>l` | LSP / lint / format | Diagnosticos, linting y formato |
| `<leader>L` | Live server | Servidor web local |
| `<leader>m` | Media | Abrir PDF/video externo |
| `<leader>r` | Run snippets | SnipRun |
| `<leader>R` | Rust | Diagnosticos Rust buffer-locales |
| `<leader>s` | Search | Busquedas en buffers/proyecto |
| `<leader>t` | Terminal | ToggleTerm |
| `<leader>w` | Windows | Splits y cierre de ventanas |
| `<leader>x` | Execute file | Ejecutar archivo actual |

## Descubrimiento

| Atajo | Accion |
| --- | --- |
| `<leader>?` | Muestra keymaps del buffer actual |
| `<leader>fk` | Busca todos los keymaps con Telescope |
| `:Keymaps` | Abre el mismo buscador de keymaps desde comandos |
| Dashboard `k` | Abre el buscador de keymaps desde la pantalla inicial |
| `<leader><space>` | Smart find files |
| `<leader>,` | Buffers abiertos |
| `<leader>/` | Grep del proyecto |
| `<leader>:` | Historial de comandos |
| `<leader>n` | Historial de notificaciones |
| `<leader>e` | Explorador de archivos |

## Edicion basica

| Atajo | Accion |
| --- | --- |
| `<A-j>` | Mueve linea o seleccion hacia abajo |
| `<A-k>` | Mueve linea o seleccion hacia arriba |
| `<leader>y` | Copia al portapapeles del sistema |
| `<leader>Y` | Copia la linea al portapapeles del sistema |
| `<leader>p` | Pega desde el portapapeles del sistema despues |
| `<leader>P` | Pega desde el portapapeles del sistema antes |

## Ventanas y buffers

| Atajo | Accion |
| --- | --- |
| `<C-h>` | Ir a ventana izquierda |
| `<C-j>` | Ir a ventana inferior |
| `<C-k>` | Ir a ventana superior |
| `<C-l>` | Ir a ventana derecha |
| `<leader>wv` | Split vertical |
| `<leader>wh` | Split horizontal |
| `<leader>wq` | Cerrar ventana |
| `<Tab>` | Buffer siguiente |
| `<S-Tab>` | Buffer anterior |
| `gb` | Buffer siguiente |
| `gB` | Buffer anterior |
| `<leader>bc` | Cerrar buffer |
| `<leader>b1` ... `<leader>b5` | Saltar a buffer 1-5 |

## Buscar

| Atajo | Accion |
| --- | --- |
| `<leader>ff` | Buscar archivos |
| `<leader>fg` | Buscar archivos de Git |
| `<leader>fb` | Buscar buffers |
| `<leader>fc` | Buscar archivos de config |
| `<leader>fp` | Buscar proyectos |
| `<leader>fr` | Archivos recientes |
| `<leader>sb` | Lineas del buffer actual |
| `<leader>sB` | Grep en buffers abiertos |
| `<leader>sg` | Grep del proyecto |
| `<leader>sw` | Buscar palabra o seleccion visual |

## LSP, lint y formato

| Atajo | Accion |
| --- | --- |
| `K` | Documentacion hover |
| `gd` | Ir a definicion |
| `gr` | Buscar referencias |
| `<leader>rn` | Renombrar simbolo |
| `<leader>ca` | Code action |
| `<leader>ld` | Detalle del diagnostico actual |
| `[d` | Diagnostico anterior |
| `]d` | Diagnostico siguiente |
| `<leader>lq` | Lista de diagnosticos |
| `<leader>ll` | Ejecutar lint |
| `<leader>li` | Info de linters |
| `<leader>lf` | Formatear archivo o rango visual |
| `<leader>lF` | Ver estado de format on save |
| `<leader>lb` | Formatear con Biome |
| `<leader>lp` | Formatear con Prettier |

## Ejecutar codigo

| Atajo | Accion | Cuándo usarlo |
| --- | --- | --- |
| `<leader>x` | Ejecuta archivo inline | Resultado rapido, vuelve al editor con Enter |
| `<leader>xx` | Ejecuta archivo en terminal flotante | Recomendado para programar y ver salida persistente |
| `<leader>vd` | Ejecuta `npm run dev` en split | Proyectos Vite/frontend |
| `<C-t>` | Abre/cierra terminal flotante | Terminal manual |
| `<leader>tt` | Toggle terminal | Alternativa explicita a `<C-t>` |
| `<leader>tq` | Cierra terminal | Cuando quieres limpiar pantalla |

El ejecutor de archivo soporta Python, JavaScript, TypeScript, Lua, Bash, Java, Rust, SQL y HTML. Para Rust, si encuentra `Cargo.toml`, intenta usar `cargo run --bin`; si no, cae a `rustc`.

## SnipRun

| Atajo | Accion |
| --- | --- |
| `<leader>r` | Ejecutar linea actual |
| Visual + `<leader>r` | Ejecutar seleccion |
| `<leader>rr` | Operador de ejecucion |
| `<leader>rf` | Ejecutar archivo completo |
| `<leader>rc` | Cerrar resultado de SnipRun |
| `<leader>ri` | Info de SnipRun |
| `<leader>rl` | Modo live |

## Iron REPL

| Atajo | Accion |
| --- | --- |
| `<leader>py` | Abrir REPL Python |
| `<leader>js` | Abrir REPL JavaScript |
| `<leader>ts` | Abrir REPL TypeScript |
| `<leader>ir` | Reiniciar REPL |
| `<leader>ih` | Ocultar REPL |
| `<space>sl` | Enviar linea al REPL |
| `<space>sc` | Enviar movimiento o seleccion |
| `<space>sf` | Enviar archivo completo |
| `<space>sp` | Enviar parrafo |
| `<space>su` | Enviar desde inicio hasta cursor |
| `<space>cl` | Limpiar REPL |
| `<space>sq` | Salir del REPL |

## Git y GitHub

| Atajo | Accion |
| --- | --- |
| `<leader>gs` | Git status |
| `<leader>gc` | Git commit |
| `<leader>gca` | Git commit amend |
| `<leader>gp` | Git push |
| `<leader>gP` | Git pull |
| `<leader>gf` | Git fetch |
| `<leader>gd` | Git diff |
| `<leader>gb` | Git blame |
| `<leader>gl` | Git log corto |
| `<leader>gL` | Git log completo |
| `<leader>gB` | Git branches |
| `<leader>gco` | Git checkout |
| `<leader>ga` | Git add archivo actual |
| `<leader>gA` | Git add todo |
| `<leader>gss` | Git stash |
| `<leader>gsp` | Git stash pop |
| `<leader>gm` | Git merge |
| `<leader>gr` | Git rebase |
| `<leader>go` | Abrir en GitHub/browser |
| `<leader>Gi` | GitHub issues abiertos |
| `<leader>Ga` | GitHub issues todos |
| `<leader>Gp` | GitHub pull requests abiertos |
| `<leader>GP` | GitHub pull requests todos |

## Harpoon y hunks

| Atajo | Accion |
| --- | --- |
| `<leader>ha` | Anadir archivo a Harpoon |
| `<leader>hh` | Menu de Harpoon |
| `<leader>1` ... `<leader>4` | Saltar a archivo Harpoon 1-4 |
| `<leader>hn` | Siguiente archivo Harpoon |
| `<leader>hp` | Archivo anterior Harpoon |
| `]h` | Siguiente hunk |
| `[h` | Hunk anterior |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage buffer |
| `<leader>hR` | Reset buffer |
| `<leader>hu` | Undo stage hunk |
| `<leader>hP` | Preview hunk |
| `<leader>hd` | Diff this |
| `<leader>hD` | Diff contra `~` |
| `<leader>hb` | Blame line completo |
| `<leader>htb` | Toggle blame line |
| `<leader>htd` | Toggle deleted |

## AI y documentacion

| Atajo | Accion |
| --- | --- |
| `<leader>ac` | Toggle Claude |
| Visual + `<leader>as` | Enviar seleccion a Claude |
| `<leader>aa` | Preguntar a Avante |
| Visual + `<leader>aa` | Preguntar a Avante sobre seleccion |
| Visual + `<leader>ae` | Editar seleccion con Avante |
| `<leader>at` | Toggle sidebar Avante |
| `<leader>ar` | Refrescar Avante |
| `<leader>af` | Enfocar sidebar Avante |
| `<leader>cd` | Generar doc de funcion actual |
| `<leader>cD` | Generar doc de clase/tipo |
| `<leader>cf` | Generar doc de archivo |

## Rust

Estos keymaps son buffer-locales: aparecen en buffers Rust cuando `rustaceanvim` se adjunta.

| Atajo | Accion |
| --- | --- |
| `<leader>Rd` | Ver diagnostico Rust |
| `<leader>Rj` | Siguiente diagnostico Rust |
| `<leader>Rk` | Diagnostico Rust anterior |
| `<leader>Rq` | Lista de diagnosticos Rust |
| `<leader>Rc` | Ejecutar `RustLsp flyCheck run` |

## Media y web

| Atajo | Accion |
| --- | --- |
| `<leader>Ls` | Iniciar live-server y abrir navegador en `http://localhost:5500` |
| `<leader>Lx` | Detener live-server |
| `<leader>mp` | Abrir PDF externo |
| `<leader>mv` | Abrir video externo |
| `<leader>ip` | Previsualizar imagen bajo el cursor |

## Terminal mode

| Atajo | Accion |
| --- | --- |
| `<Esc>` | Salir de modo terminal |
| `<C-t>` | Cerrar/ocultar terminal |
| `<C-q>` | Cerrar terminal |
| `<C-h>` | Ir a ventana izquierda |
| `<C-j>` | Ir a ventana inferior |
| `<C-k>` | Ir a ventana superior |
| `<C-l>` | Ir a ventana derecha |

## Politica para nuevos keymaps

1. Todo keymap nuevo debe tener `desc` clara.
2. No reutilices un prefijo si ya pertenece a otra area.
3. Si un plugin ya registra un grupo, documentalo aqui o cambialo antes de anadir otro.
4. Ejecuta `<leader>fk` y busca el atajo antes de crear uno nuevo.
5. Si hay conflicto, primero decide que comportamiento debe quedarse; despues documenta.
