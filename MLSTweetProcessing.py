#Processing that takes the MLS file of tweets and breaks out when a particular handle was referenced.
processed_data= []
twitter_handles = [
'@ATLUTD',
'@ChicagoFire',
'@ColoradoRapids',
'@ColumbusCrewSC',
'@dcunited',
'@FCDallas',
'@HoustonDynamo',
'@LAGalaxy',
'@LAFC',
'@MNUFC',
'@impactmontreal',
'@NERevolution',
'@NYCFC',
'@NewYorkRedBulls',
'@OrlandoCitySC',
'@PhilaUnion',
'@TimbersFC',
'@RealSaltLake',
'@SJEarthquakes',
'@SoundersFC',
'@SportingKC',
'@torontofc',
'@WhitecapsFC'
]

TeamHashtags = [
'#ATL',
'#CHI',
'#COL',
'#CLB',
'#DC',
'#DAL',
'#HOU',
'#LA',
'#LAFC',
'#MIN',
'#MTL',
'#NE',
'#NYC',
'#RBNY',
'#ORL',
'#PHI',
'#POR',
'#RSL',
'#SJ',
'#SEA',
'#SKC',
'#TOR',
'#VAN'
'vATL',
'vCHI',
'vCOL',
'vCLB',
'vDC',
'vDAL',
'vHOU',
'vLA',
'vLAFC',
'vMIN',
'vMTL',
'vNE',
'vNYC',
'vRBNY',
'vORL',
'vPHI',
'vPOR',
'vRSL',
'vSJ',
'vSEA',
'vSKC',
'vTOR',
'vVAN'
]
   
eMLS = ['eMLS']

import fileinput
for line in fileinput.input("C:\\Users\\adsmith\\Desktop\\STC_Docs\\MLSTeamsWordCloud\\MLSTweets.txt"):
    line = line.rstrip().split('\t')
    tweet_id = str(line[0])
    datetime = str(line[1])
    text = line[2]
    mention = line[3]
    retweet_flg = line[4]
    for handle in twitter_handles:
        handle=handle.replace("@","")
        if handle == mention:
            teamhashtag = ''
            output_data = (tweet_id, datetime, handle, retweet_flg, teamhashtag)
            output = '\t'.join(output_data)+'\n'
            processed_data.append(output)
    for team in TeamHashtags:
        if team in text:
            teamhashtag = team[1:]
            handle = ''
            output_data = (tweet_id, datetime, handle, retweet_flg, teamhashtag)
            output = '\t'.join(output_data)+'\n'
            processed_data.append(output)
    for entry in eMLS:
        if entry in text:
            teamhashtag = 'eMLS'
            handle = 'eMLS'
            output_data = (tweet_id, datetime, handle, retweet_flg, teamhashtag)
            output = '\t'.join(output_data)+'\n'
            processed_data.append(output)
            
            
for row in processed_data:
    f=open("C:\\Users\\adsmith\\Desktop\\STC_Docs\\MLSTeamsWordCloud\\MLSTweets_TeamByDay.txt", 'a')
    f.write("%s" % row)
    f.close()
