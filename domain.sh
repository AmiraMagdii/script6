#!/bin/bash

for tool in amass subfinder sort wc; do
    if ! command -v "$tool" &> /dev/null; then
        echo "Error: '$tool' is not installed. Please install it and try again."
        exit 1
    fi
done

read -r -p "Enter the path to the domain list file: " domain_file
read -r -p "Enter the number of iterations: " iterations
read -r -p "Enter the path to save the results: " output_file

subdomains=()

for i in $(seq 1 $iterations); do
    if [[ $i -eq 1 ]]; then
        targets=$(cat "$domain_file")
    else
        targets=$(echo "${subdomains[@]}")
    fi

    for target in $targets; do
        amass enum -d "$target" | sort -u >> temp_subdomains
        subfinder -d "$target" | sort -u >> temp_subdomains
    done
    subdomains+=($(sort -u temp_subdomains))
    > temp_subdomains
done

printf "%s\n" "${subdomains[@]}" > "$output_file"
echo "Total unique subdomains found: $(wc -l < "$output_file")"

