import sys

# Ensure correct number of arguments
if len(sys.argv) != 5:
    print("Usage: python main.py INPUTFILEPATH OUTPUTFILEPATH SEARCHSTRING REPLACESTRING")
    sys.exit(1)

# Get arguments from command line
input_file = sys.argv[1]
output_file = sys.argv[2]
search_string = sys.argv[3]
replace_string = sys.argv[4]

# Read input file, replace text, and write to output file
try:
    with open(input_file, "r", encoding="utf-8") as file:
        content = file.read()

    content = content.replace(search_string, replace_string)

    with open(output_file, "w", encoding="utf-8") as file:
        file.write(content)

    print(f"Replacement complete: '{search_string}' → '{replace_string}' in {output_file}")

except FileNotFoundError:
    print(f"Error: The file '{input_file}' does not exist.")
    sys.exit(1)

except Exception as e:
    print(f"An error occurred: {e}")
    sys.exit(1)
