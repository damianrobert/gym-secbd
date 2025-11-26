INSERT INTO gym_trainers(first_name, last_name, specialty)
VALUES ('Andrei','Pop','Strength');

INSERT INTO gym_trainers(first_name, last_name, specialty)
VALUES ('Ioana','Ionescu','Yoga');

INSERT INTO gym_members(first_name, last_name, email, phone, cnp)
VALUES ('Mihai','Georgescu','mihai@gym.ro','0712345678','1990101012345');

INSERT INTO gym_members(first_name, last_name, email, phone, cnp)
VALUES ('Ana','Marin','ana@gym.ro','0722333444','2990202123456');

INSERT INTO gym_subscriptions(name, duration_months, price)
VALUES ('Basic', 1, 120);

INSERT INTO gym_subscriptions(name, duration_months, price)
VALUES ('Premium', 3, 390);

INSERT INTO gym_classes(title, difficulty, trainer_id, max_slots)
VALUES ('Yoga de dimineață','BEGINNER', 2, 15);

INSERT INTO gym_classes(title, difficulty, trainer_id, max_slots)
VALUES ('Power Strength','ADVANCED', 1, 10);

INSERT INTO gym_contracts(member_id, sub_id, start_date, status)
VALUES (1, 1, SYSDATE, 'ACTIVE');

INSERT INTO gym_contracts(member_id, sub_id, start_date, status)
VALUES (2, 2, SYSDATE, 'ACTIVE');

COMMIT;

BEGIN
  gym_generate_master_key;
  gym_encrypt_member_phones;
END;