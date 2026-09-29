# Influenca Demo

https://run.pavlovia.org/neuromadlab/influenca-demo/

*Folder ```Data``` with Influenca files is necessary*

1. ```Preprocessing_demo.m```
   - Creates cleaned data files in folder ```Data_Cleaned```
   - Creates logfile ```processed_files_log.txt``` (each file is only processed once)
2. ```Analysis_tables_demo.m```
   - Creates run and trial tables with ML estimates in folder ```Tables```
   - Script loops through all files and applies functions from folder ```functions```
3. ```Influenca_demo_plots.R```
   - Creates plots for individual IDs and the whole sample in folder ```plots```
   - Type an ID in at the top of the script
