\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{bcathw}[2011/05/31 Jonathan Rascher's homework class]

% Load e-TeX helper commands.
\RequirePackage{etoolbox}

% Define empty commands that will be filled in by class options.
\newcommand*\@bcathw@setupclass\relax
\newcommand*\@bcathw@setuplayout\relax
\newcommand*\@bcathw@setupfonts\relax

\DeclareOption{amsart}{
  \renewcommand*\@bcathw@setupclass{
    \LoadClass{amsart}}}

\DeclareOption{article}{
  \renewcommand*\@bcathw@setupclass{
    \LoadClass{article}
    \RequirePackage{amsthm}}}

% Declare option to typeset the document with normal LaTeX margins. (Default.)
\DeclareOption{latex}{
  \renewcommand*\@bcathw@setuplayout\relax}

% Declare option to typeset the document with "standard" college essay
% formating (double-spaced with 1 in margins).
\DeclareOption{essay}{
  \renewcommand*\@bcathw@setuplayout{
    \RequirePackage{fullpage}
    \RequirePackage[doublespacing]{setspace}}}

% Declare option to typeset the document in MLA style. (Incomplete!)
\DeclareOption{mla}{
  \ExecuteOptions{essay}
  \renewcommand*\@bcathw@setuplayout{
    \RequirePackage[margin=1in,headheight=14pt,headsep=22.135pt]{geometry}
    \RequirePackage[doublespacing]{setspace}

    \RequirePackage{fancyhdr}
    \fancypagestyle{plain}{\pagestyle{fancy}}
    \pagestyle{fancy}
    \fancyhf{}
    \rhead{\@bcathw@mlaauthor\ \thepage}
    \renewcommand*\headrulewidth{0pt}
    \renewcommand*\footrulewidth{0pt}

    \RequirePackage[none]{hyphenat}}

  \raggedright
  \frenchspacing

  \AtEndOfClass{
    \renewcommand*\today{%
      \number\day
      \ifcase\month
        \or\ Jan.
        \or\ Feb.
        \or\ Mar.
        \or\ Apr.
        \or\ May
        \or\ June
        \or\ July
        \or\ Aug.
        \or\ Sept.
        \or\ Oct.
        \or\ Nov.
        \or\ Dec.
      \fi
      \number\year}

    \let\@date\today

    \def\maketitle{%
      \begingroup%
      \setlength\parindent{0pt}%
      \authors

      \@bcathw@mlainstructor

      \@bcathw@mlacourse

      \@date

      \centering\@title

      \endgroup}}

  \AtBeginDocument{
    \setlength\parindent{0.5in}}

  \newcommand*\mlaauthor[1]{\def\@bcathw@mlaauthor{#1}}
  \newcommand*\mlainstructor[1]{\def\@bcathw@mlainstructor{#1}}
  \newcommand*\mlacourse[1]{\def\@bcathw@mlacourse{#1}}}

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
\ExecuteOptions{amsart,latex,lmodern}
\ProcessOptions\relax
\@bcathw@setupclass

% Load geometry packages.
\@bcathw@setuplayout

% Load font packages.
\RequirePackage[utf8]{inputenc}
\@bcathw@setupfonts
\RequirePackage{microtype}

% Load common preamble stuff.
\RequirePackage{bcat}
