-- Campaigns
INSERT INTO campaign (id, campaign_name, parent_campaign_id) VALUES (
    'f589a28f-54d8-4791-851c-a307f252151a', 'Main', NULL
);
INSERT INTO campaign (id, campaign_name, parent_campaign_id) VALUES (
    '9fef24bb-34b9-4588-85b4-25aa9aa2c6c9', 'The Fall of New York', 'f589a28f-54d8-4791-851c-a307f252151a'
);
INSERT INTO campaign (id, campaign_name, parent_campaign_id) VALUES (
    'b559a112-9aeb-433d-a813-1a6a0f92e746', 'The Northern Campaign', 'f589a28f-54d8-4791-851c-a307f252151a'
);
INSERT INTO campaign (id, campaign_name, parent_campaign_id) VALUES (
    '42b79544-2035-44a6-a812-68d1d07f115a', 'The Philadelphia Campaign', 'f589a28f-54d8-4791-851c-a307f252151a'
);
INSERT INTO campaign (id, campaign_name, parent_campaign_id) VALUES (
    'a97b80f7-a291-4408-9071-771aa208f413', 'The French Alliance', 'f589a28f-54d8-4791-851c-a307f252151a'
);
INSERT INTO campaign (id, campaign_name, parent_campaign_id) VALUES (
    '7593fe4b-1230-4dfc-9218-2d16e5d70d31', 'The Southern Campaign', 'f589a28f-54d8-4791-851c-a307f252151a'
);

-- Main campaign
INSERT INTO level VALUES (
    'be3cf809-f71e-4209-bc4d-8b25b0b5f2a0', 'f589a28f-54d8-4791-851c-a307f252151a', 1, 'Lexington and Concord', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '9d692af7-345d-419a-bc04-16112c3f0b74', 'f589a28f-54d8-4791-851c-a307f252151a', 2, 'Bunker Hill', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '17914ebc-7052-490d-b606-afc1746da512', 'f589a28f-54d8-4791-851c-a307f252151a', 3, 'Dorchester Heights', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '55a5d12d-3cea-475f-aa8d-125271a8a0c2', 'f589a28f-54d8-4791-851c-a307f252151a', 4, 'Great Bridge', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '35916460-914a-457b-beb9-1c5bfe95e61a', 'f589a28f-54d8-4791-851c-a307f252151a', 5, 'Sullivan''s Island', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    'd71ba07d-6682-41b7-be0b-60473af700c3', 'f589a28f-54d8-4791-851c-a307f252151a', 6, 'Québec', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '99633efd-f135-44fc-8248-b8635a6db957', 'f589a28f-54d8-4791-851c-a307f252151a', 7, 'Mount Holly', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '537aba11-6201-4fe9-b789-36607de98e41', 'f589a28f-54d8-4791-851c-a307f252151a', 8, 'Trenton', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '9c6679ab-c028-48ab-95b7-93318f37c1a9', 'f589a28f-54d8-4791-851c-a307f252151a', 9, 'Princeton', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '073a132e-46ea-44fa-976d-ee719ea75464', 'f589a28f-54d8-4791-851c-a307f252151a', 10, 'Vincennes', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '42e95fce-6da1-416d-bf69-24f70bb4dc52', 'f589a28f-54d8-4791-851c-a307f252151a', 11, 'Fort Ann', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '549a67d9-f721-4cdf-8ba7-8916ba71b040', 'f589a28f-54d8-4791-851c-a307f252151a', 12, 'Saratoga', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '46157f59-b21b-4b03-9151-d404c6cd6d0b', 'f589a28f-54d8-4791-851c-a307f252151a', 13, 'Savannah', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '4ca73a47-98f6-41b6-815d-c2c797aa746e', 'f589a28f-54d8-4791-851c-a307f252151a', 14, 'Charleston', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '33d900c6-c6ff-409a-973b-f09ddc8a6f6a', 'f589a28f-54d8-4791-851c-a307f252151a', 15, 'Kettle Creek', 0.0, 0.0, 100, 20
);

-- The Fall of New York campaign
INSERT INTO level VALUES (
    '48080e89-648c-4e66-a176-42c83bfafbac', '9fef24bb-34b9-4588-85b4-25aa9aa2c6c9', 1, 'Kip''s Bay', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    'f085da64-7f9d-454d-92ac-8d41545e7b80', '9fef24bb-34b9-4588-85b4-25aa9aa2c6c9', 2, 'Harlem Heights', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    'd7875b10-bf90-41cf-9123-8a6359cdeba9', '9fef24bb-34b9-4588-85b4-25aa9aa2c6c9', 3, 'Pell''s Point', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '8725ab17-25f9-4ebc-b5fe-233d9a4ff9d2', '9fef24bb-34b9-4588-85b4-25aa9aa2c6c9', 4, 'White Plains', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '23eecc79-4ceb-4527-bf6f-217fa43c0a2c', '9fef24bb-34b9-4588-85b4-25aa9aa2c6c9', 5, 'Fort Washington', 0.0, 0.0, 100, 20
);
