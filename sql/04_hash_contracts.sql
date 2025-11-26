CREATE TABLE gym_contract_hash (
    contract_id  NUMBER PRIMARY KEY,
    hash_value   RAW(2000),
    created_at   DATE DEFAULT SYSDATE
);

CREATE OR REPLACE FUNCTION gym_contract_md5(p_contract_id IN NUMBER)
RETURN RAW IS
    v_data VARCHAR2(4000);
BEGIN
    SELECT contract_id || '|' ||
           member_id   || '|' ||
           sub_id      || '|' ||
           TO_CHAR(start_date, 'YYYYMMDDHH24MISS') || '|' ||
           NVL(TO_CHAR(end_date, 'YYYYMMDDHH24MISS'),'NULL') || '|' ||
           NVL(status,'NULL')
    INTO v_data
    FROM gym_contracts
    WHERE contract_id = p_contract_id;

    RETURN dbms_crypto.hash(
        src => utl_raw.cast_to_raw(v_data),
        typ => dbms_crypto.HASH_MD5
    );
END;

CREATE OR REPLACE TRIGGER trg_gym_contract_hash
AFTER INSERT OR UPDATE ON gym_contracts
FOR EACH ROW
DECLARE
    v_hash RAW(2000);
BEGIN
    v_hash := gym_contract_md5(:NEW.contract_id);

    MERGE INTO gym_contract_hash h
    USING (SELECT :NEW.contract_id AS contract_id FROM dual) src
    ON (h.contract_id = src.contract_id)
    WHEN MATCHED THEN
        UPDATE SET h.hash_value = v_hash, h.created_at = SYSDATE
    WHEN NOT MATCHED THEN
        INSERT (contract_id, hash_value, created_at)
        VALUES (:NEW.contract_id, v_hash, SYSDATE);
END;