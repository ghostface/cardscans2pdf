#!/bin/bash

output_name=${folder}
output_name_back=${folder}_back

# Create LaTeX template
cat <<EOF > $output_name.tex
\documentclass[${papersize}]{article}
\usepackage[margin=${margin}mm]{geometry}
\usepackage{graphicx}
\pagestyle{empty}

\begin{document}

\centering
EOF

# Add images to the LaTeX template in a grid
image_count=0
path="$folder"
backside=""

echo "-- Searching $path for backside"
#find "$path" \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png \) -iname "Backside*" -print0 | while read -r -d $'\0' file; do
#while read -r -d $'\0' find "$path" \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png \) -iname "Backside*" -print0; do
for file in "$path"/*; do
    if [[ $(basename "$file" | grep -i "^Backside\.\(png\|jpg\|jpeg\)$") ]]; then
        backside=$file
        echo "=> Found $backside"
    fi
done

if [ -z "${backside}" ]; then
    echo "Warning: No Backside.jpg/png found - skipping Backside. ${backside}"
fi

echo "-- Searching $path for images"

find "$path" \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png \) -print0 | while read -r -d $'\0' file; do
    #Skip Backside
    if [ "$file" == "$backside" ] || [ "$file" == "$folder/." ] || [ "$file" == "$folder/.." ]; then
        continue
    fi

    echo "Processing $file"

    #If we exceed the image count on a page wrap up and copy the backsides to the next page
    if [ $((image_count % images_per_page)) -eq 0 ]; then
        if [ $image_count -gt 0 ]; then
            #Finish Front Side
            echo "\vspace*{120in}" >> $output_name.tex
            echo "\\end{figure}" >> $output_name.tex

            #Backside
            if [ -n "${backside}" ]; then
                #Finish the Backside page as well
                echo "\vspace*{120in}" >> $output_name_back.tex
                echo "\\end{figure}" >> $output_name_back.tex

                #Copy temporary backside latex into our regular latex file 
                cat $output_name_back.tex >> $output_name.tex
                #Clean afterwards
                rm $output_name_back.tex
            fi
        fi

        #Begin new Page Front and Backside
        echo "\\begin{figure}[htbp]" >> $output_name.tex
        echo "\\centering" >> $output_name.tex

        if [ -n "${backside}" ]; then
            echo "\\begin{figure}[htbp]" >> $output_name_back.tex
            echo "\\centering" >> $output_name_back.tex
        fi
    fi
  
    #Frontside
    echo "\\includegraphics[width=${width_mm}mm,height=${height_mm}mm]{$file}\\hspace{${hspace_mm}mm}\\vspace{${vspace_mm}mm}" >> $output_name.tex

    #Backside  
    if [ -n "${backside}" ]; then
        echo "\\includegraphics[width=${width_mm}mm,height=${height_mm}mm]{$backside}\\hspace{${hspace_mm}mm}\\vspace{${vspace_mm}mm}" >> $output_name_back.tex
    fi
  
    ((image_count++))

    if [ $((image_count % images_per_line)) -eq 0 ]; then
        if [ -n "${backside}" ]; then
            echo -e "\n" >> $output_name_back.tex
        fi

        echo -e "\n" >> $output_name.tex
    fi
done

#Wrap up

#Final Front Side Finish
echo "\vspace*{120in}" >> $output_name.tex
echo "\\end{figure}" >> $output_name.tex

#Final Backside
if [ -n "${backside}" ]; then
    #Finish the Backside page as well
    echo "\vspace*{120in}" >> $output_name_back.tex
    echo "\\end{figure}" >> $output_name_back.tex

    #Copy temporary backside latex into our regular latex file 
    cat $output_name_back.tex >> $output_name.tex
    #Clean afterwards
    rm $output_name_back.tex $output_name_back.log
fi

# Complete the LaTeX template
cat <<EOF >> $output_name.tex
\end{document}
EOF

# Compile LaTeX template to PDF
pdflatex $output_name.tex

# Clean up temporary files
rm $output_name.aux $output_name.log $output_name.tex
echo "==============================================="
echo "PDF generated: $output_name.pdf"
