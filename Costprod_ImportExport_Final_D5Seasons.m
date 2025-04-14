clc; clear all; close all; format long
%% Load the data
AllCountries = readtable('Seasons_AllCountries_VWprod_VW_Normalized.xlsx', 'VariableNamingRule', 'preserve');
TradeCrops = readtable('Trade_CropsOnly.csv', 'VariableNamingRule', 'preserve');
ValueProd = readtable('Value_of_Production_E_All_Data.csv', 'VariableNamingRule', 'preserve');


% Get unique countries and crops
unique_countries = unique(AllCountries.Country);
unique_crops = unique(AllCountries.Crop);

% Process the TradeCrops data for import and export data
TradeCrops_import = TradeCrops(TradeCrops.("Element Code")  == 5610 | TradeCrops.("Element Code")  == 5622, :);
TradeCrops_export = TradeCrops(TradeCrops.("Element Code")  == 5910 | TradeCrops.("Element Code")  == 5922, :);

% Process the ValueProd data for gross production value
ValueProd = ValueProd(ValueProd.("Element Code")  == 57 | ValueProd.("Element Code")  == 58, :);

%% Create an empty table with the desired structure
columnNames = {'Country', 'Crop'};
for j = 2001:2021
    columnNames = [columnNames, {sprintf('%d_Production_(tonnes)', j), ...
        sprintf('%d_Yield_(tonnes/ha)', j), ...
        sprintf('%d_VW_Productivity_m3_tonnes', j), ...
        sprintf('%d_Virtual_Water_m3', j), ...
        sprintf('%d_VW_import_(m3)', j), ...
        sprintf('%d_import_price_(1000US$)', j), ...
        sprintf('%d_import_quantity', j), ... 
        sprintf('%d_VW_export_(m3)', j), ...
        sprintf('%d_export_price_(1000US$)', j), ...
        sprintf('%d_export_quantity', j), ... 
        sprintf('%d_Gross_Prod_Value_const_14_16_(1000US$)', j), ...
        sprintf('%d_Gross_Prod_Value_current_(1000US$)', j)}];
end

AllCountriesFinal = array2table(zeros(0,length(columnNames)), 'VariableNames', columnNames);

%% Populate the table
 for c = 1:length(unique_countries)
     % for c = 169:169
             country = unique_countries{c};
                         fprintf('Processing country: %s\n', country);
     for k = 1:length(unique_crops)
         %     for k = 7:7
                 crop = unique_crops{k};
%                        fprintf('Processing crop: %s\n', crop);

        % Find the rows in AllCountries for this country and crop
        AllCountries_rows = strcmp(AllCountries.Country, country) & strcmp(AllCountries.Crop, crop);
        
        % If there are no rows for this country and crop, continue to the next iteration
        if ~any(AllCountries_rows)
            continue;
        end

        newRow = array2table(zeros(1,length(columnNames)), 'VariableNames', columnNames);
        newRow.Country = {country};
        newRow.Crop = {crop};

        for j = 2001:2021
            newRow.(sprintf('%d_Production_(tonnes)', j)) = AllCountries.(sprintf('%d_Production_(tonnes)', j))(AllCountries_rows);
            newRow.(sprintf('%d_Yield_(tonnes/ha)', j)) = AllCountries.(sprintf('%d_Yield_(tonnes/ha)', j))(AllCountries_rows);
            newRow.(sprintf('%d_VW_Productivity_m3_tonnes', j)) = AllCountries.(sprintf('%d_VW_Productivity_m3_tonnes', j))(AllCountries_rows);
            newRow.(sprintf('%d_Virtual_Water_m3', j)) = AllCountries.(sprintf('%d_Virtual_Water_m3', j))(AllCountries_rows);

            import_row = strcmp(TradeCrops_import.Area, country) & strcmp(TradeCrops_import.Item, crop);
            if any(import_row)
                import_data = TradeCrops_import.(sprintf('Y%d', j))(import_row);
                if numel(import_data) > 0  % Check if import quantity exists
                    newRow.(sprintf('%d_VW_import_(m3)', j)) = import_data(1) * newRow.(sprintf('%d_VW_Productivity_m3_tonnes', j));
                    newRow.(sprintf('%d_import_quantity', j)) = import_data(1);  
                end
                if numel(import_data) > 1  % Check if import price exists
                    newRow.(sprintf('%d_import_price_(1000US$)', j)) = import_data(2);
                end
            end

            export_row = strcmp(TradeCrops_export.Area, country) & strcmp(TradeCrops_export.Item, crop);
            if any(export_row)
                export_data = TradeCrops_export.(sprintf('Y%d', j))(export_row);
                if numel(export_data) > 0  % Check if export quantity exists
                    newRow.(sprintf('%d_VW_export_(m3)', j)) = export_data(1) * newRow.(sprintf('%d_VW_Productivity_m3_tonnes', j));
                    newRow.(sprintf('%d_export_quantity', j)) = export_data(1);  
                end
                if numel(export_data) > 1  % Check if export price exists
                    newRow.(sprintf('%d_export_price_(1000US$)', j)) = export_data(2);
                end
            end


    value_row_current = strcmp(ValueProd.Area, country) & strcmp(ValueProd.Item, crop) & ValueProd.("Element Code")  == 57;
    value_row_const = strcmp(ValueProd.Area, country) & strcmp(ValueProd.Item, crop) & ValueProd.("Element Code")  == 58;
    if any(value_row_current)
        newRow.(sprintf('%d_Gross_Prod_Value_current_(1000US$)', j)) = ValueProd.(sprintf('Y%d', j))(value_row_current);
    end
    if any(value_row_const)
        newRow.(sprintf('%d_Gross_Prod_Value_const_14_16_(1000US$)', j)) = ValueProd.(sprintf('Y%d', j))(value_row_const);
    end
end

        % Append the new row to the AllCountriesFinal table
        AllCountriesFinal = [AllCountriesFinal; newRow];
    end
 end

% Write the updated AllCountries table to a new Excel file
writetable(AllCountriesFinal, 'Seasons_Final_Annual_All_Countries_CostImpExp.xlsx');