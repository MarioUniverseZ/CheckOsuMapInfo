# CheckOsuMapInfo
an application which checks difficulty information from a beatmap(might be pretty useless though)

![image](https://github.com/user-attachments/assets/f1231a49-26c0-4f48-9819-1a81ee8835b3)

# Why Do You Wanna Make This?
to practice my web scraping skill and something I learned from the class called ```Data Exploration and Information Visualization```(資料探索及資訊視覺化)

### Requires [RStudio](https://posit.co/download/rstudio-desktop/) to run this

# Things It Can Do
- displaying the imported URL
- displaying the artist - title
- displaying the beatmap host
- listing all available difficulties 
- listing diffnames, star ratings, playcounts, passcounts and the ratios of clearing the difficulty, $`x`$, $`0 \le x \le 1`$
- sorting the table by one of these options:
  - star rating
  - playcount
  - passcount
  - clear ratio
- sorting the table in the ascending/descending order with the options mentioned above

# Usage
1. download this repo
2. extract the zip somewhere else
3. double-click either ```server.R``` or ```ui.R```
4. hit the ```Run App``` button <br>
        ![image](https://github.com/user-attachments/assets/c7270baa-4f0a-4239-af4b-f1471f97aff6)
5. paste the URL of the beatmap and it does the analysis(all gamemodes work and preferably all the ranked maps or the loved one before 2021)

# Known Issues
none yet
