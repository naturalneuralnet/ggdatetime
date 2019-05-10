#! /usr/bin/bash

echo "+=====================================================================+"
echo "        Kind-a automated, bash/gcc unit testing for ggdatetime         "
echo "+=====================================================================+"

## Unit tests, compilable source files
unit_tests=( test_year.cpp test_month.cpp test_gps_week.cpp test_day_of_month.cpp )
echo " Intial source files:"
for fl in "${unit_tests[@]}" ; do echo "    * $fl" ; done

## Unit tests, non-compilable source files
declare -a errornuous_units_tests

##  For every source file, create (a) new one(s) in which we uncomment the 
##+ lines that contain CMP_ERROR, one line per file. E.g. if the file
##+ foo.cpp contains 5 lines that match "CMP_ERROR" we are going to create
##+ 5 different files; the file foo_error1.cpp will be the same as foo.cpp 
##+ except that the first line that matches "CMP_ERROR" will be uncommented.
##+ foo_error2.cpp will be the same as foo.cpp except that the second line 
##+ that matches "CMP_ERROR" will be uncommented (the first will be commented),
##+ and the same for foo_error3.cpp, foo_error4.cpp, and foo_error5.cpp
##
##  We will replace any line of type:
##+ "//[....]CMP_ERROR" with the part in braces, aka "[....]"
echo " Preparing erronuous (non-compilable source files"
for sc in "${unit_tests[@]}" ; do
  ## find have many lines we have, that contain CMP_ERROR
  OCC=$(cat $sc | grep '\(//\)\(.*;\)\( *\)\(CMP_ERROR\)' | wc -l)
  if test "${OCC}" -gt 1 ; then
    for OCC_NR in $(seq 1 $OCC) ; do
      error_file=${sc/.cpp/_error${OCC_NR}.cpp}
      tr '\n' '^' < $sc \
      | sed "s:\(//\)\( *[^;]*\)\(; *CMP_ERROR\):\2;:${OCC_NR}" \
      | tr '^' '\n' \
      > ${error_file}
      echo "    *$sc -> ${OCC_NR}/${OCC} created file: $error_file"
      errornuous_units_tests+=(${error_file})
    done
  elif test "${OCC}" -eq 1 ; then
    error_file=${sc/.cpp/_error.cpp}
    cat $sc | sed 's:\(//\)\(.*;\)\( *\)\(CMP_ERROR\):\2:g' > ${error_file}
    echo "    *$sc -> 1/1 created file: $error_file"
    errornuous_units_tests+=(${error_file})
  else
    echo "    *$sc -> No file to create"
  fi
done

echo " Compilable unit tests    : ${unit_tests[@]}"
echo " Non-Compilable unit tests: ${errornuous_units_tests[@]}"
>comp.log
echo " Ready to start compiling; all output directed to comp.log"

## Compile all compilable source code
echo " Compiling unit tests ..."
for nc in "${unit_tests[@]}" ; do
  echo "    g++ -std=c++17 -Wall -I../src -L../src ${nc} -o ${nc/.cpp/.o} -lggdatetime"
  if ! g++ -std=c++17 -Wall -I../src -L../src ${nc} -o ${nc/.cpp/.o} \
      -lggdatetime 2>>comp.log; then
    echo "FAILED; stoping with error" 1>&2
    exit 1
  fi
done

## If any of the non-compilable source codes compiles, trigger an error and stop
echo " Compiling erronuous unit tests ... (they should fail)"
for nc in "${errornuous_units_tests[@]}" ; do
  echo -n "    g++ -std=c++17 -Wall -I../src -L../src ${nc} -o ${nc/.cpp/.o} -lggdatetime ..."
  if g++ -std=c++17 -Wall -I../src -L../src ${nc} -o ${nc/.cpp/.o} \
      -lggdatetime 2>>comp.log ; then
    echo "FAILED; stoping with error" 1>&2
    exit 2
  else
    echo -e "failed"
  fi
done
echo ""

echo " Everything appears to have worked as expected!"
echo "+=====================================================================+"
exit 0
