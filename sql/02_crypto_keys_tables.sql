CREATE SEQUENCE gym_key_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE gym_keys (
    key_id      NUMBER PRIMARY KEY,
    key_value   RAW(32),
    key_type    VARCHAR2(30),    -- 'MASTER', 'ROW'
    created_at  DATE DEFAULT SYSDATE
);

CREATE TABLE gym_members_secure (
    member_id   NUMBER PRIMARY KEY REFERENCES gym_members(member_id),
    phone_enc   RAW(2000),
    row_key_id  NUMBER REFERENCES gym_keys(key_id)
);