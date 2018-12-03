library (sqldf)
library (ggplot2)
library (scales)
library (dplyr)
#library (grid)
#library (directlabels)
#library (ggrepel)



#Read in file of scraped tweets 
Account <- 'MLS'
df <- read.csv(sprintf("C:\\Users\\adsmith\\Desktop\\STC_Docs\\MLSTeamsWordCloud\\MLSTweets_TeamByDay.txt",Account), 
               sep="\t", 
               col.names=c("TweetID","DateTime","Handle","Retweet_Flg","TeamHashtag"),  
               colClasses=c("TweetID"="character")
               )

names(df)<-c("TweetID","DateTime","Handle","Retweet_Flg", "TeamHashtag")
teams<-read.csv("C:\\Users\\adsmith\\Desktop\\Teams.csv", sep=",", head=TRUE)

df_teams <- sqldf("SELECT df.*, teams.LongformTeam,teams.ShortformTeam,teams.TwitterHandle, teams.Abbreviation,teams.Handle as MetaHandle
 FROM df LEFT OUTER JOIN teams ON df.teamhashtag = teams.Abbreviation" )

summarizedbyday<- sqldf("SELECT 
                        TweetId
                        ,DateTime
                        ,case when Handle = '' then MetaHandle else Handle end as HandleComb
                        ,Retweet_Flg
                        ,case when (Handle = '' and Retweet_Flg ='N') then 'Y' else 'N'end as Game_Flg
                        ,Handle
                        ,MetaHandle
                        ,TeamHashtag
                        FROM df_teams")

df_final<- sqldf("SELECT TweetId, DateTime, HandleComb as Handle, Max(Retweet_Flg) as Retweet_Flg FROM summarizedbyday GROUP BY 1,2,3")


#Assign Colors by Team for Graphing later
atl_color = "#7F0009"
chi_color = "#CE1432"
clb_color = "#FEF100"
col_color = "#960A2C"
dcu_color = "#DA0000"
fcd_color = "#BF0D3E"
hou_color = "#F68712"
lag_color = "#00245D"
laf_color = "#C39E6D"
mnu_color = "#8DC8E8"
mon_color = "#04549B"
ner_color = "#C63323"
nyrb_color = "#ED1E36"
nyfc_color = "#78A5DB"
orl_color = "#612B9B"
phi_color ="#0E1B2A"
por_color = "#004812"
rsl_color = "#B30838"
sea_color = "#658D1B"
sje_color = "#0D4C92"
skc_color ="#93B1D7"
tfc_color = "#E31937"
van_color ="#00245E"
emls_color = "#808080"

teamcolors<-c("ATLUTD"= atl_color,
              "ChicagoFire"=chi_color,
              "ColoradoRapids"=col_color,
              "ColumbusCrewSC"=clb_color,
              "dcunited"=dcu_color,
              "FCDallas"=fcd_color,
              "HoustonDynamo"=hou_color,
              "LAGalaxy"=lag_color,
              "LAFC"=laf_color,
              "MNUFC"=mnu_color,
              "impactmontreal"=mon_color,
              "NERevolution"=ner_color,
              "NewYorkRedBulls"=nyrb_color,
              "NYCFC"=nyfc_color,
              "OrlandoCitySC"=orl_color,
              "PhilaUnion"=phi_color,
              "TimbersFC"=por_color,
              "RealSaltLake"=rsl_color,
              "SoundersFC"=sea_color,
              "SJEarthquakes"=sje_color,
              "SportingKC"=skc_color,
              "torontofc"=tfc_color,
              "WhitecapsFC"=van_color,
              "eMLS"=emls_color)



dates <- sqldf("Select distinct substr(Datetime, 1,10) as Date from df_final")   #Get unique dates from the dataframe
handles<- sqldf("Select distinct Handle from df_final")    #Get unique handles from the dataframe
retweet<- sqldf("Select distinct Retweet_Flg from df_final")  #Creates a Y/N dataset
Team_Day <- merge(dates,handles, all=TRUE)  #Creates all combos of handle/date, this was needed b/c of issues on days with no tweet activity
Team_Day <- merge(retweet,Team_Day, all=TRUE) #Creates all combos of handle/date with a RT flag of Y/N









#Reduce dataframe to only certain timeframes.  Also forces a row for every team/day combo
Act_Twts_Team_Day <- sqldf("Select td.Date,  td.Handle, td.Retweet_Flg, Count (Distinct df_final.TweetID) as Nbr_Tweets 
                           From Team_Day  td
                           Left Outer Join   df_final 
                           On td.Date = substr(df_final.Datetime,1,10)
                           And td.Handle = df_final.Handle
                           And td.Retweet_Flg = df_final.Retweet_Flg
                           Where Date >= '2018-10-29'
                           And Date <= '2018-11-30'
                           And td.Handle <> 'eMLS'
                           Group By 1,2,3
                           ")
Act_Twts_Team_Day <-Act_Twts_Team_Day[order(Act_Twts_Team_Day$Handle,Act_Twts_Team_Day$Date),]

Act_Twts_Team_Day <- mutate(group_by(Act_Twts_Team_Day,Handle,Retweet_Flg), cNbr_Tweets=cumsum(Nbr_Tweets))


Act_By_Day_Graph_Rt <-sqldf("Select Date,Handle,Handle as Handle2,
                         Sum(Case when Retweet_Flg='Y' Then cNbr_Tweets Else Null End) as Retweet, 
                          Sum(Case When Retweet_Flg='N' Then cNbr_Tweets Else Null End) as Post
                           From Act_Twts_Team_Day 
                            Where Handle <> 'eMLS'
                         Group By 1,2,3")



Graph_Label <-sqldf("Select Handle, LastDay, 'Total=' as Words, TotRT+TotPost as TotalCount From 
                    (Select Handle, Max(Date) as LastDay, Max(Retweet) as TotRT, Max(Post) as TotPost From Act_By_Day_Graph_Rt Group By 1) as temp1")
Graph_Label <-sqldf("Select Handle, LastDay, Words||TotalCount as Verbiage, TotalCount From Graph_Label")




#Generates 23 graphs, one per team
p<-ggplot(data = Act_By_Day_Graph_Rt,  aes(x=Date))+geom_area(aes(y=Retweet+Post,group=Handle)) +geom_area(aes(y=Post, group=Handle, fill=Handle))+scale_fill_manual(values = teamcolors) 
p<-p +geom_text(data=Graph_Label, aes(x=0,y=100, label=Verbiage),colour="black", size=4, inherit.aes=FALSE,parse=FALSE)+ggtitle("MLS Twitter Support by Team - 2018 Regular Season (Team color=tweet, Black=retweet)")
p+facet_wrap(~ Handle)+theme_minimal()+theme(legend.position="none")+theme(axis.text.x = element_blank())

#This code will display date ticks:  + scale_x_discrete("Dates", breaks=c("2018-03-01","2018-06-01","2018-09-01"))+theme(axis.text.x=element_text(angle=90))



#Data to look at only current time frame 
Act_By_Day_MaxDt <-sqldf("Select Date,Handle,Handle as Handle2,Retweet, Post
                            From Act_By_Day_Graph_Rt
                            Where Date = '2018-11-30'
                            And Handle <> 'eMLS'
                            ")
Act_By_Day_MaxDt$Handle <- factor(Act_By_Day_MaxDt$Handle, levels=Act_By_Day_MaxDt$Handle[order(-Act_By_Day_MaxDt$Post, Act_By_Day_MaxDt$Handle)])
ggplot(data = Act_By_Day_MaxDt, aes(x=Handle, y=Post, fill=Handle))+geom_col()+scale_fill_manual("legend", values=teamcolors)+theme(axis.text.x=element_text(angle=90))+ guides(fill=FALSE)+ggtitle("MLS Posts 2018 Playoffs")

Act_By_Day_MaxDt$Handle <- factor(Act_By_Day_MaxDt$Handle, levels=Act_By_Day_MaxDt$Handle[order(-Act_By_Day_MaxDt$Retweet,Act_By_Day_MaxDt$Handle)])
ggplot(data = Act_By_Day_MaxDt, aes(x=Handle, y=Retweet, fill=Handle))+geom_col()+scale_fill_manual("legend", values=teamcolors)+theme(axis.text.x=element_text(angle=90))+ guides(fill=FALSE)+ggtitle("MLS Retweets 2018 Playoffs")

Act_By_Day_MaxDt$Handle <- factor(Act_By_Day_MaxDt$Handle, levels=Act_By_Day_MaxDt$Handle[order(-(Act_By_Day_MaxDt$Retweet+Act_By_Day_MaxDt$Post),Act_By_Day_MaxDt$Handle)])
ggplot(data = Act_By_Day_MaxDt, aes(x=Handle, y=Retweet+Post, fill=Handle))+geom_col()+scale_fill_manual("legend", values=teamcolors)+theme(axis.text.x=element_text(angle=90))+ guides(fill=FALSE)+ggtitle("MLS Total Activity 2018 Playoffs")


#Same graphs as above, but forcing the y axis to be consistent in all 3

Act_By_Day_MaxDt$Handle <- factor(Act_By_Day_MaxDt$Handle, levels=Act_By_Day_MaxDt$Handle[order(-Act_By_Day_MaxDt$Post, Act_By_Day_MaxDt$Handle)])
ggplot(data = Act_By_Day_MaxDt, aes(x=Handle, y=Post, fill=Handle))+geom_col()+scale_fill_manual("legend", values=teamcolors)+theme(axis.text.x=element_text(angle=90))+ guides(fill=FALSE)+ggtitle("MLS Posts 2018 Playoffs")+scale_y_continuous( limits = c(0,300), expand = c(0,0) )

Act_By_Day_MaxDt$Handle <- factor(Act_By_Day_MaxDt$Handle, levels=Act_By_Day_MaxDt$Handle[order(-Act_By_Day_MaxDt$Retweet,Act_By_Day_MaxDt$Handle)])
ggplot(data = Act_By_Day_MaxDt, aes(x=Handle, y=Retweet, fill=Handle))+geom_col()+scale_fill_manual("legend", values=teamcolors)+theme(axis.text.x=element_text(angle=90))+ guides(fill=FALSE)+ggtitle("MLS Retweets 2018 Playoffs")+scale_y_continuous( limits = c(0,300), expand = c(0,0) )

Act_By_Day_MaxDt$Handle <- factor(Act_By_Day_MaxDt$Handle, levels=Act_By_Day_MaxDt$Handle[order(-(Act_By_Day_MaxDt$Retweet+Act_By_Day_MaxDt$Post),Act_By_Day_MaxDt$Handle)])
ggplot(data = Act_By_Day_MaxDt, aes(x=Handle, y=Retweet+Post, fill=Handle))+geom_col()+scale_fill_manual("legend", values=teamcolors)+theme(axis.text.x=element_text(angle=90))+ guides(fill=FALSE)+ggtitle("MLS Total Activity 2018 Playoffs")+scale_y_continuous( limits = c(0,300), expand = c(0,0) )

