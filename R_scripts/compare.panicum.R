#AUG 4 - CONSTAX treated.
library(dplyr)
library(betapart)

virg.con<-read.delim("new.pipeline.results.2024.july/Constax.virgatum/constax_taxonomy.ITS1.txt")
virg.con2<-read.delim("new.pipeline.results.2024.july/Constax.virgatum/constax_taxonomy.ITS2.txt")
virg.con.t<-rbind.data.frame(virg.con, virg.con2)
virg.con.t2<-virg.con.t[!virg.con.t$Phylum=="",]
#virg.con.t3<-virg.con.t2[!virg.con.t2$Genus=="Puccinia",]
samlist<-read.csv("~/Desktop/Manus.2024.2025/pipeline.revisions/Panicum.datasets/Re__Hello_and_data_request/NB.samples.list.csv")
otutable<-read.csv("~/Desktop/Manus.2024.2025/pipeline.revisions/Panicum.datasets/Re__Hello_and_data_request/labeled.otu_table_KBSM.csv")
taxtab<-read.csv("~/Desktop/Manus.2024.2025/pipeline.revisions/Panicum.datasets/Re__Hello_and_data_request/tax_table_KBSM.csv")

#get the column names for the samples we are interested in on the otu table provided in Panicum study.
cols.otu.sam<-c()
for(i in 1:length(samlist$PLOT_GL)){
  zz<-grep(samlist$PLOT_GL[i], colnames(otutable))
  cols.otu.sam<-c(cols.otu.sam, zz)
}

#otu table with our columns of interest
otutable.sam<-otutable[,c(1,cols.otu.sam)]
#Now all the taxonomic information is there. 
otutable.lab.sam<-cbind.data.frame(taxtab,otutable.sam)


#Calculate AVerage for one samp
#otutable.lab.sam$M3003avg<-rowMeans(otutable.lab.sam[grep("M3003", colnames(otutable.lab.sam))])
#Calc average for all samples

num_rows <- nrow(otutable.lab.sam)
row_means <- data.frame(matrix(ncol = 0, nrow = num_rows))
for (name in samlist$PLOT_GL) {
  cols <- grep(name, colnames(otutable.lab.sam), value = TRUE)
  if (length(cols) > 0) {
    row_means[[name]] <- rowMeans(otutable.lab.sam[, cols])
  }
}

otutable.lab.sam.means<-cbind.data.frame(otutable.lab.sam[,1:16], row_means)

#Next, determine the sample that was taken (plant life stage) and rename it to correspond to SRR number. 

virg.con.t2$SRR<-sub("\\..*","",virg.con.t2$OTU_ID)
#place both host individual identifiers beside each other.
Plant<-c()
for (i in 1:length(virg.con.t2$SRR)){
  zz<-samlist$PLOT_GL[samlist$SRR==virg.con.t2$SRR[i]]
  Plant<-c(Plant,zz)
}
virg.con.t4<-cbind.data.frame(virg.con.t2, Plant)

#They consider contaminants: Clavaria, Lasiodiplodia, Tausonia, Trachicladium, Malassezia, Pseudogymnoascus, Delicatula, Spizellomyces, and Lepista.
#These are not in their otu table. 
#We do not guarantee contaminant free, so omit these from our genera list.

virg.con.t4<-virg.con.t4[which(!virg.con.t4$Genus %in% c("Clavaria", "Lasiodiplodia", "Tausonia", "Trachicladium", "Malassezia", "Pseudogymnoascus", "Delicatula", "Spizellomyces", "Lepista")),]

#function to set up beta.pair:
betaprep<- function(vec1, vec2) {
  all_values <- unique(c(vec1, vec2))
  df <- rbind.data.frame(all_values %in% vec1,
                         all_values %in% vec2)
  colnames(df) <- all_values
  df <- lapply(df, as.numeric)
  df <- data.frame(df)
  rownames(df) <- c("amplicon", "pipeline")
  return(df)
}

#Find counts for families in otutable from Panicum study
Families<-na.omit(unique(otutable.lab.sam.means$Family))
Families<-Families[which(!Families=="Incertae_sedis")]

#get family counts for all columns.
# Get the column names from the 17th column onwards
column_names <- colnames(otutable.lab.sam.means)[17:ncol(otutable.lab.sam.means)]
# Initialize an empty list to store the vectors
vector_list <- list()
# Loop over each column name
for (col_name in column_names) {
  # Initialize an empty vector for the current column
  current_vector <- c()
  
  # Loop over each family
  for (i in 1:length(Families)) {
    # Calculate the sum for the current family and column
    zz <- sum(otutable.lab.sam.means[,col_name][na.omit(otutable.lab.sam.means$Family) == Families[i]])
    
    # Append the sum to the current vector
    current_vector <- c(current_vector, zz)
  }
  
  # Add the current vector to the list
  vector_list[[col_name]] <- current_vector
}

# Convert the list to a dataframe
Family.counts <- as.data.frame(vector_list)
Family.counts<-cbind.data.frame(Families, Family.counts)
Family.counts$total<-rowSums(Family.counts[,2:31])

F.co.tot<-Family.counts$Families[which(cumsum(Family.counts$total)<=0.9 * sum(Family.counts$total)[1])]


#remove singletons
virg.con.t4f<-virg.con.t4[which(!virg.con.t4$Family==""),]
virg.con.t4fs<-virg.con.t4f %>%
  group_by(SRR, Family) %>%
  mutate(n = n()) %>%
  filter(n > 1) %>%
  select(-n)

d.F.co.tot<-unique(virg.con.t4fs$Family)
#these slipped in due to unclear taxonomical relations, remove them.
d.F.co.tot<-d.F.co.tot[!d.F.co.tot %in% c("Peltaster gemmifer", "Sympodiomycopsis")]

beta.fam<-betaprep(F.co.tot, d.F.co.tot)
sor.fam<-beta.pair(beta.fam)



#~#~#~#~#~#~#~#~#~#~#~#~#~#~# Same for genera #~#~#~#~@#~#~#~#~#~#~#~#~#
#Find counts for families in otutable from Panicum study
Genera<-na.omit(unique(otutable.lab.sam.means$Genus))


#get family counts for all columns, not just M4021.
# Get the column names from the 17th column onwards
column_names <- colnames(otutable.lab.sam.means)[17:ncol(otutable.lab.sam.means)]
# Initialize an empty list to store the vectors
vector_list <- list()
# Loop over each column name
for (col_name in column_names) {
  # Initialize an empty vector for the current column
  current_vector <- c()
  
  # Loop over each family
  for (i in 1:length(Genera)) {
    # Calculate the sum for the current family and column
    zz <- sum(otutable.lab.sam.means[,col_name][na.omit(otutable.lab.sam.means$Genus) == Genera[i]])
    
    # Append the sum to the current vector
    current_vector <- c(current_vector, zz)
  }
  
  # Add the current vector to the list
  vector_list[[col_name]] <- current_vector
}

# Convert the list to a dataframe
Genus.counts <- as.data.frame(vector_list)
Genus.counts<-cbind.data.frame(Genera, Genus.counts)
Genus.counts$total<-rowSums(Genus.counts[,2:31])

G.co.tot<-Genus.counts$Genera[which(cumsum(Genus.counts$total)<=0.9 * sum(Genus.counts$total)[1])]


#remove singletons
virg.con.t4g<-virg.con.t4[which(!virg.con.t4$Genus==""),]
virg.con.t4gs<-virg.con.t4g %>%
  group_by(SRR, Genus) %>%
  mutate(n = n()) %>%
  filter(n > 1) %>%
  select(-n)

d.G.co.tot<-unique(virg.con.t4gs$Genus)
# a few full species names slipped in, we can preserve the genus.
d.G.co.tot<-sub(" .*","", d.G.co.tot)


beta.gen<-betaprep(G.co.tot, d.G.co.tot)
sor.gen<-beta.pair(beta.gen)



#~#~#~#~#~#~#~# classified with dnabarcoder + confidence > .7
virg1<-read.csv("~/Desktop/Manus.2024.2025/pipeline.revisions/new.pipeline.results.2024.july/virgatum.ITS1.labeled.csv")
virg2<-read.csv("~/Desktop/Manus.2024.2025/pipeline.revisions/new.pipeline.results.2024.july/virgatum.ITS2.labeled.csv")
virg<-rbind.data.frame(virg1,virg2)
#clean my data - only taxa detected.
virgb<-virg[!virg$taxon == "",] 
virgc<-virgb[virgb$confidence >= 0.7,]

virgd<-virgc %>% 
  group_by(taxon, ID) %>% 
  distinct(genus, ID, .keep_all = TRUE)

#establish link with sample name
virge<-virgd %>%
  left_join(samlist[,c(1,12)], join_by(ID == SRR))

virge$species<-sub("_", " ", virge$species)
#remove singletons - family
virge.f<-virge[which(!virge$family==""),]
virge.fs<-virge.f %>%
  group_by(ID, family) %>%
  mutate(n = n()) %>%
  filter(n > 1) %>%
  select(-n)
d.f.virge<-unique(virge.fs$family)
d.f.virge<-d.f.virge[!d.f.virge %in% "Dothideomycetes_fam_Incertae_sedis"]

beta.fam2<-betaprep(F.co.tot, d.f.virge)
sor.fam.70<-beta.pair(beta.fam2)

#remove singletons - genus
virge.g<-virge[which(!virge$genus==""),]
virge.gs<-virge.g %>%
  group_by(ID, genus) %>%
  mutate(n = n()) %>%
  filter(n > 1) %>%
  select(-n)
d.g.virge<-unique(virge.gs$genus)
beta.gen2<-betaprep(G.co.tot, d.g.virge)
sor.gen.70<-beta.pair(beta.gen2)

#all
sors<-rbind.data.frame(sor.fam, sor.fam.70, sor.gen, sor.gen.70)
rownames(sors)<-c("Family (Constax)", "Family (DNAbarcoder)", "Genus (Constax)", "Genus (DNAbarcoder)")
write.csv(sors,"sor.indices.virgatum.csv")
write.csv(beta.gen, "beta.gen.csv")
write.csv(beta.gen2, "beta.gen.dnabarcoder.csv")
write.csv(beta.fam, "beta.fam.csv")
write.csv(beta.fam2, "beta.fam.dnabarcoder.csv")
