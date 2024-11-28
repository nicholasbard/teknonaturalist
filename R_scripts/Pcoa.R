setwd("~/Desktop/Manus.2024.2025/pipeline.revisions/new.pipeline.results.2024.july/csvs.for.osf/")
library(dplyr)
library(reshape2)
library(vegan)
virg1<-read.csv("virgatum.ITS1.labeled.csv")
virg2<-read.csv("virgatum.ITS2.labeled.csv")
altern1<-read.csv("alternifolia.ITS1.labeled.csv")
altern2<-read.csv("alternifolia.ITS2.labeled.csv")
pendula1<-read.csv("pendula.ITS1.labeled.csv")
pendula2<-read.csv("pendula.ITS2.labeled.csv")
ermanii1<-read.csv("ermanii.ITS1.labeled.csv")
ermanii2<-read.csv("ermanii.ITS2.labeled.csv")
plat1<-read.csv("platyphylla.ITS1.labeled.csv")
plat2<-read.csv("platyphylla.ITS2.labeled.csv")

virg<-rbind.data.frame(virg1, virg2)
altern<-rbind.data.frame(altern1,altern2)
pendula<-rbind.data.frame(pendula1,pendula2)
ermanii<-rbind.data.frame(ermanii1,ermanii2)
plat<-rbind.data.frame(plat1,plat2)

virg$epith<-"virgatum"
virg2<-virg[!virg$kingdom=="unidentified",]
virg3<-virg2 %>% 
  group_by(taxon, ID) %>% 
  distinct(taxon, ID, .keep_all = TRUE)

altern$epith<-"alternifoia"
pendula$epith<-"pendula"
ermanii$epith<-"ermanii"
plat$epith<-"platyphylla"

all.sp<-rbind.data.frame(virg, altern, pendula, ermanii, plat)

all.spb<-all.sp[!all.sp$taxon == "",] 
all.spc<-all.spb[all.spb$confidence >= 0.7,]


all.spd<-all.spc %>% 
  group_by(genus, ID) %>% 
  distinct(genus, ID, .keep_all = TRUE)


df2<-cbind.data.frame(all.spd$ID, all.spd$epith, all.spd$genus)
#remove all not identified to genus
df3<-df2[!df2$`all.spd$genus`=="unidentified",]

df_freq<-data.frame(with(df3, table(df3$`all.spd$ID`, df3$`all.spd$genus`)))
df_freq.t <- dcast(df_freq, df_freq[,1] ~ df_freq[,2])
rownames(df_freq.t)<-df_freq.t[,1]
df_freq.t<-df_freq.t[,-1]

#remove hosts with only one fungal taxon
df_freq.t <- df_freq.t[rowSums(df_freq.t) > 1, ]
#calculate dissimilarity
dissim.bray <- vegdist(df_freq.t, method = "bray", binary=TRUE) 



#PCOA Bray/Sorenson
pcoa.bray<-cmdscale(dissim.bray, eig = TRUE)
pcoa.bray$species<-wascores(pcoa.bray$points, df_freq.t, expand = TRUE)
dft.pl <- ordiplot(pcoa.bray, type = "none")
#make hulls for host species
#generate names
spna<-vector()
spna[grep("ERR20", rownames(pcoa.bray$points))]<-"B. pendula"
spna[grep("SRR1030", rownames(pcoa.bray$points))]<-"Buddleja alternifolia"
spna[grep("SRR1161", rownames(pcoa.bray$points))]<-"P.virgatum"
spna[grep("SRR19939", rownames(pcoa.bray$points))]<-"B. platyphylla"
spna[grep("SRR9211", rownames(pcoa.bray$points))]<-"B. ermanii"

#make spider hulls for plot
points(dft.pl, "sites",col="blue", bg="blue", cex=0.8)
ordispider(dft.pl,groups=spna, col=c("red","purple","green","pink","orange"), spiders = "centroid", label=FALSE)


#save this, then save legend separately

#this does not work in the correct order, and colors must be manually adjusted.
plot(NULL ,xaxt='n',yaxt='n',bty='n',ylab='',xlab='', xlim=0:1, ylim=0:1)
legend("bottomleft", inset=c(0.01, 0.02), col =c("red","purple","green","pink","orange"), 
       lty = 1,
       legend = c(expression(italic("Betula ermanii")), expression(italic("Betula pendula")), expression(italic("Betula platyphylla")), expression(italic("Buddleja alternifolia")), expression(italic("Panicum virgatum")) ),
       theme(labels=element))
