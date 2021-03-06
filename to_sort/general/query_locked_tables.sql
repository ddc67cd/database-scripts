select   a.session_id
,        a.oracle_username
,        a.os_user_name
,        b.owner "object owner"
,        b.object_name
,        b.object_type
,        a.locked_mode
from     (
         select   object_id
         ,        session_id
         ,        oracle_username
         ,        os_user_name
         ,        locked_mode
         from     v$locked_object
         ) a
,        (
         select   object_id
         ,        owner
         ,        object_name
         ,        object_type
         from     dba_objects
         ) b
where    1=1
and      a.object_id = b.object_id;