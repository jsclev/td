SELECT
    c.id,
    c.campaign_name,
    l.campaign_sequence_num,
    l.level_name
FROM
    level AS l
INNER JOIN
    campaign AS c
    ON l.campaign_id = c.id
ORDER BY
    c.parent_campaign_id,
    c.campaign_name,
    l.campaign_sequence_num;
