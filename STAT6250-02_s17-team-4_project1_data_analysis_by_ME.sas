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

Methodology: Use PROC MEANS with CLASS genre

Limitations: 
The dataset is known to have missing values for the gross that are set to 0. 
It's not really possible for a movie to have $0 of gross.

Possible Follow-up Steps:
Add a WHERE gross > 0 statement to PROC PRINT. This does not appear to be a
;

proc means data=Movie_analytic_file maxdec = 2;
	var gross;
	class genre;
	output out=gross_sumstat;
run;

proc sort data=gross_sumstat(where=(_STAT_="MEAN") out=gross_mean_sorted);
    by descending gross;
run;
proc print noobs data=gross_mean_sorted(obs=20);
    var genre gross;
	label gross="mean gross";
run;


* Display the movies titles from with the top 4 genres;
proc sort data=Movie_analytic_file out=sorted_by_gross;
	by descending gross;
run;
proc print data=sorted_by_gross;
	var genre movie_title gross;
	where genre in ("Family", "Adventure", "Animation", "Action");
run;

*
Research Question: Are there actors whose moves consistently do well?

Rationale: Hollywood tends to reuse actors who are considered "hot" at the 
moment. Does this payoff?

Methodology:
1) Use PROC MEAN on the gross variable to find the quartiles
2) Use PROC FREQ to count gross by actor

Limitations: The same actor can also be in the actor2 or actor3 field. This 
analysis does not take that information into consideration.

Possible Follow-up Steps: 
;

proc means data=Movie_analytic_file q1 median q3;
	var gross;
run; 

proc format;
	value grossfmt  
		low - <5333658.00			= "Gross Q1"
		5333658.00 - <25517500.00	= "Gross Q2"
		25517500.00 - <62318875.00	= "Gross Q3"
		62318875.00	- high			= "Gross Q4"
	;

* Can't order by gross Q4;
* Using out=grossQ_by_actor did not produce the desired table;
proc freq data=Movie_analytic_file order=freq; 
	tables actor_1_name * gross / nopercent norow nocol;
	format gross grossfmt.;
run;

*
Research Question: Are movies getting more expensive to make 
(i.e. Budget over time)?

Rationale: 

Methodology: Use PROC MEANS to get the mean with VAR budget CLASS title_year. 
Then chart the results.

Limitations: The budget data is not adjusted for inflation.

Possible Follow-up Steps: The budget should be adjusted for inflation.
;

