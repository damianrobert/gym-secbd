# Proiect Securitatea Bazelor de Date – GYM

## 1. Descriere generală

Aplicația modelează o sală de fitness (GYM) cu:

- membri (`GYM_MEMBERS`),
- antrenori (`GYM_TRAINERS`),
- tipuri de abonamente (`GYM_SUBSCRIPTIONS`),
- contracte dintre membri și sală (`GYM_CONTRACTS`),
- clase de grup (`GYM_CLASSES`),
- înscrieri la clase (`GYM_ENROLLMENTS`).

Peste acest model de date sunt implementate mecanisme de securitate discutate la laborator:

- criptare simetrică a datelor sensibile (telefon membru),
- management de chei (cheie master + chei pe rând),
- hash (MD5) pentru integritatea contractelor,
- audit standard și audit detaliat (triggere),
- Fine Grained Auditing (FGA),
- utilizatori, profile de resurse și cote de tablespace.

## 2. Structura fișierelor

- `sql/01_schema_gym.sql` – creare tabele GYM (membri, antrenori, abonamente, contracte, clase, înscrieri).
- `sql/02_crypto_keys_tables.sql` – tabele pentru chei și tabelul cu date criptate ale membrilor.
- `sql/03_crypto_procs.sql` – proceduri de generare cheie master, criptare și decriptare pentru telefonul membrilor.
- `sql/04_hash_contracts.sql` – funcția de hash MD5 pentru contracte și triggerul care salvează hash-ul.
- `sql/05_audit_triggers_fga.sql` – comenzi AUDIT, tabele de audit, triggere și politica FGA.
- `sql/06_users_profiles.sql` – creare utilizatori, cote, profile de resurse și triggere de logon/logoff.
- `sql/99_demo_data.sql` – date de test (membri, antrenori, abonamente, clase, contracte).

## 3. Ordinea de rulare

Într-o sesiune SQL\*Plus / SQL Developer:

```sql
@sql/01_schema_gym.sql
@sql/02_crypto_keys_tables.sql
@sql/03_crypto_procs.sql
@sql/04_hash_contracts.sql
@sql/05_audit_triggers_fga.sql
@sql/06_users_profiles.sql
@sql/99_demo_data.sql
```

## Tehnologii și concepte folosite

-> Oracle Database
-> DBMS_CRYPTO (AES256, CBC, PAD_PKCS5)
-> Hash MD5
-> Audit standard (AUDIT ...), audit pe triggere, Fine Grained Audit (DBMS_FGA)
-> Conturi de utilizator, profile, cote tablespace
-> Triggere de audit logon/logoff
