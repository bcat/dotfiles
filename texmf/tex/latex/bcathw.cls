\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{bcathw}[2012/02/08 Jonathan Rascher's homework class]

% Load e-TeX helper commands and TeX engine conditionals.
\RequirePackage{etoolbox,iftex}

% Declare option to typeset the document with normal LaTeX margins, in
% single-spaced Latin Modern set at 10pt. (Default.)
\DeclareOption{latex}{
  \ExecuteOptions{10pt,lmodern,singlespacing}

  \def\bcathw@setuplayout{\bcathw@amsfixes}
}

% Declare option to typeset the document with tiny margins, in single-spaced
% Latin Modern set at 10pt. This is useful for full-page diagrams.
\DeclareOption{diagram}{
  \ExecuteOptions{10pt,lmodern,singlespacing}

  \def\bcathw@setuplayout{
    \bcathw@amsfixes

    \RequirePackage[margin=0.28in]{geometry}
  }
}

% Declare option to typeset the document with "standard" college essay
% formating, i.e., with one-inch margins, half-inch indentation, and double-
% spaced Times set at 12pt.
\DeclareOption{essay}{
  \ExecuteOptions{12pt,times,doublespacing}

  \def\bcathw@setuplayout{
    \bcathw@amsfixes
    \bcathw@essayindents

    \RequirePackage{fullpage}
  }
}

% Declare option to typeset the document in MLA style. The ``quotation'',
% ``quote'', and ``thebibliography'' environments are redefined to match MLA
% formatting conventions. Also, the font is set to Times at 12pt, though this
% is not a strict MLA requirement.
\DeclareOption{mlastyle}{
  % Default to 12pt Times, double-spaced.
  \ExecuteOptions{12pt,times,doublespacing}

  \def\bcathw@setuplayout{
    % Follow MLA style for paragraph indentation and block quotations.
    \AtEndOfClass{\bcathw@essayindents}

    % Use one-inch margins and position headers in the MLA-specified location.
    \RequirePackage[margin=1in,headheight=14pt,headsep=22.135pt]{geometry}

    % Set up running headers and enable showing headers on the first page.
    \RequirePackage{fancyhdr}
    \fancypagestyle{plain}{\pagestyle{fancy}}
    \pagestyle{fancy}
    \fancyhf{}
    \rhead{\bcathw@mlaauthor\ \thepage}
    \renewcommand*\headrulewidth{0pt}
    \renewcommand*\footrulewidth{0pt}

    % Disable hyphenation because MLA is stupid. :(
    \RequirePackage[none]{hyphenat}

    % Disable justification and nice sentence spacing because MLA is stupid. :(
    \raggedright
    \frenchspacing

    % Use the MLA date format.
    \renewcommand*\today{%
      \number\day
      \space
      \ifcase\month
        \or Jan.%
        \or Feb.%
        \or Mar.%
        \or Apr.%
        \or May%
        \or June%
        \or July%
        \or Aug.%
        \or Sept.%
        \or Oct.%
        \or Nov.%
        \or Dec.%
      \fi
      \space
      \number\year
    }

    % Typeset today's date by default.
    \let\@date\today

    % Typeset the document's title in the usual (ugly) MLA style.
    \renewcommand*\maketitle{%
      \begingroup
      \deflength\parindent{0pt}%
      %
      \authors\par
      \bcathw@mlainstructor\par
      \bcathw@mlacourse\par
      \@date\par
      %
      \centering\@title\par
      \endgroup
    }

    % Reformat the bibliography to function as an MLA "Works Cited" list.
    \renewcommand*\refname{Works Cited}
    \renewcommand*\bibliofont{\normalsize}
    \renewcommand*\@biblabel[1]{\relax}

    \preto\@bibtitlestyle{\pagebreak}

    \patchcmd\thebibliography{%
      \leftmargin\labelwidth \advance\leftmargin\labelsep
    }{%
      \deflength\topsep{0pt}%
      \deflength\leftmargin{0.5in}%
      \deflength\itemindent{-0.5in}%
    }{}{}

    % Define some commands to store MLA-specific title information.
    \newrobustcmd*\mlaauthor[1]{\gdef\bcathw@mlaauthor{##1}}
    \newrobustcmd*\mlainstructor[1]{\gdef\bcathw@mlainstructor{##1}}
    \newrobustcmd*\mlacourse[1]{\gdef\bcathw@mlacourse{##1}}
  }
}

% Declare helper command to typeset the date, if present, in the title rather
% than in a footnote.
\newcommand*\bcathw@amsfixes{
  \preto\@adminfootnotes{%
    \begingroup
    \let\@date\empty
  }

  \appto\@adminfootnotes{\endgroup}

  \preto\@setabstract{%
    \ifdefempty\@date{}{%
      \begin{trivlist}
        \deflength\@topsep{30pt-\baselineskip}%
        \centering
        \footnotesize
        %
        \item\relax \MakeUppercase{\@date}%
      \end{trivlist}
    }%
  }
}

% Declare helper command to use normal college essay indentation.
\newcommand*\bcathw@essayindents{%
  \deflength\parindent{0.5in}

  \renewenvironment{quotation}{%
    \list{}{%
      \deflength\topsep{0pt}%
      \deflength\leftmargin{1in}%
      \deflength\listparindent{0.25in}%
      \deflength\itemindent{\listparindent}%
    }%
  \item\relax
  }{\endlist}

  \renewenvironment{quote}{%
    \list{}{%
      \deflength\topsep{0pt}%
      \deflength\leftmargin{1in}%
      \deflength\listparindent{0.25in}%
    }%
  \item\relax
  }{\endlist}
}

% Declare options to set the body text size.
\DeclareOption{10pt}{\def\bcathw@fontsize{10pt}}
\DeclareOption{11pt}{\def\bcathw@fontsize{11pt}}
\DeclareOption{12pt}{\def\bcathw@fontsize{12pt}}

% Declare option to typeset the document in Latin Modern.
\DeclareOption{lmodern}{
  \def\bcathw@setupfonts{
    \RequirePackage[T1]{fontenc}
    \RequirePackage{amssymb,mathrsfs,lmodern}

    \bcathw@swapgreek
  }
}

% Declare option to typeset the document in Cambria. (XeTeX/LuaTeX-only.)
\DeclareOption{cambria}{
  \def\bcathw@setupfonts{
    \RequirePackage{unicode-math}
    \setmainfont[Renderer=Basic,Ligatures=TeX,Numbers=OldStyle]{Cambria}
    \newfontfamily\liningfamily[Renderer=Basic,Ligatures=TeX]{Cambria}
    \setmathfont[
      math-style=TeX,
      vargreek-shape=unicode,
      slash-delimiter=frac,
    ]{Cambria Math}

    \SetSinglespace{1.044}
    \preto\@settitle{\liningfamily}
    \pretocmd\@biblabel{\figureversion{lf}}{}{}
  }
}

% Declare option to typeset the document in Minion Pro.
\DeclareOption{minion}{
  \def\bcathw@setupfonts{
    \RequirePackage[T1]{fontenc}
    \RequirePackage{mathrsfs}
    \RequirePackage[fullfamily,minionint]{MinionPro}

    \bcathw@swapgreek
    \preto\@settitle{\figureversion{lf}}
    \pretocmd\@biblabel{\figureversion{lf,tab}}{}{}
  }
}

% Declare option to typeset the document in a Times clone.
\DeclareOption{times}{
  \def\bcathw@setupfonts{
    \RequirePackage[T1]{fontenc}
    \RequirePackage{amssymb,mathrsfs,mathptmx}

    \DeclareMathAlphabet\mathcal{OMS}{lmsy}{m}{n}
    \bcathw@swapgreek
  }
}

% Declare helper command to prefer variant forms of epsilon and phi. (For some
% reason this doesn't work with ``unicode-math''; fortunately, that package
% provides an option that does that same thing.
\newcommand*\bcathw@swapgreek{
  \let\bcathw@oldepsilon\epsilon
  \let\bcathw@oldphi\phi

  \let\epsilon\varepsilon
  \let\phi\varphi

  \let\varepsilon\bcathw@oldepsilon
  \let\varphi\bcathw@oldphi
}

% Declare option to use standard LaTeX line spacing.
\DeclareOption{singlespacing}{\def\bcathw@setupleading{\singlespacing}}

% Declare option to use double-spaced text.
\DeclareOption{doublespacing}{\def\bcathw@setupleading{\doublespacing}}

% Process class options, passing unrecognized options on to ``amsart''.
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{amsart}}
\ExecuteOptions{latex}
\ProcessOptions\relax
\LoadClass[\bcathw@fontsize]{amsart}

% Load the ``setspace'' package early so font-setting commands can use the
% ``\SetSinglespace'' command.
\RequirePackage{setspace}

% In pdfTeX, enable a limited form of Unicode support.
\ifbool{PDFTeX}{\RequirePackage[utf8]{inputenc}}{}

% Configure text and math fonts.
\bcathw@setupfonts

% Enable automatic microtypographic enhancements.
\RequirePackage{microtype}

% Configure interline spacing.
\bcathw@setupleading

% Configure page geometry.
\bcathw@setuplayout

% Use smaller text in margin notes.
\appto\@marginparreset{\footnotesize}

% Load common preamble stuff.
\RequirePackage{bcat}
