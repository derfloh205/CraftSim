cd wow-profession-tree
python generate_database.py
cd profession_traits
python get_csv_output.py
cd ../..
rm Data/Latest/csv_profession_traits.csv
mv wow-profession-tree/output/csv_profession_traits.csv Data/Latest/csv_profession_traits.csv
python mapper.py