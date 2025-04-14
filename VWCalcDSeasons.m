clc; clear all; close all; format long
%% 1.	Load relevant data files and initialize variables

% Load data files
crop_data = readtable('Seasons_Crop_Data_morethanFAO.xlsx', 'Sheet', 'Annual_Crops', 'VariableNamingRule', 'preserve');
production_data = readtable('Production_CropsOnly.csv', 'VariableNamingRule', 'preserve');
country_name_mapping = readtable('Seasons_Names_Production_Weather.xlsx', 'Sheet', 'Sheet1', 'VariableNamingRule', 'preserve');
crop_name_mapping = readtable('Crops_Production_Crops.xlsx', 'VariableNamingRule', 'preserve');
% Initialize output table
%vw_output = table();
% Initialize the results table
results_table = table();
%results = [];
% Initialize skipped_countries and skipped_crops
skipped_countries = table();
skipped_crops = table();
% Extract years from production_data
year_columns = production_data.Properties.VariableNames;
year_columns = year_columns(startsWith(year_columns, 'Y') & cellfun(@(x) length(x)==5, year_columns)); % Exclude 'F' columns
years = cellfun(@(x) str2double(x(2:5)), year_columns);
% Load hemisphere data
hemisphere_mapping = country_name_mapping(:, {'Production', 'Hemisphere'});


    %% 2. Loop through Countries

% Loop through countries
country_list = unique(production_data.Area);
for ci = 1:length(country_list)
     country = country_list{ci};

% Find the equivalent country name in weather_data and its hemisphere
country_row = strcmp(country_name_mapping.Production, country);
weather_country_name = country_name_mapping.Weather(country_row);
country_hemisphere = country_name_mapping.Hemisphere(country_row);

% If no equivalent country name or hemisphere is found, skip the country and record it
if isempty(weather_country_name) || isempty(country_hemisphere)
    skipped_countries = [skipped_countries; table({country}, 'VariableNames', {'Country'})];
    continue;
end

    % Display the current country being processed
    fprintf('Processing country: %s\n', country);
% Load weather data
    try
 %       weather_data = readtable([weather_country_name{1} '.csv'], 'ReadVariableNames', false);
 weather_data = readtable(['Weather/' weather_country_name{1} '.csv'], 'ReadVariableNames', false);
    catch
        skipped_countries = [skipped_countries; table({country}, 'VariableNames', {'Country'})];
        continue;
    end
weather_data.Properties.VariableNames = {'Date', 'Precipitation', 'ETo'};


    %% 3. Loop through Crops

    % Loop through crops
    crop_list = unique(production_data.Item);
    for cj = 1:length(crop_list)
        crop = crop_list{cj};

        % Find the equivalent crop name in crop_data
crop_data_name = crop_name_mapping.Crop_Crop(strcmp(crop_name_mapping.Crop_Production, crop));
 % If no equivalent crop name is found, skip the crop and record it
        if isempty(crop_data_name)
            skipped_crops = [skipped_crops; table({crop}, 'VariableNames', {'Crop'})];
            continue;
        end

% Identify crop data and planting month
crop_info = crop_data(strcmp(crop_data.Crop, crop_data_name{1}), :);
if isempty(crop_info)
    error('Crop data not found');
end
% Determine planting month based on the hemisphere
if strcmpi(country_hemisphere{1}, 'Northern')
    planting_month = crop_info.("Planting date north")(1);
elseif strcmpi(country_hemisphere{1}, 'Southern')
    planting_month = crop_info.("Planting date south")(1);
else
    error('Hemisphere not recognized for country: %s', country);
end

% Check if planting_month is empty
if isempty(planting_month{1})
    error('Planting month is empty for crop: %s in country: %s. Please check the data source.', crop, country);
end


%% 2. Loop through Years

% Loop through years
for yi = 1:length(years)
    year = years(yi);
    % Display the current year being processed
   % fprintf('Processing year: %d\n', year);

    %% 5. Caclulating daily_kc, monthly_kc, monthly_ETc, and total_ETc

% Calculate daily Kc values for each stage 
daily_kc_init = repmat(crop_info.("Kc Init")(1), crop_info.("Initial days")(1), 1);
daily_kc_mid = repmat(crop_info.("Kc Mid")(1), crop_info.("Middle days")(1), 1);
daily_kc_end = repmat(crop_info.("Kc End")(1), crop_info.("Late days")(1), 1);
daily_kc_dev = repmat(mean([crop_info.("Kc Init")(1), crop_info.("Kc Mid")(1)]), crop_info.("Development days")(1), 1);
daily_kc = [daily_kc_init; daily_kc_dev; daily_kc_mid; daily_kc_end];

% Calculate planting and harvest years based on the month and total days of the crop
planting_month_num = month(datetime(['01-', planting_month{1}, '-2000'], 'InputFormat', 'dd-MMMM-yyyy'));
% Calculate the end date of the crop
end_date = datenum(year, planting_month_num, 1) + crop_info.("Total days");
% Convert the end date to a datetime object
end_date_datetime = datetime(end_date, 'ConvertFrom', 'datenum');
% Calculate the planting and harvest years
planting_year = year - (planting_month_num >= month(end_date_datetime));

% Calculate planting date and harvest date
planting_date = datenum(planting_year, planting_month_num, 1);
harvest_date = planting_date + crop_info.("Total days");
planting_date_readable = datestr(planting_date);
harvest_date_readable = datestr(harvest_date);
% Calculate total_months
total_months_exact = months_exact(datetime(planting_date, 'ConvertFrom', 'datenum'), datetime(harvest_date, 'ConvertFrom', 'datenum'));
total_months = ceil(total_months_exact);

% Check if the harvest date falls within the current year
if ~(harvest_date >= datenum(year, 1, 1) && harvest_date <= datenum(year, 12, 31)) % This is a check while coding 
error('The harvest date does not fall within the specified year');
end

% Create serial_date_numbers
serial_date_numbers = datenum(weather_data.Date);
% Create daily date array between planting_date and harvest_date
daily_date_array = (planting_date:harvest_date - 1)';
% Calculate daily Kc values for the entire period between planting_date and harvest_date
daily_kc_full = zeros(size(daily_date_array));
num_indices = min(length(daily_kc), length(daily_date_array));
daily_kc_full(1:num_indices) = daily_kc(1:num_indices);
% Convert daily_date_array to datetime array
daily_date_array_datetime = datetime(daily_date_array, 'ConvertFrom', 'datenum');

% Initialize monthly_kc
monthly_kc = zeros(total_months, 1);
% Calculate monthly average Kc values
for month_idx = 1:total_months
    current_month = mod(planting_month_num + month_idx - 1 - 1, 12) + 1;
    month_mask = month(daily_date_array_datetime) == current_month;
    monthly_kc(month_idx) = mean(daily_kc_full(month_mask));
end
% Extract weather data between planting_date and harvest_date
start_month = find(serial_date_numbers >= planting_date, 1);
end_month = find(serial_date_numbers < harvest_date, 1, 'last');
weather_data_crop_period = weather_data(start_month:end_month, :);

% Multiply monthly Kc values with corresponding monthly ETo values
monthly_ETc = (monthly_kc .* weather_data_crop_period.ETo) - (0.8 * weather_data_crop_period.Precipitation);
% Replace negative values with zero (no deficit when precipitation is greater than demand)
monthly_ETc(monthly_ETc < 0) = 0;

% Calculate the proportion of days until harvest in the last month
last_date_num = daily_date_array(length(daily_date_array));
last_date_datetime = datetime(last_date_num, 'ConvertFrom', 'datenum');
[last_year, last_month, last_day] = ymd(last_date_datetime);
days_in_last_month = eomday(last_year, last_month);
days_until_harvest= last_day;
ratio_of_last_month = days_until_harvest / days_in_last_month;
% Adjust the last month's monthly_ETc value
monthly_ETc(end) = monthly_ETc(end) * ratio_of_last_month;
% Calculate total water deficit
total_ETc = sum(monthly_ETc);


%% 6. Calculating Virtual Water and Virtual Water Productivity

            % Extract production data
year_column_name = sprintf('Y%d', year);
prod_mask = strcmp(production_data.Area, country) & ...
            strcmp(production_data.Item, crop) & ...
            strcmp(production_data.Element, 'Production');
production = production_data(prod_mask, year_column_name).(year_column_name);

% Extract yield data
yield_mask = strcmp(production_data.Area, country) & ...
             strcmp(production_data.Item, crop) & ...
             strcmp(production_data.Element, 'Yield');
crop_yield = production_data(yield_mask, year_column_name).(year_column_name) * 1e-4; % Convert hg/ha to t/ha

            % Calculate virtual water productivity
            vw_productivity = (total_ETc *10) / crop_yield; % m3/tonnes

            % Calculate total virtual water
            vw = vw_productivity * production; % m3

%% 7. Saving and Displaying output

if isempty(vw_productivity) || isnan(vw_productivity) || isinf(vw_productivity)
    continue;
end

% Create a temporary table for the current iteration
%temp_table = table({country}, {crop}, year, {datestr(planting_date, 'dd-mmm-yyyy')}, {datestr(harvest_date, 'dd-mmm-yyyy')}, vw_productivity, vw, ...
%                   'VariableNames', {'Country', 'Crop', 'Year', 'Planting_Date', 'Harvest_Date', 'VW_Productivity', 'Virtual_Water'});
temp_table = table({country}, {crop}, year, production, crop_yield, vw_productivity, vw, ...
                   'VariableNames', {'Country', 'Crop', 'Year', 'Production_(tonnes)','Yield_(tonnes/ha)', 'VW_Productivity_(m3/tonnes)', 'Virtual_Water_(m3)'});

%disp(size(temp_table));
%disp(size(results_table));
%disp(['Size of vw_productivity: ', num2str(size(vw_productivity)), ', Class: ', class(vw_productivity)]);


% Append the temporary table to the results_table
results_table = [results_table; temp_table];

% Display the output table
%disp(temp_table);


    end
end
end
%results = vw_output;
% Write the new table to an Excel file
writetable(results_table, 'Results/Seasons_AllCountries_VWprod_VW.xlsx');

% Save the results to a .mat file
%save('virtual_water_output.mat', 'vw_output');
save('skipped_countries.mat', 'skipped_countries');
save('skipped_crops.mat', 'skipped_crops');

