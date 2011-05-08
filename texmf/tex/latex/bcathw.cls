\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{bcathw}[2011/05/06 Jonathan Rascher's homework class]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{amsart}}
\ProcessOptions\relax
\LoadClass[letterpaper]{amsart}

% Load math packages.
\RequirePackage{mathtools,thmtools,amssymb,mathrsfs}

\declaretheorem[name=Theorem]{thm}
\declaretheorem[sibling=thm,name=Proposition]{prop}
\declaretheorem[sibling=thm,name=Lemma]{lem}
\declaretheorem[sibling=thm,name=cor]{cor}

\declaretheorem[sibling=thm,name=Definition,style=definition]{defn}
\declaretheorem[sibling=thm,name=Example,style=definition]{xmp}
\declaretheorem[sibling=thm,name=Exercise,style=definition]{exer}

\declaretheoremstyle[notefont=,notebraces={}{}]{exer*}
\declaretheorem[numbered=no,name=Exercise,style=exer*]{exer*}

% Load font packages.
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage{lmodern,microtype}

% Load graphics packages.
\RequirePackage[dvipsnames,usenames]{color}
\RequirePackage{tikz}

% Load miscellaneous packages.
\RequirePackage{etoolbox,fixltx2e,multicol}

% Configure PDF links and metadata.
\RequirePackage[pdfusetitle]{hyperref}
\hypersetup{
  colorlinks,
  linkcolor=RawSienna,
  citecolor=RawSienna,
  urlcolor=RawSienna,
  pdfpagemode=UseNone,
  pdfstartview=FitH,
  pdfprintscaling=None}

% Load packages that must come after hyperref.
\RequirePackage{ellipsis}

% Prefer variant forms of epsilon and phi.
\let\bcathw@oldepsilon\epsilon
\let\bcathw@oldphi\phi

\let\epsilon\varepsilon
\let\phi\varphi

\let\varepsilon\bcathw@oldepsilon
\let\varphi\bcathw@oldphi

% Declare useful shorthand commands.
\newcommand*\N{\mathbb N}
\newcommand*\Z{\mathbb Z}
\newcommand*\Q{\mathbb Q}
\newcommand*\R{\mathbb R}
\newcommand*\C{\mathbb C}

\DeclareMathOperator\adj{adj}
\DeclareMathOperator\nullity{nullity}
\DeclareMathOperator\Tr{Tr}
\DeclareMathOperator\rank{rank}
\DeclareMathOperator\spans{span}

\DeclarePairedDelimiter\abs{\lvert}{\rvert}
\DeclarePairedDelimiter\norm{\lVert}{\rVert}

\newcommand*\vr[1]{\mathbf{#1}}

\newcommand*\nbds[1][-]{\nobreakdashes#1\hspace{0pt}}

\newcommand\autorefwrap[3]{\hyperref[#1]{#2\autoref*{#1}#3}}

% Extend amsmath to support augmented matrices.
% Source: <http://texblog.net/latex-archive/maths/amsmath-matrix/>.
\renewcommand*\env@matrix[1][*\c@MaxMatrixCols c]{%
  \hskip -\arraycolsep
  \let\@ifnextchar\new@ifnextchar
  \array{#1}}
