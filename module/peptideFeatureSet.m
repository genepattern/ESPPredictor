function peptideFeatureSet(peptideFile)
% Calculates feature set properties for a list of peptides. These
% feature sets can be run in the computational model for intensity
% prediction
%
% The variable input is the class labels for supervised learning.
%
% AADB = the older amino acid database that has 494 values normalized
% between 0-1.
%
% AADB2 = the latest release of the amino acid database and contains 544
% original (not normalized values).  

peptide = importdata(peptideFile);
outputFile = 'PeptideFeatureSet.csv';
propFeatures = 'avg';    % 'avg', 'sum', 'si', 'si_avg', 'avg_sum', 'si_avg_sum'
database = 'AADB2';     % select either AADB or AADB2
usePepIntergers = 0;    % yes = 1 or no = 0

peptide = upper(peptide);

if (nargin == 2)
    class = varargin{1};
end

nPeptides = size(peptide, 1);

for i = 1:nPeptides
    peptideLength(i, 1) = length(peptide{i});
end

peptideIntegers = zeros(nPeptides, max(peptideLength));

for i = 1:nPeptides
    tmpPeptide = aa2int(peptide{i});
    if (min(tmpPeptide) == 0 || max(tmpPeptide) > 20)
%        error('Non-standard amino acid found check peptides for J,U,Z,B,O,X');
        quit force;
    end
    peptideIntegers(i, 1:peptideLength(i)) = tmpPeptide;
end

% A R N D C Q E G H I  L  K  M  F  P  S  T  W  Y  V  B  Z  X  *  -  ?
% 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 0


% ---- FEATURE SETS ----

% ACIDIC RESIDUES, MOLWEIGHT, ISOELECTRIC, GAS PHASE BASICITY VALUES
nAcidic = [];
nBasic = [];
for i = 1:nPeptides
    % acidic amino acids
    D = length(find(peptideIntegers(i, :) == 4));
    E = length(find(peptideIntegers(i, :) == 7));
    nAcidic = [nAcidic; D+E];
    
    % basic amino acids
    R = length(find(peptideIntegers(i, :) == 2));
    H = length(find(peptideIntegers(i, :) == 9));
    K = length(find(peptideIntegers(i, :) == 12));
    nBasic = [nBasic; R+H+K];
    
    %mz(i, 1) = (molweight(peptide{i}) + (z(i) * 1.007276)) / z(i);
    molW(i, 1) = molweight(peptide{i});
    
    pI(i, 1) = isoelectric(peptide{i});
    
    GBmx = gasPhaseBasicity(peptideIntegers(i,:), peptideLength(i));
    
    switch lower(propFeatures)
       case 'avg'
           GB(i, 1) = mean(GBmx);
       case 'sum'
           GB(i, 1) = sum(GBmx);
       case 'si'
           GB(i, 1) = computeSI(GBmx);
       case 'si_avg'
           GB(i, 1) = computeSI(GBmx);
           GB(i, 2) = mean(GBmx);
       case 'avg_sum'
           GB(i, 1) = mean(GBmx);
           GB(i, 2) = sum(GBmx);
        case 'si_avg_sum'
           GB(i, 1) = computeSI(GBmx);
           GB(i, 2) = mean(GBmx);
           GB(i, 3) = sum(GBmx);
       otherwise
           disp('Unknown method...');
    end    
end


% AADB PROPERTIES (SUM, AVG, SI properties)
load(database);
nProperties = length(AADB.Index);

% declare the size of the property matrix
switch lower(propFeatures)
    case 'si_avg' 
        prop = zeros(nPeptides, (nProperties * 2));
        % These indexes are for combined feature properties so I can alternate si
        % and avg properties.  This becomes important when I have to write out the
        % headers in the file.
        index1 = 1:2:(nProperties * 2);
        index2 = 2:2:(nProperties * 2);
    case 'avg_sum' 
        prop = zeros(nPeptides, (nProperties * 2));
        index1 = 1:2:(nProperties * 2);
        index2 = 2:2:(nProperties * 2);
    case 'si_avg_sum'
        prop = zeros(nPeptides, (nProperties * 3));
        index1 = 1:3:(nProperties * 3);
        index2 = 2:3:(nProperties * 3);
        index3 = 3:3:(nProperties * 3);
    otherwise
        prop = zeros(nPeptides, nProperties);
end


for i = 1:nPeptides
    for j = 1:nProperties
        tmp = [];
        for k = 1:peptideLength(i)
            curPos = peptideIntegers(i, k);
            tmp = [tmp; AADB.Data(j, curPos)];
        end
        switch lower(propFeatures)
            case 'avg'
                prop(i, j) = nanmean(tmp);
            case 'sum'
                prop(i, j) = nansum(tmp);
            case 'si'
                prop(i, j) = computeSI(tmp);
            case 'si_avg'
                prop(i, index1(j)) = computeSI(tmp);
                prop(i, index2(j)) = nanmean(tmp);
            case 'avg_sum'
                prop(i, index1(j)) = nanmean(tmp);
                prop(i, index2(j)) = nansum(tmp);
            case 'si_avg_sum'
                prop(i, index1(j)) = computeSI(tmp);
                prop(i, index2(j)) = nanmean(tmp);
                prop(i, index3(j)) = nansum(tmp);
            otherwise
                disp('Unknown method...');
        end
    end
end

% combine all the features into one feature set
if (usePepIntergers == 1)
    f = [peptideIntegers, peptideLength, molW, pI, GB, nAcidic, prop];
else
    f = [peptideLength, molW, pI, GB, nAcidic, nBasic, prop];
end

% write the data to a file

% write the headers
fid = fopen(outputFile, 'wt');

if (usePepIntergers == 1)
    for i = 1:size(peptideIntegers, 2)
        fprintf(fid, 'position_%s,', num2str(i));
    end
end

switch lower(propFeatures)
   case 'avg'
       fprintf(fid, 'sequence,length,mass,pI,AVG_Gas_phase_basicity,nAcidic,nBasic,');
   case 'sum'
       fprintf(fid, 'sequence,length,mass,pI,SUM_Gas_phase_basicity,nAcidic,nBasic,');
   case 'si'
       fprintf(fid, 'sequence,length,mass,pI,SI_Gas_phase_basicity,nAcidic,nBasic,');
   case 'si_avg'
       fprintf(fid, 'sequence,length,mass,pI,SI_Gas_phase_basicity,AVG_Gas_phase_basicity,nAcidic,nBasic,');
   case 'avg_sum'
       fprintf(fid, 'sequence,length,mass,pI,AVG_Gas_phase_basicity,SUM_Gas_phase_basicity,nAcidic,nBasic,');
    case 'si_avg_sum'
       fprintf(fid, 'sequence,length,mass,pI,SI_Gas_phase_basicity,AVG_Gas_phase_basicity,SUM_Gas_phase_basicity,nAcidic,nBasic,');
end    

% remove any funny characters in order to read the table into R
for j = 1:nProperties
    description = char(AADB.Description{1,j});
    description = regexprep(description, '[.,:%()+''"/]', '');
    description = regexprep(description, '[\s]', '_');

    switch lower(propFeatures)
       case 'avg'
           fprintf(fid, 'AVG_%s,', description);
       case 'sum'
           fprintf(fid, 'SUM_%s,', description);
       case 'si'
           fprintf(fid, 'SI_%s,', description);
       case 'si_avg'
           fprintf(fid, 'SI_%s,', description);
           fprintf(fid, 'AVG_%s,', description);
       case 'avg_sum'
           fprintf(fid, 'AVG_%s,', description);      
           fprintf(fid, 'SUM_%s,', description);
        case 'si_avg_sum'
           fprintf(fid, 'SI_%s,', description);
           fprintf(fid, 'AVG_%s,', description);      
           fprintf(fid, 'SUM_%s,', description);
    end    
   
end

if (nargin == 2)
    fprintf(fid, 'class\n');
else
    fprintf(fid, '\n');
end

% write the data
for i = 1:size(f, 1)
    
    fprintf(fid, '%s,', peptide{i});
    
    fprintf(fid, '%12.6f,', f(i,:));
    
    if (nargin == 2)
        if (iscell(class))
            fprintf(fid, '%s\n', class{i});
        else
            fprintf(fid, '%s\n', num2str(class(i)));
        end
    else
        fprintf(fid, '\n');
    end
    
end

fclose(fid);

disp('DONE!');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SI = computeSI(v)
tmp = [];
for i = 1:length(v) - 1
    x = [v(i), v(i+1)];
    tmp = [tmp; nansum(x)^2];
end
SI = sqrt(nanmean(tmp));
if (isnan(SI))
    display('Peptide NaN Found');
end

