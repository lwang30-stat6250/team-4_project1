*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
[Dataset Name] IMDB 5000 Movie Dataset

[Experimental Unit] 5000+ movies from IMDB website

[Number of Observations] 5,043

[Number of Features] 29

[Data Source] https://www.kaggle.com/deepmatrix/imdb-5000-movie-dataset/downloads/imdb-5000-movie-dataset.zip

[Data Dictionary] https://www.kaggle.com/deepmatrix/imdb-5000-movie-dataset, 
"genre" field generated from first genre in the "genres" field and added

[Unique ID Schema] The column “movie_imdb_link” is a primary key
;


*environmental setup;

*create output format;

proc format;
	value $country_bins
	"USA"="USA"
	other="Not_USA"
	;	
	value budget_bins
		low-6000000="Q1 budget"
		6000001-20000000="Q2 budget"
		20000001-45000000="Q3 budget"
		45000001-high="Q4 budget"
	;
	value gross_bins
		low-5333658="Q1 gross"
		5333659-25517500="Q2 gross"
		25517501-62318875="Q3 gross"
		62318876-high="Q4 gross"
	;
	value imdb_score_bins
		low-<5.8="Q1 imdb_score"
		5.8-<6.6="Q2 imdb_score"
		6.6-<7.2="Q3 imdb_score"
		7.2-high="Q4 imdb_score"
	;
	value grossfmt  
		low - <5333658.00			= "Gross Q1"
		5333658.00 - <25517500.00	= "Gross Q2"
		25517500.00 - <62318875.00	= "Gross Q3"
		62318875.00 - high			= "Gross Q4"
	;
run;


* setup environmental parameters;
%let inputDatasetURL =
https://github.com/stat6250/team-4_project1/blob/master/movie_metadata_edit.xls?raw=true
;

* load raw movie dataset over the wire;
%macro loadDataIfNotAlreadyAvailable(dsn,url,filetype);
	%put &=dsn;
	%put &=url;
	%put &filetype;
	%if
		%sysfunc(exist(&dsn.)) = 0
	%then
		%do;
			%put Loading dataset &dsn. over the wire now...;
			filename tempfile TEMP;
			proc http
				method="get"
				url="&url."
				out=tempfile
				;
			run;
			proc import
				file=tempfile
				out=&dsn.
				dbms=&filetype.;
			run;
			filename tempfile clear;
		%end;
	%else
		%do;
			%put Dataset &dsn. already exist. Please delete and try again.;
		%end;
%mend;
%loadDataIfNotAlreadyAvailable(
	movie_data,
	&inputDatasetURL.,
	xls
)


* check movie dataset for duplicates with respect to its unique key;
* adding the title_year did not change the number of duplicates, 
* 	those are true duplicates;
proc sort nodupkey data=movie_data dupout=movie_data_dups out=_null_;
	by movie_imdb_link;
run;


* build analytic dataset from movie dataset with the least number of columns 
and minimal cleaning/transformation needed to address research questions in
corresponding data-analysis files;

data movie_analytic_file;
	retain 
		movie_imdb_link
		movie_title
		country
		title_year
		duration
		genre
		budget
		gross
		imdb_score
		actor_1_name
		actor_2_name
		actor_3_name
	;
	keep
		movie_imdb_link
		movie_title
		country
		title_year
		duration
		genre
		budget
		gross
		imdb_score
		actor_1_name
		actor_2_name
		actor_3_name
	;
	set movie_data;
run;


*Data manipulation steps;
	
*
Use data step to store the reformatted "country" variable into a dataset;
data new_country_data;
	set movie_analytic_file;
	format country country_bins.;
run;

*
Use proc means to compute the five-number summary for both "budget" and 
"gross" to bin those two variables based on quartiles;
proc means min q1 median q3 max data=movie_analytic_file;
	var
		budget
		gross
	;
run;

*
Use proc means to obtain five-number summary of "imdb_score" to bin its 
values, and then store the reformatted variables into a new analysis-ready
dataset by a data step;
proc means min q1 median q3 max data=movie_analytic_file;
	var imdb_score;
run;
data new_imdb_score_data;
	set movie_analytic_file;
		keep movie_imdb_link movie_title imdb_score gross;
		format imdb_score imdb_score_bins.;
run;
*All data manipulation steps above will be used as part of data analysis by LW;


*
Use PROC MEANS to compute the mean, median, standrard deviation, min, and max
by genre and output the results to a summary dataset and use PROC SORT
to extract and sort just the means from the summary. Also use PROC SORT
to sort the original data by gross. 
This will be used as part of data analysis by ME.
;
proc means data=Movie_analytic_file maxdec = 2 mean median std min max;
	var gross;
	class genre;
	output out=gross_sumstat;
run;
proc sort data=gross_sumstat(where=(_STAT_="MEAN")) out=gross_mean_sorted;
    by descending gross;
run;
proc sort data=Movie_analytic_file out=sorted_by_gross;
	by descending gross;
run;

*
Use PROC MEANS to compute q1, median, and q3. The numbers are then used
to hard code the format statements. Then use PROC FREQ to get a two-way
table of counts by actor and gross (which has been binned into quartiles)
and output to a file. Use PROC SORT to sort by count descending only rows
where the gross was in the 4th quartile.
This will be used as part of data analysis by ME.
;
proc means data=Movie_analytic_file q1 median q3;
	var gross;
run; 
proc freq data=Movie_analytic_file order=freq noprint; 
	tables actor_1_name * gross / nopercent norow nocol out=grossQ_by_actor;
	format gross grossfmt.;
run;
proc sort data=grossQ_by_actor(where=(gross>=62318875)) out=grossQ_by_actor_sorted;
    by descending count;
run;

