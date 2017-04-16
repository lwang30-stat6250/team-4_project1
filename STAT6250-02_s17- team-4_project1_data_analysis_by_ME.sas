*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* environmental setup;

* set relative file import path to current directory (using standard SAS trick;
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";


* load external file that generates analytic dataset FRPM1516_analytic_file;
%include '.\STAT6250-02_s17-team-4_project1_data_preparation.sas';

*
Research Question: Do some genres do better than others in theaters 
(i.e. have the highest gross)?

Rationale: Action movies are thought to be the highest grossing movies. 
Does the data support this?

Methodology: First sort the data by genre to a temporary file. Then use the 
PROC PRINT statement with SUM gross BY genre.

Limitations: 1) The genre field has multiple values separated by ‘|’. Sorting 
will only be by the first value. 2) The dataset is known to have missing values 
for the gross that are set to 0. It’s not really possible for a movie to have 
$0 of gross.

Possible Follow-up Steps: 1) The data could be pre-processed to split the genre 
field into dummy fields.  2) Add a WHERE gross > 0 statement to PROC PRINT
;

*
Research Question: Are there actors whose moves consistently do well?

Rationale: Hollywood tends to reuse actors who are considered "hot" at the 
moment. Does this payoff?

Methodology: Use PROC MEANS with VAR gross and CLASS actor1 to get the mean, 
standard deviation, minimum, and maximum. Sort by the mean to get the top 10.

Limitations: The same actor can also be in the actor2 or actor3 field. This 
analysis does not take that information into consideration.

Possible Follow-up Steps: 
;

*
Research Question: Are movies getting more expensive to make 
(i.e. Budget over time)?

Rationale: 

Methodology: Use PROC MEANS to get the mean with VAR budget CLASS title_year. 
Then chart the results.

Limitations: The budget data is not adjusted for inflation.

Possible Follow-up Steps: The budget should be adjusted for inflation.
;

