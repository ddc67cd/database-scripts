-- The following script shows how which relations (tables) should be processed by the autovacuum daemon.
-- Note: autovacuum_vacuum_threshold and autovacuum_vacuum_scale_factor are
-- database level settings and not specific to the table so some results might
-- not be correct.

select  psut.schemaname||'.'||psut.relname as relation
,       to_char(psut.last_vacuum, 'yyyy-mm-dd hh24:mi') as last_vacuum
,       to_char(psut.last_autovacuum, 'yyyy-mm-dd hh24:mi') as last_autovacuum
,       to_char(pc.reltuples, '9g999g999g999') as num_recs
,       to_char(psut.n_dead_tup, '9g999g999g999') as dead_recs
,       round(cast(case when pc.reltuples > 0 then psut.n_dead_tup/pc.reltuples else 0 end as numeric),2) as perc_change
,       to_char(cast(current_setting('autovacuum_vacuum_threshold') as bigint)
        + (cast(current_setting('autovacuum_vacuum_scale_factor') as numeric)
        * pc.reltuples), '9g999g999g999') as av_threshold
,       case
            when cast(current_setting('autovacuum_vacuum_threshold') as bigint)
            + (cast(current_setting('autovacuum_vacuum_scale_factor') as numeric)
            * pc.reltuples) < psut.n_dead_tup
            then 'Y'
            else 'N'
        end as av_expected
,       'vacuum full analyze verbose '||psut.schemaname||'.'||psut.relname||';' as clean_query
from    pg_stat_all_tables psut
,       pg_class pc
where   1=1
and     psut.relid = pc.oid
and     psut.schemaname not in ('pg_catalog','pg_toast','information_schema')
and     case
            when cast(current_setting('autovacuum_vacuum_threshold') as bigint)
                + (cast(current_setting('autovacuum_vacuum_scale_factor') as numeric)
                * pc.reltuples) < psut.n_dead_tup
            then 'Y'
            else 'N'
        end = 'Y'
and     psut.schemaname||'.'||psut.relname not in ('ui.communication_spend_mv')
--and     psut.relname = 'import_conversions'
--and     psut.autovacuum_count > 0
order by psut.n_dead_tup desc
limit 1;
