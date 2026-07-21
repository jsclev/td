rm redcoat_raid.sqlite 2>/dev/null
sqlite3 redcoat_raid.sqlite ""

# sqlite3 redcoat_raid.sqlite < drop-all-tables.sql
sqlite3 redcoat_raid.sqlite < create_tables.sql
sqlite3 redcoat_raid.sqlite < populate_baseline_data.sql

# cp redcoat_raid.sqlite "../Tests App/Resources/Db/test_redcoat_raid.sqlite"

# CLI Simulator
# FIXME Need to figure out where to actually put/bundle the database file for the CLI simulator
cp -f redcoat_raid.sqlite ~/Documents/redcoat_raid.sqlite
# cp -f redcoat_raid.sqlite ~/Documents/stone-to-space-simulations.sqlite
