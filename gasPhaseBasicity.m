function [GB] = gasPhaseBasicity(peptideIntegers, peptideLength)
% Returns the gas phase basicity values based on Zhang's analytical
% chemistry paper. 
% 
% Requires two data structures.
% data.peptideIntegers: integer representation of peptides
% data.peptideLength: length of each peptide
% dataInfo.nPeptides: number of peptides

% GAS PHASE BASICITY VALUES
GB = zeros(1, peptideLength + 1); 
nPeptides = size(peptideIntegers, 1);

% calculate the GB values for the backbone amide
for i = 1:nPeptides
    for j = 1:peptideLength(i)+1
        switch j
            case 1
                GB(i, j) = 916.84 + GBLookUp(peptideIntegers(i, j), 'right');    % N-terminal
                
            case peptideLength(i)+1
                GB(i, j) = GBLookUp(peptideIntegers(i, j-1), 'left') + -95.82; % C-terminal
                
            otherwise
            GB_L = GBLookUp(peptideIntegers(i, j-1), 'left');
            GB_R = GBLookUp(peptideIntegers(i, j), 'right');
            GB(i, j) = GB_L + GB_R; 
        end
    end
end