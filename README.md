# VANTA / GD — Android ARM64

Исходный код современного ImGui-меню для Geometry Dash. Без функции выбора фотографий.

## Автоматическая сборка

Каждый push в main запускает GitHub Actions: Android NDK + Dear ImGui v1.91.9b → ARM64 `libgdmenu.so`.
После успешной сборки workflow публикует `libgdmenu.so` и `libgdmenu.so.sha256` в GitHub Release `vanta-auto`.

Последний опубликованный файл: https://github.com/antifreakxd-sys/Geom/releases/latest/download/libgdmenu.so

## MT Manager

Скачай `gd_vanta_github_mt.sh`, положи в `/data/local/tmp/` и запускай через MT Manager c root.
Скрипт не читает `~/gd_build`: получает библиотеку с GitHub Release и Frida из официального GitHub, проверяет SHA-256 и подключает к процессу Geometry Dash.

## Ограничения

Экспериментальная сборка ARM64. Никакой APK не перепаковывается. Функции хука зависят от версии и экспорта символов `libcocos2dcpp.so`. Без внешних `.bro` offsets.h содержит только нулевые fallback-адреса. Не гарантируется работа на каждой версии игры; оставь резервную копию и тестируй.

Лицензия Dear ImGui: MIT, upstream https://github.com/ocornut/imgui.
