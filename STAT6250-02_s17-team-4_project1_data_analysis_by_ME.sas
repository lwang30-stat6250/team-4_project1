*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* environmental setup;

* set relative file import path to current directory (using standard SAS trick;
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";


* load external file that generates analytic dataset FRPM1516_analytic_file;
%include '.\STAT6250-02_s17-team-4_project1_data_preparation.sas';

title1
'Research Question: Do some genres do better than others in theaters (i.e. have the highest gross)?';

title2
'Rationale: Action movies are thought to be the highest grossing movies. Does the data support this?';

footnote1
'The genre "family" has the highest average gross but it should be noted that the genre only contains 3 movies and the standard deviation is very high';

footnote2
'The "action" genre is actually fourth in average gross.';

*
Methodology: Use PROC MEANS with CLASS genre

Limitations: This is a fairly small dataset. The "family" genre only 
has 3 movies with values for the gross. Additionally, films can be classified
as having more than on genre. This analysis only looks at the first one listed.

Possible Follow-up Steps: Limit the output of PROC MEANS to genres where
n > 5.
;

proc means data=Movie_analytic_file maxdec = 2 mean median std min max;
	var gross;
	class genre;
	output out=gross_sumstat;
run;

proc sort data=gross_sumstat(where=(_STAT_="MEAN")) out=gross_mean_sorted;
    by descending gross;
run;
proc print noobs data=gross_mean_sorted(obs=4);
    var genre gross;
	label gross="mean gross";
run;
title;
footnote;

title1
'Movies titles from the top 4 genres order by gross';
footnote1
'The top ten highest grossing films are all action films';

proc sort data=Movie_analytic_file out=sorted_by_gross;
	by descending gross;
run;
proc print data=sorted_by_gross(obs=20);
	var genre movie_title gross;
	format gross dollar12.0;
	where genre in ("Family", "Adventure", "Animation", "Action");
run;
title;
footnote;


title1
'Research Question: Are there actors whose movies consistently do well?';

title2
'Rationale: Hollywood tends to reuse actors who are considered "hot" at the moment. Does this payoff?';

footnote1
'The report displays the number of movies by actor where the gross was in the top 25 percent';

footnote2
'The names on the top ten list are not surprising. There may be some basis for thinking that getting certain actors will result in a box office hit.';

*
Methodology:
1) Use PROC MEAN on the gross variable to find the quartiles
2) Use PROC FREQ to count gross quartiles by actor

Limitations: The same actor can also be in the actor_2_name or actor_3_name field.
This analysis does not take that information into consideration.

Possible Follow-up Steps: Do the same analysis for actor_2_name and actor_3_name 
then merge the results. It was also be interesting to see the percentage of the
actors films that were in the fourth quartile.
;

proc means data=Movie_analytic_file q1 median q3;
	var gross;
run; 

<<<<<<< HEAD
proc freq data=Movie_analytic_file order=freq noprint; 
=======
proc freq data=Movie_analytic_file order=freq; 
>>>>>>> refs/remotes/origin/master
	tables actor_1_name * gross / nopercent norow nocol out=grossQ_by_actor;
	format gross grossfmt.;
run;

* Sort by Q4 frequency (i.e. the number of movies where the gross was 
in the 4th quartile);
proc sort data=grossQ_by_actor(where=(gross>=62318875)) out=grossQ_by_actor_sorted;
    by descending count;
run;
proc print noobs data=grossQ_by_actor_sorted(obs=10) label;
	var actor_1_name gross count;
	label actor_1_name='Actor 1'
		gross='Gross'
		count='Count';
run;
title;
footnote;


title1
'Research Question: Are movies getting more expensive to make (i.e. Budget over time)?';

title2
'Rationale: To help movie studios budget future movies.';
footnote1
'See chart "Average Budget by Year"';

*
Methodology: Use PROC MEANS to get the mean with VAR budget CLASS title_year. 
Then chart the results.

Limitations: The budget data is not adjusted for inflation.

Possible Follow-up Steps: The budget should be adjusted for inflation.
;
proc means data=Movie_analytic_file maxdec = 2;
	var budget;
	class title_year;
	output out=budget_sumstat
		mean=AvgBudget;
run;

title "Average Budget by Year";
footnote1
'The budget seems to be increasing exponentially over time.';

proc gplot data=budget_sumstat;                                                                                                                 
   plot AvgBudget*title_year;                                                                             
run;
quit;
title;
footnote;
