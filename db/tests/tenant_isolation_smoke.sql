-- Smoke test de integridad — OpenDayCare 20261104000000
-- Requiere: 20261104000000__init.sql aplicado y tablas vacías.
-- Uso: psql -v ON_ERROR_STOP=1 -f db/tests/tenant_isolation_smoke.sql
-- Cada bloque imprime OK (comportamiento esperado) o FAIL.

DO $$
DECLARE
  d1 uuid; d2 uuid; r1 uuid; r2 uuid; u_staff uuid; u_parent uuid; c1 uuid; p1 uuid; t1 uuid;
BEGIN
  INSERT INTO daycares(name) VALUES ('Guarderia A') RETURNING id INTO d1;
  INSERT INTO daycares(name) VALUES ('Guarderia B') RETURNING id INTO d2;
  INSERT INTO rooms(daycare_id,name) VALUES (d1,'Soles') RETURNING id INTO r1;
  INSERT INTO rooms(daycare_id,name) VALUES (d2,'Lunas') RETURNING id INTO r2;

  INSERT INTO users(daycare_id,role,status,email,full_name,password_hash)
    VALUES (d1,'staff','active','staff@a.test','Staff A','$argon2id$v=19$m=65536,t=3,p=4$abc$def')
    RETURNING id INTO u_staff;
  INSERT INTO users(daycare_id,role,status,email,full_name,password_hash)
    VALUES (d1,'parent','active','parent@a.test','Parent A','$argon2id$v=19$m=65536,t=3,p=4$abc$def')
    RETURNING id INTO u_parent;

  INSERT INTO children(daycare_id,room_id,full_name,birth_date,enrolled_at)
    VALUES (d1,r1,'Nino A','2023-05-01','2024-01-08') RETURNING id INTO c1;
  INSERT INTO posts(daycare_id,author_id,type,body)
    VALUES (d1,u_staff,'meal','Comio todo') RETURNING id INTO p1;

  -- 1. Sala de otra guardería
  BEGIN
    INSERT INTO children(daycare_id,room_id,full_name,birth_date,enrolled_at)
      VALUES (d1,r2,'Nino Cruzado','2023-05-01','2024-01-08');
    RAISE NOTICE 'FAIL 1: sala cross-tenant aceptada';
  EXCEPTION WHEN foreign_key_violation THEN RAISE NOTICE 'OK 1: sala cross-tenant rechazada';
  END;

  -- 2. Autor del mismo tenant
  BEGIN
    INSERT INTO posts(daycare_id,author_id,type,body) VALUES (d1,u_parent,'activity','x');
    RAISE NOTICE 'OK 2: autor del mismo tenant aceptado';
  EXCEPTION WHEN foreign_key_violation THEN RAISE NOTICE 'FAIL 2: autor rechazado';
  END;

  -- 3. parent_children y staff_rooms validan rol
  BEGIN
    INSERT INTO staff_rooms(daycare_id,user_id,room_id) VALUES (d1,u_parent,r1);
    RAISE NOTICE 'FAIL 3: parent aceptado en staff_rooms';
  EXCEPTION WHEN check_violation THEN RAISE NOTICE 'OK 3: parent rechazado en staff_rooms';
  END;

  BEGIN
    INSERT INTO staff_rooms(daycare_id,user_id,room_id) VALUES (d1,u_staff,r1);
    RAISE NOTICE 'OK 4: staff aceptado en staff_rooms';
  EXCEPTION WHEN others THEN RAISE NOTICE 'FAIL 4: staff rechazado';
  END;

  -- 5. archived_at coherente con status
  BEGIN
    UPDATE children SET status='archived' WHERE id=c1;
    RAISE NOTICE 'FAIL 5: archived sin archived_at aceptado';
  EXCEPTION WHEN check_violation THEN RAISE NOTICE 'OK 5: archived sin archived_at rechazado';
  END;

  -- 6. Cuenta active exige password_hash
  BEGIN
    INSERT INTO users(daycare_id,role,status,email,full_name)
      VALUES (d1,'admin','active','admin@a.test','Admin A');
    RAISE NOTICE 'FAIL 6: active sin password aceptado';
  EXCEPTION WHEN check_violation THEN RAISE NOTICE 'OK 6: active sin password rechazado';
  END;

  -- 7. Un solo token pendiente por propósito
  INSERT INTO auth_tokens(user_id,purpose,token_hash,expires_at)
    VALUES (u_staff,'password_reset',sha256('token-1'::bytea), now()+interval '1 hour');
  BEGIN
    INSERT INTO auth_tokens(user_id,purpose,token_hash,expires_at)
      VALUES (u_staff,'password_reset',sha256('token-2'::bytea), now()+interval '1 hour');
    RAISE NOTICE 'FAIL 7: segundo token pendiente aceptado';
  EXCEPTION WHEN unique_violation THEN RAISE NOTICE 'OK 7: segundo token pendiente rechazado';
  END;

  -- 8. accepted_at coherente con status
  BEGIN
    INSERT INTO invitations(daycare_id,child_id,invited_by,full_name,email,relationship,code,status,expires_at)
      VALUES (d1,c1,u_staff,'Parent A','parent@a.test','mother','ABC12345','accepted',now()+interval '7 days');
    RAISE NOTICE 'FAIL 8: accepted sin accepted_at aceptado';
  EXCEPTION WHEN check_violation THEN RAISE NOTICE 'OK 8: accepted sin accepted_at rechazado';
  END;

  -- 9. accepted_by de otra guardería
  INSERT INTO users(daycare_id,role,status,email,full_name,password_hash)
    VALUES (d2,'parent','active','parent@b.test','Parent B','$argon2id$v=19$m=65536,t=3,p=4$abc$def')
    RETURNING id INTO t1;
  BEGIN
    INSERT INTO invitations(daycare_id,child_id,invited_by,full_name,email,relationship,code,status,expires_at,accepted_at,accepted_by)
      VALUES (d1,c1,u_staff,'Parent B','parent@b.test','guardian','XYZ98765','accepted',now()+interval '7 days',now(),t1);
    RAISE NOTICE 'FAIL 9: accepted_by cross-tenant aceptado';
  EXCEPTION WHEN check_violation THEN RAISE NOTICE 'OK 9: accepted_by cross-tenant rechazado';
  END;

  -- 10. updated_at lo mantiene el trigger
  UPDATE children SET full_name='Nino A2', updated_at='2000-01-01' WHERE id=c1;
  IF (SELECT updated_at > now() - interval '1 minute' FROM children WHERE id=c1) THEN
    RAISE NOTICE 'OK 10: updated_at mantenido por trigger';
  ELSE
    RAISE NOTICE 'FAIL 10: updated_at no actualizado';
  END IF;
END $$;
