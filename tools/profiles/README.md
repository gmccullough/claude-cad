# tools/profiles

`p2s_pla_0.20mm.json` is the stock Bambu P2S / Generic PLA / 0.20mm Standard profile (all 537
keys, lifted from a project Bambu Studio saved). `tools/bambu3mf.py` builds on it: express
project settings as overrides so the diff stays readable. See `tools/README.md`.

For another Bambu printer, save any project with that printer's preset in Bambu Studio, unzip
the `.3mf`, and copy `Metadata/project_settings.config` here as JSON.
