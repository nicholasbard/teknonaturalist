#~ Generates genus abundance plot and generation of supplemental files used in Betula+others example study.
# Can be used on input files created using the analyze.5.8S.R script (e.g., "Filt.ITS.all.csv")
# Nick Bard 2023

library(ggplot2)
library(dplyr)
library(ggtree)
library(ape)
library(ggtext)
library(aplot)
library(stringr)

# Set working directory to 
setwd("~/Desktop/Manus.2024.2025/pipeline.revisions/")

# Read in combined data
Host.Fung<-read.csv("Upload files/Filt.ITS.all.csv")
# Remove hosts (e.g., B. nana)
Host.Fung<-Host.Fung[!Host.Fung$Host == "B.nana", ]

# Note: In the Betula study, Supplemental File 1 (Betula nana) is the equivalent of Supplemental File 2 (all other Betula species, combined)

# Make new general "Flank" column if 5.8S and/or alternate ITS (1 or 2) present
Host.Fung$Flank<-paste(Host.Fung$s58, Host.Fung$ITS.support, sep=".")

Host.Fung<-Host.Fung %>%
  mutate(Flank = ifelse(s58 == "yes","yes",
                        ifelse(ITS.support =="yes", "yes")))
Host.Fung$order[Host.Fung$family=="Ustilaginaceae"]<-"Ustilaginales"
Host.Fung$class[Host.Fung$family=="Ustilaginaceae"]<-"Ustilaginomycetes"

#~#~# Create Supplemental Files #~#~#

# All unique taxa, on the side
Host.Fung.all.uniq<-Host.Fung %>%
  distinct(taxon2, ID, .keep_all = TRUE) 
# Write csv for Supplemental File 2.
#write.csv(Host.Fung.all.uniq, "supp2.all.taxa.in.individuals.csv")

# Calculate distinct genera in distinct dataset (used for Table 2)
#genHost.Fung.all.uniq<-Host.Fung.all.uniq[-grep("Incertae_sedis",Host.Fung.all.uniq$genus),] 
genHost.Fung.all.uniq<-Host.Fung.all.uniq[-grep("unidentified",Host.Fung.all.uniq$genus),] 

# Filter out anything not detected at genus level in main dataset.
#gen.host.filt<-Host.Fung[-grep("Incertae_sedis",Host.Fung$genus),] 
gen.host.filt<-Host.Fung[-grep("unidentified",Host.Fung$genus),] 

# Write csv for Supplemental File 3.
#write.csv(gen.host.filt, "supp3.genus.all.conf.a.csv")
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
                                       ifelse(Host=="B.pendula", Genus_count/78,
                                              ifelse(Host=="P.virgatum", Genus_count/30,
                                                            ifelse(Host=="Bud.alternifolia", Genus_count/31,))))))

#write.csv(gen.host.3, "genus.70.conf.a.csv")
# Note: "Guild" column added manually.
#read in old csv for only Betula with a lot of guild information
guild.key<-read.csv("../../2022.3.manus/teknonaturalist/Manu.submission.mostrecent.jan2024/supplemental.tables/supp4.genus.70.conf.csv")
which(gen.host.3$genus %in% guild.key$genus)
gen.host.3$Guild<-NULL
gen.host.g<-merge(gen.host.3, guild.key[,c('genus','Guild')], by='genus',all.x=TRUE)
write.csv(gen.host.g, "gen.host.incomp.guild.csv")

#~#~# Create Genus Heatmap Figure  #~#~#
# manually inserted guilds...
# Read csv of new file with "Guild" column (required for gen.host.4 variable step)
gen.host.3<-read.csv("supp4.genus.70.conf.Guilds.csv")



# Omit single genus families, orders, and classes, and incertae sedis from graph labels. 


gen.host.3$order<-str_replace(gen.host.3$order, '.+?_..._', "")
gen.host.3$family<-str_replace(gen.host.3$family, '.+?_..._', "")
gen.host.3$family<-str_replace(gen.host.3$family, 'Incertae_sedis', "")
gen.host.3$order<-str_replace(gen.host.3$order, 'Incertae_sedis', "")


#remove fungal genera only found once per host species
gen.host3c<-gen.host.3[!gen.host.3$Genus_count==1,]



gen.host3d<-gen.host3c %>%
  group_by(family) %>%
  mutate(family = ifelse(n_distinct(genus) > 1 & family != "", family, "")) %>%
  ungroup()
gen.host3e<-gen.host3d %>%
  group_by(order) %>%
  mutate(order = ifelse(n_distinct(genus) > 1 & order != "", order, "")) %>%
  ungroup()
gen.host3f<-gen.host3e %>%
  group_by(class) %>%
  mutate(class = ifelse(n_distinct(genus) > 1 & class != "", class, "")) %>%
  ungroup()


# Prepare variables as factors grouped by genus.
gen.host.4<-gen.host3f %>%
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
gen.host.7<-gen.host.5 %>%
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
p2<-ggtree(taxa2, linetype="blank")+geom_nodelab(aes(hjust=1, angle=0, node=node, label = label, fontface="bold", size=20), size=7)+
  geom_hilight(data=d3, aes(node=node, fill=Guild), type = "rect", xmax=4.7, xmin=6, alpha=.8, size=.25)+
  scale_fill_manual(values=c("springgreen3", "firebrick3", "goldenrod1"))+
  geom_tiplab(offset = -.3, size=7, fontface=4)+geom_cladelab(node=f2$node, label='•', fontsize=20, offset.text=.7)+
  geom_hilight(node=82, fill='skyblue', extend=-3.5)+
  geom_hilight(node=123, fill='coral', extend=-3.5)+ geom_hilight(node=83, fill='khaki', extend=-2.5) +
  geom_hilight(node=95, fill='seagreen1', extend=-2.5)+geom_hilight(node=109, fill='lightpink', extend=-2.5) +
  geom_hilight(node=120, fill='khaki', extend=-2.5) +geom_hilight(node=115, fill='coral', extend=-2.5) +
  geom_hilight(node=124, fill='rosybrown', extend=-2.5) +geom_hilight(node=138, fill='khaki', extend=-2.5) +
  geom_hilight(node=148, fill='lightpink', extend=-2.5) +geom_hilight(node=145, fill='seagreen1', extend=-2.5) +
  geom_hilight(node=135, fill='rosybrown', extend=-2.5) +geom_hilight(node=132, fill='skyblue', extend=-2.5) +
  geom_hilight(node=84, fill='rosybrown', extend=-1.5) +geom_hilight(node=89, fill='seagreen1', extend=-1.5) +
  geom_hilight(node=93, fill='coral', extend=-1.5) +geom_hilight(node=98, fill='lightpink', extend=-1.5) +
  geom_hilight(node=102, fill='seagreen1', extend=-1.5) +geom_hilight(node=110, fill='skyblue', extend=-1.5) +
  geom_hilight(node=104, fill='khaki', extend=-1.5) +
  geom_hilight(node=121, fill='lightpink', extend=-1.5) +geom_hilight(node=116, fill='seagreen1', extend=-1.5) +
  geom_hilight(node=127, fill='coral', extend=-1.5) +geom_hilight(node=130, fill='lightpink', extend=-1.5) +
  geom_hilight(node=141, fill='khaki', extend=-1.5) +geom_hilight(node=139, fill='seagreen1', extend=-1.5) +
  geom_hilight(node=149, fill='skyblue', extend=-1.5) +geom_hilight(node=146, fill='khaki', extend=-1.5) +
  geom_hilight(node=85, fill='seagreen1', extend=-.5) +geom_hilight(node=86, fill='khaki', extend=-.5) +
  geom_hilight(node=88, fill='coral', extend=-.5) +geom_hilight(node=99, fill='skyblue', extend=-.5) +
  geom_hilight(node=101, fill='rosybrown', extend=-.5) +geom_hilight(node=112, fill='seagreen1', extend=-.5) +
  geom_hilight(node=150, fill='lightpink', extend=-.5) +geom_hilight(node=129, fill='seagreen1', extend=-.5) +
  theme(legend.position=c(-0.01,0.5), legend.justification="left",legend.box.spacing = unit(-8, "pt"), 
        legend.background = element_rect(fill="lightblue",colour ="darkblue"), 
        legend.text = element_text(size=20),  legend.title = element_text(size=20, face = "bold"), plot.margin=unit(c(1,-1,1,1), "pt"))

# Get taxon name and assign to match non-distinct, genus grouped data (gen.host.4).
nam2<-get_taxa_name(p2)
reorder_idx2 <- match(gen.host3f$genus,nam2)
gen.host.6<-gen.host3f %>%
  arrange(reorder_idx2)

# Create heatmap based on frequency in each host species.
g2<-ggplot(gen.host.6, aes(x=Host, y=genus, fill=adj.gen.count))+
  geom_tile() + scale_y_discrete(limits=rev(unique(gen.host.6$genus)), aes(fontface)) + 
  guides(fill=guide_legend(title="Frequency in\nsample"))+theme(legend.position=c(-0.01,0.5), 
                                                                legend.justification="left",legend.box.spacing = unit(-8, "pt"), 
                                                                legend.background = element_rect(fill="lightblue",colour ="darkblue"),
                                                                legend.title=element_text(size=20, face = "bold"), legend.text=element_text(size=20),
                                                                axis.title.y = element_blank(), axis.text.y = element_blank(), 
                                                                axis.text.x=element_text(size=21, face = "bold.italic"), axis.title.x = element_text(size=24, face="bold"))


####Revised heatmap - narrower.
#Place invisible phylogeny and heatmap side-by-side.
pg<-g2 %>% insert_left(p2, width=1.2) 
print(pg)+ggtitle("Fungal taxon")+theme(plot.title = element_text(vjust=-532, hjust=-.65, face = "bold", size=40))
# Renders well at 3650 X 2300
# Note: Taxonomic rank columns were added manually.

# Create "invisible" phylogenetic tree. This must be filled in manually for legend control:
p2<-ggtree(taxa2, linetype="blank")+geom_nodelab(aes(hjust=1, angle=0, node=node, label = label, fontface="bold", size=20), size=8, hjust=0, nudge_x=-.5) +
  geom_hilight(data=d3, aes(node=node, fill=Guild), type = "rect", xmax=4.5, xmin=5.5, alpha=.8, size=.25)+
  scale_fill_manual(values=c("springgreen3", "firebrick3", "goldenrod1"))+
  geom_tiplab(offset = -0.5, size=8, fontface=4)+geom_cladelab(node=f2$node, label='•', fontsize=20, offset.text=0.4)+
  geom_hilight(node=82, fill='skyblue', extend=-3.5)+
  geom_hilight(node=123, fill='coral', extend=-3.5)+ geom_hilight(node=83, fill='khaki', extend=-2.5) +
  geom_hilight(node=95, fill='seagreen1', extend=-2.5)+geom_hilight(node=109, fill='lightpink', extend=-2.5) +
  geom_hilight(node=120, fill='khaki', extend=-2.5) +geom_hilight(node=115, fill='coral', extend=-2.5) +
  geom_hilight(node=124, fill='rosybrown', extend=-2.5) +geom_hilight(node=138, fill='khaki', extend=-2.5) +
  geom_hilight(node=148, fill='lightpink', extend=-2.5) +geom_hilight(node=145, fill='seagreen1', extend=-2.5) +
  geom_hilight(node=135, fill='rosybrown', extend=-2.5) +geom_hilight(node=132, fill='skyblue', extend=-2.5) +
  geom_hilight(node=84, fill='rosybrown', extend=-1.5) +geom_hilight(node=89, fill='seagreen1', extend=-1.5) +
  geom_hilight(node=93, fill='coral', extend=-1.5) +geom_hilight(node=98, fill='lightpink', extend=-1.5) +
  geom_hilight(node=102, fill='seagreen1', extend=-1.5) +geom_hilight(node=110, fill='skyblue', extend=-1.5) +
  geom_hilight(node=104, fill='khaki', extend=-1.5) +
  geom_hilight(node=121, fill='lightpink', extend=-1.5) +geom_hilight(node=116, fill='seagreen1', extend=-1.5) +
  geom_hilight(node=127, fill='coral', extend=-1.5) +geom_hilight(node=130, fill='lightpink', extend=-1.5) +
  geom_hilight(node=141, fill='khaki', extend=-1.5) +geom_hilight(node=139, fill='seagreen1', extend=-1.5) +
  geom_hilight(node=149, fill='skyblue', extend=-1.5) +geom_hilight(node=146, fill='khaki', extend=-1.5) +
  geom_hilight(node=85, fill='seagreen1', extend=-.5) +geom_hilight(node=86, fill='khaki', extend=-.5) +
  geom_hilight(node=88, fill='coral', extend=-.5) +geom_hilight(node=99, fill='skyblue', extend=-.5) +
  geom_hilight(node=101, fill='rosybrown', extend=-.5) +geom_hilight(node=112, fill='seagreen1', extend=-.5) +
  geom_hilight(node=150, fill='lightpink', extend=-.5) +geom_hilight(node=129, fill='seagreen1', extend=-.5) +
  theme(legend.position=c(-0.01,0.5), legend.justification="left",legend.box.spacing = unit(-8, "pt"), 
        legend.background = element_rect(fill="lightblue",colour ="darkblue"), 
        legend.text = element_text(size=30),  legend.title = element_text(size=30, face = "bold"), plot.margin=unit(c(1,-1.5,1,1), "pt")) #this is legend for left plot

# Get taxon name and assign to match non-distinct, genus grouped data (gen.host.4).
nam2<-get_taxa_name(p2)
reorder_idx2 <- match(gen.host3f$genus,nam2)
gen.host.6<-gen.host3f %>%
  arrange(reorder_idx2)

# Create heatmap based on frequency in each host species.
g2<-ggplot(gen.host.6, aes(x=Host, y=genus, fill=adj.gen.count))+
  geom_tile() + scale_y_discrete(limits=rev(unique(gen.host.6$genus)), aes(fontface)) + 
  guides(fill=guide_legend(title="Frequency in\nsample"))+theme(legend.position=c(-0.01,0.5), 
                                                                legend.justification="left",legend.box.spacing = unit(-8, "pt"),
                                                                legend.background = element_rect(fill="lightblue",colour ="darkblue"),
                                                                legend.title=element_text(size=30, face = "bold"), legend.text=element_text(size=30),
                                                                axis.title.y = element_blank(), axis.text.y = element_blank(), 
                                                                axis.text.x=element_text(size=25, face = "bold.italic", angle = 90, hjust =1), axis.title.x = element_text(size=32, face="bold"),
                                                                aspect.ratio=6/1)

#Place invisible phylogeny and heatmap side-by-side.
pg<-g2 %>% insert_left(p2, width=5) 
print(pg)+ggtitle("Fungal taxon")+theme(plot.title = element_text(vjust=-532, hjust=-.65, face = "bold", size=40))
# Renders well at 3650 X 2300 
# Rev: 4200 X 2300
# rev:2900 X 2300
# Note: Taxonomic rank columns were added manually and "Fungal Taxon" label.

