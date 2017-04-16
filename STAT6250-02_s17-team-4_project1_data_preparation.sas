
*
[Dataset Name] IMDB 5000 Movie Dataset

[Experimental Unit] 5000+ movies from IMDB website

[Number of Observations] 5,043

[Number of Features] 28

[Data Source] https://www.kaggle.com/deepmatrix/imdb-5000-movie-dataset/downloads/imdb-5000-movie-dataset.zip

[Data Dictionary] https://www.kaggle.com/deepmatrix/imdb-5000-movie-dataset

[Unique ID Schema] The column “movie_imdb_link” is a primary key
;

%let inputDatasetURL =
https://github.com/stat6250/team-4_project1/blob/master/movie_metadata.xls?raw=true
;

filename tempfile TEMP;
proc http
     method="get"
	 url="&inputDatasetURL."
	 out=tempfile
	 ;
run;

proc import
     file=tempfile
	 out=movie_data
	 dbms=xls;
run;
filename tempfile clear;


