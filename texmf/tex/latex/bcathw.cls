\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{bcathw}[2012/01/06 Jonathan Rascher's homework class]

% Load e-TeX helper commands and TeX engine conditionals.
\RequirePackage{etoolbox,iftex}

% Declare option to typeset the document with normal LaTeX margins. (Default.)
\DeclareOption{latex}{\let\bcathw@setuplayout\relax}

% Declare option to typeset the document with "standard" college essay
% formating (double-spaced with 1 inch margins).
\DeclareOption{essay}{
  \def\bcathw@setuplayout{
    \RequirePackage{fullpage}
    \RequirePackage[doublespacing]{setspace}
  }
}

% Declare option to typeset the document with tiny margins. This is useful for
% full page diagrams.
\DeclareOption{diagram}{
  \def\bcathw@setuplayout{\RequirePackage[margin=0.28in]{geometry}}
}

% Declare option to typeset the document in MLA style.
\DeclareOption{mla}{
  \def\bcathw@setuplayout{
    % Use 1 inch margins and double spacing.
    \RequirePackage[margin=1in,headheight=14pt,headsep=22.135pt]{geometry}
    \RequirePackage[doublespacing]{setspace}

    % Set up running headers in the MLA-specified location.
    \RequirePackage{fancyhdr}
    \fancypagestyle{plain}{\pagestyle{fancy}}
    \pagestyle{fancy}
    \fancyhf{}
    \rhead{\bcathw@mlaauthor\ \thepage}
    \renewcommand*\headrulewidth{\z@}
    \renewcommand*\footrulewidth{\z@}

    % Disable hyphenation because MLA is stupid. :(
    \RequirePackage[none]{hyphenat}
  }

  % Disable justification and nice sentence spacing because MLA is stupid. :(
  \raggedright
  \frenchspacing

  \AtEndOfClass{
    % Use the MLA date format.
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
      \number\year
    }

    % Typeset today's date by default.
    \let\@date\today

    % Typeset the document's title in the usual (ugly) MLA style.
    \def\maketitle{%
      \begingroup
        \parindent\z@skip
        %
        \authors\par
        \bcathw@mlainstructor\par
        \bcathw@mlacourse\par
        %
        \centering\@title\par
      \endgroup
    }

    % Hijack the ``quotation'' environment for MLA-style block quotations that
    % begin a new paragraph.
    \renewenvironment{quotation}{%
      \list{}{%
        \topsep\z@skip
        \deflength\leftmargin{1in}%
        \deflength\listparindent{0.25in}%
        \itemindent\listparindent
      }%
      \item[]
    }{\endlist}

    % Hijack the ``quote'' environment for MLA-style block quotations that do
    % not begin a new paragraph.
    \renewenvironment{quote}{%
      \list{}{%
        \topsep\z@skip
        \deflength\leftmargin{1in}%
        \deflength\listparindent{0.25in}%
      }%
      \item[]
    }{\endlist}

    % Reformat the bibliography to function as an MLA "Works Cited" list.
    \renewenvironment{thebibliography}[1]{%
      \pagebreak\centering Works Cited\par
      %
      \list{}{%
        \topsep\z@skip
        \deflength\leftmargin{0.5in}%
        \deflength\itemindent{-0.5in}%
      }%
    }{%
      \def\@noitemerror{%
        \@latex@warning{Empty ``thebibliography'' environment.}%
      }%
      \endlist
    }

    \def\@bibitem#1{\item[]}
  }

  % Set a half-inch paragraph indent as specified by MLA.
  \AtBeginDocument{\deflength\parindent{0.5in}}

  % Define some commands to store MLA-specific title information.
  \newrobustcmd*\mlaauthor[1]{\gdef\bcathw@mlaauthor{#1}}
  \newrobustcmd*\mlainstructor[1]{\gdef\bcathw@mlainstructor{#1}}
  \newrobustcmd*\mlacourse[1]{\gdef\bcathw@mlacourse{#1}}
}

% Declare option to typeset the document in Latin Modern. (Default.)
\DeclareOption{lmodern}{
  \def\bcathw@setupfonts{
    \RequirePackage[T1]{fontenc}
    \RequirePackage{amssymb,mathrsfs,lmodern}
  }
}

% Declare option to typeset the document in Cambria (XeTeX/LuaTeX-only).
\DeclareOption{cambria}{
  \def\bcathw@setupfonts{
    \RequirePackage{unicode-math}
    \setmainfont[Renderer=Basic,Ligatures=TeX,Numbers=OldStyle]{Cambria}
    \newfontfamily\liningfamily[Renderer=Basic,Ligatures=TeX]{Cambria}
    \setmathfont[math-style=TeX,slash-delimiter=frac]{Cambria Math}

    \linespread{1.04}

    \preto\@settitle{\liningfamily}
  }
}

% Declare option to typeset the document in Minion Pro.
\DeclareOption{minion}{
  \def\bcathw@setupfonts{
    \RequirePackage{mathrsfs}
    \RequirePackage[fullfamily,minionint]{MinionPro}

    \preto\@settitle{\figureversion{lf}}
  }
}

% Declare option to typeset the document in a Times clone.
\DeclareOption{times}{
  \def\bcathw@setupfonts{
    \RequirePackage[T1]{fontenc}
    \RequirePackage{amssymb,mathrsfs,mathptmx}

    \DeclareMathAlphabet\mathcal{OMS}{lmsy}{m}{n}
  }
}

% Declare option to use standard LaTeX margin notes.
\DeclareOption{normalmargins}{\let\bcathw@setupmargins\relax}

% Declare option to use smaller text for margin notes. (Default.)
\DeclareOption{compactmargins}{
  \def\bcathw@setupmargins{\appto\@marginparreset{\footnotesize}}
}

% Process class options, passing unrecognized options on to ``amsart''.
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{amsart}}
\ExecuteOptions{latex,lmodern,compactmargins}
\ProcessOptions\relax
\LoadClass{amsart}

% Configure page geometry.
\bcathw@setuplayout

% Configure text and math fonts.
\ifbool{PDFTeX}{\RequirePackage[utf8]{inputenc}}{}
\bcathw@setupfonts
\RequirePackage{microtype}

% Configure margin notes.
\bcathw@setupmargins

% Load common preamble stuff.
\RequirePackage{bcat}
