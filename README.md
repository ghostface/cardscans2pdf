# cardscans2pdf

Takes a folder with an arbitrary number of png/jpg card scans and generates a printable pdf.

It will automatically create matching backside pages for duplex printing if it finds a backside.jpg/png file.

## Howto Use

1. Checkout folder
2. Create new folder (e.g. test) in the same directory as the *.sh files
3. Copy png/jpg files into folder, make sure to have a backside.png/jpg in there if you want backsides
4. Run card size with folder as parameter, e.g.
    ./88x125 test
5. Enjoy generated test.png


## Notes

- Sizes are provided in metric mm
- By default it generates metric A4 pdfs. If you need something else, youshould be able to replace a4paper with letterpaper or some other latex compatible format in the .sh files. 
- First time using latex so might not be a 100% clean implementation
 
## Requirements

- latex
- bash
