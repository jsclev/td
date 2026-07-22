-- Enemy paths, one row per polyline point, in map (image-pixel) space matching
-- the level art. point_index is travel order: point 0 is the spawn, the last is
-- the exit.
--
-- Lexington and Concord (path 0): the British advance — enters at "To Boston"
-- (right), follows the road west through the S-curve past Lexington Green, up to
-- Concord, and out across the Old North Bridge (left). Traced from
-- images/lexington_and_concord.png.
INSERT INTO level_path_point (id, level_info_id, path_index, point_index, map_position_x, map_position_y) VALUES
('9abaa637-df16-47e9-bdb4-fa4c8cb95cbd', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 0, 1345.0, 632.0),
('748683a2-64f9-4f88-acf5-5735310419ab', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 1, 1250.0, 600.0),
('8f9de559-14e9-44cc-b5a9-23739f1e7c02', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 2, 1185.0, 572.0),
('afc9bb58-6123-49d2-bcb5-345d9a608950', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 3, 1128.0, 558.0),
('deb42d9e-5356-4f05-8c9a-0e036140b271', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 4, 1058.0, 538.0),
('255b6e3f-cf8c-4624-8228-8ba00394bd02', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 5, 1012.0, 518.0),
('a7967387-49de-4c05-976b-c1fa62f61a53', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 6, 958.0, 515.0),
('752c40b0-fdae-444c-ade7-e0c2c4b63653', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 7, 905.0, 522.0),
('5ae8936d-371e-4f8a-bbe5-4cb93cd1ea77', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 8, 852.0, 540.0),
('52918e61-e271-4ef1-b2ca-147d9ec2acce', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 9, 802.0, 555.0),
('41d251a6-d673-49d1-b1d6-86e6fe7058f3', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 10, 762.0, 562.0),
('43b90ff6-dc7a-4c96-8f92-778d42262b78', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 11, 712.0, 548.0),
('9f1cb9ac-eac9-484a-8881-3e19acd843ab', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 12, 662.0, 545.0),
('6ae286a4-7a00-4cbb-b8f5-607a56b3def3', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 13, 612.0, 550.0),
('a0d20d5d-c974-414e-8df7-14573244f37f', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 14, 562.0, 545.0),
('c78e4f65-2f5b-4182-aa19-b4506ed19002', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 15, 510.0, 520.0),
('5927f15c-0a31-4e40-8680-bdb56547d41d', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 16, 460.0, 495.0),
('e26af914-32d8-4a0a-9a38-ebb0109a3cd0', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 17, 410.0, 478.0),
('3a9a464d-9a5c-4f8d-9ffb-cc369a75f450', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 18, 372.0, 462.0),
('d965c78a-42e6-4002-ad60-adebed29e5ad', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 19, 335.0, 477.0),
('3c15b002-77a0-4347-8963-5e980aedcac0', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 20, 305.0, 500.0),
('f06089cd-cf1a-40cd-a2e5-984864c094ce', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 21, 268.0, 516.0),
('96bce98d-ed68-4ba1-85dc-6a301774f859', (SELECT id FROM level_info WHERE level_name = 'Lexington and Concord'), 0, 22, 222.0, 528.0);
