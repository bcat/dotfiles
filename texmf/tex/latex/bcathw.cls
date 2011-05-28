\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{bcathw}[2011/05/28 Jonathan Rascher's homework class]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{amsart}}
\ProcessOptions\relax
\LoadClass[letterpaper]{amsart}

% Load font packages.
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage{lmodern,microtype}

% Load common preamble stuff.
\RequirePackage{bcat}
