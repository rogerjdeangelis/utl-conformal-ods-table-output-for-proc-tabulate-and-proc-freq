%let pgm=utl-conformal-ods-table-output-for-proc-tabulate-and-proc-freq;

Conformal ods table output for proc tabulate and proc freq

github
https://tinyurl.com/ruak6u3
https://github.com/rogerjdeangelis/utl-conformal-ods-table-output-for-proc-tabulate-and-proc-freq

related repo
github
https://tinyurl.com/w7qxsyx
https://github.com/rogerjdeangelis/utl-fixing-ods-output-bug-in-proc-freq-crosstab-creating-ods-crosstab-table

macros
https://tinyurl.com/y9nfugth
https://github.com/rogerjdeangelis/utl-macros-used-in-many-of-rogerjdeangelis-repositories


PROBLEM: I want a SAS table that looks like 'proc tabulate' static print output.

----------------------------------------------------------------------------------------------------------------
|Make          |            TYPE             |            TYPE             |             COUNTS                |
|              |-----------------------------+-----------------------------+-----------------------------------|
|              |   SUV   |  Sedan  |  Wagon  |   SUV   |  Sedan  |  Wagon  |              TYPE                 |
|              |---------+---------+---------+---------+---------+---------+-----------------------------------|
|              | INVOICE | INVOICE | INVOICE |  MSRP   |  MSRP   |  MSRP   | SUV     |   Sedan    |   Wagon    |
|--------------+---------+---------+---------+---------+---------+---------+---------+------------+------------|
|Volkswagen    |  $32,243| $335,813|  $77,184|  $35,515| $364,020|  $84,195|     1.00|       11.00|        3.00|
|--------------+---------+---------+---------+---------+---------+---------+---------+------------+------------|
|Volvo         |  $38,851| $313,990|  $57,753|  $41,250| $333,240|  $61,280|     1.00|        9.00|        2.00|
----------------------------------------------------------------------------------------------------------------


Below are numerous work arounds for the missing ods functionality with proc tabulate (and other SAS procs (print freq report).
The order of varables in the output table may be different then tabulate.


SOAPBOX ON
  Over the years I have shied-away fro using 'proc tabulate' mainly because of being painted
  into a corner.
  When ods came out I quickly noticed a serious bug with tabulate. It does not honor 'ods output'.
  Here are some lame attempts to get 'ods output' out of tabulate.
SOAPBOX OFF

Notes

  Note 'proc transpose cannot easily transpose sets of related variables' but Att's fast transpose macro can.


   1.  proc report alone can ptovide an 'ods' like ouput table but because of an ods bug we have to manually rename _c##_ vars
   2.  Proc corresp does a nice job of generating column names but requies the untranspose macro first
   3.  I use macro utl_gather instaed of utl_transpose because of a type issue with transposing or I don't know how to set type.
       https://github.com/clindocu (Alea Iacta)
   4.  Thinking aout code to output to excel and inport?


Problem: I want tabulate output like tis in a SAS table

    Six solutions (more of an academic execise)

       a. proc tabulate output dataset (basically the same as proc summary/means)
       b. proc means output
       c. Proc report
       d. Proc corresp
       e. utl_odstab macro (experimental- basically uou have to turn off stacked headings - make tabulate retangular)
       f. utl_odsfrq macro (experimental similar to utl_odstab - less retrictive than utl_odstab)

*_                   _
(_)_ __  _ __  _   _| |_
| | '_ \| '_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
;

data have;
  set sashelp.cars(
      where=(make=:"V")
      keep = make type invoice msrp
      );
  format _numeric_;
  count=1;
run;quit;


WORK.CARS total obs=27

 MAKE          TYPE      MSRP    INVOICE COUNT

 Volkswagen    SUV      35515     32243    1
 Volkswagen    Sedan    18715     17478    1
 Volkswagen    Sedan    19825     18109    1
 Volkswagen    Sedan    21055     19638    1
 Volkswagen    Sedan    21055     19638    1
 Volkswagen    Sedan    23785     21686    1
 Volkswagen    Sedan    23215     21689    1
 Volkswagen    Sedan    23955     21898    1
 Volkswagen    Sedan    33180     30583    1
 Volkswagen    Sedan    39235     36052    1
 Volkswagen    Sedan    65000     59912    1
 Volkswagen    Sedan    75000     69130    1
 Volkswagen    Wagon    19005     17427    1
 Volkswagen    Wagon    24955     22801    1
 Volkswagen    Wagon    40235     36956    1
...
*            _               _
  ___  _   _| |_ _ __  _   _| |_ ___
 / _ \| | | | __| '_ \| | | | __/ __|
| (_) | |_| | |_| |_) | |_| | |_\__ \
 \___/ \__,_|\__| .__/ \__,_|\__|___/
                |_|
           _        _           _       _
  __ _    | |_ __ _| |__  _   _| | __ _| |_ ___
 / _` |   | __/ _` | '_ \| | | | |/ _` | __/ _ \
| (_| |_  | || (_| | |_) | |_| | | (_| | ||  __/
 \__,_(_)  \__\__,_|_.__/ \__,_|_|\__,_|\__\___|

;

WANTTAB total obs=2

                     INVOICE_     MSRP_      COUNT_     INVOICE_    MSRP_SUM_      COUNT_      INVOICE_    MSRP_SUM_      COUNT_
Obs    MAKE           SUM_SUV    SUM_SUV    SUM_SUV    SUM_SEDAN      SEDAN      SUM_SEDAN    SUM_WAGON      WAGON      SUM_WAGON

 1     Volkswagen      32243      35515        1         335813       364020         11         77184        84195          3
 2     Volvo           38851      41250        1         313990       333240          9         57753        61280          2

*              _
  ___ ___   __| | ___
 / __/ _ \ / _` |/ _ \
| (_| (_) | (_| |  __/
 \___\___/ \__,_|\___|

;

* note I have turned of most headers and emoved the dollar format also box option dupplies a missing column name.


proc tabulate data=have out=havTab;

  class make type;
  var invoice msrp count;

  table
    make=''
    ,
    type='' * invoice='' * sum='' /* *f=dollar9. */
    type='' * msrp=''    * sum='' /* *f=dollar9. */
    type='' * count=''   * sum='' /* *f=dollar9. */
    /
    box = 'Make'
  ;

run;quit;

%utl_transpose(data=havTab, out=wantTab, by=make, id=type,delimiter=_, var=count_sum invoice_sum msrp_sum);


*_
| |__     _ __ ___   ___  __ _ _ __  ___
| '_ \   | '_ ` _ \ / _ \/ _` | '_ \/ __|
| |_) |  | | | | | |  __/ (_| | | | \__ \
|_.__(_) |_| |_| |_|\___|\__,_|_| |_|___/


WORK.WANTAVG total obs=2

                           INVOICE_     MSRP_      CNT_     INVOICE_    MSRP_SUM_     CNT_     INVOICE_    MSRP_SUM_
  MAKE          CNT_SUV     SUM_SUV    SUM_SUV    SEDAN    SUM_SEDAN      SEDAN      WAGON    SUM_WAGON      WAGON

  Volkswagen       1         32243      35515       11       335813       364020       3        77184        84195
  Volvo            1         38851      41250        9       313990       333240       2        57753        61280

*              _
  ___ ___   __| | ___
 / __/ _ \ / _` |/ _ \
| (_| (_) | (_| |  __/
 \___\___/ \__,_|\___|

;
proc means data=have  missing sum n nway;
class make type;
var invoice msrp;
output out=havAvg (rename=_freq_=cnt) sum= / autoname;
run;quit;

%utl_transpose(data=havAvg, out=wantAvg, by=make, id=type ,delimiter=_, var=cnt invoice_sum msrp_sum );

*                                   _
  ___     _ __ ___ _ __   ___  _ __| |_
 / __|   | '__/ _ \ '_ \ / _ \| '__| __|
| (__ _  | | |  __/ |_) | (_) | |  | |_
 \___(_) |_|  \___| .__/ \___/|_|   \__|
                  |_|

;
WORK.WANT total obs=2

                     SUM_INVOICE_      SUM_      CNT_INVOICE_    SUM_INVOICE_    SUM_MSRP_    CNT_INVOICE_    SUM_INVOICE_      SUM_      CNT_INVOICE_
Obs    MAKE               SUV        MSRP_SUV         SUV            SEDAN         SEDAN          SEDAN            WGN        MSRP_WGN         WGN

 1     Volkswagen        32243         35515           1            335813         364020          11             77184         84195           3
 2     Volvo             38851         41250           1            313990         333240           9             57753         61280           2
*              _
  ___ ___   __| | ___
 / __/ _ \ / _` |/ _ \
| (_| (_) | (_| |  __/
 \___\___/ \__,_|\___|

;
proc report data=have
nowd missing out=want (rename=(
   _c2_ =  sum_invoice_suv
   _c3_ =  sum_msrp_suv
   _c4_ =  cnt_invoice_suv
   _c5_ =  sum_invoice_sedan
   _c6_ =  sum_msrp_sedan
   _c7_ =  cnt_invoice_sedan
   _c8_ =  sum_invoice_wgn
   _c9_ =  sum_msrp_wgn
   _c10_=  cnt_invoice_wgn
));
     ;
format _numeric_;
cols make type, (invoice msrp invoice=count);
define make     / group;
define type     / across;
define invoice  / sum;
define msrp     / sum;
define count  / n;
run;quit;

*    _
  __| |     ___ ___  _ __ _ __ ___  ___ _ __
 / _` |    / __/ _ \| '__| '__/ _ \/ __| '_ \
| (_| |_  | (_| (_) | |  | | |  __/\__ \ |_) |
 \__,_(_)  \___\___/|_|  |_|  \___||___/ .__/
                                       |_|
;

Up to 40 obs from WANTCOR total obs=3

                     SUV___     SUV___    SUV___    SEDAN___    SEDAN___    SEDAN___    WAGON___    WAGON___    WAGON___
Obs    LABEL          COUNT    INVOICE     MSRP       COUNT      INVOICE      MSRP        COUNT      INVOICE      MSRP        SUM

 1     Volkswagen       1       32243      35515       11        335813      364020         3         77184       84195      928985
 2     Volvo            1       38851      41250        9        313990      333240         2         57753       61280      846376
 3     Sum              2       71094      76765       20        649803      697260         5        134937      145475     1775361
*              _
  ___ ___   __| | ___
 / __/ _ \ / _` |/ _ \
| (_| (_) | (_| |  __/
 \___\___/ \__,_|\___|

;
%utl_gather(have,maketype,tot,make type,havGth,valformat=12.);

ods exclude all;
ods output observed=wantCor;
proc corresp data=havGth dim=1 observed  cross=both;
tables make, type  maketype;
weight tot;
run;quit;
ods select all;

*                   _       _        _           _       _
  ___      ___   __| |___  | |_ __ _| |__  _   _| | __ _| |_ ___
 / _ \    / _ \ / _` / __| | __/ _` | '_ \| | | | |/ _` | __/ _ \
|  __/_  | (_) | (_| \__ \ | || (_| | |_) | |_| | | (_| | ||  __/
 \___(_)  \___/ \__,_|___/  \__\__,_|_.__/ \__,_|_|\__,_|\__\___|

;

WORK.WANTODS total obs=2

                                                                                       INVOICE_                INVOICE_
                     INVOICE_    INVOICE_    INVOICE_    MSRP_                MSRP_     WAGON_     INVOICE_     SEDAN_
Obs    MAKE            MAKE         SUV        SEDAN     WAGON    MSRP_SUV    SEDAN       CNT       SUV_CNT       CNT

 1     Volkswagen      32243      335813       77184     35515     364020     84195        1          11           3
 2     Volvo           38851      313990       57753     41250     333240     61280        1           9           2
*              _
  ___ ___   __| | ___
 / __/ _ \ / _` |/ _ \
| (_| (_) | (_| |  __/
 \___\___/ \__,_|\___|

;

%utl_odstab(setup);

proc tabulate data=have out=havTab;

  class make type;
  var invoice msrp count;

  table
    make=''
    ,
    type='' * invoice='' * sum='' /* *f=dollar9. */
    type='' * msrp=''    * sum='' /* *f=dollar9. */
    type='' * count=''   * sum='' /* *f=dollar9. */
    /
    box = 'Make'
  ;

run;quit;


%utl_odstab(outdsn=havMap);


data wantods;
  set havMap(Drop=Var:  rename=(
      J1MAKE     =  Make
      J2SUV      =  INVOICE_MAKE
      J3SEDAN    =  INVOICE_SUV
      J4WAGON    =  INVOICE_SEDAN
      J5SUV      =  MSRP_WAGON
      J6SEDAN    =  MSRP_SUV
      J7WAGON    =  MSRP_SEDAN
      J8SUV      =  INVOICE_WAGON_CNT
      J9SEDAN    =  INVOICE_SUV_CNT
      J10WAGON   =  INVOICE_SEDAN_CNT
    ));
run;quit;



* __          _   _              _      __
 / _|   _   _| |_| |    ___   __| |___ / _|_ __ __ _
| |_   | | | | __| |   / _ \ / _` / __| |_| '__/ _` |
|  _|  | |_| | |_| |  | (_) | (_| \__ \  _| | | (_| |
|_|(_)  \__,_|\__|_|___\___/ \__,_|___/_| |_|  \__, |
                  |_____|                         |_|
;

Obs    ROWNAM    LEVEL         SUV_COU    SUV_INV    SUV_MSR    SED_COU    SED_INV    SED_MSR    WAG_COU    WAG_INV    WAG_MSR

 1     COUNT     Volkswagen       1        32243      35515       11       335813     364020        3        77184      84195
 5     COUNT     Volvo            1        38851      41250        9       313990     333240        2        57753      61280

*              _
  ___ ___   __| | ___
 / __/ _ \ / _` |/ _ \
| (_| (_) | (_| |  __/
 \___\___/ \__,_|\___|

;
%utl_gather(have,maketype,tot,make type,havFrq,valformat=12.);

data havVue/view=havVue;
   length typvar $32;
   set havFrq;
   typVar=catx("-",substr(type,1,3),substr(maketype,1,3));
   drop type rownam total;
run;quit;

%utl_odsfrq(setup);

proc freq data=havVue;
tables make*typvar;
weight tot;
run;quit;

%utl_odsfrq(outdsn=havOdsFrq);

proc print data=havOdsFrq(drop=total where=(rowNam='COUNT')) width=min;
run;quit;

*      _   _              _     _        _
 _   _| |_| |    ___   __| |___| |_ __ _| |__
| | | | __| |   / _ \ / _` / __| __/ _` | '_ \
| |_| | |_| |  | (_) | (_| \__ \ || (_| | |_) |
 \__,_|\__|_|___\___/ \__,_|___/\__\__,_|_.__/
           |_____|
;

%macro utl_odstab(outdsn);

   %if %qupcase(&outdsn)=SETUP %then %do;

        filename _tmp1_ clear;  * just in case;

        %utlfkil(%sysfunc(pathname(work))/_tmp1_.txt);

        filename _tmp1_ "%sysfunc(pathname(work))/_tmp1_.txt";

        %let _ps_= %sysfunc(getoption(ps));
        %let _fc_= %sysfunc(getoption(formchar));

        OPTIONS ls=max ps=32756  FORMCHAR='|'  nodate nocenter;

        title; footnote;

        proc printto print=_tmp1_;
        run;quit;

   %end;
   %else %do;

        /* %let outdsn=tst;  */

        proc printto;
        run;quit;

        filename _tmp2_ clear;

        %utlfkil(%sysfunc(pathname(work))/_tmp2_.txt);

        filename _tmp2_ "%sysfunc(pathname(work))/_tmp2_.txt";

        proc datasets lib=work nolist;  *just in case;
         delete &outdsn;
        run;quit;

        data _null_;
          retain pos n 0 newhed;
          length newhed $255 wrd $32;
          infile _tmp1_ length=l;
          input lyn $varying32756. l;
          if lyn ne "" then n=n+1;
          if countc(lyn,'|')>1;
          if n=1 then do;
             do i=1 to countc(lyn,'|')-1;
                newhed=catx('|',newhed,cats('j',put(i,2.),scan(lyn,i,'|')));
             end;
             lyn="|"!!newhed;
          end;
          lyn=compbl(lyn);
          putlog lyn;
          file _tmp2_;
          put lyn;
        run;quit;

        proc import
           datafile=_tmp2_
           dbms=dlm
           out=&outdsn
           replace;
           delimiter='|';
           getnames=yes;
        run;quit;

        filename _tmp1_ clear;
        filename _tmp2_ clear;

        %utlfkil(%sysfunc(pathname(work))/_tmp1_.txt);
        %utlfkil(%sysfunc(pathname(work))/_tmp2_.txt);

   %end;

%mend utl_odstab;

*      _   _              _      __
 _   _| |_| |    ___   __| |___ / _|_ __ __ _
| | | | __| |   / _ \ / _` / __| |_| '__/ _` |
| |_| | |_| |  | (_) | (_| \__ \  _| | | (_| |
 \__,_|\__|_|___\___/ \__,_|___/_| |_|  \__, |
           |_____|                         |_|
;

%macro utl_odsfrq(outdsn);

   %if %qupcase(&outdsn)=SETUP %then %do;

        filename _tmp1_ clear;  * just in case;

        %utlfkil(%sysfunc(pathname(work))/_tmp1_.txt);

        filename _tmp1_ "%sysfunc(pathname(work))/_tmp1_.txt";

        %let _ps_= %sysfunc(getoption(ps));
        %let _fc_= %sysfunc(getoption(formchar));

        OPTIONS ls=max ps=32756  FORMCHAR='|'  nodate nocenter;

        title; footnote;

        proc printto print=_tmp1_;
        run;quit;

   %end;
   %else %do;

        proc printto;
        run;quit;

        filename _tmp2_ clear;

        %utlfkil(%sysfunc(pathname(work))/_tmp2_.txt);

        filename _tmp2_ "%sysfunc(pathname(work))/_tmp2_.txt";

        proc datasets lib=work nolist;  *just in case;
         delete &outdsn;
        run;quit;

        data _null_;
          infile _tmp1_ length=l;
          input lyn $varying32756. l;
          if index(lyn,'Col Pct')>0 then substr(lyn,1,7)='LEVELN   ';
          lyn=compbl(lyn);
          if countc(lyn,'|')>1;
          putlog lyn;
          file _tmp2_;
          put lyn;
        run;quit;

        proc import
           datafile=_tmp2_
           dbms=dlm
           out=_temp_
           replace;
           delimiter='|';
           getnames=yes;
        run;quit;

        data &outdsn(rename=(_total=TOTAL));
          length rowNam $8 level $64;
          retain rowNam level ;
          set _temp_;
          select (mod(_n_-1,4));
            when (0) do; level=cats(leveln); rowNam="COUNT";end;
            when (1) rowNam="PERCENT";
            when (2) rowNam="ROW PCT";
            when (3) rowNam="COL PCT";
          end;
          drop leveln;
        run;quit;

        filename _tmp1_ clear;
        filename _tmp2_ clear;

        %utlfkil(%sysfunc(pathname(work))/_tmp1_.txt);
        %utlfkil(%sysfunc(pathname(work))/_tmp2_.txt);

   %end;

%mend utl_odsfrq;


