def GetTweetHist(Account, path):
##Function to pull as many historical tweets as allowed (currently 3200).  Uses the Max_Id parm in the GetUserTimeline code
    filepath = str(path)+str(Account)+"Tweets.txt"
    
    import twitter
    import pprint as pp
    import time

    CONSUMER_KEY = 'XXXXXXXXXXXXXXXXXXXX'
    CONSUMER_SECRET = 'XXXXXXXXXXXXXXXXXXXX'
    OAUTH_TOKEN = 'XXXXXXXXXXXXXXXXXXXX'
    OAUTH_TOKEN_SECRET = 'XXXXXXXXXXXXXXXXXXXX'
    api = twitter.Api(CONSUMER_KEY,CONSUMER_SECRET,OAUTH_TOKEN,OAUTH_TOKEN_SECRET,  tweet_mode='extended')

    # -*- coding: utf-8 -*-
    alltweets = []

    out  = api.GetUserTimeline(screen_name=Account, count = 200 )
    alltweets.extend(out)
    oldest = alltweets[-1].id - 1
    while len(out) > 0:
        out  = api.GetUserTimeline(screen_name=Account, count = 200, max_id = oldest )
        alltweets.extend(out)
        oldest = alltweets[-1].id - 1

    
    #Parses the long list of tweets that have been made
    tweets = [i.AsDict() for i in alltweets]
    TweetList =[]
    for t in tweets:
        tw_id = str(t['id'])
        strtime = time.strftime('%Y-%m-%d %H:%M:%S', time.strptime(t['created_at'],'%a %b %d %H:%M:%S +0000 %Y'))    
        try: 
            if "retweeted_status" in t:
                line =  t['retweeted_status']['full_text'].strip('\n\r')
                line = line.encode('utf-8')
                line = line.replace("\n"," ")
                line = ''.join([c for c in line if ord(c)<128])
                mention = t['retweeted_status']['user']['screen_name']
                retweet = "Y"
                outdata = (tw_id,strtime,line, mention,retweet)
                outline = '\t'.join(outdata)+'\n'
                TweetList.append(outline)
                

            else:
                line =  t['full_text'].strip('\n\r') 
                line = line.encode('utf-8')
                line = line.replace("\n"," ")
                line = ''.join([c for c in line if ord(c)<128])     
                retweet = "N"
                mentionlist = (t["user_mentions"])
                for team in mentionlist:
                    mention = team["screen_name"]   
                    outdata = (tw_id,strtime,line, mention,retweet)
                    outline = '\t'.join(outdata)+'\n'
                    TweetList.append(outline)
                    
        except:
            KeyError
            line = t['full_text'].strip('\n\r') 
            line = line.encode('utf-8')
            line = line.replace("\n"," ")
            line = ''.join([c for c in line if ord(c)<128])     
            retweet = "N"
            mentionlist = (t["user_mentions"])
            for team in mentionlist:
                mention = team["screen_name"]   
                outdata = (tw_id,strtime,line, mention,retweet)
                outline = '\t'.join(outdata)+'\n'
                TweetList.append(outline)
        
    for outline in TweetList:    
        f=open(filepath, 'a')
        f.write("%s" % outline)
        f.close()
    

def GetTweetRecent (Account,path):
    import pandas as pd
    import twitter
    import time
    import csv
    CONSUMER_KEY = 'XXXXXXXXXXXXXXXXXXXX'
    CONSUMER_SECRET = 'XXXXXXXXXXXXXXXXXXXX'
    OAUTH_TOKEN = 'XXXXXXXXXXXXXXXXXXXX'
    OAUTH_TOKEN_SECRET = 'XXXXXXXXXXXXXXXXXXXX'

    api = twitter.Api(CONSUMER_KEY,CONSUMER_SECRET,OAUTH_TOKEN,OAUTH_TOKEN_SECRET,  tweet_mode='extended')
   
    filepath = str(path)+str(Account)+"Tweets.txt"
    
    tweets_df = pd.read_csv(filepath , sep = '\t', quoting=csv.QUOTE_NONE, names=['tw_id','datetime','tweet_text','mention','retweet'])
    max_tw = tweets_df.loc[:,'tw_id'].max()+1

    #print(max_tw)
    # -*- coding: utf-8 -*-

    #Pull all tweets first
    alltweets = []

    out  = api.GetUserTimeline(screen_name=Account, count = 200, since_id = max_tw  )
    alltweets.extend(out)
    #max_tw = alltweets[0].id + 1
    oldest = alltweets[-1].id-1
    while len(out) > 0:
        out  = api.GetUserTimeline(screen_name=Account, count = 200, since_id = max_tw, max_id = oldest  )
        alltweets.extend(out)
        #max_tw = alltweets[0].id + 1
        oldest = alltweets[-1].id-1

    
    #Parses the long list of tweets that have been made
    tweets = [i.AsDict() for i in alltweets]
    TweetList =[]
    for t in tweets:
        tw_id = str(t['id'])
        strtime = time.strftime('%Y-%m-%d %H:%M:%S', time.strptime(t['created_at'],'%a %b %d %H:%M:%S +0000 %Y'))    
        try: 
            if "retweeted_status" in t:
                line =  t['retweeted_status']['full_text'].strip('\n\r')
                line = line.encode('utf-8')
                line = line.replace("\n"," ")
                line = ''.join([c for c in line if ord(c)<128])
                mention = t['retweeted_status']['user']['screen_name']
                retweet = "Y"
                outdata = (tw_id,strtime,line, mention,retweet)
                outline = '\t'.join(outdata)+'\n'
                TweetList.append(outline)
                

            else:
                line =  t['full_text'].strip('\n\r') 
                line = line.encode('utf-8')
                line = line.replace("\n"," ")
                line = ''.join([c for c in line if ord(c)<128])     
                retweet = "N"
                mentionlist = (t["user_mentions"])
                for team in mentionlist:
                    mention = team["screen_name"]   
                    outdata = (tw_id,strtime,line, mention,retweet)
                    outline = '\t'.join(outdata)+'\n'
                    TweetList.append(outline)
                    
        except:
            KeyError
            line = t['full_text'].strip('\n\r') 
            line = line.encode('utf-8')
            line = line.replace("\n"," ")
            line = ''.join([c for c in line if ord(c)<128])     
            retweet = "N"
            mentionlist = (t["user_mentions"])
            for team in mentionlist:
                mention = team["screen_name"]   
                outdata = (tw_id,strtime,line, mention,retweet)
                outline = '\t'.join(outdata)+'\n'
                TweetList.append(outline)
        
    for outline in TweetList:    
        #print(outline)
        f=open(filepath, 'a')
        f.write("%s" % outline)
        f.close()