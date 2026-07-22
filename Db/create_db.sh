rm redcoat_raid.sqlite 2>/dev/null
sqlite3 redcoat_raid.sqlite ""

sqlite3 redcoat_raid.sqlite < DDL/create_tables.sql
sqlite3 redcoat_raid.sqlite < DML/campaigns.sql
sqlite3 redcoat_raid.sqlite < DML/level_tower_slots.sql
sqlite3 redcoat_raid.sqlite < DML/enemy_types.sql
sqlite3 redcoat_raid.sqlite < DML/level_paths.sql

# cp redcoat_raid.sqlite "../Tests App/Resources/Db/test_redcoat_raid.sqlite"

# Simulator
cp -f redcoat_raid.sqlite ~/Documents/redcoat_raid.sqlite
# cp -f redcoat_raid.sqlite ~/Documents/redcoat-raid-simulations.sqlite
