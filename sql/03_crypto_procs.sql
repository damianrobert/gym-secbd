
GRANT EXECUTE ON dbms_crypto TO gym_secbd;  -- se ruleaza ca SYS și pui numele userului tău

CREATE OR REPLACE PROCEDURE gym_generate_master_key IS
    v_key   RAW(32);
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO   v_count
    FROM   gym_keys
    WHERE  key_type = 'MASTER';

    IF v_count = 0 THEN
        v_key := dbms_crypto.randombytes(32);
        INSERT INTO gym_keys(key_id, key_value, key_type)
        VALUES (gym_key_seq.NEXTVAL, v_key, 'MASTER');
    END IF;
END;

CREATE OR REPLACE PROCEDURE gym_encrypt_member_phones IS
    v_master_key   RAW(32);
    v_master_id    NUMBER;
    v_row_key      RAW(32);
    v_row_key_id   NUMBER;
    v_hybrid_key   RAW(32);
BEGIN
    SELECT key_id, key_value
    INTO   v_master_id, v_master_key
    FROM   gym_keys
    WHERE  key_type = 'MASTER';

    DELETE FROM gym_members_secure;

    FOR rec IN (SELECT member_id, phone
                FROM gym_members
                WHERE phone IS NOT NULL) LOOP

        v_row_key_id := gym_key_seq.NEXTVAL;
        v_row_key    := dbms_crypto.randombytes(32);

        INSERT INTO gym_keys(key_id, key_value, key_type)
        VALUES (v_row_key_id, v_row_key, 'ROW');

        v_hybrid_key := utl_raw.bit_xor(v_master_key, v_row_key);

        INSERT INTO gym_members_secure(member_id, phone_enc, row_key_id)
        VALUES (
            rec.member_id,
            dbms_crypto.encrypt(
                src => utl_raw.cast_to_raw(rec.phone),
                typ => dbms_crypto.ENCRYPT_AES256
                     + dbms_crypto.CHAIN_CBC
                     + dbms_crypto.PAD_PKCS5,
                key => v_hybrid_key
            ),
            v_row_key_id
        );
    END LOOP;
END;

    CREATE OR REPLACE FUNCTION gym_decrypt_phone(p_member_id IN NUMBER)
    RETURN VARCHAR2 IS
        v_master_key   RAW(32);
        v_row_key      RAW(32);
        v_hybrid_key   RAW(32);
        v_phone_raw    RAW(2000);
        v_phone        VARCHAR2(50);
    BEGIN
        SELECT key_value INTO v_master_key
        FROM   gym_keys
        WHERE  key_type = 'MASTER';

        SELECT k.key_value, ms.phone_enc
        INTO   v_row_key, v_phone_raw
        FROM   gym_members_secure ms
            JOIN gym_keys k ON ms.row_key_id = k.key_id
        WHERE  ms.member_id = p_member_id;

        v_hybrid_key := utl_raw.bit_xor(v_master_key, v_row_key);

        v_phone :=
        utl_i18n.raw_to_char(
            dbms_crypto.decrypt(
            src => v_phone_raw,
            typ => dbms_crypto.ENCRYPT_AES256
                + dbms_crypto.CHAIN_CBC
                + dbms_crypto.PAD_PKCS5,
            key => v_hybrid_key
            ),
            'AL32UTF8'
        );

        RETURN v_phone;
    END;