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

-- Moore's Creek Bridge (level 4): same as Great Bridge for now. The design
-- notes call this the artillery-payoff level, so artillery may deepen later.
INSERT INTO level_tower_unlock (id, level_info_id, tower_kind, max_tower_level) VALUES
('20d6a049-b026-450b-a413-3f101757df31', (SELECT id FROM level_info WHERE level_name = 'Moore''s Creek Bridge'), 'ranged', 3),
('b7e57218-ce25-4de3-a896-bd9285c7081b', (SELECT id FROM level_info WHERE level_name = 'Moore''s Creek Bridge'), 'melee', 2),
('d1924daf-13e0-4835-9684-7eeebac43053', (SELECT id FROM level_info WHERE level_name = 'Moore''s Creek Bridge'), 'artillery', 1);

-- Long Island (level 5): same as Great Bridge for now.
INSERT INTO level_tower_unlock (id, level_info_id, tower_kind, max_tower_level) VALUES
('1fde7bd4-ad8b-47d7-b850-8bae80d4b0ee', (SELECT id FROM level_info WHERE level_name = 'Long Island'), 'ranged', 3),
('4148872a-e51e-468c-b56f-d8983f5b851d', (SELECT id FROM level_info WHERE level_name = 'Long Island'), 'melee', 2),
('d59c732f-c0f5-4d6f-822b-0d5611104816', (SELECT id FROM level_info WHERE level_name = 'Long Island'), 'artillery', 1);

-- Trenton (level 6): same as Great Bridge for now.
INSERT INTO level_tower_unlock (id, level_info_id, tower_kind, max_tower_level) VALUES
('10099bf9-a788-47b2-8f36-3ec6ef963545', (SELECT id FROM level_info WHERE level_name = 'Trenton'), 'ranged', 3),
('6fdc2d3d-a8a3-4af5-af16-ff90dbc07364', (SELECT id FROM level_info WHERE level_name = 'Trenton'), 'melee', 2),
('7b4b3249-11b2-4bd0-8a39-aa377f355f08', (SELECT id FROM level_info WHERE level_name = 'Trenton'), 'artillery', 1);

-- Princeton (level 7): same as Great Bridge for now.
INSERT INTO level_tower_unlock (id, level_info_id, tower_kind, max_tower_level) VALUES
('68c1e463-bd20-4f76-a19d-2d6db044770b', (SELECT id FROM level_info WHERE level_name = 'Princeton'), 'ranged', 3),
('e62de2ae-f72b-4bd6-8cf2-17ae1cf26882', (SELECT id FROM level_info WHERE level_name = 'Princeton'), 'melee', 2),
('e105b05c-8756-42d5-94bc-3418a4654f1d', (SELECT id FROM level_info WHERE level_name = 'Princeton'), 'artillery', 1);

-- Charleston (level 14): placeholder unlocks, same as Great Bridge for now.
INSERT INTO level_tower_unlock (id, level_info_id, tower_kind, max_tower_level) VALUES
('60750eaf-2063-401c-bc17-24a98cd69342', (SELECT id FROM level_info WHERE level_name = 'Charleston'), 'ranged', 3),
('f32c3a19-6e40-4261-8e06-a377556904e1', (SELECT id FROM level_info WHERE level_name = 'Charleston'), 'melee', 2),
('fcfb5d8b-245a-49cb-823b-fb55cbf62bcb', (SELECT id FROM level_info WHERE level_name = 'Charleston'), 'artillery', 1);
