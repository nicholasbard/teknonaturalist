# This script may be run once classification has been run on pooled samples for each taxon. 
# The code uses example data from Betula dataset (Betula ermanii, B. nana, B. pendula, B. platyphylla, S. doronicum, P. virgatum, B. alternifolia) to locate ITS1/ITS2 sequences with support at class taxonomic rank by 5.8S, or any additional classified ITS1 or ITS2 sequences.
# ITS2 sequences are prioritized, with ITS1 sequences secondarily considered.

library(dplyr)
library(stringr)

#Set working directory, read in data, and set host names. 
setwd("~/Desktop/Manus.2024.2025/pipeline.revisions/new.pipeline.results.2024.july")
erm.s58<-read.csv("ermanii.5_8S.labeled.csv")
erm.ITS2<-read.csv("ermanii.ITS2.labeled.csv")
erm.ITS1<-read.csv("ermanii.ITS1.labeled.csv")
nana.s58<-read.csv("nana.5_8S.labeled.csv")
nana.ITS2<-read.csv("nana.ITS2.labeled.csv")
nana.ITS1<-read.csv("nana.ITS1.labeled.csv")
pen.s58<-read.csv("pendula.5_8S.labeled.csv")
pen.ITS2<-read.csv("pendula.ITS2.labeled.csv")
pen.ITS1<-read.csv("pendula.ITS1.labeled.csv")
plat.s58<-read.csv("platyphylla.5_8S.labeled.csv")
plat.ITS2<-read.csv("platyphylla.ITS2.labeled.csv")
plat.ITS1<-read.csv("platyphylla.ITS1.labeled.csv")
virg.s58<-read.csv("virgatum.5_8S.labeled.csv")
virg.ITS2<-read.csv("virgatum.ITS2.labeled.csv")
virg.ITS1<-read.csv("virgatum.ITS1.labeled.csv")
altern.s58<-read.csv("alternifolia.5_8S.labeled.csv")
altern.ITS2<-read.csv("alternifolia.ITS2.labeled.csv")
altern.ITS1<-read.csv("alternifolia.ITS1.labeled.csv")
erm.ITS2$Host<-"B.ermanii"
erm.ITS1$Host<-"B.ermanii"
erm.s58$Host<-"B.ermanii"
nana.ITS2$Host<-"B.nana"
nana.ITS1$Host<-"B.nana"
nana.s58$Host<-"B.nana"
pen.ITS2$Host<-"B.pendula"
pen.ITS1$Host<-"B.pendula"
pen.s58$Host<-"B.pendula"
plat.ITS2$Host<-"B.platyphylla"
plat.ITS1$Host<-"B.platyphylla"
plat.s58$Host<-"B.platyphylla"
virg.ITS2$Host<-"P.virgatum"
virg.ITS1$Host<-"P.virgatum"
virg.s58$Host<-"P.virgatum"
altern.ITS2$Host<-"Bud.alternifolia"
altern.ITS1$Host<-"Bud.alternifolia"
altern.s58$Host<-"Bud.alternifolia"

# Create 5.8S (s58), ITS2, and ITS1 dataframes.
s58<-rbind(erm.s58, nana.s58, pen.s58, plat.s58, virg.s58, altern.s58)
ITS2<-rbind(erm.ITS2, nana.ITS2, pen.ITS2, plat.ITS2, virg.ITS2, altern.ITS2)
ITS1<-rbind(erm.ITS1, nana.ITS1, pen.ITS1, plat.ITS1, virg.ITS1, altern.ITS1)

# Combine SRA and read ID in new variable "IDread"
s58$IDread<-paste(s58$ID, s58$read, sep=".")
ITS2$IDread<-paste(ITS2$ID, ITS2$read, sep=".")
ITS1$IDread<-paste(ITS1$ID, ITS1$read, sep=".")

# Optional: Combine ITS1 and ITS2.
ITSdetected.sum<-rbind(ITS1,ITS2)

# Delete unverified taxa
s58<-s58[!s58$taxon == "", ]
ITS2<-ITS2[!ITS2$taxon == "", ]
ITS1<-ITS1[!ITS1$taxon == "", ]
# Make new taxon category with genus or higher determination
ITS2$taxon2<- str_remove(ITS2$taxon, "(\\s+\\w+)")
ITS2$taxon2<- str_remove(ITS2$taxon2, "(-\\w+)")
ITS1$taxon2<- str_remove(ITS1$taxon, "(\\s+\\w+)")
ITS1$taxon2<- str_remove(ITS1$taxon2, "(-\\w+)")

# Identify flanked regions that support class
ITS2.5.8S<-rbind(data.frame(cbind(IDread=s58$IDread[s58$IDread %in% ITS2$IDread],class=s58$class[s58$IDread %in% ITS2$IDread],region=s58$region[s58$IDread %in% ITS2$IDread],Host=s58$Host[s58$IDread %in% ITS2$IDread])), 
                 data.frame(cbind(IDread=ITS2$IDread[ITS2$IDread %in% s58$IDread],class=ITS2$class[ITS2$IDread %in% s58$IDread],region=ITS2$region[ITS2$IDread %in% s58$IDread],Host=ITS2$Host[ITS2$IDread %in% s58$IDread])))

ITS1.5.8S<-rbind(data.frame(cbind(IDread=s58$IDread[s58$IDread %in% ITS1$IDread],class=s58$class[s58$IDread %in% ITS1$IDread],region=s58$region[s58$IDread %in% ITS1$IDread],Host=s58$Host[s58$IDread %in% ITS1$IDread])), 
                 data.frame(cbind(IDread=ITS1$IDread[ITS1$IDread %in% s58$IDread],class=ITS1$class[ITS1$IDread %in% s58$IDread],region=ITS1$region[ITS1$IDread %in% s58$IDread],Host=ITS1$Host[ITS1$IDread %in% s58$IDread])))

ITS2.ITS1<-rbind(data.frame(cbind(IDread=ITS1$IDread[ITS1$IDread %in% ITS2$IDread],class=ITS1$class[ITS1$IDread %in% ITS2$IDread],region=ITS1$region[ITS1$IDread %in% ITS2$IDread],Host=ITS1$Host[ITS1$IDread %in% ITS2$IDread])), 
                 data.frame(cbind(IDread=ITS2$IDread[ITS2$IDread %in% ITS1$IDread],class=ITS2$class[ITS2$IDread %in% ITS1$IDread],region=ITS2$region[ITS2$IDread %in% ITS1$IDread],Host=ITS2$Host[ITS2$IDread %in% ITS1$IDread])))

# Select ITS that match class to 5.8S, and/or additional ITS1 or ITS2 sequence
class.ITS2.5.8S<-ITS2.5.8S %>%
  group_by(IDread) %>%
  arrange(desc(region), .by_group = TRUE) %>%
  distinct(class, .keep_all = TRUE) %>%
  filter(n() == 1)
fil.ITS2.5.8S<-ITS2[ITS2$IDread %in% class.ITS2.5.8S$IDread,]
class.ITS1.5.8S<-ITS1.5.8S %>%
  arrange(desc(region), .by_group = TRUE) %>%
  group_by(IDread) %>%
  distinct(class, .keep_all = TRUE) %>%
  filter(n() == 1)
fil.ITS1.5.8S<-ITS1[ITS1$IDread %in% class.ITS1.5.8S$IDread,]
class.ITS2.ITS1<-ITS2.ITS1 %>%
  arrange(desc(region), .by_group = TRUE) %>%
  group_by(IDread) %>%
  distinct(class, .keep_all = TRUE) %>%
  filter(n() == 1)
fil.ITS2.ITS1<-ITS1[ITS1$IDread %in% class.ITS2.ITS1$IDread,]

# Make new columns if they have 5.8S or additional ITS1 or ITS2 support at class level
ITS2$s58<-ITS2$IDread[match(ITS2$IDread,class.ITS2.5.8S$IDread)]
ITS2$s58<-ifelse(ITS2$s58 != "NA", "yes")
ITS1$s58<-ITS1$IDread[match(ITS1$IDread,class.ITS1.5.8S$IDread)]
ITS1$s58<-ifelse(ITS1$s58 != "NA", "yes")
ITS<-rbind(ITS2,ITS1)
ITS$ITS.support<-ITS$IDread[match(ITS$IDread,class.ITS2.ITS1$IDread)]
ITS$ITS.support<-ifelse(ITS$ITS.support != "NA", "yes")
# Note: retained for "verified fungi" - Table 2).

#Filter out anything not detected at genus level.
gen.ITS<-ITS[-grep("Incertae_sedis",ITS$genus),] 
gen.ITS<-gen.ITS[-grep("unidentified",gen.ITS$genus),] 
#(retained for "verified fungi" - Table 2))

# Keep highest confidence determinations
filt.ITS<-ITS %>%
  arrange(confidence, .by_group = TRUE) %>%
  distinct(IDread, .keep_all = TRUE)

# Save 
write.csv(filt.ITS, "Filt.ITS.all.csv")
