@echo off
setlocal

rem Always run from the script directory so relative paths work.
cd /d "%~dp0"

set TEXFILE=main
set OUTDIR=build
set PDFPATH=%OUTDIR%\%TEXFILE%.pdf
rem Allow BibTeX/LaTeX to find .bib/.bst when aux files live under build\
set TEXINPUTS=.;%CD%\;;
set BIBINPUTS=.;%CD%\;;
set BSTINPUTS=.;%CD%\;;

echo Compiling %TEXFILE%.tex into %OUTDIR%...

if not exist "%OUTDIR%" (
    mkdir "%OUTDIR%"
)

rem Clean previous build artifacts inside the output folder.
del /Q "%OUTDIR%\%TEXFILE%.*" 2>nul
if exist "%OUTDIR%\_minted-%TEXFILE%" rd /s /q "%OUTDIR%\_minted-%TEXFILE%"
if exist "_minted-%TEXFILE%" rd /s /q "_minted-%TEXFILE%"

rem First pass to generate aux files.
pdflatex -interaction=nonstopmode -file-line-error -output-directory "%OUTDIR%" "%TEXFILE%.tex"
if errorlevel 1 goto end

rem BibTeX pass for references.
pushd "%OUTDIR%" >nul
bibtex "%TEXFILE%"
if errorlevel 1 (
    popd >nul
    goto end
)
popd >nul

rem Final passes to resolve references.
pdflatex -interaction=nonstopmode -file-line-error -output-directory "%OUTDIR%" "%TEXFILE%.tex"
pdflatex -interaction=nonstopmode -file-line-error -output-directory "%OUTDIR%" "%TEXFILE%.tex"

if not exist "%PDFPATH%" (
    echo Build finished but %PDFPATH% was not created. Check the log for errors.
    goto end
)

echo Build succeeded: %PDFPATH%
echo Copying PDF to working directory...
copy /Y "%PDFPATH%" "%TEXFILE%.pdf" >nul

:end
endlocal
