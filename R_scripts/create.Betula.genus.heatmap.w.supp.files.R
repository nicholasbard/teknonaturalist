#~ Generates genus abundance plot and generation of supplemental files used in Betula example study.
# Can be used on input files created using the analyze.5.8S.R script (e.g., "Filt.ITS.Betula.csv")
# Nick Bard 2023

library(ggplot2)
library(dplyr)
library(ggtree)
library(ape)
library(ggtext)
library(aplot)
library(stringr)

# Set working directory to 
setwd("~/Desktop/2022.3.manus/teknonaturalist/Manu.submission.mostrecent.jan2024/")

# Read in combined data
Host.Fung<-read.csv("Filt.ITS.Betula.csv")
# Remove hosts (e.g., B. nana)
Host.Fung<-Host.Fung[!Host.Fung$Host == "B.nana", ]
# Note: In the Betula study, Supplemental File 1 (Betula nana) is the equivalent of Supplemental File 2 (all other Betula species, combined)

# Make new general "Flank" column if 5.8S and/or alternate ITS (1 or 2) present
Host.Fung$Flank<-paste(Host.Fung$s58, Host.Fung$ITS.support, sep=".")

Host.Fung<-Host.Fung %>%
  mutate(Flank = ifelse(s58 == "yes","yes",
                        ifelse(ITS.support =="yes", "yes")))

#~#~# Create Supplemental Files #~#~#

# All unique taxa, on the side
Host.Fung.all.uniq<-Host.Fung %>%
  distinct(taxon2, ID, .keep_all = TRUE) 
# Write csv for Supplemental File 2.
write.csv(Host.Fung.all.uniq, "supp2.all.taxa.in.individuals.csv")

# Calculate distinct genera in distinct dataset (used for Table 2)
genHost.Fung.all.uniq<-Host.Fung.all.uniq[-grep("Incertae_sedis",Host.Fung.all.uniq$genus),] 
genHost.Fung.all.uniq<-genHost.Fung.all.uniq[-grep("unidentified",genHost.Fung.all.uniq$genus),] 

# Filter out anything not detected at genus level in main dataset.
gen.host.filt<-Host.Fung[-grep("Incertae_sedis",Host.Fung$genus),] 
gen.host.filt<-gen.host.filt[-grep("unidentified",gen.host.filt$genus),] 

# Write csv for Supplemental File 3.
write.csv(gen.host.filt, "supp3.genus.all.conf.csv")
#~#~##~#~##~#~##~#~##~#~##~#~#


# Filter low confidence classifications (below 0.7).
gen.host.f.conf70<-gen.host.filt[!gen.host.filt$confidence < 0.7, ]

# Add raw count column, keep only distinct genus/ID pairs.
gen.host.2<-gen.host.f.conf70 %>%
  distinct(genus, ID, .keep_all = TRUE) %>%
  group_by(genus, Host) %>%
  mutate(Genus_count = n())


#Add adjusted count by sample individual total (B.ermanii=24, B.platyphylla=83, B.pendula=78)
gen.host.3<-gen.host.2 %>%
  mutate(adj.gen.count = ifelse(Host == "B.ermanii", Genus_count/24,
                                       ifelse(Host == "B.platyphylla", Genus_count/83,
                                              ifelse(Host=="B.pendula", Genus_count/78))))
# Write csv for Supplemental File 4.
write.csv(gen.host.3, "supp4.genus.70.conf.csv")
# Note: "Guild" column added manually.

#~#~# Create Genus Heatmap Figure  #~#~#

# Read csv of new file with "Guild" column (required for gen.host.4 variable step)
gen.host.3<-read.csv("supp4.genus.70.conf.csv")

# Omit single genus families, orders, and classes, and incertae sedis from graph. 
gen.host.3$order<-str_replace(gen.host.3$order, '.+?_..._', "")
gen.host.3$family<-str_replace(gen.host.3$family, '.+?_..._', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Incertae_sedis', "")
gen.host.3$order<-str_replace(gen.host.3$order, 'Incertae_sedis', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Arthoniaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Aspergillaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Coryneliaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Cortinariaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Elsinoaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Endosporiaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Erysiphaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Exobasidiaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Gloniaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Inocybaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Kondoaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Melampsoraceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Melanconidaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Microstromataceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Nectriaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Palawaniaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Pannariaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Paracladophialophoraceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Pertusariaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Phaeotremellaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Pilodermataceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Pertusariaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Pilodermataceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Pucciniastraceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Pyriculariaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Quambalariaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Ramalinaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Russulaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Sebacinaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Sporocadaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Sporormiaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Strelitzianaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Sporormiaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Taphrinaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Tremellaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Tylosporaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Strelitzianaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Umbelopsidaceae', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Ustilentylomataceae', "")
gen.host.3$order<-str_replace(gen.host.3$order, 'Agaricostilbales', "")
gen.host.3$order<-str_replace(gen.host.3$order, 'Arthoniales', "")
gen.host.3$order<-str_replace(gen.host.3$order, 'Agaricostilbales', "")
gen.host.3$order<-str_replace(gen.host.3$order, 'Coryneliales', "")
gen.host.3$order<-str_replace(gen.host.3$order, 'Erysiphales', "")
gen.host.3$order<-str_replace(gen.host.3$order, 'Eurotiales', "")
gen.host.3$order<-str_replace(gen.host.3$order, 'Exobasidiales', "")
gen.host.3$order<-str_replace(gen.host.3$order, 'Hypocreales', "")
gen.host.3$order<-str_replace(gen.host.3$order, 'Magnaporthales', "")
gen.host.3$order<-str_replace(gen.host.3$order, 'Microbotryales', "")
gen.host.3$order<-str_replace(gen.host.3$order, 'Peltigerales', "")
gen.host.3$order<-str_replace(gen.host.3$order, 'Pertusariales', "")
gen.host.3$order<-str_replace(gen.host.3$order, 'Russulales', "")
gen.host.3$order<-str_replace(gen.host.3$order, 'Sebacinales', "")
gen.host.3$order<-str_replace(gen.host.3$order, 'Taphrinales', "")
gen.host.3$order<-str_replace(gen.host.3$order, 'Umbelopsidales', "")
gen.host.3$class<-str_replace(gen.host.3$class, 'Agaricostilbomycetes', "")
gen.host.3$class<-str_replace(gen.host.3$class, 'Microbotryomycetes', "")
gen.host.3$class<-str_replace(gen.host.3$class, 'Taphrinomycetes', "")
gen.host.3$class<-str_replace(gen.host.3$class, 'Umbelopsidomycetes', "")

# Prepare variables as factors grouped by genus.
gen.host.4<-gen.host.3 %>%
  group_by(genus) %>%
  distinct(phylum, class, order, family, genus, Host, adj.gen.count, Guild, Flank) 
gen.host.5<-gen.host.4 %>%
  distinct(phylum,class,order, family, genus, Guild, Flank) 

gen.host.5$genus<-as.factor(gen.host.5$genus)
gen.host.5$family<-as.factor(gen.host.5$family)
gen.host.5$order<-as.factor(gen.host.5$order)
gen.host.5$class<-as.factor(gen.host.5$class)
gen.host.5$phylum<-as.factor(gen.host.5$phylum)

# This keeps distinct genera, preferentially those that are flanked (by "Yes"), to make a phylogeny.
gen.host.7<-gen.host.5%>%
  arrange(desc(Flank), .by_group = TRUE) %>%
  distinct(genus, .keep_all = TRUE)
# Create phylogenetic tree
taxa2 <- as.phylo(~phylum/class/order/family/genus, data = gen.host.7, collapse = FALSE)
# Reorder genus by tip labels
reorder_idx3 <- match(gen.host.7$genus,taxa2$tip.label)
gen.host.8<-gen.host.7 %>%
  arrange(reorder_idx3)
# Add in plant pathogen, endophyte, and combined color-coded guild types.
d2 <- data.frame(node=grep("plant pathogen", gen.host.8$Guild, ignore.case = TRUE), Guild=c("Plant pathogen"))
d2<-rbind.data.frame(d2, data.frame(node=grep("endophyte", gen.host.8$Guild, ignore.case = TRUE), Guild=c("Endophyte")))
d2<-rbind.data.frame(d2, data.frame(node=d2$node[which(duplicated(d2$node))], Guild=c("Plant pathogen/\nendophyte")))
# Sort by nodes in Guild column, retain only unique nodes.
d3<-d2 %>%
  arrange(desc(Guild), .by_group = TRUE) %>%
  distinct(node, .keep_all = TRUE)

# Create dataframe for nodes where flank = "yes"
f2<-data.frame(node=grep("yes", gen.host.8$Flank, ignore.case = TRUE))
# Calculate number of nodes for node.labels representing Order, Class, and Phylum taxonomic ranks.
n2<-length(taxa2$tip.label)+grep(pattern="mycota|mycetes|ales", x=taxa2$node.label)

# Create "invisible" phylogenetic tree. This must be filled in manually for legend control:
p2<-ggtree(taxa2, linetype="blank")+geom_nodelab(aes(hjust=1, angle=0, node=node, label = label, fontface="bold", fontsize=15))+
  geom_hilight(data=d3, aes(node=node, fill=Guild), type = "rect", xmax=4.7, xmin=6, alpha=.8, size=.25)+
  scale_fill_manual(values=c("springgreen3", "firebrick3", "goldenrod1"))+
  geom_tiplab(offset = -.3, size=4, fontface=4)+geom_cladelab(node=f2$node, label='•', fontsize=13, offset.text=.7)+
  geom_hilight(node=85, fill='skyblue', extend=-3.5) +geom_hilight(node=137, fill='coral', extend=-3.5)+
  geom_hilight(node=164, fill='seagreen1', extend=-3.5)+ 
  geom_hilight(node=86, fill='rosybrown', extend=-2.5)+ geom_hilight(node=103, fill='khaki', extend=-2.5) +
  geom_hilight(node=95, fill='seagreen1', extend=-2.5)+geom_hilight(node=128, fill='lightpink', extend=-2.5) +
  geom_hilight(node=122, fill='coral', extend=-2.5)+geom_hilight(node=117, fill='rosybrown', extend=-2.5) +
  geom_hilight(node=138, fill='lightpink', extend=-2.5)+geom_hilight(node=157, fill='seagreen1', extend=-2.5) +
  geom_hilight(node=152, fill='khaki', extend=-2.5)+ 
  geom_hilight(node=161, fill='skyblue', extend=-2.5) +
  geom_hilight(node=87, fill='skyblue', extend=-1.5) +geom_hilight(node=104, fill='seagreen1', extend=-1.5)+
  geom_hilight(node=107, fill='coral', extend=-1.5) +geom_hilight(node=114, fill='rosybrown', extend=-1.5)+
  geom_hilight(node=113, fill='lightpink', extend=-1.5) +geom_hilight(node=109, fill='skyblue', extend=-1.5)+
  geom_hilight(node=111, fill='seagreen1', extend=-1.5) +geom_hilight(node=96, fill='lightpink', extend=-1.5)+
  geom_hilight(node=101, fill='rosybrown', extend=-1.5) +geom_hilight(node=119, fill='skyblue', extend=-1.5)+
  geom_hilight(node=129, fill='coral', extend=-1.5)+ geom_hilight(node=123, fill='khaki', extend=-1.5)+
  geom_hilight(node=143, fill='khaki', extend=-1.5)+ geom_hilight(node=118, fill='lightpink', extend=-1.5)+
  geom_hilight(node=145, fill='seagreen1', extend=-1.5)+ geom_hilight(node=141, fill='coral', extend=-1.5) +
  geom_hilight(node=139, fill='skyblue', extend=-1.5)+ geom_hilight(node=158, fill='rosybrown', extend=-1.5) +
  geom_hilight(node=155, fill='coral', extend=-1.5)+ geom_hilight(node=162, fill='lightpink', extend=-1.5) +
  geom_hilight(node=91, fill='lightpink', extend=-.5)+geom_hilight(node=90, fill='khaki', extend=-.5)+
  geom_hilight(node=88, fill='coral', extend=-.5) +geom_hilight(node=89, fill='rosybrown', extend=-.5)+
  geom_hilight(node=105, fill='khaki', extend=-.5) +geom_hilight(node=108, fill='seagreen1', extend=-.5)+
  geom_hilight(node=97, fill='skyblue', extend=-.5) +geom_hilight(node=131, fill='seagreen1', extend=-.5)+
  geom_hilight(node=125, fill='skyblue', extend=-.5) +geom_hilight(node=119, fill='coral', extend=-.5)+
  geom_hilight(node=146, fill='lightpink', extend=-.5) +geom_hilight(node=142, fill='skyblue', extend=-.5)+
  geom_hilight(node=159, fill='khaki', extend=-.5) +
  geom_tiplab(offset = -.3, size=4, fontface=4)+geom_cladelab(node=f2$node, label='•', fontsize=13, offset.text=.7)+
  theme(legend.position=c(-0.01,0.5), legend.justification="left",legend.box.spacing = unit(-8, "pt"), 
        legend.background = element_rect(fill="lightblue",colour ="darkblue"), 
        legend.text = element_text(size=14),  legend.title = element_text(size=14, face = "bold"), plot.margin=unit(c(1,-1.5,1,1), "pt"))

# Get taxon name and assign to match non-distinct, genus grouped data (gen.host.4).
nam2<-get_taxa_name(p2)
reorder_idx2 <- match(gen.host.4$genus,nam2)
gen.host.6<-gen.host.4 %>%
  arrange(reorder_idx2)

# Create heatmap based on frequency in each host species.
g2<-ggplot(gen.host.6, aes(x=Host, y=genus, fill=adj.gen.count))+
  geom_tile() + scale_y_discrete(limits=rev(unique(gen.host.6$genus)), aes(fontface)) + 
  guides(fill=guide_legend(title="Frequency in\nsample"))+theme(legend.position=c(-0.01,0.5), 
                                                                legend.justification="left",legend.box.spacing = unit(-8, "pt"), 
                                                                legend.background = element_rect(fill="lightblue",colour ="darkblue"),
                                                                legend.title=element_text(size=14, face = "bold"), legend.text=element_text(size=13),
                                                                axis.title.y = element_blank(), axis.text.y = element_blank(), 
                                                                axis.text.x=element_text(size=15, face = "bold.italic"), axis.title.x = element_text(size=15, face="bold"))

#Place invisible phylogeny and heatmap side-by-side.
pg<-g2 %>% insert_left(p2, width=1.2) 
print(pg)+ggtitle("Fungal taxon")+theme(plot.title = element_text(vjust=-532, hjust=-.65, face = "bold", size=15))
# Renders well at 2300 X 2300
# Note: Taxonomic rank columns were added manually.





