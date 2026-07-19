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

-- The Northern Campaign
INSERT INTO level VALUES (
    '54ec40cb-172f-4455-9817-8e1e5c0280fb', 'b559a112-9aeb-433d-a813-1a6a0f92e746', 1, 'Valcour Island', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '729c02dc-6e72-4069-b001-ce9e374b33ab', 'b559a112-9aeb-433d-a813-1a6a0f92e746', 2, 'Hubbardton', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '28f0a08a-a2e7-4884-8871-961821031884', 'b559a112-9aeb-433d-a813-1a6a0f92e746', 3, 'Oriskany', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '4e49eb5b-8b5d-4f57-a5e3-3dcf03dac98c', 'b559a112-9aeb-433d-a813-1a6a0f92e746', 4, 'Bennington', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    'ce461940-db85-4750-8c0e-6c2cf6392bb8', 'b559a112-9aeb-433d-a813-1a6a0f92e746', 5, 'Fort Stanwix', 0.0, 0.0, 100, 20
);

-- The Philadelphia Campaign
INSERT INTO level VALUES (
    '1f9749e3-0876-42b0-9099-e7bd425c32c2', '42b79544-2035-44a6-a812-68d1d07f115a', 1, 'Valcour Island', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    'cda69d20-4953-455a-8695-14c1c436f382', '42b79544-2035-44a6-a812-68d1d07f115a', 2, 'Hubbardton', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    'a4172f5b-8129-4509-b65c-7937cac42f8d', '42b79544-2035-44a6-a812-68d1d07f115a', 3, 'Oriskany', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    'c4607381-0279-4c2a-a748-f972bd63adaa', '42b79544-2035-44a6-a812-68d1d07f115a', 4, 'Bennington', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '003b9745-b9e4-49fe-a4eb-38492f3e2ede', '42b79544-2035-44a6-a812-68d1d07f115a', 5, 'Fort Stanwix', 0.0, 0.0, 100, 20
);

-- The French Alliance
INSERT INTO level VALUES (
    '8eb1b567-1991-4154-8e3b-83dd80d3ab41', 'a97b80f7-a291-4408-9071-771aa208f413', 1, 'Monmouth', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '1b139b53-f9e4-4ad6-8e55-adf1105c6372', 'a97b80f7-a291-4408-9071-771aa208f413', 2, 'Rhode Island', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    'bc8512c1-bb02-4b1e-a587-1246abc88b5f', 'a97b80f7-a291-4408-9071-771aa208f413', 3, 'Stony Point', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    'b01bfd74-6f62-4f66-ba84-1af4d08112c0', 'a97b80f7-a291-4408-9071-771aa208f413', 4, 'Savannah', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '772825cb-40e7-4d49-9b98-cd3086cacbd5', 'a97b80f7-a291-4408-9071-771aa208f413', 5, 'Flamborough Head', 0.0, 0.0, 100, 20
);

-- The Southern Campaign
INSERT INTO level VALUES (
    'c818b5d0-e991-414d-86ce-f14901006452', '7593fe4b-1230-4dfc-9218-2d16e5d70d31', 1, 'Camden', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '7f0d1ed5-a76a-47eb-ad70-78e510d3efcc', '7593fe4b-1230-4dfc-9218-2d16e5d70d31', 2, 'Kings Mountain', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    'b1a225f9-e568-4b5d-98ad-f35c4c9fb93a', '7593fe4b-1230-4dfc-9218-2d16e5d70d31', 3, 'Cowpens', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '06ca7915-be33-4ffb-80bb-0089bb1aafcf', '7593fe4b-1230-4dfc-9218-2d16e5d70d31', 4, 'Guilford Courthouse', 0.0, 0.0, 100, 20
);
INSERT INTO level VALUES (
    '231705e7-e33f-4fd1-863d-e9bf32a44857', '7593fe4b-1230-4dfc-9218-2d16e5d70d31', 5, 'Eutaw Springs', 0.0, 0.0, 100, 20
);
