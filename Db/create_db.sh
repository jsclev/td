rm redcoat_raid.sqlite 2>/dev/null
sqlite3 redcoat_raid.sqlite ""

sqlite3 redcoat_raid.sqlite < DDL/create_tables.sql
sqlite3 redcoat_raid.sqlite < DML/campaigns.sql
sqlite3 redcoat_raid.sqlite < DML/level_tower_slots.sql
sqlite3 redcoat_raid.sqlite < DML/level_tower_unlocks.sql
sqlite3 redcoat_raid.sqlite < DML/enemy_types.sql
sqlite3 redcoat_raid.sqlite < DML/level_paths.sql
sqlite3 redcoat_raid.sqlite < DML/dorchester_heights_level.sql
sqlite3 redcoat_raid.sqlite < DML/sullivans_island_level.sql
sqlite3 redcoat_raid.sqlite < DML/fort_ann_level.sql
sqlite3 redcoat_raid.sqlite < DML/saratoga_level.sql
sqlite3 redcoat_raid.sqlite < DML/kettle_creek_level.sql
sqlite3 redcoat_raid.sqlite < DML/new_haven_level.sql
sqlite3 redcoat_raid.sqlite < DML/savannah_level.sql

# cp redcoat_raid.sqlite "../Tests App/Resources/Db/test_redcoat_raid.sqlite"

# Simulator
cp -f redcoat_raid.sqlite ~/Documents/redcoat_raid.sqlite
# cp -f redcoat_raid.sqlite ~/Documents/redcoat-raid-simulations.sqlite
