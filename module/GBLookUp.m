% this function looks up the left and right GB values for the amide bond
% according to Zhang's paper.
% AA are assumed to be in alphabetical order according like this:
% A R N D C Q E G H I  L  K  M  F  P  S  T  W  Y  V  B  Z  X  *  -  ?
% 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 0
function [GB_Value] = GBLookUp(index, GB_L_Or_GB_R)

% index, GB_L, GB_R
GBTable = [1, 881.82, 0;
           2, 882.98, 6.28;
           3, 881.18, 1.56;
           4, 880.02, -.63;
           5, 881.15, -.69;
           6, 881.5, 4.1;
           7, 880.1, -.39;
           8, 881.17, .92;
           9, 881.27, -.19;
           10, 880.99, -1.17;
           11, 881.88, -.09;
           12, 880.06, -.71;
           13, 881.38, .3;
           14, 881.08, .03;
           15, 881.25, 11.75;
           16, 881.08, .98;
           17, 881.14, 1.21;
           18, 881.31, .1;
           19, 881.2, -.38;
           20, 881.17, -.9];

switch GB_L_Or_GB_R
    case 'left'
        col = 2;
    case 'right'
        col = 3;
    otherwise
        disp('Forgot to select left or right GB');
end

GB_Value = GBTable(index, col);
           
