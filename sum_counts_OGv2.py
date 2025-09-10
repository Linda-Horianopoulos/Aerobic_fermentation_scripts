import pandas as pd

# Read the table which describes which genes are in each OG
table1 = pd.read_csv('Sdis_OG.txt', dtype={'GeneNames': str}, delimiter='\t')

###UPDATE table each time for each count file
# Read the counts table from ht-seqcount
table2 = pd.read_csv('Sdis1_S280_L002.aligned..count_fraction.txt', header=None, names=['Gene', 'Count'], delimiter='\t', dtype={'Gene': str, 'Count': float})

# Create a dictionary to store the sums
sums = {}

# Iterate over each row in the first table
for _, row in table1.iterrows():
    identifier = row['Orthogroup']
    gene_names = row['GeneNames']

    # Initialize the sum as 0
    sums[identifier] = 0

    # Check if gene_names is a string and non-empty
    if isinstance(gene_names, str) and gene_names.strip() != '':
        # Split the gene names and iterate over each gene name in the current row
        for gene_name in gene_names.split(', '):
            # Find the matching gene in the second table and add its count to the sum
            matching_rows = table2[table2['Gene'] == gene_name]
            if not matching_rows.empty:
                count_sum = matching_rows['Count'].sum()
                sums[identifier] += count_sum
                print(f"Added count {count_sum} for gene {gene_name} in Orthogroup {identifier}")
            else:
                print(f"No matching gene found for {gene_name} in Orthogroup {identifier}")
    else:
        # Skip if there are no genes in this OG
        print(f"Skipping row with identifier '{identifier}' due to missing or empty gene names.")

# Store the results
result = pd.DataFrame.from_dict(sums, orient='index', columns=['SumCount'])

# Reset the index and rename the columns
result = result.reset_index().rename(columns={'index': 'Orthogroup'})

###Rename output file for each replicate
# Save the result DataFrame as a tab-delimited text file
result.to_csv('Sdis1_sum_OG_v2.txt', sep='\t', index=False)
