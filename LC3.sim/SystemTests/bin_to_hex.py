import sys

def bin_to_hex(input_file, output_file):
    with open(input_file, "rb") as bin_file:
        # Read first two bytes
        first_two_bytes = bin_file.read(2)

        # Check if they are both 0x00, if so, skip them
        if first_two_bytes != b'\x00\x00':
            bin_data = first_two_bytes + bin_file.read()  # Keep first two bytes
        else:
            bin_data = bin_file.read()  # Skip first two bytes
        
    with open(output_file, "w") as hex_file:
        for i in range(0, len(bin_data), 2):  # Process 2 bytes at a time
            chunk = bin_data[i:i+2]
            hex_value = chunk.hex().upper()  # Convert to uppercase hex
            hex_file.write(hex_value + "\n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python bin_to_hex.py input.obj output.hex")
        sys.exit(1)

    bin_to_hex(sys.argv[1], sys.argv[2])
    print(f"Conversion complete! Output saved to {sys.argv[2]}")
