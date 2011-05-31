\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{bcathw}[2011/05/31 Jonathan Rascher's homework class]

% Define empty commands that will be filled in by class options.
\newcommand*\@bcathw@setupgeometry\relax
\newcommand*\@bcathw@setupfonts\relax

% Declare option to typeset the document with normal LaTeX margins. (Default.)
\DeclareOption{latex}\relax

% Declare option to typeset the document with "standard" college essay
% formating (double-spaced with 1 in margins).
\DeclareOption{essay}{
  \renewcommand*\@bcathw@setupgeometry{
    \RequirePackage{fullpage}
    \RequirePackage[doublespacing]{setspace}}}

% Declare option to typeset the document in Latin Modern. (Default.)
\DeclareOption{lmodern}{
  \renewcommand*\@bcathw@setupfonts{
    \RequirePackage[T1]{fontenc}
    \RequirePackage{amssymb,mathrsfs,lmodern}}}

% Declare option to typeset the document in Minion Pro.
\DeclareOption{minion}{
  \renewcommand*\@bcathw@setupfonts{
    \RequirePackage{mathrsfs}
    \RequirePackage[fullfamily,minionint]{MinionPro}
    \preto\@settitle{
      \figureversion{lf}}}}

% Declare option to typeset the document in a Palatino clone.
\DeclareOption{palatino}{
  \renewcommand*\@bcathw@setupfonts{
    \RequirePackage[T1]{fontenc}
    \RequirePackage{amssymb,mathrsfs,mathpazo}}}

% Declare option to typeset the document in a Times clone.
\DeclareOption{times}{
  \renewcommand*\@bcathw@setupfonts{
    \RequirePackage[T1]{fontenc}
    \RequirePackage{amssymb,mathrsfs,mathptmx}
    \DeclareMathAlphabet{\mathcal}{OMS}{lmsy}{m}{n}}}

% Process class options, passing unrecognized options on to amsart.
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{amsart}}
\ExecuteOptions{latex,lmodern}
\ProcessOptions\relax
\LoadClass{amsart}

% Load e-TeX helper commands.
\RequirePackage{etoolbox}

% Load geometry packages.
\@bcathw@setupgeometry

% Load font packages.
\RequirePackage[utf8]{inputenc}
\@bcathw@setupfonts
\RequirePackage{microtype}

% Load common preamble stuff.
\RequirePackage{bcat}
