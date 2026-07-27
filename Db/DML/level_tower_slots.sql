INSERT INTO tower_slot (id, level_info_id, map_position_x, map_position_y) VALUES
('9dcef9c8-fa3c-4d26-ad86-ae80c5fd8b20', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 1080.0, 669.0),
('7e382b1a-9fdc-4ef0-979b-158b300672b3', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 921.0, 454.0),
('93bd8328-7778-415f-8c98-a22dd53c01d1', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 656.0, 565.0),
('60b75c75-5483-4053-8a6e-98248ab16f4d', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 492.0, 578.0),
('20bcc452-1bb7-4b82-939d-12d0c18a4f70', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 485.0, 579.0);

-- Bunker Hill: the ten numbered platforms painted on the map (slot order
-- follows the art's badge numbers 1-10).
INSERT INTO tower_slot (id, level_info_id, map_position_x, map_position_y) VALUES
('abb1fbb8-2523-4ac6-93ef-de922b44aa01', (SELECT id FROM level_info WHERE level_name = 'Bunker Hill'), 500.0, 313.0),
('479315db-b690-49d8-8d68-101d2897c756', (SELECT id FROM level_info WHERE level_name = 'Bunker Hill'), 741.0, 308.0),
('02f132e6-2c0c-404b-9091-7485de70458b', (SELECT id FROM level_info WHERE level_name = 'Bunker Hill'), 939.0, 321.0),
('0031751a-b816-437a-8542-2260ebdf3754', (SELECT id FROM level_info WHERE level_name = 'Bunker Hill'), 1048.0, 477.0),
('d0a8718e-ab1e-4079-b0e5-3605224b8bd6', (SELECT id FROM level_info WHERE level_name = 'Bunker Hill'), 656.0, 462.0),
('440df2be-02b1-4d65-9330-af8293f8c0f7', (SELECT id FROM level_info WHERE level_name = 'Bunker Hill'), 931.0, 481.0),
('129b5bf3-b2fa-46f1-8c30-4d965838a201', (SELECT id FROM level_info WHERE level_name = 'Bunker Hill'), 707.0, 589.0),
('215503bb-38fb-4ce6-8834-104d1176fb9f', (SELECT id FROM level_info WHERE level_name = 'Bunker Hill'), 906.0, 594.0),
('079f2581-fcbc-46c3-b11c-1ae41c1c9e2b', (SELECT id FROM level_info WHERE level_name = 'Bunker Hill'), 490.0, 602.0),
('294d9440-531a-4a50-89c1-11025c61a5b5', (SELECT id FROM level_info WHERE level_name = 'Bunker Hill'), 1077.0, 588.0);

-- Great Bridge: seven platforms flanking the causeway on both banks.
INSERT INTO tower_slot (id, level_info_id, map_position_x, map_position_y) VALUES
('7fe14be3-774f-4a43-be95-3080c43014a5', (SELECT id FROM level_info WHERE level_name = 'Great Bridge'), 450.0, 480.0),
('a2e0a884-828f-4321-908b-642061e3dbab', (SELECT id FROM level_info WHERE level_name = 'Great Bridge'), 560.0, 640.0),
('2cf2d64b-a2bc-4fcf-bf9a-5ca8b3e19d73', (SELECT id FROM level_info WHERE level_name = 'Great Bridge'), 680.0, 420.0),
('2ec068e5-c124-4fe4-b79b-83e6dd998fcc', (SELECT id FROM level_info WHERE level_name = 'Great Bridge'), 1000.0, 640.0),
('ec8d6e21-d5df-41be-8c50-4eb8e35f49bc', (SELECT id FROM level_info WHERE level_name = 'Great Bridge'), 1060.0, 420.0),
('e3638f94-aa2a-42f5-adf6-7262b4177a76', (SELECT id FROM level_info WHERE level_name = 'Great Bridge'), 1180.0, 650.0),
('ef54f2ae-2610-48f7-95ec-89262f6b9ffd', (SELECT id FROM level_info WHERE level_name = 'Great Bridge'), 1250.0, 500.0);
