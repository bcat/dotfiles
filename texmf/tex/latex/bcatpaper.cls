\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{bcatpaper}[2011/05/28 Jonathan Rascher's college essay class]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{amsart}}
\ProcessOptions\relax
\LoadClass[12pt,letterpaper]{amsart}

% Set margins and line spacing.
\RequirePackage{fullpage}
\RequirePackage[doublespacing]{setspace}

% Load font packages.
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage{mathptmx,microtype}

% Load common preamble stuff.
\RequirePackage{bcat}
