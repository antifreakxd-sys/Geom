#!/system/bin/sh
# VANTA GD: only download releases from GitHub; no local ~/gd_build or old .so files.
# MT Manager: copy to /data/local/tmp/gd_vanta_geom_mt.sh and execute.
# Modes: --test (network test), --install (download release + launch/inject, default)
# Owner/repository: https://github.com/antifreakxd-sys/Geom
set -eu
PATH=/system/bin:/system/xbin:/sbin:/vendor/bin:/product/bin:/data/local/tmp:/data/data/com.termux/files/usr/bin:$PATH
export PATH
APP=com.robtopx.geometryjump
REPO=antifreakxd-sys/Geom
BASE=/data/local/tmp
SELF=$BASE/gd_vanta_github_mt.sh
MOD=$BASE/libgdmenu.so
INJECTOR=$BASE/gd_frida_inject
SCRIPT=$BASE/gd_vanta_load.js
LOG=$BASE/gd_vanta_inject.log
MODE=${1:---install}
[ "$MODE" = --root-install ] && MODE=--install
fail() { echo "[ERROR] $*" >&2; exit 1; }
info() { echo "[VANTA] $*"; }

# MT Manager may run a file as a normal user even when its file manager has root.
# This tool does not use Termux's pkg, clang, ~/gd_build, or any old mod libraries.
if [ "$(id -u 2>/dev/null)" != 0 ]; then
    [ "$MODE" = --install ] || [ "$MODE" = --test ] || fail 'Используй --install или --test.'
    [ -f "$SELF" ] || fail "Положи скрипт в $SELF и запусти оттуда."
    command -v su >/dev/null 2>&1 || fail 'su не найден. Разреши root для MT Manager.'
    if [ "$MODE" = --install ]; then
        exec su -c "/system/bin/sh '$SELF' --root-install"
    else
        exec su -c "/system/bin/sh '$SELF' --test"
    fi
fi

[ -d "$BASE" ] || mkdir -p "$BASE"

fetch() {
    url=$1 output=$2
    rm -f "$output"
    case "${url}" in https://*) ;; *) fail "Разрешены только HTTPS-ссылки: $url" ;; esac
    if command -v curl >/dev/null 2>&1; then
        curl -fLsS --retry 2 --connect-timeout 15 --max-time 240 -o "$output" "$url" || return 1
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$output" "$url" || return 1
    elif command -v busybox >/dev/null 2>&1; then
        busybox wget -q -O "$output" "$url" || return 1
    else
        fail 'Нет HTTPS-загрузчика curl/wget/busybox wget. В MT Manager установи BusyBox с поддержкой HTTPS.'
    fi
    [ -s "$output" ]
}

# Actual, independent GitHub smoke test: fetch a real public project file.
check_github() {
    info 'Проверяю загрузку с GitHub (Dear ImGui)...'
    if ! fetch 'https://raw.githubusercontent.com/antifreakxd-sys/Geom/main/README.md' "$BASE/.gd_vanta_github_probe.$$"; then
        fail 'GitHub недоступен. Проверь интернет и поддержку HTTPS в curl/wget.'
    fi
    if ! grep -q 'VANTA / GD' "$BASE/.gd_vanta_github_probe.$$"; then
        rm -f "$BASE/.gd_vanta_github_probe.$$"
        fail 'GitHub вернул неожиданные данные.'
    fi
    size=$(wc -c < "$BASE/.gd_vanta_github_probe.$$" | tr -d ' ')
    rm -f "$BASE/.gd_vanta_github_probe.$$"
    info "GitHub доступен: README скачан ($size байт)."
}

check_github
[ "$MODE" = --test ] && { info 'Тест завершён успешно. Старые файлы мода не использовались.'; exit 0; }
[ "$MODE" = --install ] || fail "Неизвестная команда: $MODE"
[ "$(getprop ro.product.cpu.abi 2>/dev/null)" = arm64-v8a ] || fail 'Этот вариант рассчитан только на Android ARM64.'

# Download mod from GitHub Releases instead of reading the previous local .so.
RELEASE="https://github.com/$REPO/releases/download/vanta-auto"
info "Скачиваю свежую библиотеку из GitHub: $REPO"
TMPMOD=$BASE/.libgdmenu.download.$$.so
TMPSHA=$BASE/.libgdmenu.download.$$.sha256
TMPAPI=$BASE/.frida.release.$$.json
TMPXZ=$BASE/.frida.inject.$$.xz
TMPBIN=$BASE/.frida.inject.$$
cleanup() { rm -f "$TMPMOD" "$TMPSHA" "$TMPAPI" "$TMPXZ" "$TMPBIN"; }
trap cleanup EXIT HUP INT TERM
if ! fetch "$RELEASE/libgdmenu.so" "$TMPMOD"; then
    echo ''
    echo "[NOT READY] Нет опубликованной библиотеки:"
    echo "  $RELEASE/libgdmenu.so"
    echo 'В репозитории Geom пока нет успешно собранного GitHub Release.'
    echo 'Проверь сборку: https://github.com/antifreakxd-sys/Geom/actions'
    echo 'После успешной сборки Actions автоматически опубликует необходимые файлы.'
    exit 2
fi
if ! fetch "$RELEASE/libgdmenu.so.sha256" "$TMPSHA"; then
    fail 'Для безопасной установки нужен файл libgdmenu.so.sha256 в том же GitHub Release.'
fi
if ! command -v sha256sum >/dev/null 2>&1; then
    fail 'На устройстве нет sha256sum для проверки библиотеки.'
fi
expected=$(sed -n '1s/[[:space:]].*//p' "$TMPSHA" | tr 'A-F' 'a-f')
case "$expected" in
    ''|*[!0123456789abcdef]*) fail 'Неправильный SHA-256 в файле с GitHub.' ;;
esac
[ "${#expected}" -eq 64 ] || fail 'SHA-256 должен содержать 64 символа.'
actual=$(sha256sum "$TMPMOD" | sed 's/[[:space:]].*//')
[ "$actual" = "$expected" ] || fail 'Хеш скачанной libgdmenu.so не совпал!'
if command -v od >/dev/null 2>&1; then
    magic=$(od -An -tx1 -N4 "$TMPMOD" | tr -d ' \r\n')
    [ "$magic" = 7f454c46 ] || fail 'Скачан не ELF-файл.'
fi
if command -v readelf >/dev/null 2>&1; then
    readelf -h "$TMPMOD" | grep -q 'AArch64' || fail 'Неверная архитектура библиотеки (нужна AArch64).'
fi
# Replace only after full download+verification; do not consume an existing mod.
mv -f "$TMPMOD" "$MOD"
chmod 755 "$MOD"
restorecon "$MOD" >/dev/null 2>&1 || true
info "Новая библиотека из GitHub: $MOD"

# Download an independent arm64 Frida injector from the official GitHub project.
info 'Проверяю Frida из официального GitHub...'
fetch 'https://api.github.com/repos/frida/frida/releases/latest' "$TMPAPI" || fail 'Не могу получить релиз Frida с GitHub.'
VERSION=$(sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$TMPAPI" | head -n 1)
case "$VERSION" in ''|*[!0-9a-zA-Z._-]*) fail 'Неправильная версия Frida в GitHub API.' ;; esac
FRIDA_URL="https://github.com/frida/frida/releases/download/$VERSION/frida-inject-$VERSION-android-arm64.xz"
fetch "$FRIDA_URL" "$TMPXZ" || fail "Не удалось скачать frida-inject $VERSION с GitHub."
if command -v xz >/dev/null 2>&1; then
    xz -dc "$TMPXZ" > "$TMPBIN" || fail 'Не удалось распаковать frida-inject (xz).'
elif command -v xzcat >/dev/null 2>&1; then
    xzcat "$TMPXZ" > "$TMPBIN" || fail 'Не удалось распаковать frida-inject (xzcat).'
elif command -v busybox >/dev/null 2>&1 && busybox --list 2>/dev/null | grep -q '^unxz$'; then
    busybox unxz -c "$TMPXZ" > "$TMPBIN" || fail 'Не удалось распаковать frida-inject (busybox).'
else
    fail 'Для Frida нужна распаковка XZ (xz, xzcat или BusyBox с unxz).'
fi
[ -s "$TMPBIN" ] || fail 'frida-inject пустой.'
mv -f "$TMPBIN" "$INJECTOR"
chmod 755 "$INJECTOR"
restorecon "$INJECTOR" >/dev/null 2>&1 || true
info "Инжектор загружен из GitHub: Frida $VERSION"

# Minimal loader generated from this script, never borrowed from old project.
cat > "$SCRIPT" <<'JS'
setImmediate(function () {
    try {
        var lib = Module.load('/data/local/tmp/libgdmenu.so');
        console.log('GD_MOD_LOADED: ' + lib.name);
    } catch (e) {
        console.error('GD_MOD_ERROR: ' + e);
    }
});
JS
chmod 644 "$SCRIPT"

getpid() { pidof "$APP" 2>/dev/null | sed 's/ .*//'; }
PID=$(getpid)
if [ -z "$PID" ]; then
    info 'Запускаю Geometry Dash...'
    monkey -p "$APP" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 || \
        am start -n "$APP/com.robtopx.geometryjump.GeometryJump" >/dev/null 2>&1 || true
    i=0
    while [ "$i" -lt 125 ]; do
        PID=$(getpid)
        [ -n "$PID" ] && break
        sleep 0.2
        i=$((i+1))
    done
fi
[ -n "$PID" ] || fail 'Процесс Geometry Dash не найден.'
if grep -Fq 'libgdmenu.so' "/proc/$PID/maps" 2>/dev/null; then
    info 'Мод уже подключён к запущенной игре. Для обновления перезапусти игру.'
    exit 0
fi
# Wait until native game code is loaded (no fixed 6-second pause).
i=0
while [ "$i" -lt 60 ]; do
    grep -Fq 'libcocos2dcpp.so' "/proc/$PID/maps" 2>/dev/null && break
    sleep 0.2
    i=$((i+1))
done
info "Подключаю скачанную библиотеку к PID=$PID"
: > "$LOG"
if command -v nohup >/dev/null 2>&1; then
    nohup "$INJECTOR" -p "$PID" -s "$SCRIPT" >"$LOG" 2>&1 </dev/null &
else
    "$INJECTOR" -p "$PID" -s "$SCRIPT" >"$LOG" 2>&1 </dev/null &
fi
i=0
while [ "$i" -lt 75 ]; do
    if grep -q 'GD_MOD_LOADED' "$LOG" 2>/dev/null || grep -Fq 'libgdmenu.so' "/proc/$PID/maps" 2>/dev/null; then
        info 'Мод загружен. Все библиотеки взяты из GitHub.'
        exit 0
    fi
    if grep -q 'GD_MOD_ERROR' "$LOG" 2>/dev/null; then
        tail -n 15 "$LOG" >&2
        fail 'Библиотека не загрузилась.'
    fi
    [ -d "/proc/$PID" ] || fail 'Игра закрылась во время внедрения.'
    sleep 0.2
    i=$((i+1))
done
[ -f "$LOG" ] && tail -n 20 "$LOG" >&2
fail "Подтверждение внедрения не получено. Лог: $LOG"