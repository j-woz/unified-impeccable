
/*
 DB PRINT SQL
 Just dump the tables for human inspection
 See db-print.sh for usage
*/

\dt

\echo == TASKS ==
select * from tasks;

\echo == EMEWS TASK TAGS ==
select * from task_tags;
