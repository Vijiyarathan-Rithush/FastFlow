# Changelog

All notable changes to **FastFlow (ff)** will be documented in this file.

This project follows **semantic versioning**.

---

## [1.0.0] – 2025-12-01  
### Added
- Initial stable release of FastFlow
- Main branch protection system (`MAIN_PROTECTION`)
- `ff enable main` and `ff disable main` commands
- Safe push workflow (`ff push "<msg>"`)
- Rebase-based pull (`ff pull`)
- Soft reset undo (`ff undo`)
- Hard reset with confirmation (`ff hard`)
- Safe branch switching (`ff switch <branch>`)
- Branch listing (`ff branch`)
- Git info helpers (`ff status`, `ff log`, `ff reflog`)
- Automatic config initialization (~/.ffconfig)
- Helper functions: `enforce_protection`, `safe_switch_check`
- Fully documented README

---

## [Unreleased]
### Planned  
- `ff new <branch>` for creating and switching to a new branch  
- Automatic stash before switching (optional flag)  
- Interactive menu mode (`ff menu`)  
- Expanded configuration options
