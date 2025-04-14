% Run VWCalcD5.m
run('VWCalcDSeasons.m')% For Irrigation VW %Creates 'Results/Seasons_AllCountries_VWprod_VW.xlsx'
run('VWTotalCalcDSeasons.m') %For Total VW = Irrigation VW + Precepitation VW %Creates 'Results/Seasons_TOTALVW_AllCountries_VWprod_VW.xlsx'

% Set the working directory to the "Results" subfolder
cd('Results')

% Run Normalizing %By "normalizing" I mean re-formating the results to simplify Excel readability
run('TableNormalizingSeasons.m') %Creates 'Seasons_AllCountries_VWprod_VW_Normalized.xlsx' 
run('VWTOTAL_TableNormalizingSeasons.m') %Creates 'Seasons_VWTOTAL_AllCountries_VWprod_VW_Normalized.xlsx'

% Run to calculate Cost of production, Import data, and Export data
run('Costprod_ImportExport_Final_D5Seasons.m') %Creates 'Seasons_Final_Annual_All_Countries_CostImpExp.xlsx'
run('VWTOTAL_Costprod_ImportExport_Final_D5Seasons.m')  %Creates 'Seasons_VWTOTAL_Final_Annual_All_Countries_CostImpExp.xlsx'

%Run Code to combine Data From the 2 excel sheets we just calculated. 
%Combining "Irrigation VW" and "Total VW", then calculate "Precepitation VW"
run('VWTOTAL_Irr_Prec_Cost_Import_Export_CombinationD5.m')  
%Variables calculated for each year in 'Seasons_FINAL_Combined_VW_Data_USD.xlsx'
% 1. Country
% 2. Crop
% 3. 2001_Production_(tonnes)	
% 4. 2001_Yield_(tonnes/ha)	

% 5. 2001_VW_Productivity_Total_m3_tonnes	
% 6. 2001_VW_Productivity_Irrigation_m3_tonnes	
% 7. 2001_VW_Productivity_Precipitation_m3_tonnes	
 
% 8. 2001_Total_VW_m3	
% 9. 2001_Irrigation_VW_m3	
% 10. 2001_Precipitation_VW_m3	
 
% 11. 2001_import_quantity	
 
% 12. 2001_VW_import_Total(m3)	
% 13. 2001_VW_import_Irrigation(m3)	
% 14. 2001_VW_import_Precipitation(m3)	
 
% 15. 2001_import_price_Total(US$)
% 16. 2001_import_price_Irrigation(US$)	
% 17. 2001_import_price_Precipitation(US$)	
 
% 18. 2001_import_price_per_1m3VW(US$/m3)	
% 19. 2001_import_price_per_1tonnecrop(US$/tonne)	
 
% 20. 2001_export_quantity	
 
% 21. 2001_VW_export_Total(m3)	
% 22. 2001_VW_export_Irrigation(m3)	
% 23. 2001_VW_export_Precipitation(m3)
 
% 24. 2001_export_price_Total(US$)	
% 25. 2001_export_price_Irrigation(US$)	
% 26. 2001_export_price_Precipitation(US$)	
 
% 27. 2001_export_price_per_1m3VW(US$/m3)	
% 28. 2001_export_price_per_1tonnecrop(US$/tonne)	
 
 
% 29. 2001_Gross_Prod_Value_const_14_16_Total(US$)
% 30. 2001_Gross_Prod_Value_const_14_16_Irrigation(US$)
% 31. 2001_Gross_Prod_Value_const_14_16_Precipitation(US$)
 
% 32. 2001_Gross_Prod_Value_const_14_16_per_1m3VW(US$/m3)
% 33. 2001_Gross_Prod_Value_const_14_16_per_1tonnecrop(US$/tonne)
 
% 34. 2001_Gross_Prod_Value_current_(US$) 
% 35. 2001_WaterUseEfficiency_WUE_(Yield_(tonnes/ha) / VW_Productivity_Total_(m3/tonnes))