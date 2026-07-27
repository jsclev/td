-- Tower unlock progression per level. A kind with no row is locked on that
-- level; max_tower_level is how far it may be upgraded there.
--
-- Level 1 (Lexington): ranged and melee, one upgrade each (to level 2).
-- Level 2 (Bunker Hill): artillery unlocks (build only).
-- Level 3 (Great Bridge): ranged opens to level 3 -- the riflemen level,
-- teaching enfilade fire on the causeway, as at the historical battle.
INSERT INTO level_tower_unlock (id, level_info_id, tower_kind, max_tower_level) VALUES
('ec49efb7-3ead-4880-ab05-3a93c4271ca4', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 'ranged', 2),
('5f7a784f-dae1-4660-8da7-31ac09d18429', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 'melee', 2),
('935b8ec2-7b93-493c-8138-9c1a3d7a966a', (SELECT id FROM level_info WHERE level_name = 'Bunker Hill'), 'ranged', 2),
('e823e982-0a16-44c2-889c-8c791a5a57e9', (SELECT id FROM level_info WHERE level_name = 'Bunker Hill'), 'melee', 2),
('d644d655-97a6-4737-ac48-38321c70a76e', (SELECT id FROM level_info WHERE level_name = 'Bunker Hill'), 'artillery', 1),
('f56615bd-bcff-4643-9e2d-31998f419319', (SELECT id FROM level_info WHERE level_name = 'Great Bridge'), 'ranged', 3),
('f3c1999c-d0ee-4ff1-aa92-b37cd211f7c0', (SELECT id FROM level_info WHERE level_name = 'Great Bridge'), 'melee', 2),
('7bc4e586-cd74-419d-8597-26eaf4bdcdcd', (SELECT id FROM level_info WHERE level_name = 'Great Bridge'), 'artillery', 1);
