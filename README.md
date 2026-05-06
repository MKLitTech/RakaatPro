# Rakat Pro

**A clean, minimal, open-source Islamic prayer times app for iPhone.**

No ads. No account. No login. Just prayer times.

> 🕌 Coming early 2026 — fully open source, 100% free, no ads. Ever.

---

## The Story

This app started as a simple idea — a prayer times app that didn't track you, didn't show you ads, and didn't make you create an account just to know when Fajr is.

The first attempt was built using **GitHub Copilot**. Four months of headaches, broken builds, half-working features, and code that made less sense every week. The project got scrapped entirely.

Then I rebuilt the whole thing from scratch using **Claude by Anthropic** — the free version. What took four months of frustration took a fraction of the time. Claude helped architect the app, fix bugs, redesign screens, and think through the UX. Every file in this project was written with Claude's help.

I'm not saying this to advertise anything. I'm saying it because it's honest — and because if you're a solo dev or a content creator trying to ship something real, the tools matter.

---

## What It Does

- **Accurate prayer times** using the [AlAdhan API](https://aladhan.com) — the same calculation engine used by major Islamic apps worldwide
- **Qibla compass** using your device's true heading, GPS-corrected when available
- **10 calculation methods** — ISNA, Muslim World League, Umm Al-Qura, Gulf, Kuwait, Qatar, Singapore, Turkey, Egypt, Karachi
- **Adhan toggle** — enable or disable prayer time alerts
- **Liquid Glass UI** for iOS 26, gracefully disabled on older devices
- **No account required** — enter your name and an optional photo, that's it
- **No ads, no analytics, no tracking of any kind**
- All data stored locally on your device

---

## Calculation Methods

| Method | Best for |
|--------|----------|
| ISNA (default) | North America |
| Muslim World League | Europe, Far East |
| Umm Al-Qura | Saudi Arabia |
| Egyptian Authority | Africa, Syria |
| Gulf Region | UAE, Bahrain |
| Kuwait | Kuwait |
| Qatar | Qatar |
| Singapore | Singapore, Malaysia |
| Turkey | Turkey |
| Karachi | Pakistan, Afghanistan, India |

---

## Tech Stack

- **SwiftUI** — iOS 17+
- **CoreLocation** — GPS coordinates and true heading
- **CoreMotion** — compass heading
- **AlAdhan API** — free, open, no API key required
- **UserDefaults / AppStorage** — fully local, no cloud

---

## License

MIT — do whatever you want with it, just don't sell it with ads.

---

## Credits

Built by **Mohammed** — [@MKLitTech](https://github.com/MKLitTech)

Prayer time calculations by [AlAdhan.com](https://aladhan.com)

Built entirely with the help of **[Claude](https://claude.ai) by Anthropic** — after 4 months of failed attempts with Copilot, Claude rebuilt the entire app from scratch. Free version, by the way.

---

*Bismillah.*
