# coding: utf-8
import pandas as pd
df = pd.read_csv('WIKI_PRICES.csv')
df.head()
aapl = df[df['ticker'] == 'AAPL']
aapl.head()
pd.set_option('display.height', 1000)
pd.set_option('display.max_rows', 500)
pd.set_option('display.max_columns', 500)
pd.set_option('display.width', 1000)
aapl.head()
df.describe()
aapl.tail()
pd.set_option('display.expand_frame_repr', False)
aapl.tail()
aapl.info()
aapl[aapl['close'] != aapl['adj_close']]
aapl[aapl['close'] != aapl['adj_close']].head()
get_ipython().run_line_magic('save', 'stock_session')
get_ipython().run_line_magic('save', 'stock_session ~0/')
