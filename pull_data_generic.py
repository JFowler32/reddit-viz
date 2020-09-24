from psaw import PushshiftAPI
import praw
import pandas as pd
import datetime as dt

r = praw.Reddit(client_id='xxxxxxxx', \
			 client_secret='xxxxxxxx', \
			 user_agent='xxxxxxxx', \
			 username='xxxxxxxx', \
			 password='xxxxxxxx')
\
api = PushshiftAPI()
\
start_epoch=int(dt.datetime(START_YEAR,START_MONTH,START_DAY).timestamp())
\
end_epoch=int(dt.datetime(END_YEAR,END_MONTH,END_DAY).timestamp())
\
thread_data = pd.DataFrame(api.search_submissions(after=start_epoch, 
before=end_epoch,
max_results_per_request=1000,
filter=['score','id','comms_num','author','created','body'],
subreddit='SUBREDDIT_NAME'))
\
comment_data = pd.DataFrame(api.search_comments(after=start_epoch, 
before=end_epoch,
max_results_per_request=1000,
filter=['id','author','created','comment'],
subreddit='SUBREDDIT_NAME'))
\
def get_date(created):
	return dt.datetime.fromtimestamp(created)
\
_timestamp = thread_data['created'].apply(get_date)
\
thread_data = thread_data.assign(timestamp = _timestamp)
\
_timestamp = comment_data['created'].apply(get_date)
\
comment_data = comment_data.assign(timestamp = _timestamp)
\
thread_data
\
comment_data
