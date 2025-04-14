% Read data from an Excel file
% Read the production data
%prod_data = readtable('AllCountries_VWprod_Imp_Exp_VW_Normalized.xlsx');

filename = 'AllCountries_VWprod_VW.xlsx';
opts = detectImportOptions(filename);
opts.VariableNamingRule = 'preserve';
dataTable = readtable(filename, opts);

% Get unique countries and crops
uniqueCountries = unique(dataTable.Country);
uniqueCrops = unique(dataTable.Crop);

% Create a new table with the desired format
headers = [{'Country', 'Crop'}];
for year = 2001:2021
    headers = [headers, {strcat(num2str(year), '_Production_(tonnes)'),  ...
                         strcat(num2str(year), '_Yield_(tonnes/ha)'), ...
                         strcat(num2str(year), '_VW_Productivity_(m3/ton'), ...
                         strcat(num2str(year), '_Virtual_Water_(m3)'), ...
                         strcat(num2str(year), '_VW_import_(m3)'), ...
                         strcat(num2str(year), '_import_price_(1000US$)'), ...
                         strcat(num2str(year), '_VW_export_(m3)'), ...
                         strcat(num2str(year), '_export_price_(1000US$)'), ...
                         strcat(num2str(year), '_Gross_Prod_Value_const_14_16_(1000US$)'), ...
                         strcat(num2str(year), '_Gross_Prod_Value_current_(1000US$)')}];
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
            
            % Add calculated values from the 'results' array
            vw_import = resultscost(i, j, year - 2000, 2);
            import_price = resultscost(i, j, year - 2000, 3);
            vw_export = resultscost(i, j, year - 2000, 1);
            export_price = resultscost(i, j, year - 2000, 4);
           
            % Add calculated values from the 'results' array
            cost_US_Dollar_2014_16_constant = resultscost(i, j, year - 2000, 5);
            cost_US_Dollar_current = resultscost(i, j, year - 2000, 6);

% Retrieve the gross production values for the specific year
%    gross_prod_value_const = const_prod_value_data{strcmpi(strip(const_prod_value_data.("Area")), strip(target_country_trade)) & strcmpi(strip(const_prod_value_data.("Item")), strip(target_crop_trade)), sprintf('Y%d', year)};
%    gross_prod_value_current = current_prod_value_data{strcmpi(strip(current_prod_value_data.("Area")), strip(target_country_trade)) & strcmpi(strip(current_prod_value_data.("Item")), strip(target_crop_trade)), sprintf('Y%d', year)};

            if isempty(vwProductivity) || isempty(virtualWater)
                newRow = [newRow, {NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN}];
            else
                newRow = [newRow, {Production(1), Yield(1), vwProductivity(1), virtualWater(1), vw_import, import_price, vw_export, export_price, cost_US_Dollar_2014_16_constant, cost_US_Dollar_current}];
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

% Write the new table to the AllCountries_VW_Costprod_Imp_Exp_Normalized.xlsx Excel file
writetable(newTable, 'AllCountries_VW_Costprod_Imp_Exp_Normalized_Ukraine.xlsx');