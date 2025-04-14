clc; clear all; close all; format long;

% Load both Excel sheets with 'VariableNamingRule' set to 'preserve'
irrigation_data = readtable('Seasons_Final_Annual_All_Countries_CostImpExp.xlsx', 'VariableNamingRule', 'preserve');
total_vw_data = readtable('Seasons_VWTOTAL_Final_Annual_All_Countries_CostImpExp.xlsx', 'VariableNamingRule', 'preserve');

% Initialize combined results table
combined_data = irrigation_data(:, {'Country', 'Crop'});

% Process data for each year (2001 to 2021)
for year = 2001:2021
    year_str = num2str(year); % Convert year to string

    % Production and Yield
    combined_data.([year_str '_Production_(tonnes)']) = irrigation_data.([year_str '_Production_(tonnes)']);
    combined_data.([year_str '_Yield_(tonnes/ha)']) = irrigation_data.([year_str '_Yield_(tonnes/ha)']);

    % VW Productivities
    combined_data.([year_str '_VW_Productivity_Total_m3_tonnes']) = total_vw_data.([year_str '_VW_Productivity_m3_tonnes']);
    combined_data.([year_str '_VW_Productivity_Irrigation_m3_tonnes']) = irrigation_data.([year_str '_VW_Productivity_m3_tonnes']);
    combined_data.([year_str '_VW_Productivity_Precipitation_m3_tonnes']) = ...
        combined_data.([year_str '_VW_Productivity_Total_m3_tonnes']) - combined_data.([year_str '_VW_Productivity_Irrigation_m3_tonnes']);

    % Total VW, Irrigation VW, and Precipitation VW
    combined_data.([year_str '_Total_VW_m3']) = total_vw_data.([year_str '_Virtual_Water_m3']);
    combined_data.([year_str '_Irrigation_VW_m3']) = irrigation_data.([year_str '_Virtual_Water_m3']);
    combined_data.([year_str '_Precipitation_VW_m3']) = ...
        combined_data.([year_str '_Total_VW_m3']) - combined_data.([year_str '_Irrigation_VW_m3']);

    % VW Imports and Exports
    combined_data.([year_str '_import_quantity']) = irrigation_data.([year_str '_import_quantity']);
    combined_data.([year_str '_VW_import_Total(m3)']) = total_vw_data.([year_str '_VW_import_(m3)']);
    combined_data.([year_str '_VW_import_Irrigation(m3)']) = irrigation_data.([year_str '_VW_import_(m3)']);
    combined_data.([year_str '_VW_import_Precipitation(m3)']) = ...
        combined_data.([year_str '_VW_import_Total(m3)']) - combined_data.([year_str '_VW_import_Irrigation(m3)']);

    % Import Prices
    combined_data.([year_str '_import_price_Total(US$)']) = irrigation_data.([year_str '_import_price_(1000US$)']).* 1000;
    combined_data.([year_str '_import_price_Irrigation(US$)']) = ...
        (combined_data.([year_str '_import_price_Total(US$)']) .* combined_data.([year_str '_VW_import_Irrigation(m3)'])) ./ combined_data.([year_str '_VW_import_Total(m3)']);
    combined_data.([year_str '_import_price_Precipitation(US$)']) = ...
        (combined_data.([year_str '_import_price_Total(US$)']) .* combined_data.([year_str '_VW_import_Precipitation(m3)'])) ./ combined_data.([year_str '_VW_import_Total(m3)']);
    combined_data.([year_str '_import_price_per_1m3VW(US$/m3)']) = ...
        combined_data.([year_str '_import_price_Total(US$)']) ./ combined_data.([year_str '_VW_import_Total(m3)']);
    combined_data.([year_str '_import_price_per_1tonnecrop(US$/tonne)']) = ...
        combined_data.([year_str '_import_price_Total(US$)']) ./ combined_data.([year_str '_import_quantity']);
   

    % VW Exports
    combined_data.([year_str '_export_quantity']) = irrigation_data.([year_str '_export_quantity']);
    combined_data.([year_str '_VW_export_Total(m3)']) = total_vw_data.([year_str '_VW_export_(m3)']);
    combined_data.([year_str '_VW_export_Irrigation(m3)']) = irrigation_data.([year_str '_VW_export_(m3)']);
    combined_data.([year_str '_VW_export_Precipitation(m3)']) = ...
        combined_data.([year_str '_VW_export_Total(m3)']) - combined_data.([year_str '_VW_export_Irrigation(m3)']);

    % Export Prices
    combined_data.([year_str '_export_price_Total(US$)']) = irrigation_data.([year_str '_export_price_(1000US$)']).* 1000;
    combined_data.([year_str '_export_price_Irrigation(US$)']) = ...
        (combined_data.([year_str '_export_price_Total(US$)']) .* combined_data.([year_str '_VW_export_Irrigation(m3)'])) ./ combined_data.([year_str '_VW_export_Total(m3)']);
    combined_data.([year_str '_export_price_Precipitation(US$)']) = ...
        (combined_data.([year_str '_export_price_Total(US$)']) .* combined_data.([year_str '_VW_export_Precipitation(m3)'])) ./ combined_data.([year_str '_VW_export_Total(m3)']);
    combined_data.([year_str '_export_price_per_1m3VW(US$/m3)']) = ...
        combined_data.([year_str '_export_price_Total(US$)']) ./ combined_data.([year_str '_VW_export_Total(m3)']);
    combined_data.([year_str '_export_price_per_1tonnecrop(US$/tonne)']) = ...
        combined_data.([year_str '_export_price_Total(US$)']) ./ combined_data.([year_str '_export_quantity']);
    
    % Gross Production Value
    combined_data.([year_str '_Gross_Prod_Value_const_14_16_Total(US$)']) = irrigation_data.([year_str '_Gross_Prod_Value_const_14_16_(1000US$)']).* 1000;
    combined_data.([year_str '_Gross_Prod_Value_const_14_16_Irrigation(US$)']) = ...
        combined_data.([year_str '_Gross_Prod_Value_const_14_16_Total(US$)']) .* ...
        (combined_data.([year_str '_Irrigation_VW_m3']) ./ combined_data.([year_str '_Total_VW_m3']));
    combined_data.([year_str '_Gross_Prod_Value_const_14_16_Precipitation(US$)']) = ...
        combined_data.([year_str '_Gross_Prod_Value_const_14_16_Total(US$)']) .* ...
        (combined_data.([year_str '_Precipitation_VW_m3']) ./ combined_data.([year_str '_Total_VW_m3']));

    combined_data.([year_str '_Gross_Prod_Value_const_14_16_per_1m3VW(US$/m3)']) = ...
        combined_data.([year_str '_Gross_Prod_Value_const_14_16_Total(US$)']) ./ combined_data.([year_str '_Total_VW_m3']);
    combined_data.([year_str '_Gross_Prod_Value_const_14_16_per_1tonnecrop(US$/tonne)']) = ...
        combined_data.([year_str '_Gross_Prod_Value_const_14_16_Total(US$)']) ./ combined_data.([year_str '_Production_(tonnes)']);

    combined_data.([year_str '_Gross_Prod_Value_current_(US$)']) = irrigation_data.([year_str '_Gross_Prod_Value_current_(1000US$)']).* 1000;

    % Water Use Efficiency (WUE)
    combined_data.([year_str '_WUE_(Yield(tonnes/ha)/Productivity(m3/tonnes))']) = ...
        combined_data.([year_str '_Yield_(tonnes/ha)']) ./ combined_data.([year_str '_VW_Productivity_Total_m3_tonnes']);
end

% Save the combined results to a new Excel file
writetable(combined_data, 'Seasons_FINAL_Combined_VW_Data_USD.xlsx');
