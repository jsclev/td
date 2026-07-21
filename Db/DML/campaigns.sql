-- Campaigns
INSERT INTO campaign VALUES (
    'f589a28f-54d8-4791-851c-a307f252151a',
    'Main',
    NULL
);
INSERT INTO campaign VALUES (
    '9fef24bb-34b9-4588-85b4-25aa9aa2c6c9',
    'The Fall of New York',
    'f589a28f-54d8-4791-851c-a307f252151a'
);
INSERT INTO campaign VALUES (
    'b559a112-9aeb-433d-a813-1a6a0f92e746',
    'The Northern Campaign',
    'f589a28f-54d8-4791-851c-a307f252151a'
);
INSERT INTO campaign VALUES (
    '42b79544-2035-44a6-a812-68d1d07f115a',
    'The Philadelphia Campaign',
    'f589a28f-54d8-4791-851c-a307f252151a'
);
INSERT INTO campaign VALUES (
    'a97b80f7-a291-4408-9071-771aa208f413',
    'The French Alliance',
    'f589a28f-54d8-4791-851c-a307f252151a'
);
INSERT INTO campaign VALUES (
    '7593fe4b-1230-4dfc-9218-2d16e5d70d31',
    'The Southern Campaign',
    'f589a28f-54d8-4791-851c-a307f252151a'
);

-- Main campaign
INSERT INTO level_info VALUES (
    'be3cf809-f71e-4209-bc4d-8b25b0b5f2a0',
    'f589a28f-54d8-4791-851c-a307f252151a',
    'Lexington and Concord',
    0.0,
    0.0,
    julianday('1775-04-19T00:00:00-05:00'),
    julianday('1775-04-19T14:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '9d692af7-345d-419a-bc04-16112c3f0b74',
    'f589a28f-54d8-4791-851c-a307f252151a',
    'Bunker Hill',
    0.0,
    0.0,
    julianday('1775-06-17T10:00:00-05:00'),
    julianday('1775-06-17T12:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '55a5d12d-3cea-475f-aa8d-125271a8a0c2',
    'f589a28f-54d8-4791-851c-a307f252151a',
    'Great Bridge',
    0.0,
    0.0,
    julianday('1775-12-09T07:00:00-05:00'),
    julianday('1775-12-09T07:30:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    'd71ba07d-6682-41b7-be0b-60473af700c3',
    'f589a28f-54d8-4791-851c-a307f252151a',
    'Québec',
    0.0,
    0.0,
    julianday('1775-12-31T04:00:00-05:00'),
    julianday('1775-12-31T10:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '17914ebc-7052-490d-b606-afc1746da512',
    'f589a28f-54d8-4791-851c-a307f252151a',
    'Dorchester Heights',
    0.0,
    0.0,
    julianday('1776-03-04T18:00:00-05:00'),
    julianday('1779-04-19T00:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '35916460-914a-457b-beb9-1c5bfe95e61a',
    'f589a28f-54d8-4791-851c-a307f252151a',
    'Sullivan''s Island',
    0.0,
    0.0,
    julianday('1776-06-28T11:00:00-05:00'),
    julianday('1776-06-28T21:30:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '99633efd-f135-44fc-8248-b8635a6db957',
    'f589a28f-54d8-4791-851c-a307f252151a',
    'Long Island',
    0.0,
    0.0,
    julianday('1776-08-27T03:00:00-05:00'),
    julianday('1776-08-27T14:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '537aba11-6201-4fe9-b789-36607de98e41',
    'f589a28f-54d8-4791-851c-a307f252151a',
    'Trenton',
    0.0,
    0.0,
    julianday('1776-12-26T08:00:00-05:00'),
    julianday('1776-12-26T09:30:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '9c6679ab-c028-48ab-95b7-93318f37c1a9',
    'f589a28f-54d8-4791-851c-a307f252151a',
    'Princeton',
    0.0,
    0.0,
    julianday('1777-01-03T08:00:00-05:00'),
    julianday('1777-01-03T11:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '073a132e-46ea-44fa-976d-ee719ea75464',
    'f589a28f-54d8-4791-851c-a307f252151a',
    'Vincennes',
    0.0,
    0.0,
    julianday('1779-02-23T19:00:00-05:00'),
    julianday('1779-02-25T10:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '42e95fce-6da1-416d-bf69-24f70bb4dc52',
    'f589a28f-54d8-4791-851c-a307f252151a',
    'Fort Ann',
    0.0,
    0.0,
    julianday('1777-07-08T10:30:00-05:00'),
    julianday('1777-07-08T12:30:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '549a67d9-f721-4cdf-8ba7-8916ba71b040',
    'f589a28f-54d8-4791-851c-a307f252151a',
    'Saratoga',
    0.0,
    0.0,
    julianday('1777-09-19T13:00:00-05:00'),
    julianday('1777-09-19T18:30:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '46157f59-b21b-4b03-9151-d404c6cd6d0b',
    'f589a28f-54d8-4791-851c-a307f252151a',
    'Savannah',
    0.0,
    0.0,
    julianday('1779-09-16T12:00:00-05:00'),
    julianday('1779-10-18T12:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '4ca73a47-98f6-41b6-815d-c2c797aa746e',
    'f589a28f-54d8-4791-851c-a307f252151a',
    'Charleston',
    0.0,
    0.0,
    julianday('1780-03-29T08:00:00-05:00'),
    julianday('1780-05-12T14:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '33d900c6-c6ff-409a-973b-f09ddc8a6f6a',
    'f589a28f-54d8-4791-851c-a307f252151a',
    'Kettle Creek',
    0.0,
    0.0,
    julianday('1779-02-14T10:00:00-05:00'),
    julianday('1779-02-14T13:00:00-05:00'),
    100,
    20
);

-- The Fall of New York
INSERT INTO level_info VALUES (
    '48080e89-648c-4e66-a176-42c83bfafbac',
    '9fef24bb-34b9-4588-85b4-25aa9aa2c6c9',
    'Kip''s Bay',
    0.0,
    0.0,
    julianday('1776-04-19T00:00:00-05:00'),
    julianday('1779-04-19T00:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    'f085da64-7f9d-454d-92ac-8d41545e7b80',
    '9fef24bb-34b9-4588-85b4-25aa9aa2c6c9',
    'Harlem Heights',
    0.0,
    0.0,
    julianday('1776-09-16T07:00:00-05:00'),
    julianday('1776-09-16T15:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    'd7875b10-bf90-41cf-9123-8a6359cdeba9',
    '9fef24bb-34b9-4588-85b4-25aa9aa2c6c9',
    'Pell''s Point',
    0.0,
    0.0,
    julianday('1776-10-18T09:00:00-05:00'),
    julianday('1776-10-18T17:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '8725ab17-25f9-4ebc-b5fe-233d9a4ff9d2',
    '9fef24bb-34b9-4588-85b4-25aa9aa2c6c9',
    'White Plains',
    0.0,
    0.0,
    julianday('1776-10-28T10:00:00-05:00'),
    julianday('1776-10-28T17:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '23eecc79-4ceb-4527-bf6f-217fa43c0a2c',
    '9fef24bb-34b9-4588-85b4-25aa9aa2c6c9',
    'Fort Washington',
    0.0,
    0.0,
    julianday('1776-11-16T07:00:00-05:00'),
    julianday('1776-11-16T15:00:00-05:00'),
    100,
    20
);

-- The Northern Campaign
INSERT INTO level_info VALUES (
    '54ec40cb-172f-4455-9817-8e1e5c0280fb',
    'b559a112-9aeb-433d-a813-1a6a0f92e746',
    'Valcour Island',
    0.0,
    0.0,
    julianday('1776-10-11T11:00:00-05:00'),
    julianday('1776-10-13T12:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '729c02dc-6e72-4069-b001-ce9e374b33ab',
    'b559a112-9aeb-433d-a813-1a6a0f92e746',
    'Hubbardton',
    0.0,
    0.0,
    julianday('1777-07-07T05:00:00-05:00'),
    julianday('1777-07-07T08:30:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '28f0a08a-a2e7-4884-8871-961821031884',
    'b559a112-9aeb-433d-a813-1a6a0f92e746',
    'Oriskany',
    0.0,
    0.0,
    julianday('1777-08-06T10:00:00-05:00'),
    julianday('1777-08-06T16:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '4e49eb5b-8b5d-4f57-a5e3-3dcf03dac98c',
    'b559a112-9aeb-433d-a813-1a6a0f92e746',
    'Bennington',
    0.0,
    0.0,
    julianday('1777-08-16T15:00:00-05:00'),
    julianday('1777-08-16T19:30:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    'ce461940-db85-4750-8c0e-6c2cf6392bb8',
    'b559a112-9aeb-433d-a813-1a6a0f92e746',
    'Fort Stanwix',
    0.0,
    0.0,
    julianday('1777-08-02T12:00:00-05:00'),
    julianday('1777-08-22T14:00:00-05:00'),
    100,
    20
);

-- The Philadelphia Campaign
INSERT INTO level_info VALUES (
    '1f9749e3-0876-42b0-9099-e7bd425c32c2',
    '42b79544-2035-44a6-a812-68d1d07f115a',
    'Cooch''s Bridge',
    0.0,
    0.0,
    julianday('1777-09-03T09:00:00-05:00'),
    julianday('1777-09-03T13:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    'cda69d20-4953-455a-8695-14c1c436f382',
    '42b79544-2035-44a6-a812-68d1d07f115a',
    'Brandywine',
    0.0,
    0.0,
    julianday('1777-09-11T06:30:00-05:00'),
    julianday('1777-09-11T19:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    'a4172f5b-8129-4509-b65c-7937cac42f8d',
    '42b79544-2035-44a6-a812-68d1d07f115a',
    'Paoli',
    0.0,
    0.0,
    julianday('1777-09-21T01:00:00-05:00'),
    julianday('1777-09-21T02:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    'c4607381-0279-4c2a-a748-f972bd63adaa',
    '42b79544-2035-44a6-a812-68d1d07f115a',
    'Germantown',
    0.0,
    0.0,
    julianday('1777-10-04T05:00:00-05:00'),
    julianday('1777-10-04T10:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '003b9745-b9e4-49fe-a4eb-38492f3e2ede',
    '42b79544-2035-44a6-a812-68d1d07f115a',
    'White Marsh',
    0.0,
    0.0,
    julianday('1777-12-05T09:00:00-05:00'),
    julianday('1777-12-08T14:00:00-05:00'),
    100,
    20
);

-- The French Alliance
INSERT INTO level_info VALUES (
    '8eb1b567-1991-4154-8e3b-83dd80d3ab41',
    'a97b80f7-a291-4408-9071-771aa208f413',
    'Monmouth',
    0.0,
    0.0,
    julianday('1778-06-28T10:00:00-05:00'),
    julianday('1778-06-28T18:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '1b139b53-f9e4-4ad6-8e55-adf1105c6372',
    'a97b80f7-a291-4408-9071-771aa208f413',
    'Rhode Island',
    0.0,
    0.0,
    julianday('1778-08-29T07:00:00-05:00'),
    julianday('1778-08-29T16:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    'bc8512c1-bb02-4b1e-a587-1246abc88b5f',
    'a97b80f7-a291-4408-9071-771aa208f413',
    'Stony Point',
    0.0,
    0.0,
    julianday('1779-07-16T00:30:00-05:00'),
    julianday('1779-07-16T01:30:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    'b01bfd74-6f62-4f66-ba84-1af4d08112c0',
    'a97b80f7-a291-4408-9071-771aa208f413',
    'Savannah',
    0.0,
    0.0,
    julianday('1779-09-16T12:00:00-05:00'),
    julianday('1779-10-18T12:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '772825cb-40e7-4d49-9b98-cd3086cacbd5',
    'a97b80f7-a291-4408-9071-771aa208f413',
    'Flamborough Head',
    0.0,
    0.0,
    julianday('1779-09-23T14:00:00-05:00'),
    julianday('1779-09-23T17:30:00-05:00'),
    100,
    20
);

-- The Southern Campaign
INSERT INTO level_info VALUES (
    'c818b5d0-e991-414d-86ce-f14901006452',
    '7593fe4b-1230-4dfc-9218-2d16e5d70d31',
    'Camden',
    0.0,
    0.0,
    julianday('1780-08-16T05:30:00-05:00'),
    julianday('1780-08-16T06:30:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '7f0d1ed5-a76a-47eb-ad70-78e510d3efcc',
    '7593fe4b-1230-4dfc-9218-2d16e5d70d31',
    'Kings Mountain',
    0.0,
    0.0,
    julianday('1780-10-07T15:00:00-05:00'),
    julianday('1780-10-07T16:05:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    'b1a225f9-e568-4b5d-98ad-f35c4c9fb93a',
    '7593fe4b-1230-4dfc-9218-2d16e5d70d31',
    'Cowpens',
    0.0,
    0.0,
    julianday('1781-01-17T07:00:00-05:00'),
    julianday('1781-01-17T07:45:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '06ca7915-be33-4ffb-80bb-0089bb1aafcf',
    '7593fe4b-1230-4dfc-9218-2d16e5d70d31',
    'Guilford Courthouse',
    0.0,
    0.0,
    julianday('1781-03-15T13:30:00-05:00'),
    julianday('1781-03-15T15:00:00-05:00'),
    100,
    20
);
INSERT INTO level_info VALUES (
    '231705e7-e33f-4fd1-863d-e9bf32a44857',
    '7593fe4b-1230-4dfc-9218-2d16e5d70d31',
    'Eutaw Springs',
    0.0,
    0.0,
    julianday('1781-09-08T09:00:00-05:00'),
    julianday('1781-09-08T13:00:00-05:00'),
    100,
    20
);
