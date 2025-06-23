
/**
    WORKFLOW SQL
    Initialize the PSQL DB for workflows
    See db-create.py for usage
*/

/* For SQLite: */
/* PRAGMA foreign_keys = ON; */

/*
  Each row here is a model run
  See desc-email for original definitions
*/
create table tasks (
       /* the task id; task_id==0 is the dummy null point */
       task_id integer PRIMARY KEY,
       /* e.g. 'experiment':'X-032' or 'iteration':421 */
       description text,
       /* major phase in workflow */
       step integer,
       /* minor phase in workflow */ 
       substep integer,
       /* learn about this */     
       member integer,
       /* learn about this */            
       iteration integer,
       /* See db_tools.py for valid status codes */
       status integer,
       /* time this task started */
       time_start timestamp,
       /* time this task finished */
       time_stop  timestamp
);

/*
  A given task_id may have multiple tags here
*/      
create table task_tags (
       task_id integer PRIMARY KEY,
       tag text
);


