        clc; clear all; close all; format long
% Read data from an Excel file
filename = 'Seasons_AllCountries_VWprod_VW.xlsx';
opts = detectImportOptions(filename);
opts.VariableNamingRule = 'preserve';
dataTable = readtable(filename, opts);

% Get unique countries and crops
uniqueCountries = unique(dataTable.Country);
uniqueCrops = unique(dataTable.Crop);

% Create a new table with the desired format
headers = [{'Country', 'Crop'}];
for year = 2001:2021
    headers = [headers, {strcat(num2str(year), '_Production_(tonnes)'), strcat(num2str(year), '_Yield_(tonnes/ha)'), strcat(num2str(year), '_VW_Productivity_m3_tonnes'), strcat(num2str(year), '_Virtual_Water_m3')}];
end
newTable = cell2table(cell(0, numel(headers)), 'VariableNames', headers);

% Populate the new table
for i = 1:numel(uniqueCountries)
    for j = 1:numel(uniqueCrops)
        country = uniqueCountries(i);
        crop = uniqueCrops(j);
        
        newRow = {country{1}, crop{1}};
        emptyRow = true;
        
        for year = 2001:2021
            
            Production = dataTable.("Production_(tonnes)")(strcmp(dataTable.Country, country) & strcmp(dataTable.Crop, crop) & dataTable.Year == year);
            Yield = dataTable.("Yield_(tonnes/ha)")(strcmp(dataTable.Country, country) & strcmp(dataTable.Crop, crop) & dataTable.Year == year);
            vwProductivity = dataTable.("VW_Productivity_(m3/tonnes)")(strcmp(dataTable.Country, country) & strcmp(dataTable.Crop, crop) & dataTable.Year == year);
            virtualWater = dataTable.("Virtual_Water_(m3)")(strcmp(dataTable.Country, country) & strcmp(dataTable.Crop, crop) & dataTable.Year == year);

            if isempty(vwProductivity) || isempty(virtualWater)
                newRow = [newRow, {NaN, NaN, NaN, NaN}];
            else
                newRow = [newRow, {Production(1), Yield(1), vwProductivity(1), virtualWater(1)}];
                if ~isnan(vwProductivity(1)) || ~isnan(virtualWater(1))
                    emptyRow = false;
                end
            end
        end
        
        if ~emptyRow
            newTable = [newTable; newRow];
        end
    end
end


% Write the new table to an Excel file
writetable(newTable, 'Seasons_AllCountries_VWprod_VW_Normalized.xlsx');
