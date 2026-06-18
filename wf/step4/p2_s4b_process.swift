
import assert;
import io;
import files;
import string;
import sys;

assert(argc() == 1, "p2_s4b_process.swift: Provide the list file!");

list_file = argp(1);

app (void v) process(string i, string ITR_DIR, string WORK_DIR)
{
  "p2_s4b_process.sh" i ITR_DIR WORK_DIR ;
}

lines = file_lines(input(list_file));

int A[];
foreach line, i in lines
{
  string tokens[] = split(line);
  int N = file_size(pdb);
  @prio=N
  process(tokens[0], tokens[1], tokens[2]) => A[i] = 0;
}

A => printf("WORKFLOW DONE!");
