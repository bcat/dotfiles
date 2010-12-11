push @generated_exts, 'synctex.gz';

$pdflatex = 'pdflatex -synctex=1 %O %S';

$dvi_previewer = 'start xdg-open %O %S';
$dvi_previewer_landscape = 'start xdg-open %O %S';
$pdf_previewer = 'start xdg-open %O %S';
$ps_previewer = 'start xdg-open %O %S';
$ps_previewer_landscape = 'start xdg-open %O %S';
