#!/usr/bin/env python3
"""
update_translations.py — bulk-add or replace translations in Localizable.xcstrings.

Run from project root:
    python3 Scripts/update_translations.py

The xcstrings file is sorted by key by Xcode itself when it opens, so we
don't bother sorting here.
"""

import json
import sys
from collections import OrderedDict
from pathlib import Path

XCSTRINGS = Path(__file__).resolve().parent.parent \
    / "CleanYourBoard - Keyboard Cleaner" / "Localizable.xcstrings"

LANGS = ["en", "de", "fr", "es", "it", "ja", "zh-Hans"]

TRANSLATIONS = {
    "Unlock keyboard": {
        "en": "Unlock keyboard",
        "de": "Tastatur entsperren",
        "fr": "Déverrouiller le clavier",
        "es": "Desbloquear teclado",
        "it": "Sblocca tastiera",
        "ja": "キーボードのロックを解除",
        "zh-Hans": "解锁键盘",
    },
    "Keyboard unlocked": {
        "en": "Keyboard unlocked",
        "de": "Tastatur entsperrt",
        "fr": "Clavier déverrouillé",
        "es": "Teclado desbloqueado",
        "it": "Tastiera sbloccata",
        "ja": "キーボードのロックが解除されました",
        "zh-Hans": "键盘已解锁",
    },
    "Show window": {
        "en": "Show window",
        "de": "Fenster anzeigen",
        "fr": "Afficher la fenêtre",
        "es": "Mostrar ventana",
        "it": "Mostra finestra",
        "ja": "ウィンドウを表示",
        "zh-Hans": "显示窗口",
    },
    "Settings…": {
        "en": "Settings…",
        "de": "Einstellungen…",
        "fr": "Réglages…",
        "es": "Ajustes…",
        "it": "Impostazioni…",
        "ja": "設定…",
        "zh-Hans": "设置…",
    },
    "Quit CleanYourBoard": {
        "en": "Quit CleanYourBoard",
        "de": "CleanYourBoard beenden",
        "fr": "Quitter CleanYourBoard",
        "es": "Salir de CleanYourBoard",
        "it": "Esci da CleanYourBoard",
        "ja": "CleanYourBoard を終了",
        "zh-Hans": "退出 CleanYourBoard",
    },
    "General": {
        "en": "General",
        "de": "Allgemein",
        "fr": "Général",
        "es": "General",
        "it": "Generale",
        "ja": "一般",
        "zh-Hans": "通用",
    },
    "Updates": {
        "en": "Updates",
        "de": "Updates",
        "fr": "Mises à jour",
        "es": "Actualizaciones",
        "it": "Aggiornamenti",
        "ja": "アップデート",
        "zh-Hans": "更新",
    },
    "Changing the language requires CleanYourBoard to restart.": {
        "en": "Changing the language requires CleanYourBoard to restart.",
        "de": "Beim Sprachwechsel muss CleanYourBoard neu gestartet werden.",
        "fr": "Le changement de langue nécessite le redémarrage de CleanYourBoard.",
        "es": "Cambiar el idioma requiere reiniciar CleanYourBoard.",
        "it": "La modifica della lingua richiede il riavvio di CleanYourBoard.",
        "ja": "言語の変更には CleanYourBoard の再起動が必要です。",
        "zh-Hans": "切换语言需要重新启动 CleanYourBoard。",
    },
    "Match the system setting or pick light or dark explicitly.": {
        "en": "Match the system setting or pick light or dark explicitly.",
        "de": "Folge der Systemeinstellung oder wähle Hell oder Dunkel explizit.",
        "fr": "Suivre les réglages du système ou choisir clair ou sombre.",
        "es": "Seguir el ajuste del sistema o elegir claro u oscuro.",
        "it": "Segui l’impostazione di sistema o scegli chiaro o scuro.",
        "ja": "システム設定に従うか、ライトかダークを明示的に選択します。",
        "zh-Hans": "跟随系统设置，或显式选择浅色或深色。",
    },
    "Automatically check for updates": {
        "en": "Automatically check for updates",
        "de": "Automatisch nach Updates suchen",
        "fr": "Rechercher automatiquement les mises à jour",
        "es": "Buscar actualizaciones automáticamente",
        "it": "Cerca aggiornamenti automaticamente",
        "ja": "アップデートを自動的に確認",
        "zh-Hans": "自动检查更新",
    },
    "Automatically download and install updates": {
        "en": "Automatically download and install updates",
        "de": "Updates automatisch laden und installieren",
        "fr": "Télécharger et installer les mises à jour automatiquement",
        "es": "Descargar e instalar actualizaciones automáticamente",
        "it": "Scarica e installa gli aggiornamenti automaticamente",
        "ja": "アップデートを自動的にダウンロードしてインストール",
        "zh-Hans": "自动下载并安装更新",
    },
    "CleanYourBoard checks the official update feed; no other data is sent.": {
        "en": "CleanYourBoard checks the official update feed; no other data is sent.",
        "de": "CleanYourBoard prüft nur den offiziellen Update-Feed; keine anderen Daten werden gesendet.",
        "fr": "CleanYourBoard vérifie uniquement le flux de mise à jour officiel ; aucune autre donnée n’est envoyée.",
        "es": "CleanYourBoard solo consulta el feed oficial de actualizaciones; no se envía ningún otro dato.",
        "it": "CleanYourBoard verifica solo il feed ufficiale degli aggiornamenti; nessun altro dato viene inviato.",
        "ja": "CleanYourBoard は公式のアップデートフィードのみを確認します。他のデータは送信されません。",
        "zh-Hans": "CleanYourBoard 仅查询官方更新源；不会发送任何其他数据。",
    },
    "Check now": {
        "en": "Check now",
        "de": "Jetzt prüfen",
        "fr": "Vérifier maintenant",
        "es": "Comprobar ahora",
        "it": "Verifica ora",
        "ja": "今すぐ確認",
        "zh-Hans": "立即检查",
    },
    "Settings": {
        "en": "Settings",
        "de": "Einstellungen",
        "fr": "Réglages",
        "es": "Ajustes",
        "it": "Impostazioni",
        "ja": "設定",
        "zh-Hans": "设置",
    },
    "Open settings": {
        "en": "Open settings",
        "de": "Einstellungen öffnen",
        "fr": "Ouvrir les réglages",
        "es": "Abrir ajustes",
        "it": "Apri impostazioni",
        "ja": "設定を開く",
        "zh-Hans": "打开设置",
    },
    "Enjoying CleanYourBoard?": {
        "en": "Enjoying CleanYourBoard?",
        "de": "Gefällt dir CleanYourBoard?",
        "fr": "Vous aimez CleanYourBoard ?",
        "es": "¿Te gusta CleanYourBoard?",
        "it": "Ti piace CleanYourBoard?",
        "ja": "CleanYourBoard は気に入りましたか？",
        "zh-Hans": "喜欢 CleanYourBoard 吗？",
    },
    "A GitHub star helps others find the app.": {
        "en": "A GitHub star helps others find the app.",
        "de": "Ein Stern auf GitHub hilft anderen, die App zu finden.",
        "fr": "Une étoile sur GitHub aide les autres à découvrir l’app.",
        "es": "Una estrella en GitHub ayuda a otros a descubrir la app.",
        "it": "Una stella su GitHub aiuta gli altri a trovare l’app.",
        "ja": "GitHub のスターは、他の人がアプリを見つけるのに役立ちます。",
        "zh-Hans": "在 GitHub 上点亮一颗星，帮助更多人发现这款 App。",
    },
    "Star on GitHub": {
        "en": "Star on GitHub",
        "de": "Auf GitHub mit Stern markieren",
        "fr": "Mettre une étoile sur GitHub",
        "es": "Dar estrella en GitHub",
        "it": "Metti una stella su GitHub",
        "ja": "GitHub でスターを付ける",
        "zh-Hans": "在 GitHub 上加星",
    },
    "No thanks": {
        "en": "No thanks",
        "de": "Nein danke",
        "fr": "Non merci",
        "es": "No, gracias",
        "it": "No grazie",
        "ja": "今はしない",
        "zh-Hans": "不用了",
    },
}


def main() -> int:
    if not XCSTRINGS.exists():
        print(f"Catalog not found at {XCSTRINGS}")
        return 1

    with XCSTRINGS.open("r", encoding="utf-8") as f:
        catalog = json.load(f, object_pairs_hook=OrderedDict)

    strings = catalog.setdefault("strings", OrderedDict())
    added = 0
    updated = 0

    for key, by_lang in TRANSLATIONS.items():
        entry = strings.get(key)
        is_new = entry is None or not entry
        entry = OrderedDict()
        entry["extractionState"] = "manual"
        loc = OrderedDict()
        for lang in LANGS:
            value = by_lang.get(lang)
            if value is None:
                continue
            loc[lang] = OrderedDict(
                stringUnit=OrderedDict(state="translated", value=value)
            )
        entry["localizations"] = loc
        strings[key] = entry
        if is_new:
            added += 1
        else:
            updated += 1

    catalog["strings"] = OrderedDict(sorted(strings.items(), key=lambda kv: kv[0]))

    with XCSTRINGS.open("w", encoding="utf-8") as f:
        json.dump(catalog, f, ensure_ascii=False, indent=2)
        f.write("\n")

    print(f"Wrote {XCSTRINGS}")
    print(f"  added:   {added}")
    print(f"  updated: {updated}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
